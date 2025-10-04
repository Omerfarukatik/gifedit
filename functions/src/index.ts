// .env dosyasını kullanmaya devam ediyoruz.
import "dotenv/config";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// VERİTABANI İÇİN admin VE firestore GEREKLİ.
import * as admin from "firebase-admin";
import { v2 as cloudinary } from "cloudinary";
import Busboy from "busboy";
import * as os from "os";
import * as path from "path";
import * as fs from "fs";

// admin SDK'sını ve Firestore'u başlatıyoruz.
admin.initializeApp();
const db = admin.firestore();

// --- YARDIMCI FONKSİYONLAR (SENİN KODUN, DOKUNULMADI) ---
const uploadToCloudinary = async (filePath: string, folder: string): Promise<string> => {
  // ... Bu fonksiyon senin çalışan kodunla aynı, dokunmadım ...
  try {
    if (!fs.existsSync(filePath)) {
      throw new Error(`Dosya bulunamadı: ${filePath}`);
    }
    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: "auto",
    });
    return result.secure_url;
  } catch (error: any) {
    logger.error("Cloudinary yükleme hatası:", error);
    throw new Error(`Cloudinary hatası: ${error.message || JSON.stringify(error)}`);
  }
};

const callFalAI = async (faceUrl: string, gifUrl: string): Promise<any> => {
  // ... Bu fonksiyon da aynı, .env'den okumaya devam ediyor ...
  const FAL_API_URL = "https://fal.run/easel-ai/easel-gifswap";
  const FAL_API_KEY = process.env.FAL_KEY;

  if (!FAL_API_KEY) {
    throw new Error("FAL_KEY .env dosyasında bulunamadı!");
  }

  const response = await fetch(FAL_API_URL, {
    method: "POST",
    headers: {
      "Authorization": `Key ${FAL_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      face_image: faceUrl,
      gif_image: gifUrl,
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    logger.error("FAL.AI'den başarısız yanıt alındı!", { status: response.status, body: errorBody });
    throw new Error(`FAL.AI hatası: ${response.status} - ${errorBody}`);
  }
  return response.json();
};


// --- ANA CLOUD FUNCTION (SENİN KODUN + VERİTABANI) ---
export const createGif = onRequest(
  // Secret Manager falan yok, her şey eskisi gibi.
  { region: "europe-west1", memory: "1GiB", timeoutSeconds: 300 },
  async (request, response) => {

    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true,
    });

    // CORS ayarların aynı, dokunmadım.
    response.set("Access-Control-Allow-Origin", "*");
    if (request.method === "OPTIONS") {
      response.set("Access-Control-Allow-Methods", "POST");
      response.set("Access-Control-Allow-Headers", "Content-Type");
      response.set("Access-Control-Max-Age", "3600");
      response.status(204).send("");
      return;
    }

    const busboy = Busboy({ headers: request.headers });
    const tmpdir = os.tmpdir();
    const uploads: { [key: string]: string } = {};
    const fields: { [key: string]: string } = {};
    const fileWrites: Promise<void>[] = [];

    // ###############################################################
    // #           YENİ: İsteği yapan kullanıcı ID'sini alıyoruz          #
    // ###############################################################
    // Flutter'dan 'userId' diye bir alan göndermeni bekleyeceğiz.
    let userId: string | null = null;
    // ###############################################################

    busboy.on("file", (fieldname, file, info) => {
        const filepath = path.join(tmpdir, `${fieldname}-${Date.now()}-${info.filename}`);
        uploads[fieldname] = filepath;
        const writeStream = fs.createWriteStream(filepath);
        file.pipe(writeStream);
        const promise = new Promise<void>((resolve, reject) => {
            file.on("end", () => { writeStream.end(); });
            writeStream.on("finish", () => { resolve(); });
            writeStream.on("error", reject);
        });
        fileWrites.push(promise);
    });

    busboy.on("field", (fieldname, val) => {
        fields[fieldname] = val;
        // Gelen alan 'userId' ise, onu değişkene ata.
        if (fieldname === 'userId') {
            userId = val;
        }
    });

    busboy.on("finish", async () => {
      await Promise.all(fileWrites);
      try {
        // ###############################################################
        // #           YENİ: userId var mı diye kontrol ediyoruz             #
        // ###############################################################
        if (!userId) {
            throw new Error("İstek içinde 'userId' alanı bulunamadı. Veritabanı kaydı için bu zorunludur.");
        }
        logger.info(`İşlem yapılan kullanıcı: ${userId}`);
        // ###############################################################

        // --- Burası senin çalışan kodun, dokunulmadı ---
        const faceImageUrl = await uploadToCloudinary(uploads.face_image, "memecreat/faces");
        let gifImageUrl: string;

        if (uploads.user_gif) {
          gifImageUrl = await uploadToCloudinary(uploads.user_gif, "memecreat/gifs");
        } else if (fields.gif_template) {
           const templateDoc = await db.collection('templates').doc(fields.gif_template).get();
           if (templateDoc.exists) {
               gifImageUrl = templateDoc.data()?.sourceUrl;
               if (!gifImageUrl) throw new Error(`Template (${fields.gif_template}) 'sourceUrl' alanına sahip değil.`);
           } else {
               throw new Error(`Template bulunamadı: ${fields.gif_template}`);
           }
        } else {
          throw new Error("GIF dosyası veya şablonu belirtilmedi.");
        }

        const falResult = await callFalAI(faceImageUrl, gifImageUrl);
        const temporaryFalUrl = falResult.image.url as string;
         logger.info(`fal.ai'den geçici URL alındı: ${temporaryFalUrl}`);
         logger.info("Bu geçici URL, şimdi kalıcı hale getirilmek üzere Cloudinary'ye YENİDEN yüklenecek...");
               // ADIM 4 & 5: Geçici fal.ai URL'sindeki resmi bizim Cloudinary'ye yükle
         const finalCloudinaryResult = await cloudinary.uploader.upload(temporaryFalUrl, {
               folder: "memecreat/results", // Sonuçları ayrı bir klasörde tutalım
               resource_type: "auto",
         });

                        // İŞTE BU! VERİTABANINA KAYDEDECEĞİMİZ ASIL URL!
         const rawPermanentUrl = finalCloudinaryResult.secure_url;
         logger.info(`KALICI URL oluşturuldu: ${rawPermanentUrl}`);
        const finalPermanentUrl = rawPermanentUrl.replace(
          "/image/upload/",
          "/image/upload/q_auto,f_auto/"
        );
        logger.info("Firestore'a kayıt işlemi başlıyor...");
        const userRef = db.collection('users').doc(userId);
        const userDoc = await userRef.get(); // transaction dışında okuma

        if (!userDoc.exists) throw new Error(`Kullanıcı bulunamadı: ${userId}`);

        const newGifRef = db.collection('gifs').doc();
        const newGifId = newGifRef.id;

        // Yazma işlemlerini bir batch'te topla
        const batch = db.batch();

        // A) Ana 'gifs' koleksiyonuna kaydet
        batch.set(newGifRef, {
            id: newGifId,
            gifUrl: finalPermanentUrl,
            creatorId: userId,
            creatorUsername: userDoc.data()?.username || 'bilinmiyor',
            creatorProfileUrl: userDoc.data()?.avatarUrl || '',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            saves: 0,
            likes: 0,
        });

        // B) Kullanıcının 'createdGifs' alt koleksiyonuna kaydet
        const userCreatedGifRef = userRef.collection('createdGifs').doc(newGifId);

        // Ana koleksiyona ne yazıyorsak, buraya da aynısını yazalım.
        // Bu, uygulamadaki tutarlılığı sağlar ve hataları önler.
        batch.set(userCreatedGifRef, {
            id: newGifId, // <<< DOKÜMAN ID'SİNİ DE VERİNİN İÇİNE EKLİYORUZ
            gifUrl: finalPermanentUrl,
            creatorId: userId,
            creatorUsername: userDoc.data()?.username || 'bilinmiyor', // <<< EKLENDİ
            creatorProfileUrl: userDoc.data()?.avatarUrl || '',      // <<< EKLENDİ
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            saves: 0, // Bu bilgileri de eklemek tutarlılık için iyidir.
            likes: 0, // Bu bilgileri de eklemek tutarlılık için iyidir.
        });

        // C) Kullanıcının stats'ını güncelle
        batch.update(userRef, {
            'stats.creationsCount': admin.firestore.FieldValue.increment(1)
        });

        await batch.commit(); // Tüm işlemleri tek seferde yap
        logger.info("Firestore'a kayıt başarıyla tamamlandı.");
        // ###############################################################

        // --- Sonuç gönderme, senin kodunla aynı, dokunulmadı ---
        response.status(200).send({
          success: true,
          result_gif_url: finalPermanentUrl,
        });

      } catch (error) {
        // --- Hata yönetimi, senin kodunla aynı, dokunulmadı ---
        const errorMessage = error instanceof Error ? error.message : "Bilinmeyen sunucu hatası.";
        logger.error("Fonksiyonun TRY bloğunda hata oluştu:", { error: errorMessage });
        response.status(500).send({ success: false, error: errorMessage });
      } finally {
        // --- Dosya temizleme, senin kodunla aynı, dokunulmadı ---
        for (const file in uploads) {
          if (fs.existsSync(uploads[file])) {
            fs.unlinkSync(uploads[file]);
          }
        }
      }
    });
    busboy.end(request.rawBody);
  }
);

// index.ts dosyasının içindeki mevcut toggleLike fonksiyonunu sil ve bunu yapıştır.
export const toggleLike = onRequest(
  { region: "europe-west1" },
  async (request, response) => {
    // CORS ayarları aynı
    response.set("Access-Control-Allow-Origin", "*");
    if (request.method === "OPTIONS") {
      response.set("Access-Control-Allow-Methods", "POST");
      response.set("Access-Control-Allow-Headers", "Content-Type");
      response.set("Access-Control-Max-Age", "3600");
      response.status(204).send("");
      return;
    }

    // ARTIK JSON BODY DEĞİL, FORM-DATA BEKLİYORUZ
    const busboy = Busboy({ headers: request.headers });
    const fields: { [key: string]: string } = {};

    busboy.on("field", (fieldname, val) => {
      fields[fieldname] = val;
    });

    busboy.on("finish", async () => {
      try {
        const { userId, gifId } = fields;

        if (!userId || !gifId) {
          logger.error("Eksik form alanları:", { userId, gifId });
          response.status(400).send({
            success: false,
            error: "İstek içinde 'userId' ve 'gifId' alanları zorunludur.",
          });
          return;
        }

        logger.info(`toggleLike işlemi: Kullanıcı=${userId}, GIF=${gifId}`);

        const gifRef = db.collection("gifs").doc(gifId);
        const userLikeRef = db.collection("users").doc(userId).collection("likedGifs").doc(gifId);

        await db.runTransaction(async (transaction) => {
          const userLikeDoc = await transaction.get(userLikeRef);
          const gifDoc = await transaction.get(gifRef);

          if (!gifDoc.exists) {
            throw new Error(`Beğenilmeye çalışılan GIF bulunamadı: ${gifId}`);
          }

          const gifData = gifDoc.data();
          if (!gifData) {
            throw new Error(`GIF verisi okunamadı: ${gifId}`);
          }

          const currentLikeCount = gifData.likes || 0;

          if (userLikeDoc.exists) {
            // Beğeniyi Geri Al
            transaction.delete(userLikeRef);
            transaction.update(gifRef, { likes: currentLikeCount > 0 ? currentLikeCount - 1 : 0 });
            logger.info(`Kullanıcı ${userId}, ${gifId} beğenisini geri aldı.`);
          } else {
            // Beğen
            transaction.set(userLikeRef, {
              ...gifData,
              id: gifId,
              likedAt: new Date(),
            });
            transaction.update(gifRef, { likes: currentLikeCount + 1 });
            logger.info(`Kullanıcı ${userId}, ${gifId} GIF'ini beğendi.`);
          }
        });

        response.status(200).send({
          success: true,
          message: "Beğeni durumu başarıyla güncellendi.",
        });

      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : "Bilinmeyen sunucu hatası.";
        logger.error("toggleLike busboy.on('finish') hatası:", { error: errorMessage });
        response.status(500).send({ success: false, error: `Beğeni işlemi sırasında bir hata oluştu: ${errorMessage}` });
      }
    });

    busboy.end(request.rawBody);
  }
);
export * from "./sync"; // sync.ts dosyasındaki tüm export'ları dışarıya aç.

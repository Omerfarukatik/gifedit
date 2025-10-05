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
// SENİN MEVCUT export const createGif ... BLOĞUNU SİL VE YERİNE BUNU YAPIŞTIR.

export const createGif = onRequest(
  // Ayarların aynı, dokunulmadı.
  { region: "europe-west1", memory: "1GiB", timeoutSeconds: 300 },
  async (request, response) => {
    // Cloudinary config ve CORS ayarların aynı.
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true,
    });
    response.set("Access-Control-Allow-Origin", "*");
    if (request.method === "OPTIONS") {
      response.set("Access-Control-Allow-Methods", "POST");
      response.set("Access-Control-Allow-Headers", "Content-Type");
      response.set("Access-Control-Max-Age", "3600");
      response.status(204).send("");
      return;
    }

    // Busboy kullanımın aynı.
    const busboy = Busboy({ headers: request.headers });
    const tmpdir = os.tmpdir();
    const uploads: { [key: string]: string } = {};
    const fields: { [key: string]: string } = {};
    const fileWrites: Promise<void>[] = [];

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
    });

    busboy.on("finish", async () => {
      await Promise.all(fileWrites);
      try {
        const { userId, caption } = fields; // Caption'ı da alıyoruz
        if (!userId) {
            throw new Error("İstek içinde 'userId' alanı bulunamadı.");
        }
        if (!uploads.face_image) {
          throw new Error("Yüz resmi ('face_image') bulunamadı.");
        }
        logger.info(`İşlem yapılan kullanıcı: ${userId}`);

        // --- Yüz resmini en başta bir kere yükleyelim ---
        const faceImageUrl = await uploadToCloudinary(uploads.face_image, "memecreat/faces");

        // ===========================================================================
        // =              İŞTE İSTEDİĞİN DEĞİŞİKLİK BURADA BAŞLIYOR                  =
        // ===========================================================================
        let sourceGifUrl: string; // Bu, fal.ai'ye gönderilecek olan orijinal şablon URL'si olacak

      if (uploads.user_gif) {
        // Senaryo 1: Kullanıcı kendi GIF'ini yüklüyor.
        logger.info(`Senaryo 1: Kullanıcı ${userId} kendi GIF'ini yüklüyor.`);
        sourceGifUrl = await uploadToCloudinary(uploads.user_gif, "memecreat/gifs");

      }else if (fields.gif_template) {
         // Eğer gelen veri URL ise direkt kullan, ID ise Firestore'dan çek
         const templateValue = fields.gif_template.trim();

         if (templateValue.startsWith('http://') || templateValue.startsWith('https://')) {
           // URL gelmiş, direkt kullan
           logger.info(`Template URL kullanılıyor: ${templateValue}`);
           sourceGifUrl = templateValue;
         } else {
           // ID gelmiş, Firestore'dan çek
           const cleanTemplateId = templateValue.replace(/^\//, '');
           logger.info(`Template ID kullanılıyor: ${cleanTemplateId}`);
           const templateDoc = await db.collection('templates').doc(cleanTemplateId).get();
           if (templateDoc.exists && templateDoc.data()?.sourceUrl) {
             sourceGifUrl = templateDoc.data()?.sourceUrl;
           } else {
             throw new Error(`Template bulunamadı: ${cleanTemplateId}`);
           }
         }

      } else if (fields.gif_template_url) {
        // Senaryo 3: Kullanıcı mevcut bir GIF'i yeniden kullanıyor (Remix).
        logger.info(`Senaryo 3: Kullanıcı ${userId} bir URL'yi remixliyor: ${fields.gif_template_url}`);
        sourceGifUrl = fields.gif_template_url;

      } else {
        // Hiçbir kaynak belirtilmemişse hata ver.
        throw new Error("GIF kaynağı belirtilmedi (user_gif, gif_template veya gif_template_url).");
      }
        // ===========================================================================
        // =                  DEĞİŞİKLİK BURADA BİTİYOR                              =
        // ===========================================================================

        // Artık 'gifImageUrl' yerine hep 'sourceGifUrl' kullanıyoruz.
        const falResult = await callFalAI(faceImageUrl, sourceGifUrl);
        const temporaryFalUrl = falResult.image.url as string;
        logger.info(`fal.ai'den geçici URL alındı: ${temporaryFalUrl}`);

        // Sonucu Cloudinary'ye yükleme ve optimize etme (q_auto,f_auto)
        const finalCloudinaryResult = await cloudinary.uploader.upload(temporaryFalUrl, {
               folder: "memecreat/results",
               resource_type: "auto",
               format: 'gif', // .gif uzantısını garantilemek için
         });
         const rawPermanentUrl = finalCloudinaryResult.secure_url;
         const finalOptimizedUrl = rawPermanentUrl.replace("/image/upload/", "/image/upload/q_auto,f_auto/"); // Optimizasyon
         logger.info(`KALICI VE OPTİMİZE URL oluşturuldu: ${finalOptimizedUrl}`);

        logger.info("Firestore'a kayıt işlemi başlıyor...");
        const userRef = db.collection('users').doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) throw new Error(`Kullanıcı bulunamadı: ${userId}`);

        const newGifRef = db.collection('gifs').doc();
        const newGifId = newGifRef.id;
        const batch = db.batch();

        // Veritabanına kaydedilecek olan ortak veri objesi
        const newGifData = {
            id: newGifId,
            gifUrl: finalOptimizedUrl, // Sonuç (remixlenmiş) GIF
            templateImageUrl: sourceGifUrl, // <<<<<<<< İŞTE BU! HANGİ ŞABLONDAN YAPILDIĞI
            creatorId: userId,
            creatorUsername: userDoc.data()?.username || 'bilinmiyor',
            creatorProfileUrl: userDoc.data()?.avatarUrl || '', // SENİN KODUNDA "avatarUrl"
            caption: caption || '', // Flutter'dan gelen caption
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            saves: 0,
            likes: 0,
        };

        // A) Ana 'gifs' koleksiyonuna kaydet
        batch.set(newGifRef, newGifData);

        // B) Kullanıcının 'createdGifs' alt koleksiyonuna kaydet (SENİN MİMARİN)
        const userCreatedGifRef = userRef.collection('createdGifs').doc(newGifId);
        batch.set(userCreatedGifRef, newGifData);

        // C) Kullanıcının stats'ını güncelle (SENİN MİMARİN)
        batch.update(userRef, {
            'stats.creationsCount': admin.firestore.FieldValue.increment(1)
        });

        await batch.commit();
        logger.info(`Firestore'a kayıt başarıyla tamamlandı. Yeni GIF ID: ${newGifId}`);

        response.status(200).send({
          success: true,
          result_gif_url: finalOptimizedUrl,
        });

      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : "Bilinmeyen sunucu hatası.";
        logger.error("Fonksiyonda kritik hata:", { error: errorMessage, stack: (error as Error).stack });
        response.status(500).send({ success: false, error: errorMessage });
      } finally {
        for (const file in uploads) {
          try {
            if (fs.existsSync(uploads[file])) {
              fs.unlinkSync(uploads[file]);
            }
          } catch(e) { logger.warn(`Geçici dosya silinemedi: ${uploads[file]}`)}
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
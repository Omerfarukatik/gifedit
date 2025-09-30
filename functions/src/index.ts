import "dotenv/config";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { v2 as cloudinary } from "cloudinary";
import Busboy from "busboy";
import * as os from "os";
import * as path from "path";
import * as fs from "fs";

admin.initializeApp();

// --- YARDIMCI FONKSİYONLAR ---
const uploadToCloudinary = async (filePath: string, folder: string): Promise<string> => {
  try {
    logger.info(`Cloudinary'ye yükleniyor: ${filePath} -> ${folder}`);

    // Dosyanın var olup olmadığını kontrol et
    if (!fs.existsSync(filePath)) {
      throw new Error(`Dosya bulunamadı: ${filePath}`);
    }

    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: "auto",
    });
    logger.info(`Cloudinary yükleme başarılı: ${result.secure_url}`);
    return result.secure_url;
  } catch (error: any) {
    logger.error("Cloudinary yükleme hatası - TAM DETAY:", {
      message: error.message,
      error: error.error,
      statusCode: error.http_code,
      fullError: JSON.stringify(error, null, 2)
    });
    throw new Error(`Cloudinary hatası: ${error.message || JSON.stringify(error)}`);
  }
};

// --- YENİ YARDIMCI: FAL.AI'Yİ ELLE ÇAĞIRMA ---
const callFalAI = async (faceUrl: string, gifUrl: string): Promise<any> => {
  const FAL_API_URL = "https://fal.run/easel-ai/easel-gifswap";
  const FAL_API_KEY = process.env.FAL_KEY;

  if (!FAL_API_KEY) {
    throw new Error("FAL_KEY .env dosyasında bulunamadı!");
  }

  logger.info("FAL.AI'ye fetch ile istek gönderiliyor...");
  logger.info("Face URL:", faceUrl);
  logger.info("GIF URL:", gifUrl);

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
    logger.error("FAL.AI'den başarısız yanıt alındı!", {
        status: response.status,
        statusText: response.statusText,
        body: errorBody
    });
    throw new Error(`FAL.AI hatası: ${response.status} ${response.statusText}`);
  }

  return response.json();
};


// --- ANA CLOUD FUNCTION (V2 SÖZDİZİMİ) ---
export const createGif = onRequest(
  { region: "europe-west1", memory: "1GiB", timeoutSeconds: 300 },
  async (request, response) => {

    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true,
    });

    logger.info("Cloudinary config yapıldı:", {
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key_exists: !!process.env.CLOUDINARY_API_KEY,
      api_secret_exists: !!process.env.CLOUDINARY_API_SECRET,
    });

    // CORS ve diğer kontroller
    response.set("Access-Control-Allow-Origin", "*");
    if (request.method === "OPTIONS") {
      response.set("Access-Control-Allow-Methods", "POST");
      response.set("Access-Control-Allow-Headers", "Content-Type");
      response.set("Access-Control-Max-Age", "3600");
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }


    const busboy = Busboy({ headers: request.headers });
    const tmpdir = os.tmpdir();
    const uploads: { [key: string]: string } = {};
    const fields: { [key: string]: string } = {};
    const fileWrites: Promise<unknown>[] = [];

    busboy.on("file", (fieldname, file, info) => {
      logger.info(`Processing file: ${info.filename} (${fieldname})`);
      const filepath = path.join(tmpdir, info.filename);
      uploads[fieldname] = filepath;
      const writeStream = fs.createWriteStream(filepath);
      file.pipe(writeStream);
      const promise = new Promise((resolve, reject) => {
        file.on("end", () => { writeStream.end(); });
        writeStream.on("finish", () => resolve(true));
        writeStream.on("error", reject);
      });
      fileWrites.push(promise);
    });

    busboy.on("field", (fieldname, val) => {
      logger.info(`Processing field ${fieldname}: ${val}`);
      fields[fieldname] = val;
    });

    busboy.on("finish", async () => {
      await Promise.all(fileWrites);
      try {
        logger.info("Dosya yüklemeleri tamamlandı, Cloudinary'ye yükleme başlıyor...");

        const faceImageUrl = await uploadToCloudinary(uploads.face_image, "memecreat/faces");
        logger.info(`Face image yüklendi: ${faceImageUrl}`);

        let gifImageUrl: string;
        if (uploads.user_gif) {
          gifImageUrl = await uploadToCloudinary(uploads.user_gif, "memecreat/gifs");
          logger.info(`User GIF yüklendi: ${gifImageUrl}`);
        } else {
          gifImageUrl = "https://res.cloudinary.com/demo/image/upload/dog.gif";
          logger.info("Kullanıcı GIF'i yok, varsayılan kullanılıyor");
        }

        logger.info("FAL.AI çağrısı yapılıyor...");
        const result = await callFalAI(faceImageUrl, gifImageUrl);

        const resultGifUrl = result.image.url;
        logger.info("fal.ai sonucu alındı:", resultGifUrl);
        response.status(200).send({
          success: true,
          result_gif_url: resultGifUrl,
        });

      } catch (error) {
        logger.error("Fonksiyonun TRY bloğunda hata oluştu:", error);
        if (error instanceof Error) {
            logger.error("Hata Mesajı:", error.message);
            logger.error("Hata Stack Trace:", error.stack);
        }
        response.status(500).send({ success: false, error: "Sunucu hatası. Detaylar loglarda." });
      } finally {
        for (const file in uploads) {
          fs.unlinkSync(uploads[file]);
        }
      }
    });
    busboy.end(request.rawBody);
  }
);
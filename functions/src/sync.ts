// functions/src/sync.ts (NİHAİ, DÜZELTİLMİŞ, TAM VERSİYON)

import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Firestore veritabanını burada da kullanmamız gerekiyor.
const db = admin.firestore();

// =========================================================================================
// ==================         SENKRONİZASYON FONKSİYONU         ==================
// =========================================================================================

export const updateUserPostsOnProfileUpdate = onDocumentUpdated(
  // 1. DİNLEME HEDEFİ: 'users' koleksiyonundaki herhangi bir dökümanı dinle.
  { document: "users/{userId}", region: "europe-west1" },
  async (event) => {
    // 2. VERİLERİ AL
    const newData = event.data?.after.data();
    const previousData = event.data?.before.data();
    const userId = event.params.userId;

    if (!newData || !previousData) {
      logger.info(`Kullanıcı ${userId} için veri okunamadı, senkronizasyon durduruldu.`);
      return;
    }

    // 3. KONTROL: Gerçekten ilgili bir değişiklik var mı?
    const usernameChanged = newData.username !== previousData.username;
    // DİKKAT: Senin `index.ts` kodunda 'avatar_url' kullanılıyor.
    const avatarChanged = newData.avatar_url !== previousData.avatar_url;

    if (!usernameChanged && !avatarChanged) {
      logger.info(`Kullanıcı ${userId} için ilgili alanlar (username, avatar_url) değişmedi.`);
      return;
    }

    logger.info(`Kullanıcı ${userId} profilini güncelledi. Senkronizasyon başlıyor...`);

    // 4. TOPLU GÜNCELLEME HAZIRLIĞI
    const batch = db.batch();

    // 5. GÜNCELLENECEK DOKÜMANLARI BUL
    // Ana 'gifs' koleksiyonu
    const gifsToUpdateQuery = db.collection("gifs").where("creatorId", "==", userId);


    // Güncellenecek yeni veriyi hazırla
    const updateData: { creatorUsername?: string, creatorProfileUrl?: string } = {};
    if (usernameChanged) {
      // DİKKAT: GIF dökümanlarındaki alan adı 'creatorUsername'
      updateData.creatorUsername = newData.username;
    }
    if (avatarChanged) {
      // DİKKAT: GIF dökümanlarındaki alan adı 'creatorProfileUrl'
      updateData.creatorProfileUrl = newData.avatar_url;
    }

    // -- HATA DÜZELTİLDİ: try...catch bloğu doğru yapıya kavuşturuldu --
    try {
      // Ana 'gifs' koleksiyonunu güncellemek için sorguyu çalıştır
      const gifsSnapshot = await gifsToUpdateQuery.get();
      gifsSnapshot.forEach((doc) => {
        batch.update(doc.ref, updateData);
      });

      // Eğer güncellenecek bir şey bulunduysa, toplu güncellemeyi gönder.
      if (gifsSnapshot.size > 0) {
        // 6. PAKETİ GÖNDER
        await batch.commit();
        // Günlük mesajını da temizliyoruz.
        logger.info(`Başarılı: Kullanıcı ${userId} için ${gifsSnapshot.size} adet gönderi güncellendi.`);
      } else {
        logger.info(`Kullanıcı ${userId} için güncellenecek gönderi bulunamadı.`);
      }
    } catch (error) { // 'catch' bloğu artık if/else'in dışında, doğru yerde.
      logger.error(`Kullanıcı ${userId} için gönderileri güncellerken hata oluştu:`, error);
    }
  }
);

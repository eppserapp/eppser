/* eslint-disable linebreak-style */
/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.checkPhoneNumber = functions.https.onRequest(async (req, res) => {
  // eslint-disable-next-line max-len
  const phoneNumber = req.query.phoneNumber; // İstek parametresinden telefon numarasını alın
  const decodedPhoneNumber = decodeURIComponent(phoneNumber);

  // eslint-disable-next-line max-len
  // Firestore'da "users" koleksiyonunu sorgulayarak telefon numarasını kontrol edin
  const usersRef = admin.firestore().collection("Phones");
  // eslint-disable-next-line max-len
  const querySnapshot = await usersRef.where("phone", "==", decodedPhoneNumber).get();

  if (!querySnapshot.empty) {
    // eslint-disable-next-line max-len
    res.status(200).send(decodedPhoneNumber); // Telefon numarası Firestore'da bulundu
  } else {
    // eslint-disable-next-line max-len
    res.status(404).send(decodedPhoneNumber); // Telefon numarası Firestore'da bulunamadı
  }
});

exports.checkUsernameAvailability = functions.https.onRequest(async (req, res) => {
  // Belirli bir domain için CORS ayarlarını ekleyin
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  // OPTIONS preflight isteğini yönetmek için kontrol
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  const username = req.query.username;

  if (!username) {
    return res.status(400).json({message: "Kullanıcı adı sağlanmadı."});
  }

  try {
    const userSnapshot = await db.collection("Users")
        .where("username", "==", username)
        .get();

    if (userSnapshot.empty) {
      return res.status(200).json({available: true, message: "Kullanıcı adı kullanılabilir."});
    } else {
      return res.status(200).json({available: false, message: "Kullanıcı adı zaten kullanılıyor."});
    }
  } catch (error) {
    console.error("Hata:", error);
    return res.status(500).json({message: "Kullanıcı adı kontrol edilirken bir hata oluştu."});
  }
});


exports.createUserAccount = functions.firestore
    .document("Users/{userId}")
    .onCreate(async (snap, context) => {
      const userId = context.params.userId;

      try {
        await db.collection("Users").doc(userId).collection("Account").doc("wallet").set({
          tl: 0,
          gold: 0,
          token: 0,
        });

        console.log(`Account koleksiyonu ${userId} için başarıyla oluşturuldu.`);
      } catch (error) {
        console.error("Account koleksiyonu oluşturulurken bir hata oluştu:", error);
      }
    });

exports.sendFunds = functions.https.onCall(async (data, context) => {
  const senderId = data.senderId;
  const receiverUsername = data.receiverUsername;
  const amount = data.amount;
  const currency = data.currency; // "tl" veya "gold" olabilir

  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "İşlemi gerçekleştirmek için giriş yapmalısınız.");
  }

  if (context.auth.uid !== senderId) {
    throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  if (!senderId || !receiverUsername || !amount || !currency) {
    throw new functions.https.HttpsError("invalid-argument", "Gerekli parametrelerden biri eksik.");
  }

  try {
    const liquidityDoc = await admin.firestore()
        .collection("Liquidity")
        .doc(currency === "gold" ? "Gold" : "TL")
        .get();

    const commissionRate = liquidityDoc.data().commission || 0.0030;
    const commissionAmount = amount * commissionRate;
    const netAmount = amount; // Gönderilen miktar direkt olarak alıcıya geçecek

    const receiverQuerySnapshot = await admin.firestore().collection("Users").where("username", "==", receiverUsername).limit(1).get();

    if (receiverQuerySnapshot.empty) {
      throw new functions.https.HttpsError("not-found", "Alıcı kullanıcı adı bulunamadı.");
    }

    const receiverId = receiverQuerySnapshot.docs[0].id;

    const senderWalletRef = admin.firestore().collection("Users").doc(senderId).collection("Account").doc("wallet");
    const receiverWalletRef = admin.firestore().collection("Users").doc(receiverId).collection("Account").doc("wallet");
    const profitRef = admin.firestore().collection("Profit").doc("Profit");
    const liquidityRef = admin.firestore().collection("Liquidity").doc(currency === "gold" ? "Gold" : "TL");

    await admin.firestore().runTransaction(async (transaction) => {
      const senderWalletDoc = await transaction.get(senderWalletRef);
      const receiverWalletDoc = await transaction.get(receiverWalletRef);
      const profitDoc = await transaction.get(profitRef);
      const liquidityDoc = await transaction.get(liquidityRef);

      if (!senderWalletDoc.exists || !receiverWalletDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Gönderici veya alıcı cüzdanı bulunamadı.");
      }

      const senderBalance = senderWalletDoc.data()[currency];
      const receiverBalance = receiverWalletDoc.data()[currency];
      const currentProfit = profitDoc.exists ? profitDoc.data().profit : 0;
      const currentLiquidity = liquidityDoc.exists ? liquidityDoc.data().liquidity : 0;

      // Göndericinin bakiyesinin hem miktar hem de komisyon için yeterli olup olmadığını kontrol et
      if (senderBalance < (amount + commissionAmount)) {
        throw new functions.https.HttpsError("failed-precondition", "Gönderici bakiyesi yetersiz.");
      }

      const newSenderBalance = senderBalance - amount - commissionAmount;
      const newReceiverBalance = receiverBalance + netAmount;

      if (currency === "gold") {
        const newLiquidity = currentLiquidity + commissionAmount;
        transaction.update(liquidityRef, {liquidity: newLiquidity});
      } else {
        const newProfit = currentProfit + commissionAmount;
        transaction.update(profitRef, {profit: newProfit});
      }

      transaction.update(senderWalletRef, {[currency]: newSenderBalance});
      transaction.update(receiverWalletRef, {[currency]: newReceiverBalance});
    });

    const db = admin.firestore();

    await db.collection("Users").doc(senderId).collection("TransactionHistory").add({
      userId: senderId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      type: "transfer",
      description: `${amount} ${currency} gönderildi. Komisyon: ${commissionAmount}.`,
      amount: -amount,
      commission: -commissionAmount,
      isGold: currency == "gold" ? true : false,
    });

    await db.collection("Users").doc(receiverId).collection("TransactionHistory").add({
      userId: senderId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      type: "transfer",
      description: `${netAmount} ${currency} alındı.`,
      amount: netAmount,
      isGold: currency == "gold" ? true : false,
    });

    return {success: true, message: "Transfer başarılı ve kaydedildi."};
  } catch (error) {
    console.error("Transfer hatası:", error);
    throw new functions.https.HttpsError("internal", "Transfer sırasında bir hata oluştu.");
  }
});


exports.buyGold = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const goldAmount = data.amount; // Almak istediği altın miktarı

  // Kullanıcı kimlik doğrulamasını yap
  if (!context.auth || context.auth.uid !== userId) {
    throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  if (!goldAmount || goldAmount <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Geçerli bir miktar girin.");
  }

  try {
    const liquidityRefGold = admin.firestore().collection("Liquidity").doc("Gold");
    const liquidityRefTL = admin.firestore().collection("Liquidity").doc("TL");
    const userWalletRef = admin.firestore().collection("Users").doc(userId).collection("Account").doc("wallet");
    const profitRef = admin.firestore().collection("Profit").doc("Profit"); // Profit koleksiyonu

    // Tüm okuma işlemlerini gruplandır
    const [liquidityDocGold, liquidityDocTL, priceDoc, userWalletDoc, profitDoc] = await Promise.all([
      liquidityRefGold.get(),
      liquidityRefTL.get(),
      admin.firestore().collection("Price").doc("Price").get(),
      userWalletRef.get(),
      profitRef.get(),
    ]);

    // Likidite bilgisini kontrol et
    if (!liquidityDocGold.exists) {
      throw new functions.https.HttpsError("not-found", "Altın likidite bilgisi bulunamadı.");
    }
    const currentLiquidity = liquidityDocGold.data().liquidity;

    // TL likidite bilgisini kontrol et
    if (!liquidityDocTL.exists) {
      throw new functions.https.HttpsError("not-found", "TL likidite bilgisi bulunamadı.");
    }

    // Altın fiyatını kontrol et
    if (!priceDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Altın fiyat bilgisi bulunamadı.");
    }
    const goldPrice = priceDoc.data().gold;

    // Kullanıcının cüzdan bilgilerini kontrol et
    if (!userWalletDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Kullanıcı cüzdanı bulunamadı.");
    }
    const currentUserGold = userWalletDoc.data().gold || 0;
    const currentUserTl = userWalletDoc.data().tl || 0;

    // Komisyon oranını al
    const commissionRate = liquidityDocGold.data().commission || 0.0030; // Varsayılan komisyon %0.30

    // Toplam maliyeti hesapla ve kullanıcı TL bakiyesinin yeterli olup olmadığını kontrol et
    const totalCost = goldAmount * goldPrice;
    const commission = totalCost * commissionRate; // Komisyonu hesapla
    const totalDeduction = totalCost + commission; // Toplam düşüş
    if (currentUserTl < totalDeduction) {
      throw new functions.https.HttpsError("failed-precondition", "Yetersiz TL bakiyesi.");
    }

    // Likiditenin yeterli olup olmadığını kontrol et
    if (currentLiquidity < goldAmount) {
      throw new functions.https.HttpsError("failed-precondition", "Yeterli likidite bulunmamaktadır.");
    }

    // Yazma işlemleri
    await admin.firestore().runTransaction(async (transaction) => {
      // Yeni bakiyeleri hesapla
      const newLiquidity = currentLiquidity - goldAmount;
      const newUserGold = currentUserGold + goldAmount;
      const newUserTl = currentUserTl - totalDeduction;

      // Likiditeyi ve kullanıcı bakiyelerini güncelle
      transaction.update(liquidityRefGold, {liquidity: newLiquidity});
      transaction.update(userWalletRef, {gold: newUserGold, tl: newUserTl});

      // Kalan TL'yi TL likiditeye ekle (komisyon dışında kalan miktar)
      const remainingTl = totalCost; // TL bakiyesinden kesilen toplam - komisyon
      const currentTLLiquidity = liquidityDocTL.data().liquidity || 0;
      transaction.update(liquidityRefTL, {liquidity: currentTLLiquidity + remainingTl});

      // Profit koleksiyonundaki profit alanını güncelle
      const currentProfit = profitDoc.exists ? profitDoc.data().profit || 0 : 0;
      transaction.set(profitRef, {profit: currentProfit + commission}, {merge: true});
    });

    return {success: true, message: "Altın satın alma işlemi başarılı."};
  } catch (error) {
    console.error("Altın satın alma hatası:", error);
    throw new functions.https.HttpsError("internal", "Altın satın alma sırasında bir hata oluştu.");
  }
});

exports.buyTL = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const goldAmount = data.amount; // Satmak istediği altın miktarı

  // Kullanıcı kimlik doğrulamasını yap
  if (!context.auth || context.auth.uid !== userId) {
    throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  if (!goldAmount || goldAmount <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Geçerli bir miktar girin.");
  }

  try {
    const liquidityRefGold = admin.firestore().collection("Liquidity").doc("Gold");
    const liquidityRefTL = admin.firestore().collection("Liquidity").doc("TL");
    const userWalletRef = admin.firestore().collection("Users").doc(userId).collection("Account").doc("wallet");
    const profitRef = admin.firestore().collection("Profit").doc("Profit");

    // Tüm okuma işlemlerini gruplandır
    const [liquidityDocGold, liquidityDocTL, priceDoc, userWalletDoc, profitDoc] = await Promise.all([
      liquidityRefGold.get(),
      liquidityRefTL.get(),
      admin.firestore().collection("Price").doc("Price").get(),
      userWalletRef.get(),
      profitRef.get(),
    ]);

    // Altın likiditesini kontrol et
    if (!liquidityDocGold.exists) {
      throw new functions.https.HttpsError("not-found", "Altın likidite bilgisi bulunamadı.");
    }
    const currentGoldLiquidity = liquidityDocGold.data().liquidity;

    // TL likiditesini kontrol et
    if (!liquidityDocTL.exists) {
      throw new functions.https.HttpsError("not-found", "TL likidite bilgisi bulunamadı.");
    }
    const currentTLLiquidity = liquidityDocTL.data().liquidity;

    // Altın fiyatını kontrol et
    if (!priceDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Altın fiyat bilgisi bulunamadı.");
    }
    const goldPrice = priceDoc.data().gold;

    // Kullanıcının cüzdanını kontrol et
    if (!userWalletDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Kullanıcı cüzdanı bulunamadı.");
    }
    const currentUserGold = userWalletDoc.data().gold || 0;
    const currentUserTl = userWalletDoc.data().tl || 0;

    // Komisyon oranını al
    const commissionRate = liquidityDocGold.data().commission || 0.0030; // Varsayılan komisyon %0.30

    // Kullanıcı bakiyesini kontrol et
    if (currentUserGold < goldAmount) {
      throw new functions.https.HttpsError("failed-precondition", "Yetersiz altın bakiyesi.");
    }

    // Satış işleminden elde edilen TL ve komisyonu hesapla
    const totalTl = goldAmount * goldPrice;
    const commission = totalTl * commissionRate; // Komisyonu TL olarak hesapla
    const netTlAmount = totalTl - commission; // Kullanıcıya verilecek TL miktarı

    // Yeterli TL likiditesi olup olmadığını kontrol et
    if (currentTLLiquidity < netTlAmount) {
      throw new functions.https.HttpsError("failed-precondition", "Yeterli TL likidite bulunmamaktadır.");
    }

    // Yazma işlemleri
    await admin.firestore().runTransaction(async (transaction) => {
      // Yeni bakiyeleri hesapla
      const newGoldLiquidity = currentGoldLiquidity + goldAmount;
      const newUserGold = currentUserGold - goldAmount;
      const newUserTl = currentUserTl + netTlAmount;

      // Likiditeyi ve kullanıcı bakiyelerini güncelle
      transaction.update(liquidityRefGold, {liquidity: newGoldLiquidity});
      transaction.update(liquidityRefTL, {liquidity: currentTLLiquidity - netTlAmount});
      transaction.update(userWalletRef, {gold: newUserGold, tl: newUserTl});

      // Profit koleksiyonundaki profit alanını güncelle
      const currentProfit = profitDoc.exists ? profitDoc.data().profit || 0 : 0;
      transaction.set(profitRef, {profit: currentProfit + commission}, {merge: true});
    });

    return {success: true, message: "Altın satışı işlemi başarılı."};
  } catch (error) {
    console.error("Altın satışı hatası:", error);
    throw new functions.https.HttpsError("internal", "Altın satışı sırasında bir hata oluştu.");
  }
});

exports.buyToken = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const tlAmount = data.amount;

  if (!context.auth || context.auth.uid !== userId) {
    throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  if (!tlAmount || tlAmount <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Geçerli bir miktar girin.");
  }

  try {
    const userWalletRef = admin.firestore().collection("Users").doc(userId).collection("Account").doc("wallet");
    const profitRef = admin.firestore().collection("Profit").doc("Token");

    const userWalletDoc = await userWalletRef.get();
    if (!userWalletDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Kullanıcı cüzdanı bulunamadı.");
    }
    const currentUserTl = userWalletDoc.data().tl || 0;
    const currentUserToken = userWalletDoc.data().token || 0;

    if (currentUserTl < tlAmount) {
      throw new functions.https.HttpsError("failed-precondition", "Yetersiz TL bakiyesi.");
    }

    const tokenAmount = tlAmount;
    const tokenSaleSnapshot = await admin.firestore()
        .collection("TokenSale")
        .orderBy("timestamp")
        .get();

    let tokensPurchased = 0;
    const tokenDocsToUpdate = [];

    for (const doc of tokenSaleSnapshot.docs) {
      const saleData = doc.data();
      const availableTokens = saleData.tokenAmount;

      if (tokensPurchased + availableTokens <= tokenAmount) {
        tokensPurchased += availableTokens;
        tokenDocsToUpdate.push({docRef: doc.ref, userId: saleData.userId, amountToReduce: availableTokens});
      } else {
        const remainingTokensNeeded = tokenAmount - tokensPurchased;
        tokensPurchased += remainingTokensNeeded;
        tokenDocsToUpdate.push({docRef: doc.ref, userId: saleData.userId, amountToReduce: remainingTokensNeeded});
        break;
      }

      if (tokensPurchased >= tokenAmount) break;
    }

    if (tokensPurchased < tokenAmount) {
      const liquidityRefToken = admin.firestore().collection("Liquidity").doc("Token");
      const liquidityDocToken = await liquidityRefToken.get();

      if (!liquidityDocToken.exists) {
        throw new functions.https.HttpsError("not-found", "Token likidite bilgisi bulunamadı.");
      }

      const currentTokenLiquidity = liquidityDocToken.data().liquidity || 0;
      const liquidityNeeded = tokenAmount - tokensPurchased;

      if (currentTokenLiquidity < liquidityNeeded) {
        throw new functions.https.HttpsError("failed-precondition", "Yeterli Token likidite bulunmamaktadır.");
      }

      await admin.firestore().runTransaction(async (transaction) => {
        const newUserTl = currentUserTl - tlAmount;
        const newUserToken = currentUserToken + tokenAmount;

        transaction.update(userWalletRef, {tl: newUserTl, token: newUserToken});

        for (const {docRef, userId: sellerId, amountToReduce} of tokenDocsToUpdate) {
          const tokenData = (await docRef.get()).data();
          const newTokenAmount = tokenData.tokenAmount - amountToReduce;
          const sellerWalletRef = admin.firestore().collection("Users").doc(sellerId).collection("Account").doc("wallet");
          const sellerWalletDoc = await sellerWalletRef.get();
          const currentSellerTl = sellerWalletDoc.exists ? sellerWalletDoc.data().tl || 0 : 0;
          const updatedSellerTl = currentSellerTl + amountToReduce;

          transaction.update(sellerWalletRef, {tl: updatedSellerTl});

          if (newTokenAmount <= 0) {
            transaction.delete(docRef);
          } else {
            transaction.update(docRef, {tokenAmount: newTokenAmount});
          }
        }

        const newLiquidity = currentTokenLiquidity - liquidityNeeded;
        transaction.update(liquidityRefToken, {liquidity: newLiquidity});

        const currentProfit = (await profitRef.get()).exists ? (await profitRef.get()).data().profit || 0 : 0;
        transaction.set(profitRef, {profit: currentProfit + tlAmount}, {merge: true});
      });
    } else {
      await admin.firestore().runTransaction(async (transaction) => {
        const newUserTl = currentUserTl - tlAmount;
        const newUserToken = currentUserToken + tokensPurchased;

        transaction.update(userWalletRef, {tl: newUserTl, token: newUserToken});

        for (const {docRef, userId: sellerId, amountToReduce} of tokenDocsToUpdate) {
          const tokenData = (await docRef.get()).data();
          const newTokenAmount = tokenData.tokenAmount - amountToReduce;
          const sellerWalletRef = admin.firestore().collection("Users").doc(sellerId).collection("Account").doc("wallet");
          const sellerWalletDoc = await sellerWalletRef.get();
          const currentSellerTl = sellerWalletDoc.exists ? sellerWalletDoc.data().tl || 0 : 0;
          const updatedSellerTl = currentSellerTl + amountToReduce;

          transaction.update(sellerWalletRef, {tl: updatedSellerTl});

          if (newTokenAmount <= 0) {
            transaction.delete(docRef);
          } else {
            transaction.update(docRef, {tokenAmount: newTokenAmount});
          }
        }
      });
    }

    return {success: true, message: "Token satın alma işlemi başarılı."};
  } catch (error) {
    console.error("Token satın alma hatası:", error);
    throw new functions.https.HttpsError("internal", "Token satın alma sırasında bir hata oluştu.");
  }
});


exports.sellToken = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const amount = data.amount;

  if (!context.auth || context.auth.uid !== userId) {
    throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  if (!amount || amount <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Geçerli bir token miktarı girin.");
  }

  try {
    const userWalletRef = admin.firestore().collection("Users").doc(userId).collection("Account").doc("wallet");
    const userWalletDoc = await userWalletRef.get();

    if (!userWalletDoc.exists || (userWalletDoc.data().token || 0) < amount) {
      throw new functions.https.HttpsError("failed-precondition", "Yetersiz token bakiyesi.");
    }

    await admin.firestore().runTransaction(async (transaction) => {
      const newTokenBalance = (userWalletDoc.data().token || 0) - amount;
      transaction.update(userWalletRef, {token: newTokenBalance});

      const tokenSaleRef = admin.firestore().collection("TokenSale");
      transaction.set(tokenSaleRef.doc(), {
        userId: userId,
        tokenAmount: amount,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        sold: false,
      });
    });

    return {success: true, message: "Token satış ilanı başarıyla oluşturuldu."};
  } catch (error) {
    console.error("Token satış ilanı oluşturulurken hata:", error);
    throw new functions.https.HttpsError("internal", "Token satış ilanı sırasında bir hata oluştu.");
  }
});


exports.cancelAllTokenSales = functions.https.onCall(async (data, context) => {
  const userId = data.userId;

  // Kullanıcı kimlik doğrulaması
  if (!context.auth || context.auth.uid !== userId) {
    throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  try {
    const userWalletRef = admin.firestore().collection("Users").doc(userId).collection("Account").doc("wallet");
    const tokenSaleRef = admin.firestore().collection("TokenSale");

    // Kullanıcının aktif satış ilanlarını al
    const activeSalesSnapshot = await tokenSaleRef.where("userId", "==", userId).get();

    if (activeSalesSnapshot.empty) {
      throw new functions.https.HttpsError("not-found", "Aktif satış ilanı bulunamadı.");
    }

    let totalTokensToReturn = 0;

    await admin.firestore().runTransaction(async (transaction) => {
      const userWalletDoc = await transaction.get(userWalletRef);

      if (!userWalletDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Kullanıcı cüzdanı bulunamadı.");
      }

      const currentUserTokens = userWalletDoc.data().token || 0;

      // Tüm aktif satış ilanlarını sil ve token miktarını topla
      activeSalesSnapshot.forEach((doc) => {
        const saleData = doc.data();
        totalTokensToReturn += saleData.tokenAmount;

        // Satış ilanını sil
        transaction.delete(doc.ref);
      });

      // Kullanıcının token bakiyesini güncelle
      const newUserTokenBalance = currentUserTokens + totalTokensToReturn;
      transaction.update(userWalletRef, {token: newUserTokenBalance});
    });

    return {success: true, message: "Tüm satış ilanları başarıyla iptal edildi, tokenlar iade edildi ve dökümanlar silindi."};
  } catch (error) {
    console.error("Satış iptali hatası:", error);
    throw new functions.https.HttpsError("internal", "Satış iptali sırasında bir hata oluştu.");
  }
});

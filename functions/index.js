const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
const {firestore} = require("firebase-admin");
admin.initializeApp({
  // eslint-disable-next-line no-undef, max-len
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

exports.sendNotifications = functions.firestore
    .document("/Users/{userId}/Chats/{senderId}/Messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const recieverId = snapshot.data()["recieverId"];
      const sendId = snapshot.data()["senderId"];
      const message = snapshot.data()["text"];
      const userId = context.params.userId;

      const profile = await db.collection("fcmToken").doc(recieverId).get();
      const profile2 = await db.collection("Users").doc(sendId).get();
      const token = profile.get("fcmToken");
      const name = profile2.get("name") + " " + profile2.get("surname");
      const payload = {
        notification: {
          title: name,
          body: message,
        },
      };
      if (userId != sendId) {
        return admin.messaging().sendToDevice(token, payload);
      }
    });


// eslint-disable-next-line max-len
exports.story = functions.pubsub.schedule("every 1 hours").onRun(async (context) => {
  const today = firestore.Timestamp.now();
  const yesterday = firestore.Timestamp.fromMillis(today.toMillis() - 86400000);
  await db.collection("Story").where("datePublished", "<", yesterday)
      .get().then(function(querySnapshote) {
        querySnapshote.forEach((element) => {
          element.ref.delete();
        });
      });
});

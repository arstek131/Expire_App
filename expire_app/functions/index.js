const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.myFunction = functions.firestore
    .document("families/{familyId}/products/{productId}")
    .onCreate((snap, context) => {
      const data = snap.data();
      const familyId = context.params.familyId;

      return admin.messaging().sendToTopic(familyId, {
        notification: {
          title: "Someone added a product!",
          body: data["title"],
          icon: "../assets/logo/expiry_app_logo.png",
        },
      });
    });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

const isToday = (someDate) => {
  const today = new Date();
  return someDate.getDate() == today.getDate() &&
    someDate.getMonth() == today.getMonth() &&
    someDate.getFullYear() == today.getFullYear();
};

exports.newProductEvent = functions.firestore
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

exports.newShoppingListEvent = functions.firestore
    .document("families/{familyId}/shopping_lists/{shoppingListId}")
    .onCreate((snap, context) => {
      const data = snap.data();
      const familyId = context.params.familyId;

      return admin.messaging().sendToTopic(familyId, {
        notification: {
          title: "Someone added a shopping list!",
          body: "List: " + data["title"],
          icon: "../assets/logo/expiry_app_logo.png",
        },
      });
    });

exports.newUserJoinsFamily = functions.firestore
    .document("users/{userId}")
    .onCreate((snap, context) => {
      const data = snap.data();
      // const userId = context.params.userId;
      const familyId = data["familyId"];

      return admin.messaging().sendToTopic(familyId, {
        notification: {
          title: "Someone new joined the family!",
          body: "",
          icon: "../assets/logo/expiry_app_logo.png",
        },
      });
    });

exports.checkExpirationSchedule = functions.pubsub.schedule("00 07 * * *")
    .timeZone("Europe/Rome")
    .onRun(async (context) => {
      const familiesRef = db.collection("families");
      // get all families
      const familiesDocs = await familiesRef.get();
      for (let i = 0; i < familiesDocs.docs.length; i++) {
        const familyDoc = familiesDocs.docs[i];
        let numberOfProducts = 0;
        const productsRef = db
            .collection("families")
            .doc(familyDoc.id)
            .collection("products");

        const productsDocs = await productsRef.get();
        for (let j = 0; j < productsDocs.docs.length; j++) {
          const productDoc = productsDocs.docs[j];
          const productData = productDoc.data();
          const expirationDate = new Date(productData["expiration"]);
          if (isToday(expirationDate)) {
            numberOfProducts++;
          }
        }
        if (numberOfProducts > 0) {
          admin.messaging().sendToTopic(familyDoc.id, {
            notification: {
              title: "Some products are expiring today!",
              body: "Don't waste food",
              icon: "../assets/logo/expiry_app_logo.png",
            },
          });
        }
      }
      return null;
    });

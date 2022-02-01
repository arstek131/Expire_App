const functions = require("firebase-functions");

exports.myFunction = functions.firestore
    .document("families/{familyId}/products/{productId}")
    .onCreate((snapshot, context) => {
      console.log(snapshot.data.toString());
      return;
    });

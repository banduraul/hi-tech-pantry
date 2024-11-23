const {onDocumentCreated} = require("firebase-functions/v2/firestore");

const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const {onSchedule} = require("firebase-functions/v2/scheduler");

const admin = require("firebase-admin");

initializeApp();

exports.newProductNotification = onDocumentCreated({document: "users/{userId}/products/{docId}", region: "europe-west1"}, async (event) => {
    const document = await getFirestore()
        .collection("fcmTokens")
        .doc(event.params.userId)
        .get();
    
    const pushTokens = document.data().pushTokens;

    await admin.messaging().sendEachForMulticast({
        tokens: pushTokens,
        data: {
            'type': "newProduct",
            'name': event.data.data().name,
        },
    });
});

exports.expiredProductsNotification = onSchedule({schedule: "every day 09:00", region: "europe-west1", timeZone: "Europe/London"}, () => {
    getFirestore()
        .collection("users")
        .get().then((snapshot) => {
            snapshot.forEach(async (doc) => {
                const expiredProducts = await getFirestore()
                    .collection("users")
                    .doc(doc.id)
                    .collection("products")
                    .where("isExpired", "==", true)
                    .get();
                if (expiredProducts.docs.length > 0) {
                    const document = await getFirestore()
                    .collection("fcmTokens")
                    .doc(doc.id)
                    .get();
                    const pushTokens = document.data().pushTokens;

                    expiredProducts.docs.forEach(async (document) => {
                        await admin.messaging().sendEachForMulticast({
                            tokens: pushTokens,
                            data: {
                                'type': "expiredProduct",
                                'name': document.data().name,
                                'expiryDate': document.data().expiryDate.toDate().toLocaleDateString("en-GB"),
                            },
                        });
                    });
                }
            })
        });
});

exports.productsExpiringSoonNotification = onSchedule({schedule: "every day 09:30", region: "europe-west1", timeZone: "Europe/London"}, () => {
    getFirestore()
        .collection("users")
        .get().then((snapshot) => {
            snapshot.forEach(async (doc) => {
                const today = new Date();
                today.setUTCHours(0, 0, 0, 0);
                const threeDaysFromNow = new Date(today);
                threeDaysFromNow.setUTCDate(today.getUTCDate() + 3);

                const expireSoonProducts = await getFirestore()
                    .collection("users")
                    .doc(doc.id)
                    .collection("products")
                    .where("expiryDate", ">=", today)
                    .where("expiryDate", "<=", threeDaysFromNow)
                    .get();
                if (expireSoonProducts.docs.length > 0) {
                    const document = await getFirestore()
                    .collection("fcmTokens")
                    .doc(doc.id)
                    .get();
                    const pushTokens = document.data().pushTokens;

                    expireSoonProducts.docs.forEach(async (document) => {
                        const expiryDate = document.data().expiryDate.toDate();
                        const expiryDateUTC = Date.UTC(expiryDate.getUTCFullYear(), expiryDate.getMonth(), expiryDate.getDate());
                        const todayUTC = Date.UTC(today.getUTCFullYear(), today.getMonth(), today.getDate());

                        const differenceInTime = Math.abs(expiryDateUTC - todayUTC);
                        const differenceInDays = Math.ceil(differenceInTime / (1000 * 60 * 60 * 24));

                        await admin.messaging().sendEachForMulticast({
                            tokens: pushTokens,
                            data: {
                                'type': "expireSoon",
                                'name': document.data().name,
                                'days': differenceInDays.toString(),
                            },
                        });
                    });
                }
            })
        });
});

exports.productsRunningLowNotification = onSchedule({schedule: "every day 10:00", region: "europe-west1", timeZone: "Europe/London"}, () => {
    getFirestore()
        .collection("users")
        .get().then((snapshot) => {
            snapshot.forEach(async (doc) => {
                const today = new Date();
                today.setUTCHours(0, 0, 0, 0);
                
                const runningLowProducts = await getFirestore()
                    .collection("users")
                    .doc(doc.id)
                    .collection("products")
                    .where("quantity", "<=", 3)
                    .where("expiryDate", ">=", today)
                    .get();
                if (runningLowProducts.docs.length > 0) {
                    const document = await getFirestore()
                    .collection("fcmTokens")
                    .doc(doc.id)
                    .get();
                    const pushTokens = document.data().pushTokens;

                    runningLowProducts.docs.forEach(async (document) => {
                        await admin.messaging().sendEachForMulticast({
                            tokens: pushTokens,
                            data: {
                                'type': "runningLow",
                                'name': document.data().name,
                                'quantity': document.data().quantity.toString(),
                            },
                        });
                    });
                }
            })
        });
});

exports.checkExpiredProducts = onSchedule({schedule: "every day 00:00", region: "europe-west1", timeZone: "Europe/London"}, () => {
    getFirestore()
        .collection("users")
        .get().then((snapshot) => {
            snapshot.forEach(async (doc) => {
                const today = new Date();
                today.setUTCHours(0, 0, 0, 0);

                const expiredProducts = await getFirestore()
                    .collection("users")
                    .doc(doc.id)
                    .collection("products")
                    .where("expiryDate", "<", today)
                    .get();
                if (expiredProducts.docs.length > 0) {
                    expiredProducts.docs.forEach(async (document) => {
                        await getFirestore()
                            .collection("users")
                            .doc(doc.id)
                            .collection("products")
                            .doc(document.id)
                            .set({
                                isExpired: true,
                            }, {merge: true});
                    });
                }
            })
        });
});
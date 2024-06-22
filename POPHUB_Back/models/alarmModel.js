const admin = require("firebase-admin");

const db = admin.firestore();

const alarmModel = {
  tokenResetModel: async (userName, fcmToken) => {
    await db
      .collection("users")
      .doc(userName)
      .set({ fcmToken: fcmToken }, { merge: true });
  },

  alarmAddModel: async (userName, type, alarmDetails) => {
    const userRef = db.collection("users").doc(userName).collection(type);

    const existingAlarms = await userRef
      .where("time", "==", alarmDetails.time)
      .where("label", "==", alarmDetails.label)
      .get();

    if (!existingAlarms.empty) {
      throw new Error("동일한 알람이 이미 존재합니다.");
    }

    const alarmRef = await userRef.add({
      time: alarmDetails.time,
      label: alarmDetails.label,
      title: alarmDetails.title,
      active: alarmDetails.active,
    });

    return alarmRef.id;
  },

  tokenSaveModel: async (userName, fcmToken) => {
    const expiresIn = 14; // 토큰 유효 기간 (14일)
    const expirationDate = new Date();
    expirationDate.setDate(expirationDate.getDate() + expiresIn); // 현재 날짜에 + 14일

    await db.collection("users").doc(userName).set(
      {
        fcmToken: fcmToken,
        expirationDate: expirationDate,
      },
      { merge: true }
    );
  },

  waitListAddModel: async (userName, storeId, date, desiredTime) => {
    const waitlistRef = db.collection("waitlist");
    const waitlistDoc = await waitlistRef.add({
      userName,
      storeId,
      date,
      desiredTime,
      notified: false,
    });
    return waitlistDoc.id;
  },

  checkNotifyModel: async (storeId) => {
    const waitlistSnapshot = await db
      .collection("waitlist")
      .where("storeId", "==", storeId)
      .where("notified", "==", false)
      .get();

    const batch = db.batch();

    waitlistSnapshot.forEach(async (doc) => {
      const waitlistData = doc.data();
      const userRef = db.collection("users").doc(waitlistData.userName);
      const userDoc = await userRef.get();

      if (userDoc.exists) {
        const fcmToken = userDoc.data().fcmToken;
        if (fcmToken) {
          const message = {
            notification: {
              title: "예약 가능 알림",
              body: `${waitlistData.date} ${waitlistData.desiredTime}에 예약이 가능합니다.`,
            },
            token: fcmToken,
          };

          try {
            await admin.messaging().send(message);
            console.log("성공적으로 메시지가 보내짐:", message);
          } catch (error) {
            console.error("메시지 보내는 중 오류남", error);
          }
        }
      }

      batch.update(doc.ref, { notified: true });
    });

    await batch.commit();
  },
};

module.exports = alarmModel;

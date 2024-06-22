const express = require("express");
const bodyParser = require("body-parser");
const cron = require("node-cron");
const admin = require("firebase-admin");

const app = express();
const routes = require("./routes");

// Firebase Admin SDK 초기화
var serviceAccount = require("/config/PopHub_Key.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

app.use(bodyParser.json());
app.use("/", routes);

// 매일 자정에 만료된 FCM 토큰을 자동 삭제
cron.schedule("0 0 * * *", async () => {
  const now = new Date();
  const expiredTokens = await db
    .collection("users")
    .where("expirationDate", "<=", now)
    .get();
  const batch = db.batch();

  expiredTokens.forEach((doc) => {
    batch.delete(doc.ref); // 만료된 토큰 삭제
  });

  await batch.commit();
  console.log("만료된 토큰 처리 완료");
});

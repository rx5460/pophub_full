const alarmModel = require("../models/alarmModel");
const popupModel = require("../models/popupModel");

const alarmController = {
  tokenReset: async (req, res) => {
    try {
      const { userName, fcmToken } = req.body;
      await alarmModel.tokenResetModel(userName, fcmToken);
      res.status(201).send(`사용자 ${userName} 및 FCM 토큰 저장 성공`);
    } catch (error) {
      console.error("사용자 추가 오류:", error);
      res.status(500).send("사용자 추가 오류");
    }
  },
  alarmAdd: async (req, res) => {
    try {
      const { userName, type, alarmDetails } = req.body;
      await alarmModel.alarmAddModel(userName, type, alarmDetails);
      res.status(201).send(`알람이 성공적으로 추가되었습니다`);
    } catch (error) {
      console.error("알람 추가 오류:", error);
      res.status(500).send("알람 추가 오류");
    }
  },
  tokenSave: async (req, res) => {
    try {
      const { userName, fcmToken } = req.body;
      const expiresIn = 14; // 토큰 유효 기간 (14일)
      const expirationDate = new Date();
      expirationDate.setDate(expirationDate.getDate() + expiresIn); // 현재 날짜에 + 14일
      await alarmModel.tokenSaveModel(userName, fcmToken);
      res.status(201).send("토큰이 성공적으로 저장됨");
    } catch (error) {
      console.error("토큰 저장 오류:", error);
      res.status(500).send("토큰 저장 오류");
    }
  },
  waitlistAdd: async (req, res) => {
    try {
      const { userName, storeId, date, desiredTime } = req.body;
      await alarmModel.waitListAddModel(userName, storeId, date, desiredTime);
      res.status(201).send(`대기 알림이 성공적으로 추가되었습니다`);
    } catch (error) {
      console.error("대기 알림 추가 오류:", error);
      res.status(500).send("대기 알림 추가 오류");
    }
  },
  checkNotify: async (req, res) => {
    try {
      const { storeId } = req.body;

      const response = await popupModel.reservation(storeId);
      const data = response.length;

      if (data) {
        await alarmModel.checkNotifyModel(storeId);
        res.status(201).send("알림이 성공적으로 전송되었습니다.");
      } else {
        res
          .status(200)
          .send("예약 가능한 수량이 없어 알림을 전송하지 않았습니다.");
      }
    } catch (error) {
      console.error("알림 전송 오류:", error);
      res.status(500).send("알림 전송 오류");
    }
  },
};

module.exports = alarmController;

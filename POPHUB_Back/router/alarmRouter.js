const express = require("express");
const router = express.Router();

const alarmController = require("../controllers/alarmController");

router.post("/token_reset", alarmController.tokenReset);
router.post("/alarm_add", alarmController.alarmAdd);
router.post("/token_save", alarmController.tokenSave);
router.post("/waitlist_add", alarmController.waitlistAdd);
router.post("/check_and_notify", alarmController.checkNotify);

module.exports = router;

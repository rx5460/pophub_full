const upload = require('../function/multer');
const token = require('../function/jwt');

const express = require('express');
const router = express.Router();

const { signController, authController, userController } = require('../controllers/userController');

// sign route
router.post("/sign_up", signController.signUp);
router.post("/sign_in", signController.signIn);

// auth route
router.post("/certification", authController.certification);
router.post("/verify", authController.verifyCertification);

// user route
router.get("/check", userController.doubleCheck);
router.get("/search_id/:phoneNumber", userController.searchId);
router.post("/change_password", userController.changePassword);
router.get("/search_inquiry", userController.searchInquiry);
router.get("/search_answer", token.verifyToken, userController.searchAnswer);
router.post("/create_profile", token.verifyToken, upload.single("file"), userController.createProfile);
router.post("/update_profile", token.verifyToken, upload.single("file"), userController.updateProfile);

// 토큰 검증 필요
router.get("/:userId", token.verifyToken, userController.searchUser);
router.post("/create_inquiry", token.verifyToken, upload.single("file"), userController.createInquiry);

router.post("/user_delete", token.verifyToken, userController.deleteUser);

module.exports = router;
const express = require('express');
const router = express.Router();
const { productController } = require('../controllers/productController');
const upload = require('../function/multer');

router.get('/', productController.allProducts); // 모든 굿즈
router.get('/store/:store_id', productController.storeProducts); // 스토어별 굿즈 조회
router.post('/create/:store_id', upload.array("files", 5), productController.createProduct); // 굿즈 생성
router.get('/view/:product_id/:user_name?', productController.getProduct); // 특정 굿즈 상세 조회
router.put('/update/:product_id', upload.array("files", 5), productController.updateProduct); // 굿즈 수정
router.delete('/delete/:product_id', productController.deleteProduct); // 굿즈 삭제
router.post('/like/:product_id', productController.likeProduct); // 굿즈 찜
router.get('/likeUser/:user_name', productController.likeUser); // 유저별 찜 조회


//router.put('/order/:product_id', productController.orderProduct); // 굿즈 구매 
// 리뷰 삭제
// router.get('/reviews/:product_id', productController.productReview); // 굿즈 리뷰
// router.get('/review/:review_id', productController.productReviewDetail); // 굿즈 리뷰 상세 조회
// router.post('/review/create/:product_id', productController.createReview); // 굿즈 리뷰 생성
// router.put('/review/:review_id', productController.updateReview); // 굿즈 리뷰 수정
// router.delete('/review/:review_id', productController.deleteReview); // 굿즈 리뷰 삭제
module.exports = router;
const express = require('express');
const router = express.Router();
const { popupController } = require('../controllers/popupController');
const upload = require('../function/multer');
const token = require('../function/jwt');


router.get('/', popupController.allPopups); // 모든 팝업 조회
router.get('/view/:store_id/:user_name?', popupController.getPopup); // 특정 팝업 조회
router.get('/popular', popupController.popularPopups); // 인기 팝업 조회
router.get('/president/:user_name', popupController.popupByPresident); // 팝업 등록자별 조회
router.get('/scheduledToOpen', popupController.scheduledToOpen); // 오픈 예정 팝업 조회
router.get('/scheduledToclose', popupController.scheduledToClose); // 마감 임박 팝업 조회
router.get('/searchStoreName', popupController.searchStoreName); // 스토어 이름으로 팝업 검색
router.get('/searchCategory/:category_id', popupController.searchCategory); // 카테고리로 팝업 검색

router.post('/review/create/:store_id', popupController.createReview); // 팝업 리뷰 생성
router.get('/reviews/store/:store_id', popupController.storeReview); // 특정 팝업 리뷰 조회
router.get('/reviews/user/:user_name', popupController.storeUserReview); // 특정 아이디별 리뷰 조회
router.get('/review/storeReview/:review_id', popupController.storeReviewDetail); // 특정 팝업 리뷰 상세 조회
router.put('/review/update/:review_id', popupController.updateReview);  // 팝업 리뷰 수정
router.delete('/review/delete/:review_id', popupController.deleteReview); // 팝업 리뷰 삭제


router.post('/', upload.array("files", 5), popupController.createPopup); // 팝업 생성
router.put('/update/:store_id', upload.array("files", 5), popupController.updatePopup); // 팝업 수정
router.delete('/delete/:store_id', popupController.deletePopup); // 팝업 삭제

router.get('/viewDenialReason/:store_id', popupController.viewDenialReason); // 팝업 등록 거부 이유 확인
router.post('/like/:store_id', popupController.likePopup); // 팝업 찜
router.get('/likeUser/:user_name', popupController.likeUser); // 팝업 유저별 찜 조회

router.get('/reservationStatus/:store_id', popupController.reservationStatus); // 스토어별 예약 상태
router.post('/reservation/:store_id', popupController.reservation); // 사전 예약
router.get('/getReservation/user/:user_name', popupController.getReservationUser); // 예약자 예약 조회
router.get('/getReservation/president/:store_id', popupController.getReservationPresident); // 팝업 등록자 스토어 예약 조회
router.delete('/deleteReservation/:reservation_id', popupController.deleteReservation) // 예약 취소

router.get('/recommendation/:user_name?', popupController.recommendation); // 추천 시스템
module.exports = router;



// router.post('/reservation/:store_id', popupController.waitReservation); // 예약
// router.get('/reservation/:store_id', popupController.getWaitOrder); // 예약자 대기 순서 조회
// router.get('/waitList', popupController.adminWaitList); // (팝업 등록자) waitList
// router.put('/popupStatus/:store_id', popupController.popupStatus); // (팝업 등록자) 팝업 예약 상태 변경
// router.put('/waitStatus/:wait_id', popupController.waitStatus); // (팝업 등록자)예약자 대기 상태 변경
// router.delete('/waitDelete/:wait_id', popupController.waitDelete); // (팝업 등록자) 예약 삭제
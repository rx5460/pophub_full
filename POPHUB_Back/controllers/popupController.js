const popupModel = require('../models/popupModel');
const moment = require('moment');
const { v4: uuidv4 } = require("uuid");
const { getRecommendation } = require('../function/recommendation');

const popupController = {

    // 모든 팝업 조회
    allPopups: async (req, res) => {
        try {
            const result = await popupModel.allPopups();
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("전체 팝업 조회 중 오류가 발생하였습니다.");
        }
    },

    // 인기 팝업 조회
    popularPopups: async (req, res) => {
        try {
            const popular = await popupModel.popularPopups();
            res.status(200).json(popular);
        } catch (err) {
            console.log(err);
            res.status(500).send("인기 팝업 조회 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 등록자별 조회
    popupByPresident: async (req, res) => {
        try {
            const user_name = req.params.user_name;
            const result = await popupModel.popupByPresident(user_name);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 등록자별 조회 중 오류가 발생하였습니다.");
        }
    },

    // 오픈 예정 팝업 조회
    scheduledToOpen: async (req, res) => {
        try {
            const result = await popupModel.scheduledToOpen();
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("오픈 예정 팝업 조회 중 오류가 발생하였습니다.");
        }
    },

    // 마감 임박 팝업 조회
    scheduledToClose: async (req, res) => {
        try {
            const result = await popupModel.scheduledToClose();
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("마감 임박 팝업 조회 중 오류가 발생하였습니다.");
        }
    },

    // 스토어 이름으로 팝업 검색
    searchStoreName: async (req, res) => {
        try {
            const store_name = req.query.store_name;
            const result = await popupModel.searchStoreName(store_name);
            res.status(200).json(result);
            console.log(store_name);
        } catch (err) {
            console.log(err);
            res.status(500).send("오류 발생");
        }
    },

    // 스토어 카테고리로 팝업 검색
    searchCategory: async (req, res) => {
        try {
            const category_id = req.params.category_id;
            const result = await popupModel.searchCategory(category_id);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("오류 발생");
        }
    },

    // 팝업 스토어 생성
    createPopup: async (req, res) => {
        try {
            const body = req.body;
            const user_name = body.user_name;
            const store_id = uuidv4(); // uuid 생성
            const popupData = { // 팝업 스토어 생성에 들어갈 객체
                store_id,
                category_id: body.category_id,
                user_name, //
                store_name: body.store_name,
                store_location: body.store_location,
                store_contact_info: body.store_contact_info,
                store_description: body.store_description,
                max_capacity: body.max_capacity,
                store_start_date: body.store_start_date,
                store_end_date: body.store_end_date,
            };

            const popupSchedule = { schedule: [] };

            for (let i = 0; i < body.schedule.length; i++) {
                const daySchedule = body.schedule[i];
                const dayOfWeek = daySchedule.day_of_week;
                const openTime = daySchedule.open_time;
                const closeTime = daySchedule.close_time;

                popupSchedule.schedule.push({
                    day_of_week: dayOfWeek,
                    open_time: openTime,
                    close_time: closeTime
                });
            }

            await popupModel.createPopup(popupData); // 팝업 정보 생성
            await popupModel.uploadSchedule(store_id, popupSchedule.schedule); // 팝업 스케줄 정보

            let userImages = [];
            if (req.files) {
                await Promise.all(req.files.map(async (file) => {
                    userImages.push(file.path);
                    await popupModel.uploadImage(store_id, file.path);
                }));
            }

            res.status(201).json(`팝업스토어 등록 요청이 접수되었습니다. 관리자 승인 결과를 기다려 주십시오.`);
        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 생성 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 상세 조회 및 수정시 기본 정보 보내기
    getPopup: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const user_name = req.params.user_name || null;
            const result = await popupModel.getPopup(store_id, user_name);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 상세 조회 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 수정
    updatePopup: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const body = req.body;
            const updateData = {
                store_id,
                category_id: body.category_id,
                user_name: body.user_name,
                store_name: body.store_name,
                store_location: body.store_location,
                store_contact_info: body.store_contact_info,
                store_description: body.store_description,
                max_capacity: body.max_capacity,
                store_start_date: body.store_start_date,
                store_end_date: body.store_end_date,
            };

            const popupSchedule = { schedule: [] };

            for (let i = 0; i < body.schedule.length; i++) {
                const daySchedule = body.schedule[i];
                const dayOfWeek = daySchedule.day_of_week;
                const openTime = daySchedule.open_time;
                const closeTime = daySchedule.close_time;

                popupSchedule.schedule.push({
                    day_of_week: dayOfWeek,
                    open_time: openTime,
                    close_time: closeTime
                });
            }

            await popupModel.updatePopup(store_id, updateData);
            let userImages = [];
            await popupModel.uploadSchedule(store_id, popupSchedule.schedule);
            if (req.files) {
                await Promise.all(req.files.map(async (file) => {
                    userImages.push(file.path);
                    await popupModel.uploadImage(store_id, file.path);
                }));
            }
            res.status(200).json(`수정 요청이 접수되었습니다. 관리자 승인 결과를 기다려 주십시오.`);
        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 수정 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 삭제
    deletePopup: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            await popupModel.deletePopup(store_id);
            res.status(200).json(`해당 팝업스토어의 정보가 삭제되었습니다.`);

        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 삭제 중 오류가 발생하였습니다.");
        }
    },

    // 거부 사유 확인
    viewDenialReason: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const check = await popupModel.viewDenialReason(store_id);
            res.status(200).json(check);
        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 거부 조회 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 찜
    likePopup: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const user_name = req.body.user_name;
            const like = await popupModel.likePopup(user_name, store_id);
            res.status(201).json(like);
        } catch (err) {
            console.log(err);
            res.status(500).send("팝업 찜 중 오류가 발생하였습니다.");
        }
    },

    // 유저별 찜 조회
    likeUser: async (req, res) => {
        try {
            const user_name = req.params.user_name;
            const result = await popupModel.likeUser(user_name);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("사용자별 찜 조회 중 오류가 발생하였습니다.");
        }
    },

    // 스토어별 리뷰
    storeReview: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const review = await popupModel.storeReview(store_id);
            res.status(200).json(review);
        } catch (err) {
            console.log(err);
            res.status(500).send("스토어별 리뷰 조회 중 오류가 발생하였습니다.");
        }
    },

    // 아이디별 리뷰
    storeUserReview: async (req, res) => {
        try {
            const user_name = req.params.user_name;
            const review = await popupModel.storeUserReview(user_name);
            res.status(200).json(review);
        } catch (err) {
            console.log(err);
            res.status(500).send("사용자별 리뷰 조회 중 오류가 발생하였습니다.");
        }
    },


    // 팝업 스토어 리뷰 상세 조회
    storeReviewDetail: async (req, res) => {
        try {
            const review_id = req.params.review_id;
            const reviewDetail = await popupModel.storeReviewDetail(review_id);
            res.status(200).json(reviewDetail);
        } catch (err) {
            console.log(err);
            res.status(500).send("리뷰 상세 조회 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 리뷰 생성
    createReview: async (req, res) => {
        try {
            const body = req.body;
            const store_id = req.params.store_id;
            const review_date = moment().format('YYYY-MM-DD HH:mm:ss');
            const reviewData = {
                user_name: body.user_name,
                store_id,
                review_rating: body.review_rating,
                review_content: body.review_content,
                review_date,
            }

            // 예약 확인
            const checkReservation = await popupModel.checkReservation(store_id, body.user_name);
            if (checkReservation) {
                const checkReview = await popupModel.checkReview(store_id, body.user_name);
                if (checkReview) { // 리뷰 중복 체크
                    return res.status(400).json('이미 리뷰를 작성하셨습니다.');
                }
                await popupModel.createReview(reviewData);
                return res.status(201).json('리뷰가 등록되었습니다.');
            }

            res.status(400).json('리뷰 작성 권한이 없습니다.');
        } catch (err) {
            console.log(err);
            res.status(500).send("리뷰 생성 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 리뷰 수정
    updateReview: async (req, res) => {
        try {
            const body = req.body;
            const review_id = req.params.review_id;
            const review_modified_date = moment().format('YYYY-MM-DD HH:mm:ss');
            const reviewdata = {
                user_name: body.user_name,
                review_rating: body.review_rating,
                review_content: body.review_content,
                review_modified_date,
            }
            await popupModel.updateReview(reviewdata, review_id);
            res.status(200).json('수정이 완료되었습니다.');
        } catch (err) {
            console.log(err);
            res.status(500).send("리뷰 수정 중 오류가 발생하였습니다.");
        }
    },

    // 팝업 스토어 리뷰 삭제
    deleteReview: async (req, res) => {
        try {
            const review_id = req.params.review_id;
            await popupModel.deleteReview(review_id);
            res.status(200).json('삭제가 완료되었습니다.');
        } catch (err) {
            console.log(err);
            res.status(500).send("리뷰 삭제 중 오류가 발생하였습니다.");
        }
    },

    // // 현장 대기 등록
    // waitReservation: async (req, res) => {
    //     try {
    //         const { user_name, wait_visitor_name, wait_visitor_number } = req.body;
    //         const store_id = req.params.store_id;
    //         const wait_reservation_time = moment().format('YYYY-MM-DD HH:mm:ss');
    //         const waitReservation = {
    //             store_id,
    //             user_name,
    //             wait_visitor_name,
    //             wait_visitor_number,
    //             wait_reservation_time,
    //         }

    //         const status = await popupModel.waitReservation(waitReservation);
    //         res.status(201).json(status);
    //     } catch (err) {
    //         throw err;
    //     }
    // },

    // // 현장 예약자 대기 순서 조회
    // getWaitOrder: async (req, res) => {
    //     try {
    //         const user_name = req.body.user_name;
    //         const store_id = req.params.store_id;
    //         const waitOrder = await popupModel.getWaitOrder(store_id, user_name);
    //         res.status(200).json(waitOrder);
    //     } catch (err) {
    //         throw err;
    //     }
    // },

    // // 팝업 등록자 대기 리스트 확인
    // adminWaitList: async (req, res) => {
    //     try {
    //         const user_name = req.body.user_name;
    //         const waitList = await popupModel.adminWaitList(user_name);
    //         res.status(200).json(waitList);
    //     } catch (err) {
    //         throw err;
    //     }
    // },

    // // 팝업 등록자 팝업 대기 상태 변경 (토글)
    // popupStatus: async (req, res) => {
    //     try {
    //         const store_id = req.params.store_id;
    //         const status = await popupModel.popupStatus(store_id);
    //         res.status(200).json(status);
    //     } catch (err) {
    //         throw err;
    //     }
    // },

    // // 예약자 status 변경
    // waitStatus: async (req, res) => {
    //     try {
    //         const wait_id = req.params.wait_id;
    //         const new_status = req.body.wait_status;
    //         await popupModel.waitStatus(wait_id, new_status);
    //         res.status(200).json(`대기 상태가 ${new_status}로 변경되었습니다.`);
    //     } catch (err) {
    //         throw err;
    //     }
    // },

    // // 예약 삭제
    // waitDelete: async (req, res) => {
    //     try {
    //         const wait_id = req.params.wait_id;
    //         await popupModel.waitDelete(wait_id);
    //         res.status(200).json('삭제되었습니다.');
    //     } catch (err) {
    //         throw err;
    //     }
    // },

    // 스토어별 예약 상태
    reservationStatus: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const result = await popupModel.reservationStatus(store_id);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("스토어별 예약 상태 확인 중 오류가 발생하였습니다.");
        }
    },

    // 예약
    reservation: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const body = req.body;
            const reservation_id = uuidv4();
            const created_at = moment().format('YYYY-MM-DD HH:mm:ss');
            let reservationData = {
                reservation_id,
                store_id,
                user_name: body.user_name,
                reservation_date: body.reservation_date,
                reservation_time: body.reservation_time,
                capacity: body.capacity,
                created_at
            };

            const result = await popupModel.reservation(reservationData);

            if (result.success == true) {
                res.status(201).json(`예약 등록이 완료되었습니다. 현재 인원:${result.update_capacity}, 최대 인원: ${result.max_capacity}`);
            } else {
                res.status(400).json(`최대 인원을 초과하였습니다. 시간당 최대 인원:${result.max_capacity}`);
            }
        } catch (err) {
            console.log(err);
            res.status(500).send("예약 중 오류가 발생하였습니다.");
        }
    },

    // 예약 조회 - 유저
    getReservationUser: async (req, res) => {
        try {
            const user_name = req.params.user_name;
            const result = await popupModel.getReservationUser(user_name);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("예약 조회 중 오류가 발생하였습니다.");
        }
    },

    // 예약 조회 - 스토어 (팝업 등록자가 볼 것)
    getReservationPresident: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const result = await popupModel.getReservationPresident(store_id);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("예약 조회 오류가 발생하였습니다.");
        }
    },

    // 예약 취소
    deleteReservation: async (req, res) => {
        try {
            const reservation_id = req.params.reservation_id;
            await popupModel.deleteReservation(reservation_id);
            res.status(200).json("예약이 취소되었습니다.");
        } catch (err) {
            console.log(err);
            res.status(500).send("예약 삭제 오류가 발생하였습니다.");
        }
    },

    // 추천
    recommendation: async (req, res) => {
        try {
            if (!req.params.user_name) {
                return res.status(200).send("로그인 후 추천 시스템을 사용해보세요!");
            }
            const user_recommendation = await getRecommendation(req.params.user_name);
            const data = await popupModel.recommendationData(user_recommendation);
            res.status(200).json(data);
        } catch (err) {
            console.log(err);
            res.status(500).send("추천 시스템 확인 오류가 발생하였습니다.");
        }
    }
};

module.exports = { popupController }
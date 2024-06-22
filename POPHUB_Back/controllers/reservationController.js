const reservationModel = require('../models/reservationModel');

const reservationController = {
    searchWaitList: async (req, res) => {
        try {
            const { userName, storeId } = req.query;

            if (userName) {
                const userResult = await reservationModel.searchUserWait(userName);
                res.status(200).json(userResult);
            } else if (storeId) {
                const storeResult = await reservationModel.searchStoreWait(storeId);
                res.status(200).json(storeResult);
            }
        } catch (err) {
            res.status(500).send('현장 대기 검색 중 오류가 발생했습니다.');
        }
    },

    createWaitList: async (req, res) => {
        try {
            const body = req.body;
            const insertData = {
                user_name: body.userName,
                store_id: body.storeId,
            };

            await reservationModel.createWaitList(insertData);
            res.status(201);
        } catch (err) {
            res.status(500).send('현장 대기 신청 중 오류가 발생했습니다.');
        }
    },

    admissionWaitList: async (req, res) => {
        try {
            const { userName, storeId } = req.body;

            await reservationModel.admissionWaitList(userName, storeId);
            await reservationModel.createStand(userName, storeId);
            res.status(201);
        } catch (err) {
            res.status(500).send('입장 수락 및 입장 데이터 입력 중 오류가 발생했습니다.');
        }
    },

    cancelWaitList: async (req, res) => {
        try {
            const { userName, storeId } = req.body;

            await reservationModel.cancelWaitList(userName, storeId);
            res.status(200);
        } catch (err) {
            res.status(500).send('현장 대기 예약을 취소하는 중 오류가 발생했습니다.');
        }
    },
};

module.exports = reservationController;

const express = require('express');
const token = require('../function/jwt');
const payController = require('../controllers/payController');

const router = express.Router();

router.get('/search', payController.searchPay);
router.get('/success', payController.success);
router.get('/fail', payController.fail);
router.get('/cancel', payController.cancel);
router.post('', token.verifyToken, payController.payRequest);

module.exports = router;
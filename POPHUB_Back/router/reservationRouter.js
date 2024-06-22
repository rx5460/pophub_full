const reservationController = require('../controllers/reservationController');

const express = require('express');
const router = express.Router();

router.get('/', reservationController.searchWaitList);
router.post('/wait', reservationController.createWaitList);
router.post('/admission', reservationController.admissionWaitList);
router.post('/cancel', reservationController.cancelWaitList);

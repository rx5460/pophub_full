const db = require('../config/mysqlDatabase');

const pay_request_query = 'INSERT INTO payment_details SET ?';
const payments_query = 'INSERT INTO payments SET ?';
const update_payments_query = 'UPDATE payments SET status = ?, aid = ? WHERE partner_order_id = ?';
const update_payreq_query = 'UPDATE payment_details SET status = ? WHERE partner_order_id = ?';
const search_partner_query = 'SELECT * FROM payments WHERE partner_order_id = ?'
const search_payment_order_query = 'SELECT * FROM payments WHERE order_id = ?'
const search_details_order_query = 'SELECT * FROM payments WHERE order_id = ?'

const payModel = {
    payRequest : (payRequestData) => {
        return new Promise((resolve, reject) => {
            db.query(pay_request_query, payRequestData, (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            });
        })
    },

    payments : (paymentsData) => {
        return new Promise((resolve, reject) => {
            db.query(payments_query, paymentsData, (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            })
        })
    },

    updatePayments : (partnerOrderId, aid) => {
        return new Promise((resolve, reject) => {
            db.query(update_payments_query, ['approved', aid, partnerOrderId], (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            });
        })
    },

    updatePayReq : (partnerOrderId) => {
        return new Promise((resolve, reject) => {
            db.query(update_payreq_query, ['complete', partnerOrderId], (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            });
        })
    },

    searchOrder : (partnerOrderId) => {
        return new Promise((resolve, reject) => {
            db.query(search_partner_query, partnerOrderId, (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            });
        })
    },

    searchPayDetails : (orderId) => {
        return new Promise((resolve, reject) => {
            db.query(search_details_order_query, orderId, (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            });
        })
    },

    searchPayment : (orderId) => {
        return new Promise((resolve, reject) => {
            db.query(search_payment_order_query, orderId, (err, result) => {
                if(err) reject(err); 
                else resolve(result[0]);
            });
        })
    },
}

module.exports = payModel;
const db = require('../config/mysqlDatabase');

// ------- POST Query -------
const sign_up_query = 'INSERT INTO user_join_info (user_id, user_password, user_role) VALUES (?, ?, ?)';
const sign_in_query = 'SELECT * FROM user_join_info WHERE user_id = ?';

const signModel = {
    signUp: (userId, userPassword, userRole) => {
        return new Promise((resolve, reject) => {
            db.query(sign_up_query, [userId, userPassword, userRole], async (err, result) => {
                if (err) reject(err);
                else resolve({ userId, userPassword, userRole });
            });
        });
    },

    signIn: (userId) => {
        return new Promise((resolve, reject) => {
            db.query(sign_in_query, [userId], async (err, result) => {
                if (err) reject(err);
                else resolve(result[0].user_password);
            });
        });
    },
};

module.exports = signModel;

const db = require('../config/mysqlDatabase');

// ------- GET Query -------

const pending_query = 'SELECT ps.*, GROUP_CONCAT(i.image_url) AS image_urls FROM popup_stores ps LEFT JOIN images i ON ps.store_id = i.store_id WHERE ps.approval_status = "pending" AND deleted = "false" GROUP BY ps.store_id';
const search_category_query = 'SELECT * FROM category';
const select_category_query = 'SELECT category_name FROM category WHERE category_id = ?';
const search_notice_query = 'SELECT * FROM notice'
const select_notice_query = 'SELECT * FROM notice WHERE notice_id = ?'
const search_inquiry_query = 'SELECT * FROM inquiry'
// ------- POST Query -------
const create_answer_query = 'INSERT INTO answer(inquiry_id, user_name, content) VALUES (?, ?, ?)'
const create_notice_query = 'INSERT INTO notice SET ?'
// ------- PUT Query -------
const update_inquiry_query = 'UPDATE inquiry SET status = ? WHERE inquiry_id = ?'
const pendingCheck_query = 'UPDATE popup_stores SET approval_status = "check" WHERE store_id = ?';
const pendingDeny_query = 'UPDATE popup_stores SET approval_status = "deny" WHERE store_id = ?';
const userName_query = 'SELECT user_name FROM popup_stores WHERE store_id = ?';
const insertDeny_query = 'INSERT INTO popup_denial_logs SET ?';


const adminModel = {
    selectCategory: (categoryId) => {
        return new Promise((resolve, reject) => {
            db.query(select_category_query, categoryId, (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        })
    },

    searchCategory: () => {
        return new Promise((resolve, reject) => {
            db.query(search_category_query, (err, result) => {
                if (err) reject(err);
                else resolve(result);
            });
        })
    },

    createAnswer: (inquiry_id, user_name, content) => {
        return new Promise((resolve, reject) => {
            db.query(create_answer_query, [inquiry_id, user_name, content], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        })
    },

    updateInquiry: (inquiry_id) => {
        return new Promise((resolve, reject) => {
            db.query(update_inquiry_query, ['complete', inquiry_id], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        })
    },

    searchInquiry: () => {
        return new Promise((resolve, reject) => {
            db.query(search_inquiry_query, (err, result) => {
                if (err) reject(err);
                else resolve(result);
            });
        })
    },

    searchNotice: () => {
        return new Promise((resolve, reject) => {
            db.query(search_notice_query, (err, result) => {
                if (err) reject(err);
                else resolve(result);
            })
        })
    },

    selectNotice: (noticeId) => {
        return new Promise((resolve, reject) => {
            db.query(select_notice_query, noticeId, (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            })
        })
    },

    createNotice: (noticeData) => {
        return new Promise((resolve, reject) => {
            db.query(create_notice_query, noticeData, (err, result) => {
                if (err) reject(err);
                else resolve(result);
            })
        })
    },

    // 관리자 pending List 출력
    popupPendingList: async (user_name) => {
        try {
            const pendingList = await new Promise((resolve, reject) => {
                db.query(pending_query, (err, result) => {
                    if (err) reject(err);
                    else {
                        const pendingData = result.map(data => ({
                            ...data,
                            image_urls: data.image_urls ? data.image_urls.split(',') : []
                        }));
                        resolve(pendingData);
                    }
                });
            });
            return pendingList;
        } catch (err) {
            throw err;
        }
    },

    // 관리자 승인 check
    popupPendingCheck: async (store_id) => {
        try {
            await new Promise((resolve, reject) => {
                db.query(pendingCheck_query, store_id, (err, result) => {
                    if (err) reject(err);
                    else resolve(result);
                });
            });

            const user_name = await new Promise((resolve, reject) => {
                db.query(userName_query, store_id, (err, result) => {
                    if (err) reject(err);
                    else resolve(result[0].user_name);
                })
            })

            return user_name;
        } catch (err) {
            throw err;
        }
    },

    // 관리자 거부 및 거부 사유 등록
    popupPendingDeny: async (denyData) => {
        try {
            await new Promise((resolve, reject) => {
                db.query(pendingDeny_query, denyData.store_id, (err, result) => {
                    if (err) reject(err);
                    else resolve(result);
                });
            });

            await new Promise((resolve, reject) => {
                db.query(insertDeny_query, denyData, (err, result) => {
                    if (err) reject(err);
                    else resolve(result);
                });
            });

            const user_name = await new Promise((resolve, reject) => {
                db.query(userName_query, denyData.store_id, (err, result) => {
                    if (err) reject(err);
                    else resolve(result[0].user_name);
                })
            })

            return user_name;

        } catch (err) {
            throw err;
        }
    },
}

module.exports = adminModel;
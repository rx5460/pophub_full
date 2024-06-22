const cron = require('node-cron');
const db = require('../config/mysqlDatabase');
const open_query =
    'UPDATE popup_stores SET store_status = "오픈" WHERE store_status = "오픈 예정" AND store_start_date <= DATE(NOW() + INTERVAL 9 HOUR)';
const close_query =
    'UPDATE popup_stores SET store_status = "마감" WHERE store_status = "오픈" AND store_end_date < DATE(NOW() + INTERVAL 9 HOUR)';
const completed_query =
    'UPDATE reservation SET reservation_status = "completed" WHERE reservation_date < DATE(NOW() + INTERVAL 9 HOUR)';

const delete_wait_list_query = 'DROP TABLE IF EXISTS wait_list';
const create_wait_list_query = `
CREATE TABLE wait_list(
    user_name varchar(50) NOT NULL,
    store_id varchar(50) NOT NULL,
    status ENUM('waiting', 'completed', 'cancelled') NOT NULL default 'waiting',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_name) REFERENCES user_info(user_name) ON UPDATE CASCADE,
    FOREIGN KEY (store_id) REFERENCES popup_stores(store_id) ON UPDATE CASCADE,
    
    primary key(user_name, store_id)
  )
`;

const updateStatus = (query) =>
    new Promise((resolve, reject) => {
        db.query(query, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });

async function updatePopupStatus() {
    try {
        const openResult = await updateStatus(open_query);
        console.log('Open stores updated: ', openResult);

        const closeResult = await updateStatus(close_query);
        console.log('Closed stores updated: ', closeResult);
    } catch (err) {
        throw err;
    }
}

async function updateReservationStatus() {
    try {
        const completedResult = await updateStatus(completed_query);
        console.log('Update Reservation: ', completedResult);
    } catch (err) {
        throw err;
    }
}

const resetWaitList = async () => {
    try {
        await updateStatus(delete_wait_list_query);
        await updateStatus(create_wait_list_query);
    } catch (err) {
        throw err;
    }
};

function scheduleDatabaseUpdate() {
    cron.schedule('0 0 * * *', async () => {
        console.log('Update status');
        await updatePopupStatus();
        await updateReservationStatus();
        await resetWaitList();
    });
}

module.exports = { scheduleDatabaseUpdate };

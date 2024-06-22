require('dotenv').config();
const CoolSms = require('coolsms-node-sdk').default;
const CoolAPI = new CoolSms(process.env.COOL_API, process.env.COOL_SECRET);

function sendMessage(phoneNumber, Number) {
    CoolAPI.sendOne({
        'to' : phoneNumber,
        'from' : process.env.COOL_FROM,
        'text' : `[POPHUB]\n인증번호는 ${Number}입니다.`
    });
}

module.exports = sendMessage;
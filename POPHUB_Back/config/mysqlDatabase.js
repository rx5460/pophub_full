const mysql = require("mysql");
require('dotenv').config();

let connection = mysql.createConnection({
    host     : process.env.DB_HOST, //실제로 연결할 데이터베이스의 위치
    user     : process.env.DB_USER,
    password : process.env.DB_PASSWORD,
    database : process.env.DB_DATABASE //데이터베이스 이름
  });

connection.connect();

module.exports = connection;
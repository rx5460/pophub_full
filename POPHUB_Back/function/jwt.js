const jwt = require('jsonwebtoken');
require('dotenv').config();

// JWT를 생성하는 함수
generateToken = userId => {
  // 사용자 아이디를 기반으로 JWT를 생성합니다.
  const token = jwt.sign({ userId }, process.env.TOKEN_SECRET, { expiresIn: '1h' });
  return token;
}

verifyToken = (req, res, next) => {
  const token = req.headers['authorization']; // 헤더에서 토큰 추출

  if (!token) {
      return res.status(401).json({ message: '토큰이 존재하지 않습니다.' });
  }

  jwt.verify(token, process.env.TOKEN_SECRET, (err, decoded) => {
      if (err) {
          return res.status(403).json({ message: '토큰이 유효하지 않습니다.' });
      }
      req.decoded = decoded;
      next();
  });
}

module.exports = {
  generateToken: generateToken,
  verifyToken: verifyToken
};
const multer = require("multer");
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const { v4 } = require("uuid");
require('dotenv').config();

cloudinary.config({ 
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME, 
    api_key: process.env.CLOUDINARY_KEY, 
    api_secret: process.env.CLOUDINARY_SECRET 
});

const currentDate = new Date();
const year = currentDate.getFullYear();
const month = (currentDate.getMonth() + 1).toString().padStart(2, '0');
const day = currentDate.getDate().toString().padStart(2, '0');
const hours = currentDate.getHours().toString().padStart(2, '0');
const minutes = currentDate.getMinutes().toString().padStart(2, '0');
const seconds = currentDate.getSeconds().toString().padStart(2, '0');
const timestamp = `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params:{
      folder:'user_images',
      allowedFormats: ['jpeg', 'png', 'jpg'],
      public_id: (req, file) => {
        return timestamp + "_" + v4()
      },
  },
});

const upload = multer({ storage: storage });

module.exports = upload;
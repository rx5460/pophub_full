const productModel = require('../models/productModel');
const moment = require('moment');
const { v4: uuidv4 } = require("uuid");

const productController = {
    // 모든 굿즈 조회
    allProducts: async (req, res) => {
        try {
            const result = await productModel.allProducts();
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 스토어별 굿즈 조회
    storeProducts: async (req, res) => {
        try {
            const store_id = req.params.store_id;
            const result = await productModel.storeProducts(store_id);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 굿즈 생성
    createProduct: async (req, res) => {
        try {
            const product_id = uuidv4();
            const body = req.body;
            const store_id = req.params.store_id;
            const productData = {
                product_id,
                store_id,
                product_name: body.product_name,
                product_price: body.product_price,
                product_description: body.product_description,
                remaining_quantity: body.remaining_quantity,
            }

            const check = await productModel.createProduct(productData, body.user_name);

            if (check === false) {
                res.status(400).json({ error: '유저 닉네임이 일치하지 않습니다.' });
            } else {
                let productImages = [];
                if (req.files) {
                    await Promise.all(req.files.map(async (file) => {
                        productImages.push(file.path);
                        await productModel.uploadImage(product_id, file.path);
                    }));
                }
                res.status(201).json('해당 상품이 등록되었습니다.');
            }

        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 특정 굿즈 상세 조회
    getProduct: async (req, res) => {
        try {
            const product_id = req.params.product_id;
            const user_name = req.params.user_name || null;
            const result = await productModel.getProduct(product_id, user_name);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 굿즈 수정
    updateProduct: async (req, res) => {
        try {
            const product_id = req.params.product_id;
            const body = req.body;
            const updateData = {
                product_id,
                product_name: body.product_name,
                product_price: body.product_price,
                product_description: body.product_description,
                remaining_quantity: body.remaining_quantity,
            }
            const check = await productModel.updateProduct(updateData, body.user_name);

            if (check === false) {
                res.status(400).json({ error: '유저 닉네임이 일치하지 않습니다.' });
            } else {
                await productModel.deleteImage(product_id);
                let productImages = [];
                if (req.files) {
                    await Promise.all(req.files.map(async (file) => {
                        productImages.push(file.path);
                        await productModel.uploadImage(product_id, file.path);
                    }));
                }
                res.status(200).json('해당 상품이 수정되었습니다.');
            }
        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 굿즈 삭제
    deleteProduct: async (req, res) => {
        try {
            const product_id = req.params.product_id;
            await productModel.deleteImage(product_id);
            await productModel.deleteProduct(product_id);
            res.status(200).json('해당 상품이 삭제되었습니다.');
        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 굿즈 찜
    likeProduct: async (req, res) => {
        try {
            const product_id = req.params.product_id;
            const user_name = req.body.user_name;
            const like = await productModel.likeProduct(user_name, product_id);
            res.status(201).json(like);
        } catch (err) {
            console.log(err);
            res.status(500).send("오류가 발생하였습니다.");
        }
    },

    // 유저별 찜 조회
    likeUser: async (req, res) => {
        try {
            const user_name = req.params.user_name;
            const result = await productModel.likeUser(user_name);
            res.status(200).json(result);
        } catch (err) {
            console.log(err);
            res.status(500).send("사용자별 찜 조회 중 오류가 발생하였습니다.");
        }
    } 

    // // 주문
    // orderProduct: async (req, res) => {
    //     try {
    //         const product_id = req.params.product_id;
    //         const user_name = req.body.user_name;
    //         await productModel.orderProduct(product_id);
    //         res.status(200).json('주문이 완료되었습니다.');
    //     } catch (err) {
    //         console.log(err);
    //         res.status(500).send("오류가 발생하였습니다.");
    //     }
    // },

    // // 특정 굿즈 리뷰
    // productReview: async (req, res) => {
    //     try {
    //         const product_id = req.params.product_id;
    //         const review = await (productModel.productReview(product_id));
    //         res.status(200).json(review);
    //     } catch (err) {
    //         console.log(err);
    //         res.status(500).send("오류가 발생하였습니다.");
    //     }
    // },

    // // 굿즈 리뷰 상세 조회
    // productReviewDetail: async (req, res) => {
    //     try {
    //         const review_id = req.params.review_id;
    //         const reviewDetail = await productModel.productReviewDetail(review_id);
    //         res.status(200).json(reviewDetail);
    //     } catch (err) {
    //         console.log(err);
    //         res.status(500).send("오류가 발생하였습니다.");
    //     }
    // },

    // // 굿즈 리뷰 생성
    // createReview: async (req, res) => {
    //     try {
    //         const user_name = req.body.user_name;

    //         if (!user_name) {
    //             return res.status(400).send("로그인 후 사용해주세요");
    //         }

    //         const product_id = req.params.product_id;
    //         const reviewData = req.body.reviewData;
    //         const review_date = moment().format('YYYY-MM-DD HH:mm:ss');
    //         const reviewdata = {
    //             user_name,
    //             product_id,
    //             review_rating: reviewData.review_rating,
    //             review_content: reviewData.review_content,
    //             review_date,
    //         }
    //         const allreview = await productModel.createReview(reviewdata);
    //         res.status(201).json(allreview);
    //     } catch (err) {
    //         console.log(err);
    //         res.status(500).send("오류가 발생하였습니다.");
    //     }
    // },

    // // 굿즈 리뷰 수정
    // updateReview: async (req, res) => {
    //     try {
    //         const user_name = req.body.user_name;
    //         if (!user_name) {
    //             return res.status(400).send("로그인 후 사용해주세요");
    //         }

    //         const review_id = req.params.review_id;
    //         const reviewData = req.body.reviewData;
    //         const review_modified_date = moment().format('YYYY-MM-DD HH:mm:ss');
    //         const reviewdata = {
    //             user_name,
    //             review_rating: reviewData.review_rating,
    //             review_content: reviewData.review_content,
    //             review_modified_date,
    //         }
    //         await productModel.updateReview(reviewdata, review_id);
    //         res.status(200).json('수정이 완료되었습니다.');
    //     } catch (err) {
    //         console.log(err);
    //         res.status(500).send("오류가 발생하였습니다.");
    //     }
    // },

    // // 굿즈 리뷰 삭제
    // deleteReview: async (req, res) => {
    //     try {
    //         const review_id = req.params.review_id;
    //         await productModel.deleteReview(review_id);
    //         res.status(200).json('삭제가 완료되었습니다.');
    //     } catch (err) {
    //         console.log(err);
    //         res.status(500).send("오류가 발생하였습니다.");
    //     }
    // }
}

module.exports = { productController }
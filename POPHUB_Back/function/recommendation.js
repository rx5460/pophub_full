const kMeans = require('kmeans-js');
const db = require('../config/mysqlDatabase');

// 사용자 정보를 가져오는 함수
async function loginUserInfo(user_name) {
    return new Promise((resolve, reject) => {
        const query = `SELECT gender, age FROM user_info WHERE user_name = ?`;
        db.query(query, [user_name], (err, result) => {
            if (err) reject(err);
            else resolve(result[0]);
        });
    });
}

function getUserInfo() {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT rv.user_name, ps.category_id, ui.gender, ui.age
            FROM reservation as rv
            LEFT JOIN popup_stores as ps ON rv.store_id = ps.store_id
            LEFT JOIN user_info as ui ON rv.user_name = ui.user_name
        `;
        db.query(query, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });
}

async function getRecommendation(user_name) {
    try {
        // 사용자 정보 가져오기
        const userInfo = await loginUserInfo(user_name);

        // 모든 사용자 정보 가져오기
        const reservationData = await getUserInfo();

        // 사용자 성별과 나이를 기반으로 userData 생성
        const userData = [[userInfo.gender === 'M' ? 1 : 0, userInfo.age]];

        // 사용자와 동일한 성별을 가진 데이터 필터링
        const filteredData = reservationData.filter(entry => entry.gender === userInfo.gender);

        // 사용자 정보를 기반으로 카테고리 추천을 위한 데이터 생성
        const data = filteredData.map(entry => ({
            category_id: entry.category_id,
            gender: entry.gender,
            age: entry.age
        }));

        // 클러스터 개수
        const k = 3;

        // 초기 중심 설정 - 남성
        const initialCentroidsMale = [
            [1, 10],
            [1, 20],
            [1, 30],
            [1, 40],
            [1, 50]
        ];

        // 초기 중심 설정 - 여성
        const initialCentroidsFemale = [
            [0, 10],
            [0, 20],
            [0, 30],
            [0, 40],
            [0, 50]
        ];

        // 선택된 성별에 따라 초기 중심 설정
        const initialCentroids = userInfo.gender === 'M' ? initialCentroidsMale : initialCentroidsFemale;

        // K-means 클러스터링 수행
        const kmeans = new kMeans();
        const centroids = kmeans.cluster(data.map(item => [item.gender === 'M' ? 1 : 0, item.age]), {
            k,
            runs: 100,
            init: initialCentroids,
            normalize: false
        });

        // 클러스터링 결과 출력
        console.log("클러스터 중심:", centroids);

        // 해당 사용자가 속한 클러스터 찾기
        let userClusterIndex = -1;
        let minDistance = Number.MAX_VALUE;

        centroids.forEach((center, index) => {
            const distance = Math.sqrt(Math.pow(center[0] - userData[0][0], 2) + Math.pow(center[1] - userData[0][1], 2));
            if (distance < minDistance) {
                minDistance = distance;
                userClusterIndex = index;
            }
        });

        // 해당 클러스터에서 가장 선호하는 카테고리를 찾기
        const clusterData = reservationData.filter(item => (item.gender === 'M' ? 1 : 0) === centroids[userClusterIndex][0] && item.age === centroids[userClusterIndex][1]);
        const categoryCounts = {};

        clusterData.forEach(item => {
            if (!categoryCounts[item.category_id]) {
                categoryCounts[item.category_id] = 1;
            } else {
                categoryCounts[item.category_id]++;
            }
        });

        // 가장 선호하는 카테고리를 찾기
        const sortedCategories = Object.entries(categoryCounts).sort((a, b) => b[1] - a[1]);
        const recommendedCategory = sortedCategories.length > 0 ? sortedCategories[0][0] : null;

        console.log(`${userClusterIndex}번 클러스터`);
        console.log(`추천 카테고리: ${recommendedCategory}`);
        const recommendedCategories = sortedCategories.slice(0, 2).map(category => category[0]);

        return recommendedCategories;
    } catch (err) {
        throw err;
    }
}

module.exports = { getRecommendation };

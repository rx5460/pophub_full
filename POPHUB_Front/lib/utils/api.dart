import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:pophub/model/answer_model.dart';
import 'package:pophub/model/category_model.dart';
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/model/inquiry_model.dart';
import 'package:pophub/model/like_model.dart';
import 'package:pophub/model/notice_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/reservation_model.dart';
import 'package:pophub/model/review_model.dart';
import 'package:pophub/model/schedule_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/GoodsNotifier.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/utils/http.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';

class Api {
  static String domain = "https://pophub-fa05bf3eabc0.herokuapp.com";
  // SMS 전송
  static Future<Map<String, dynamic>> sendCertifi(String phone) async {
    final data =
        await postData("$domain/user/certification", {'phoneNumber': phone});
    Logger.debug("### SMS 전송 $data");
    return data;
  }

  // SMS 인증
  static Future<Map<String, dynamic>> sendVerify(
      String authCode, String expectedCode) async {
    final data = await postData('$domain/user/verify',
        {'authCode': authCode, 'expectedCode': expectedCode});
    Logger.debug("### SMS 인증 $data");

    return data;
  }

  // 회원가입
  static Future<Map<String, dynamic>> signUp(
      String userId, String userPassword, String userRole) async {
    final data = await postData('$domain/user/sign_up',
        {'userId': userId, "userPassword": userPassword, "userRole": userRole});
    Logger.debug("### 회원가입 $data");
    return data;
  }

  // 로그인
  static Future<Map<String, dynamic>> login(
      String userId, String authPassword) async {
    final data = await postData('$domain/user/sign_in',
        {'userId': userId, 'authPassword': authPassword});
    Logger.debug("### 로그인 $data");
    return data;
  }

  // 비밀번호 변경
  static changePasswd(String userId, String userPassword) async {
    final data = await postNoAuthData('$domain/user/change_password',
        {'userId': userId, "userPassword": userPassword});
    Logger.debug("### 비밀번호 변경 $data");
    return data;
  }

  // 프로필 조회
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final data = await getData('$domain/user/$userId', {});
    Logger.debug("### 프로필 조회 $data");
    return data;
  }

  // 인기 팝업 조회
  static Future<List<PopupModel>> getPopupList() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/popular',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to fetch popup list: $e');
      throw Exception('Failed to fetch popup list');
    }
  }

  static Future<PopupModel> getPopup(
      String storeId, bool getLocation, String userName) async {
    Logger.debug(storeId);
    try {
      Map<String, dynamic> data =
          await getData('$domain/popup/view/$storeId/$userName', {});
      print('팝업 데이터 : $data');
      if (getLocation) {
        PopupModel popupModel = PopupModel.fromJson(data);

        final locationData = await Api.getAddress(
            popupModel.location.toString().split("/")[0] != ""
                ? popupModel.location.toString().split("/")[0]
                : "서울특별시 강남구 강남대로 지하396");

        var documents = locationData['documents'];
        if (documents != null && documents.isNotEmpty) {
          var firstDocument = documents[0];
          var x = firstDocument['x'];
          var y = firstDocument['y'];
          data['x'] = x;
          data['y'] = y;
        } else {
          Logger.debug('No documents found');
        }
      }

      return PopupModel.fromJson(data);
    } catch (e) {
      // 오류 처리
      Logger.debug('팝업스토어 조회 오류: $e');
      throw Exception('Failed to fetch popup');
    }
  }

  // 팝업스토어 예약
  static Future<Map<String, dynamic>> popupWait(
      String popup, String visitorName, int count, String userId) async {
    final data = await postData('$domain/popup/reservation/$popup', {
      'user_id': userId,
      'wait_visitor_name': visitorName,
      'wait_visitor_number': count
    });
    Logger.debug("### 예약 $data");
    return data;
  }

  //리뷰 조회 -  팝업별
  static Future<List<ReviewModel>> getReviewList(String popup) async {
    try {
      final List<dynamic> dataList =
          await getListData('$domain/popup/reviews/store/$popup', {});

      List<ReviewModel> reviewList =
          dataList.map((data) => ReviewModel.fromJson(data)).toList();
      return reviewList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch review list: $e');
      throw Exception('Failed to fetch review list');
    }
  }

//리뷰 조회 -  사용자별
  static Future<List<ReviewModel>> getReviewListUser(String userName) async {
    try {
      final List<dynamic> dataList =
          await getListData('$domain/popup/reviews/user/$userName', {});
      print('$domain/popup/reviews/user/$userName');
      List<ReviewModel> reviewList =
          dataList.map((data) => ReviewModel.fromJson(data)).toList();
      return reviewList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch review list: $e');
      throw Exception('Failed to fetch review list');
    }
  }

  //리뷰 작성
  static Future<Map<String, dynamic>> writeReview(
      String popup, double rating, String content, String userName) async {
    final data = await postData('$domain/popup/review/create/$popup', {
      'user_name': userName,
      'review_rating': rating,
      'review_content': content
    });
    Logger.debug("### 리뷰 작성 $data");
    return data;
  }

  // 닉네임 중복 체크
  static Future<Map<String, dynamic>> nameCheck(String userName) async {
    final data = await getData('$domain/user/check/?userName=$userName', {});
    Logger.debug("### 닉네임 중복 확인 $data");
    return data;
  }

  // 프로필 수정 (이미지 x)
  static Future<Map<String, dynamic>> profileModify(
      String userId, String userName) async {
    final data = await postData('$domain/user/update_profile/', {
      'userId': userId,
      'userName': userName,
    });
    Logger.debug("### 프로필 수정 이미지x $data");
    return data;
  }

  // 프로필 수정 (이미지 o)
  static Future<Map<String, dynamic>> profileModifyImage(
      String userId, String userName, image) async {
    final data = await postDataWithImage(
        '$domain/user/update_profile/',
        {
          'userId': userId,
          'userName': userName,
        },
        'file',
        image);
    Logger.debug("### 프로필 수정 이미지o $data");
    return data;
  }

  //결제
  static Future<Map<String, dynamic>> pay(String userId, String itemName,
      int quantity, int totalAmount, int vatAmount, int taxFreeAmount) async {
    final data = await postData('$domain/pay', {
      'userId': userId,
      "itemName": itemName,
      "quantity": quantity,
      "totalAmount": totalAmount,
      "vatAmount": vatAmount,
      "taxFreeAmount": taxFreeAmount
    });
    Logger.debug("### 결제 $data");
    return data;
  }

  //팝업 예약
  static Future<Map<String, dynamic>> popupReservation(String userName,
      String popup, String date, String time, int count) async {
    final data = await postData('$domain/popup/reservation/$popup/', {
      'user_name': userName,
      'reservation_date': date,
      'reservation_time': time,
      'capacity': count
    });
    print({
      'user_name': userName,
      'reservation_date': date,
      'reservation_time': time,
      'capacity': count
    });
    Logger.debug("### 팝업 예약 $data");
    return data;
  }

  //팝업 좋아여
  static Future<Map<String, dynamic>> storeLike(
      String userName, String popup) async {
    final data = await postData('$domain/popup/like/$popup/', {
      'user_name': userName,
    });
    Logger.debug(popup);
    Logger.debug("### 팝업 좋아요 $data");
    return data;
  }

  //아이디 조회
  static Future<Map<String, dynamic>> getId(String phoneNumber) async {
    final data = await getNoAuthData('$domain/user/search_id/$phoneNumber', {});
    Logger.debug("### 아이디 조회 $data");
    return data;
  }

  // 프로필 추가 (이미지 o)
  static Future<Map<String, dynamic>> profileAddWithImage(
      String nickName, String gender, String age, image, String phone) async {
    final data = await postDataWithImage(
        '$domain/user/create_profile/',
        {
          'userId': User().userId,
          'userName': nickName,
          'phoneNumber': phone,
          'Gender': gender,
          'Age': age,
        },
        'file',
        image);
    Logger.debug("### 프로필 추가 이미지o $data");
    return data;
  }

  // 프로필 추가 (이미지 x)
  static Future<Map<String, dynamic>> profileAdd(
      String nickName, String gender, String age, String phone) async {
    final data = await postData('$domain/user/create_profile/', {
      'userId': User().userId,
      'userName': nickName,
      'phoneNumber': phone,
      'Gender': gender,
      'Age': age,
    });
    Logger.debug("### 프로필 추가 이미지x $data");
    return data;
  }

  // 스토어 추가
  static Future<Map<String, dynamic>> storeAdd(StoreModel store) async {
    FormData formData = FormData();

    //파일 추가
    for (var imageMap in store.images) {
      if (imageMap['type'] == 'file') {
        var file = imageMap['data'] as File;
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }
    }

    formData.fields.addAll([
      MapEntry('category_id', store.category),
      MapEntry('user_name', User().userName),
      MapEntry(
        'store_name',
        store.name,
      ),
      MapEntry('store_location', "${store.location}/${store.locationDetail}"),
      MapEntry('store_contact_info', store.contact),
      MapEntry('store_description', store.description),
      MapEntry('store_start_date',
          store.startDate.toIso8601String().split('T').first),
      MapEntry(
          'store_end_date', store.endDate.toIso8601String().split('T').first),
      MapEntry('max_capacity', store.maxCapacity.toString()),
    ]);

    if (store.schedule != null) {
      for (int i = 0; i < store.schedule!.length; i++) {
        Schedule schedule = store.schedule![i];

        formData.fields.addAll([
          MapEntry('schedule[$i][day_of_week]',
              getDayOfWeekAbbreviation(schedule.dayOfWeek, "en"))
        ]);
        formData.fields.addAll([
          MapEntry('schedule[$i][open_time]', formatTime(schedule.openTime))
        ]);
        formData.fields.addAll([
          MapEntry('schedule[$i][close_time]', formatTime(schedule.closeTime))
        ]);
      }
    }

    final data = await postFormData('$domain/popup', formData);
    Logger.debug("### 스토어 추가 $data");
    return data;
  }

  //펜딩 리스트
  static Future<List<PopupModel>> pendingList() async {
    try {
      final List<dynamic> dataList =
          await getListData('$domain/admin/popupPendingList', {});
      Logger.debug("### 펜딩리스트  ${dataList.toString()}");

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch review list: $e');
      throw Exception('Failed to fetch review list');
    }
  }

  // 팝업 승인
  static Future<Map<String, dynamic>> popupAllow(String storeId) async {
    final data = await putData('$domain/admin/popupPendingCheck/', {
      'store_id': storeId,
    });
    Logger.debug("### 팝업 승인 $data");
    return data;
  }

  // 내 팝업스토어 조회
  static Future<List<dynamic>> getMyPopup(String userName) async {
    final data = await getListData('$domain/popup/president/$userName', {});
    Logger.debug("### 내 팝업스토어 조회 $data");
    return data;
  }

  // 카카오 api 조회
  static Future<Map<String, dynamic>> getAddress(String location) async {
    String encode = Uri.encodeComponent(location);
    final data = await getKaKaoApi(
        'https://dapi.kakao.com/v2/local/search/address.json?nalyze_type=similar&page=1&size=10&query=$encode',
        {});

    return data;
  }

// 전체 공지사항 조회
  static Future<List<NoticeModel>> getNoticeList() async {
    final dataList = await getListData('$domain/admin/notice', {});

    List<NoticeModel> noticeList =
        dataList.map((data) => NoticeModel.fromJson(data)).toList();
    Logger.debug("### 공지사항 조회 $noticeList");

    return noticeList;
  }

  static Future<dynamic> getFirstItem(String url) async {
    final List<dynamic> dataList = await getListData(url, {});
    if (dataList.isNotEmpty) {
      return dataList.first;
    } else {
      throw Exception('Data list is empty');
    }
  }

  // 문의 내역
  static Future<List<InquiryModel>> getInquiryList(String userName) async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/user/search_inquiry/?userName=$userName',
        {},
      );

      Logger.debug("### 문의 내역 조회 $dataList");

      List<InquiryModel> inquiryList =
          dataList.map((data) => InquiryModel.fromJson(data)).toList();
      return inquiryList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch inquiry list: $e');
      throw Exception('Failed to fetch inquiry list');
    }
  }

  // 스토어 수정
  static Future<Map<String, dynamic>> storeModify(StoreModel store) async {
    FormData formData = FormData();

    //파일 추가
    for (var imageMap in store.images) {
      if (imageMap['type'] == 'file') {
        var file = imageMap['data'] as File;
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      } else if (imageMap['type'] == 'url') {
        var url = imageMap['data'] as String;
        var response = await Dio().get<List<int>>(url,
            options: Options(responseType: ResponseType.bytes));
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(response.data!,
              filename: url.split('/').last),
        ));
      }
    }

    String locationPart = "";

    if (store.location.isNotEmpty) {
      List<String> parts = store.location.split("/");
      if (parts.length > 1) {
        locationPart = parts[1];
      }
    }
    formData.fields.addAll([
      MapEntry('category_id', store.category),
      MapEntry('user_name', User().userName),
      MapEntry(
        'store_name',
        store.name,
      ),
      MapEntry(
          'store_location',
          locationPart == ""
              ? store.locationDetail != ""
                  ? "${store.location}/${store.locationDetail}"
                  : store.location
              : "${store.location.split("/").first}/${store.locationDetail}"),
      MapEntry('store_contact_info', store.contact),
      MapEntry('store_description', store.description),
      MapEntry('store_start_date',
          store.startDate.toIso8601String().split('T').first),
      MapEntry(
          'store_end_date', store.endDate.toIso8601String().split('T').first),
      MapEntry('max_capacity', store.maxCapacity.toString()),
    ]);

    if (store.schedule != null) {
      for (int i = 0; i < store.schedule!.length; i++) {
        Schedule schedule = store.schedule![i];

        formData.fields.addAll([
          MapEntry('schedule[$i][day_of_week]',
              getDayOfWeekAbbreviation(schedule.dayOfWeek, "en"))
        ]);
        formData.fields.addAll([
          MapEntry('schedule[$i][open_time]', formatTime(schedule.openTime))
        ]);
        formData.fields.addAll([
          MapEntry('schedule[$i][close_time]', formatTime(schedule.closeTime))
        ]);
      }
    }

    Map<String, dynamic> data =
        await putFormData('$domain/popup/update/${store.id}', formData);
    Logger.debug("### 스토어 수정 $data");
    Logger.debug("### 스토어 수정 $formData");
    return data;
  }

  // 팝업 승인 거절
  static Future<Map<String, dynamic>> popupDeny(
      String storeId, String content) async {
    final data = await postData('$domain/admin/popupPendingDeny/', {
      'store_id': storeId,
      'denial_reason': content,
    });
    Logger.debug("### 팝업 승인 거절 $data");
    return data;
  }

  //팝업 예약 상태 조회
  static Future<List<ReservationModel>> getReserveStatus(String popup) async {
    try {
      final dataList =
          await getListData('$domain/popup/reservationStatus/$popup', {});
      Logger.debug("### 예약 상태 조회 $dataList");

      List<ReservationModel> reservationList =
          dataList.map((data) => ReservationModel.fromJson(data)).toList();
      return reservationList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch reservation list: $e');
      throw Exception('Failed to fetch reservation list');
    }
  }

  // 문의내역 추가 (이미지 o)
  static Future<Map<String, dynamic>> inquiryAddWithImage(
      String title, String content, String category, image) async {
    final data = await postDataWithImage(
        '$domain/user/create_inquiry/',
        {
          'userName': User().userName,
          'categoryId': category,
          'title': title,
          'content': content,
        },
        'file',
        image);
    Logger.debug("### 문의내역 추가 이미지o $data");
    return data;
  }

  // 문의내역 추가 (이미지 x)
  static Future<Map<String, dynamic>> inquiryAdd(
      String title, String content, String category) async {
    final data = await postData('$domain/user/create_inquiry/', {
      'userName': User().userName,
      'categoryId': category,
      'title': title,
      'content': content,
    });
    Logger.debug("### 문의내역 추가 이미지x $data");
    return data;
  }

  //문의 내역 상세 조회
  static Future<InquiryModel> getInquiry(int inquiryId) async {
    final data =
        await getData('$domain/user/search_inquiry/?inquiryId=$inquiryId', {});
    Logger.debug("### 문의 내역 상세 조회 $data");

    InquiryModel inquirtModel = InquiryModel.fromJson(data);

    return inquirtModel;
  }

  // 문의 답변
  static Future<Map<String, dynamic>> inquiryAnswer(
      int inquiryId, String content) async {
    final data = await postData('$domain/admin/answer/', {
      'inquiryId': inquiryId,
      'userName': User().userName,
      'content': content,
    });
    Logger.debug("### 문의 답변 $data");
    return data;
  }

  //문의 내역 전체 조회
  static Future<List<InquiryModel>> getAllInquiryList() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/admin/search_inquiry',
        {},
      );

      Logger.debug("### 문의 내역 전체 조회 $dataList");

      List<InquiryModel> inquiryList =
          dataList.map((data) => InquiryModel.fromJson(data)).toList();
      return inquiryList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch inquiry list: $e');
      throw Exception('Failed to fetch inquiry list');
    }
  }

  //답변 조회
  static Future<AnswerModel> getAnswer(int inquiryId) async {
    final data =
        await getData('$domain/user/search_answer/?inquiryId=$inquiryId', {});
    Logger.debug("### 답변 조회 $data");

    AnswerModel inquirtModel = AnswerModel.fromJson(data);

    return inquirtModel;
  }

  //특정 팝업스토어 굿즈 조회
  static Future<List<GoodsModel>> getPopupGoodsList(String popup) async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/product/store/$popup',
        {},
      );

      List<GoodsModel> goodsList =
          dataList.map((data) => GoodsModel.fromJson(data)).toList();
      return goodsList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to fetch goods list: $e');
      throw Exception('Failed to fetch goods list');
    }
  }

  //굿즈 등록
  static Future<Map<String, dynamic>> goodsAdd(
      GoodsNotifier goods, String storeId) async {
    FormData formData = FormData();

    //파일 추가
    for (var imageMap in goods.images) {
      if (imageMap['type'] == 'file') {
        var file = imageMap['data'] as File;
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      } else if (imageMap['type'] == 'url') {
        var url = imageMap['data'] as String;
        var response = await Dio().get<List<int>>(url,
            options: Options(responseType: ResponseType.bytes));
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(response.data!,
              filename: url.split('/').last),
        ));
      }
    }

    formData.fields.addAll([
      MapEntry('user_name', goods.userName),
      MapEntry('product_name', goods.productName),
      MapEntry(
        'product_price',
        goods.price.toString(),
      ),
      MapEntry(
        'product_description',
        goods.description,
      ),
      MapEntry(
        'remaining_quantity',
        goods.quantity.toString(),
      ),
    ]);

    Map<String, dynamic> data =
        await postFormData('$domain/product/create/$storeId', formData);
    Logger.debug("### 굿즈 추가 $data");
    return data;
  }

  //굿즈 수정
  static Future<Map<String, dynamic>> goodsModify(
      GoodsNotifier goods, String productId) async {
    FormData formData = FormData();

    //파일 추가
    for (var imageMap in goods.images) {
      if (imageMap['type'] == 'file') {
        var file = imageMap['data'] as File;
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      } else if (imageMap['type'] == 'url') {
        var url = imageMap['data'] as String;
        var response = await Dio().get<List<int>>(url,
            options: Options(responseType: ResponseType.bytes));
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(response.data!,
              filename: url.split('/').last),
        ));
      }
    }

    formData.fields.addAll([
      MapEntry('user_name', User().userName),
      MapEntry('product_name', goods.productName),
      MapEntry(
        'product_price',
        goods.price.toString(),
      ),
      MapEntry(
        'product_description',
        goods.description,
      ),
      MapEntry(
        'remaining_quantity',
        goods.quantity.toString(),
      ),
    ]);

    Map<String, dynamic> data =
        await putFormData('$domain/product/update/$productId', formData);
    Logger.debug("### 굿즈 수정 $data");
    return data;
  }

  // 특정 팝업 굿즈 상세 조회
  static Future<GoodsModel> getPopupGoodsDetail(String productId) async {
    final data = await getListData('$domain/product/view/$productId', {});
    Logger.debug("### 특정 팝업 굿즈 상세 조회 $data");

    GoodsModel goodsModel = GoodsModel.fromJson(data[0]);
    return goodsModel;
  }

  // 회원탈퇴
  static Future<Map<String, dynamic>> userDelete() async {
    final data = await postData('$domain/user/user_delete/', {
      'userId': User().userId,
      'phoneNumber': User().phoneNumber,
    });
    Logger.debug("### 회원탈퇴 $data");
    return data;
  }

  // 카테고리 리스트 조회
  static Future<List<CategoryModel>> getCategory() async {
    final dataList = await getListData('$domain/admin/category', {});

    List<CategoryModel> categoryList =
        dataList.map((data) => CategoryModel.fromJson(data)).toList();
    Logger.debug("### 카테고리 리스트 조회 $dataList");
    return categoryList;
  }

  // 팝업 삭제
  static Future<Map<String, dynamic>> popupDelete(String storeId) async {
    final data = await deleteData('$domain/popup/delete/$storeId', {});
    Logger.debug("### 팝업 삭제 $data");
    return data;
  }

  // 스토어 이름으로 팝업 검색
  static Future<List<PopupModel>> getPopupByName(String storeName) async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/searchStoreName/?store_name=$storeName',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to fetch getPopupByName list: $e');
      throw Exception('Failed to fetch getPopupByName list');
    }
  }

  // 카테고리로 팝업 검색
  static Future<List<PopupModel>> getPopupByCategory(int category) async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/searchCategory/$category',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to fetch getPopupByCategory list: $e');
      throw Exception('Failed to fetch getPopupByCategory list');
    }
  }

  // 굿즈 삭제
  static Future<Map<String, dynamic>> goodsDelete(String productId) async {
    final data = await deleteData('$domain/product/delete/$productId', {});
    Logger.debug("### 굿즈 삭제 $data");
    return data;
  }

// 지도 조회용 모든 팝업 조회
  static Future<Map<String, Set<Marker>>> getAllPopupList() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();

      Map<String, Set<Marker>> popupMarkersMap = {};

      for (PopupModel popup in popupList) {
        final locationData = await Api.getAddress(
          popup.location.toString().split("/")[0] != ""
              ? popup.location.toString().split("/")[0]
              : "서울특별시 강남구 강남대로 지하396",
        );

        var documents = locationData['documents'];
        if (documents != null && documents.isNotEmpty) {
          var firstDocument = documents[0];
          var x = firstDocument['x'].toString();
          var y = firstDocument['y'].toString();

          Marker marker = Marker(
            markerId: '${popupMarkersMap.length + 1}',
            latLng: LatLng(double.parse(y), double.parse(x)),
          );

          if (popupMarkersMap.containsKey(popup.id)) {
            popupMarkersMap[popup.id]!.add(marker);
          } else {
            popupMarkersMap[popup.id.toString()] = {marker};
          }
        } else {
          Logger.debug('No documents found');
        }
      }

      return popupMarkersMap;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to All popup list: $e');
      throw Exception('Failed to All popup list');
    }
  }

  // 추천 팝업 조회
  static Future<List<PopupModel>> getRecommandPopupList() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/recommendation/${User().userName}',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to getRecommandPopupList popup list: $e');
      throw Exception('Failed to getRecommandPopupList popup list');
    }
  }

  // 오픈 예정 팝업 조회
  static Future<List<PopupModel>> getWillBeOpenPopupList() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/scheduledToOpen',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to getWillBeOpenPopupList popup list: $e');
      throw Exception('Failed to getWillBeOpenPopupList popup list');
    }
  }

  // 종료 예정 팝업 조회
  static Future<List<PopupModel>> getWillBeClosePopupList() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/scheduledToClose',
        {},
      );

      List<PopupModel> popupList =
          dataList.map((data) => PopupModel.fromJson(data)).toList();
      return popupList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to getWillBeClosePopupList popup list: $e');
      throw Exception('Failed to getWillBeClosePopupList popup list');
    }
  }

  // 찜 페이지 조회
  static Future<List<LikeModel>> getLikePopup() async {
    try {
      final List<dynamic> dataList = await getListData(
        '$domain/popup/likeUser/${User().userName}',
        {},
      );

      List<LikeModel> likeList =
          dataList.map((data) => LikeModel.fromJson(data)).toList();
      return likeList;
    } catch (e) {
      // 오류 처리–
      Logger.debug('Failed to getLikePopup popup list: $e');
      throw Exception('Failed to getLikePopup popup list');
    }
  }

  //팝업 예약 상태 조회 by name
  static Future<List<ReservationModel>> getReservationByUserName() async {
    final dataList = await getListData(
        '$domain/popup/getReservation/user/${User().userName}', {});
    Logger.debug("### 팝업 예약 상태 조회 by name $dataList");

    List<ReservationModel> reservationList =
        dataList.map((data) => ReservationModel.fromJson(data)).toList();
    return reservationList;
  }

  //팝업 예약 상태 조회 by store
  static Future<List<ReservationModel>> getReservationByStoreId(
      String storeId) async {
    final dataList = await getListData(
        '$domain/popup/getReservation/president/$storeId', {});
    Logger.debug("### 팝업 예약 상태 조회 by storeId $dataList");

    List<ReservationModel> reservationList =
        dataList.map((data) => ReservationModel.fromJson(data)).toList();
    return reservationList;
  }

  // 예약 삭제
  static Future<Map<String, dynamic>> reserveDelete(
      String reservationId) async {
    final data =
        await deleteData('$domain/popup/deleteReservation/$reservationId', {});
    Logger.debug("### 예약 삭제 $data");
    return data;
  }

  // 아이디 중복 체크
  static Future<Map<String, dynamic>> idCheck(String userId) async {
    final data = await getData('$domain/user/check/?userId=$userId', {});
    Logger.debug("### 아이디 중복 확인 $data");
    return data;
  }
}

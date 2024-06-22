class InquiryModel {
  final int inquiryId;
  final int? answerId;
  final String userName;
  final int? categoryId;
  final String? category;
  final String title;
  final String writeDate;
  final String? answerStatus;
  final String? status;
  final String? image;
  final String? content;

  InquiryModel.fromJson(Map<String, dynamic> json)
      : inquiryId = json['inquiryId'],
        answerId = json['answerId'],
        userName = json['userName'],
        categoryId = json['categoryId'],
        category = json['category'],
        title = json['title'],
        writeDate = json['writeDate'],
        answerStatus = json['answerStatus'],
        status = json['status'],
        image = json['image'],
        content = json['content'];

  Map<String, dynamic> toJson() {
    return {
      'inquiryId': inquiryId,
      'answerId': answerId,
      'userName': userName,
      'categoryId': categoryId,
      'category': category,
      'title': title,
      'writeDate': writeDate,
      'answerStatus': answerStatus,
      'status': status,
      'image': image,
      'content': content,
    };
  }
}

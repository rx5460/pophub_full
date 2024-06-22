class AnswerModel {
  final int inquiryId, answerId;
  final String userName;
  final String content;
  final String writeDate;

  AnswerModel.fromJson(Map<String, dynamic> json)
      : answerId = json['answerId'],
        inquiryId = json['inquiryId'],
        userName = json['userName'],
        content = json['content'],
        writeDate = json['writeDate'];

  Map<String, dynamic> toJson() {
    return {
      'answerId': answerId,
      'inquiryId': inquiryId,
      'userName': userName,
      'content': content,
      'writeDate': writeDate,
    };
  }
}

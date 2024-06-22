class LikeModel {
  final int markId;
  final String userName;
  final String storeId;

  LikeModel(
      {required this.markId, required this.userName, required this.storeId});

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      markId: json['mark_id'],
      userName: json['user_name'],
      storeId: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mark_id': markId,
      'user_name': userName,
      'store_id': storeId,
    };
  }
}

class ReviewModel {
  final String? store, user, content, date, modifyDate;
  final int? review, rating;

  ReviewModel.fromJson(Map<String, dynamic> json)
      : review = json['review_id'],
        store = json['store_id'],
        user = json['user_name'],
        rating = json['review_rating'],
        content = json['review_content'],
        date = json['review_date'],
        modifyDate = json['review_modified_date'];
}

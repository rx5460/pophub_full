class CategoryModel {
  final int categoryId;
  final String categoryName;

  CategoryModel.fromJson(Map<String, dynamic> json)
      : categoryId = json['categoryId'],
        categoryName = json['categoryName'];

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}

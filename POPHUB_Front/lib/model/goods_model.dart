class GoodsModel {
  int price, quantity, view, mark;
  final String product, store, productName, description;
  final String? userName;
  final List? image;

  GoodsModel.fromJson(Map<String, dynamic> json)
      : product = json['product_id'],
        store = json['store_id'],
        view = json['product_view_count'],
        mark = json['product_mark_number'],
        userName = json['user_name'],
        productName = json['product_name'],
        price = json['product_price'],
        description = json['product_description'],
        quantity = json['remaining_quantity'],
        image = json['imageUrls'];

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'product_name': productName,
      'product_price': price,
      'product_description': description,
      'remaining_quantity': quantity,
      'files': image,
    };
  }
}

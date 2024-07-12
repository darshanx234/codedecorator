class CartItem {
  String sku;
  String title;
  int quantity;
  var price;
  String imageurl;

  CartItem({
    required this.sku,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageurl,
  });
}

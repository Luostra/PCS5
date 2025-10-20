class ProductCardItem {
  final int id;
  final String name;
  final double price;
  final String image;
  final String description;

  ProductCardItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });
}

class CartItem {
  final int productId;
  int quantity;

  CartItem({required this.productId, this.quantity = 1});
}

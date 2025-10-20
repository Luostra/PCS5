import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/custom_fonts.dart';
import '../models/model.dart';
import '../widgets/cart.dart';

class CartScreen extends StatelessWidget {
  final List<ProductCardItem> products;
  final List<CartItem> cartItems;
  final void Function(int productId) onIncreaseTap;
  final void Function(int productId) onDecreaseTap;
  final void Function(int productId) onRemoveTap;

  const CartScreen({
    super.key,
    required this.products,
    required this.cartItems,
    required this.onIncreaseTap,
    required this.onDecreaseTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemsInCart = cartItems.where((item) => item.quantity > 0).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Cart', style: AppTextStyles.title),
            const SizedBox(width: 7),
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.bubbleBackground,
                borderRadius: BorderRadius.circular(36),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                '${itemsInCart.fold(0, (sum, item) => sum + item.quantity)}',
                style: AppTextStyles.cartNumber,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 77),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: itemsInCart.length,
          itemBuilder: (context, index) {
            final cartItem = itemsInCart[index];
            final product = products.firstWhere(
              (p) => p.id == cartItem.productId,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CartItemWidget(
                image: product.image,
                name: product.name,
                price: product.price,
                quantity: cartItem.quantity,
                description: product.description,
                onIncreaseTap: () => onIncreaseTap(product.id),
                onDecreaseTap: () => onDecreaseTap(product.id),
                onRemoveTap: () => onRemoveTap(product.id),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.checkoutBackground),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Total', style: AppTextStyles.totalCheckout),
                const SizedBox(width: 5),
                Text(
                  '\$${itemsInCart.fold(0.0, (sum, item) {
                    final product = products.firstWhere((p) => p.id == item.productId);
                    return sum + product.price * item.quantity;
                  }).toStringAsFixed(2)}',
                  style: AppTextStyles.productPriceInCart,
                ),
              ],
            ),
            SizedBox(
              width: 128,
              height: 40,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Checkout', style: AppTextStyles.checkoutButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

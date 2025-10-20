import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/custom_fonts.dart';
import '../models/model.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final List<ProductCardItem> products;
  final List<int> favoriteIds;
  final List<CartItem> cartItems;
  final void Function(int productId) onFavoriteTap;
  final void Function(int productId) onCartTap;

  const HomeScreen({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.cartItems,
    required this.onFavoriteTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Shop', style: AppTextStyles.title),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bubbleBackground,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18.81),
                  alignment: Alignment.centerLeft,
                  child: Text('Clothing', style: AppTextStyles.searchTitle),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxItemWidth = 180;
            int itemsPerRow = (constraints.maxWidth / maxItemWidth).floor();
            itemsPerRow = itemsPerRow > 0 ? itemsPerRow : 1;

            List<List<ProductCardItem>> rows = [];
            for (int i = 0; i < products.length; i += itemsPerRow) {
              int end = (i + itemsPerRow < products.length)
                  ? i + itemsPerRow
                  : products.length;
              rows.add(products.sublist(i, end));
            }

            return ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, rowIndex) {
                final rowProducts = rows[rowIndex];
                int itemsCount = rowProducts.length;

                double totalWidth = constraints.maxWidth;
                double itemWidth = 165;
                double spacing =
                    (totalWidth - itemWidth * itemsPerRow) / (itemsPerRow + 1);

                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: List.generate(rowProducts.length, (columnIndex) {
                      final product = rowProducts[columnIndex];
                      final isFavorite = favoriteIds.contains(product.id);
                      final isCartItem = cartItems.any(
                        (item) =>
                            item.productId == product.id && item.quantity > 0,
                      );

                      return Padding(
                        padding: EdgeInsets.only(
                          left: columnIndex == 0 ? spacing : spacing / 2,
                          right: columnIndex == itemsCount - 1
                              ? spacing
                              : spacing / 2,
                        ),
                        child: SizedBox(
                          width: itemWidth,
                          height: 253,
                          child: ProductItemWidget(
                            image: product.image,
                            name: product.name,
                            price: product.price,
                            isFavorite: isFavorite,
                            isCartItem: isCartItem,
                            onFavoriteTap: () => onFavoriteTap(product.id),
                            onCartTap: () => onCartTap(product.id),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

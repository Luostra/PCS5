import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../theme/custom_fonts.dart';

class ProductItemWidget extends StatelessWidget {
  final String image;
  final String name;
  final double price;
  final bool isFavorite;
  final bool isCartItem;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCartTap;

  const ProductItemWidget({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    this.isFavorite = false,
    this.isCartItem = false,
    required this.onFavoriteTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 165),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product card with image and action buttons
          _buildProductCard(),
          const SizedBox(height: 8),
          // Product information
          _buildProductInfo(),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: 165,
      height: 181,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.102),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product image
          _buildProductImage(),
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(image, fit: BoxFit.cover, width: 155, height: 171),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _CartButton(isCartItem: isCartItem, onTap: onCartTap),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Product name
        SizedBox(
          width: 165,
          child: Text(
            name,
            style: AppTextStyles.productTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // Product price
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: AppTextStyles.productPrice,
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 12),
      child: GestureDetector(
        onTap: onTap,
        child: SvgPicture.asset(
          'assets/icons/favorite.svg',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
            isFavorite ? AppColors.likeActive : AppColors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final bool isCartItem;
  final VoidCallback onTap;

  const _CartButton({required this.isCartItem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 12),
      child: GestureDetector(
        onTap: onTap,
        child: SvgPicture.asset(
          'assets/icons/cart.svg',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
            isCartItem ? AppColors.black : AppColors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

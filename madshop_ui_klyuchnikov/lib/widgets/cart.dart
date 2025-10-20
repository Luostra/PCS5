import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../theme/custom_fonts.dart';

class CartItemWidget extends StatelessWidget {
  final String image;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final VoidCallback onIncreaseTap;
  final VoidCallback onDecreaseTap;
  final VoidCallback onRemoveTap;

  const CartItemWidget({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    required this.onIncreaseTap,
    required this.onDecreaseTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 109,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with shadow and delete button
          _buildImageContainer(),
          const SizedBox(width: 10),
          // Product details and controls
          _buildProductDetails(),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: 129,
      height: 109,
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
        alignment: Alignment.center,
        children: [
          // Product image
          Container(
            width: 121.18,
            height: 101.64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Delete button
          Positioned(left: 10, bottom: 10, child: _buildDeleteButton()),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: onRemoveTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/delete.svg',
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(
              AppColors.deleteIcon,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and description
            _buildProductTextInfo(),
            const Spacer(),
            // Price and quantity controls
            _buildPriceAndControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTextInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 196,
          child: Text(
            name,
            style: AppTextStyles.productTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: AppTextStyles.productDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPriceAndControls() {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: AppTextStyles.productPriceInCart,
          ),
          // Quantity controls
          _buildQuantityControls(),
        ],
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Row(
      children: [
        // Decrease button
        _buildControlButton(
          icon: 'assets/icons/less.svg',
          onTap: onDecreaseTap,
        ),
        const SizedBox(width: 6),
        // Quantity display
        Container(
          width: 37,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.bubbleBackground,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            quantity.toString(),
            style: AppTextStyles.productQuantity,
          ),
        ),
        const SizedBox(width: 6),
        // Increase button
        _buildControlButton(
          icon: 'assets/icons/more.svg',
          onTap: onIncreaseTap,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}

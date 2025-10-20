import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favourites_screen.dart';
import 'cart_screen.dart';
import '../theme/colors.dart';
import '../models/model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<ProductCardItem> products = [
    ProductCardItem(
      id: 1,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product7.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 2,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product2.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 3,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product3.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 4,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product8.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 5,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product6.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 6,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product5.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 7,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product1.png',
      description: 'Pink, Size M',
    ),
    ProductCardItem(
      id: 8,
      name: 'Lorem ipsum dolor sit amet consectetur.',
      price: 17.00,
      image: 'assets/images/product4.png',
      description: 'Pink, Size M',
    ),
  ];

  final List<int> favoriteIds = [2, 11];

  final List<CartItem> cartItems = [
    CartItem(productId: 1, quantity: 2),
    CartItem(productId: 3, quantity: 1),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFavoriteTap(int productId) {
    setState(() {
      if (favoriteIds.contains(productId)) {
        favoriteIds.remove(productId);
      } else {
        favoriteIds.add(productId);
      }
    });
  }

  void _onCartTap(int productId) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        cartItems[index].quantity = (cartItems[index].quantity != 0) ? 0 : 1;
      } else {
        cartItems.add(CartItem(productId: productId, quantity: 1));
      }
    });
  }

  void _onIncreaseTap(int productId) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(CartItem(productId: productId, quantity: 1));
      }
    });
  }

  void _onDecreaseTap(int productId) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1 && cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else if (index != -1) {
        cartItems.removeAt(index);
      }
    });
  }

  void _onRemoveTap(int productId) {
    setState(() {
      cartItems.removeWhere((item) => item.productId == productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        products: products,
        favoriteIds: favoriteIds,
        cartItems: cartItems,
        onFavoriteTap: _onFavoriteTap,
        onCartTap: _onCartTap,
      ),
      FavouritesScreen(
        products: products,
        favoriteIds: favoriteIds,
        cartItems: cartItems,
        onFavoriteTap: _onFavoriteTap,
        onCartTap: _onCartTap,
      ),
      CartScreen(
        products: products,
        cartItems: cartItems,
        onIncreaseTap: _onIncreaseTap,
        onDecreaseTap: _onDecreaseTap,
        onRemoveTap: _onRemoveTap,
      ),
    ];

    final List<String> icons = [
      'assets/icons/home.svg',
      'assets/icons/favorite.svg',
      'assets/icons/cart.svg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],

      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icons.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      icons[index],
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.black : AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 3),
                    isSelected
                        ? Container(
                            height: 3,
                            width: 12,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )
                        : const SizedBox(height: 3),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/category_chip.dart';
import '../models/food_item.dart';
import 'food_cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Pizza', 'Burger', 'Dessert', 'Drinks'];
  String selectedCategory = 'All';

  final List<FoodItem> allItems = [
    FoodItem(name: 'Cheese Pizza', price: 249, category: 'Pizza', image: 'assets/piza.png'),
    FoodItem(name: 'Veg Burger', price: 199, category: 'Burger', image: 'assets/'),
    FoodItem(name: 'Chocolate Cake', price: 149, category: 'Dessert', image: 'assets/cake.png'),
    FoodItem(name: 'Cold Coffee', price: 99, category: 'Drinks', image: 'assets/coffee.png'),
  ];

  List<FoodItem> get filteredItems {
    if (selectedCategory == 'All') return allItems;
    return allItems.where((item) => item.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FoodieHub 🍔'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        children: [
          //  Banner Section
          Container(
            margin: const EdgeInsets.all(16),
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Category Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CategoryChip(
              categories: categories,
              onSelected: (category) {
                setState(() => selectedCategory = category);
              },
            ),
          ),

          const SizedBox(height: 12),

          //  Grid of Items
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return FoodCard(item: filteredItems[index]);
            },
          ),
        ],
      ),
    );
  }
}

Widget? CategoryChip({required List<String> categories, required Null Function(dynamic category) onSelected}) {
}

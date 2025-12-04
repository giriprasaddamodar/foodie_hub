import 'package:flutter/material.dart';
import 'package:foodie_hub/screens/video_library_screen.dart';
import 'package:get/get.dart';
import '../widgets/animated_bottom_nav.dart';
import '../widgets/background_container.dart';
import '../models/user_model.dart';
import '../controller/home_controller.dart';
import 'food_detail_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'personal_settings_screen.dart';
import 'notification_screen.dart';
import '../widgets/food_cart.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser;
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key, required this.currentUser}) {
    controller.welcomeNotification(currentUser);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Exit", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage("assets/banner.gif"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            "POPULAR",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.deepOrange,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            itemCount: controller.foodItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 9,
              mainAxisSpacing: 14,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = controller.foodItems[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => FoodDetailScreen(item: item, currentUser: currentUser));
                },
                child: FoodCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      VideoShortsScreen(),
      FavoritesScreen(currentUser: currentUser),
      CartScreen(currentUser: currentUser),
      PersonalSettingsScreen(currentUser: currentUser),
    ];

    return BackgroundContainer(
      child: WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Obx(() => Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: screens[controller.currentIndex.value]),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () => Get.to(() => NotificationScreen()),
            child: const Icon(Icons.notifications, color: Colors.grey),
          ),
          bottomNavigationBar: AnimatedBottomNav(
            currentIndex: controller.currentIndex.value,
            onTap: controller.updateIndex,
          ),
        )),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/food_item.dart';
import '../models/user_model.dart';
import '../widgets/background_container.dart';
import '../controller/home_controller.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem item;
  final User currentUser;

  FoodDetailScreen({super.key, required this.item, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FoodDetailController(item: item, currentUser: currentUser));

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(item.name),
          actions: [
            if (!controller.isViewMore)
              Obx(() => IconButton(
                icon: Icon(controller.isFavorite.value ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                onPressed: controller.isLoading.value ? null : controller.toggleFavorite,
              )),
          ],
        ),
        body: ListView(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.asset(item.image, height: 250, width: double.infinity, fit: BoxFit.cover),
                  if (!controller.isViewMore)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), offset: const Offset(2, 2), blurRadius: 6)],
                        ),
                        child: Text(
                          "\₹ ${item.price!.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  if (!controller.isViewMore)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Quantity", style: TextStyle(color: Colors.white, fontSize: 18)),
                        Obx(() => Row(
                          children: [
                            IconButton(
                                onPressed: controller.decrementQuantity,
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white)),
                            Text(controller.quantity.value.toString(), style: const TextStyle(fontSize: 18, color: Colors.white)),
                            IconButton(
                                onPressed: controller.incrementQuantity,
                                icon: const Icon(Icons.add_circle_outline, color: Colors.white)),
                          ],
                        )),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (!controller.isViewMore)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.addToCart,
                        icon: const Icon(Icons.shopping_cart, color: Colors.grey),
                        label: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

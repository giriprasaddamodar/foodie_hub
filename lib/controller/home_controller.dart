// home_controller.dart
import 'package:get/get.dart';
import '../models/food_item.dart';
import '../models/user_model.dart';
import '../db/db_helper.dart';
import '../services/notification_service.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  final List<FoodItem> foodItems = [
    FoodItem(name: "Cheese Pizza", image: "assets/piza.gif", price: 249, category: "Pizza", quantity: 1),
    FoodItem(name: "Chicken Burger", image: "assets/burger.gif", price: 149, category: "Burgers", quantity: 1),
    FoodItem(name: "Chocolate Cake", image: "assets/cake.gif", price: 199, category: "Desserts", quantity: 1),
    FoodItem(name: "Cold Coffee", image: "assets/coffee.gif", price: 99, category: "Drinks", quantity: 1),
    FoodItem(name: "Chicken Momos", image: "assets/momos.gif", price: 159, category: "Chinese", quantity: 1),
    FoodItem(name: "Chicken Fingers", image: "assets/fries.gif", price: 189, category: "Snacks", quantity: 1),
    FoodItem(name: "Schezwan Chicken Noodles", image: "assets/noodles.gif", price: 179, category: "Chinese", quantity: 1),
    FoodItem(name: "Chicken Curry Biryani", image: "assets/biriyani.gif", price: 299, category: "Indian", quantity: 1),
    FoodItem(name: "Chicken Gravy", image: "assets/chicken.gif", price: 149, category: "Snacks", quantity: 1),
    FoodItem(name: "More Dishes", image: "assets/more.gif"),
  ];

  void updateIndex(int i) => currentIndex.value = i;

  Future<void> welcomeNotification(User currentUser) async {
    bool isFirstTime = await DBHelper.instance.isFirstTimeUser();

    if (isFirstTime) {
      await NotificationService.showInstantNotification(
        title: "Welcome to FoodieHub!",
        body: "Thanks for joining FoodieHub 🍔 Enjoy your delicious journey!",
      );
      await DBHelper.instance.setFirstTime(0);
    } else {
      await NotificationService.showInstantNotification(
        title: "Welcome Back!",
        body: "Glad to see you again 😊",
      );
    }
  }
}

// food_detail_controller.dart

class FoodDetailController extends GetxController {
  final FoodItem item;
  final User currentUser;
  final DBHelper dbHelper = DBHelper.instance;

  var quantity = 1.obs;
  var isFavorite = false.obs;
  var isLoading = false.obs;

  bool get isViewMore => item.name == "More Dishes";

  FoodDetailController({required this.item, required this.currentUser});

  @override
  void onInit() {
    super.onInit();
    if (!isViewMore) checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    if (currentUser.id == null) return;
    final favs = await dbHelper.getFavorites(currentUser.id!);
    isFavorite.value = favs.any((f) => f.name == item.name);
  }

  Future<void> toggleFavorite() async {
    if (currentUser.id == null) return;
    isLoading.value = true;
    try {
      final uid = currentUser.id!;
      if (isFavorite.value) {
        await dbHelper.removeFavorite(item.name, uid);
      } else {
        await dbHelper.insertFavorite(item, uid);
      }
      await checkIfFavorite();
    } finally {
      isLoading.value = false;
    }
  }

  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> addToCart() async {
    if (currentUser.id == null) return;
    await dbHelper.insertCartItem(item, quantity.value, currentUser.id!);
  }
}

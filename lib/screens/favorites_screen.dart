import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/food_item.dart';
import '../db/db_helper.dart';
import '../widgets/background_container.dart';
import 'food_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final User currentUser;
  const FavoritesScreen({super.key, required this.currentUser});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DBHelper dbHelper = DBHelper.instance;
  List<FoodItem> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final favs = await dbHelper.getFavorites(widget.currentUser.id!);
      setState(() {
        favorites = favs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> removeFavorite(FoodItem item) async {
    await dbHelper.removeFromFavorites(widget.currentUser.id!, item.name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.name} removed from favorites")),
    );
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Favorites', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.isEmpty
            ? const Center(
          child: Text(
            'No favorites yet',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: favorites.length,
          itemBuilder: (_, i) {
            final item = favorites[i];
            return Card(
              color: Colors.white10,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "₹${item.price!.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => removeFavorite(item),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodDetailScreen(
                        item: item,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  );
                  loadFavorites(); // Refresh after returning
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

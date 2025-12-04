import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/user_model.dart';
import '../db/db_helper.dart';
import '../widgets/background_container.dart';

class CartScreen extends StatefulWidget {
  final User currentUser;
  const CartScreen({super.key, required this.currentUser});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DBHelper dbHelper = DBHelper.instance;
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    loadCart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInterstitialAd();
    });  }

  // void _loadInterstitialAd() async {
  //   showDialog(context: context, builder: (BuildContext context){
  //     return Center(child: CircularProgressIndicator(),);
  //   });
  //   await InterstitialAd.load(
  //     adUnitId: 'ca-app-pub-3940256099942544/1033173712',
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _interstitialAd = ad;
  //         _isAdLoaded = true;
  //       },
  //       onAdFailedToLoad: (err) {
  //         _isAdLoaded = false;
  //         debugPrint('Failed to load interstitial ad: $err');
  //       },
  //     ),
  //   );
  //   Navigator.pop(context);
  // }


  Future<void> _loadInterstitialAd() async {

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Wrap the load in a completer to wait for onAdLoaded/onAdFailedToLoad
    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          completer.complete(); // Notify that ad is loaded
        },
        onAdFailedToLoad: (err) {
          _isAdLoaded = false;
          debugPrint('Failed to load interstitial ad: $err');
          completer.complete(); // Complete anyway so we can remove the loading
        },
      ),
    );

    // Wait for ad to load (or fail)
    await completer.future;

    // Remove loading indicator
    Navigator.pop(context);
  }


  void _showInterstitialAd(VoidCallback onAdClosed) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onAdClosed(); // Proceed with checkout
          _loadInterstitialAd(); // Reload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onAdClosed(); // Ad not loaded, proceed
    }
  }

  Future<void> loadCart() async {
    try {
      final items = await dbHelper.getCartItems(widget.currentUser.id!);
      setState(() {
        cartItems = items.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading cart: $e');
      setState(() => isLoading = false);
    }
  }

  double get total {
    double sum = 0;
    for (var item in cartItems) {
      double price = (item['price'] as num).toDouble();
      int quantity = item['quantity'] as int;
      sum += price * quantity;
    }
    return sum;
  }

  Future<void> updateQuantity(int index, int change) async {
    final item = cartItems[index];
    int newQty = (item['quantity'] as int) + change;

    if (newQty < 1) {
      await dbHelper.removeCartItem(item['name'], widget.currentUser.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item['name']} removed from cart')),
      );
    } else {
      await dbHelper.updateCartQuantity(
          widget.currentUser.id!, item['name'], newQty);
    }

    await loadCart();
  }

  Future<void> clearCart() async {
    await dbHelper.clearCart(widget.currentUser.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cart cleared successfully')),
    );
    await loadCart();
  }

  // Checkout function with interstitial ad
  void checkout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty!')),
      );
      return;
    }

    _showInterstitialAd(() {
      // After ad is closed, show order confirmation popup
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Confirmation'),
          content: const Text('Your order has been placed successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Clear cart after checkout
      clearCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cart', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
            ? const Center(
          child: Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (_, i) {
                  final item = cartItems[i];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '₹${item['price']} × ${item['quantity']}',
                        style:
                        const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.white),
                            onPressed: () => updateQuantity(i, -1),
                          ),
                          Text(
                            item['quantity'].toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.white),
                            onPressed: () => updateQuantity(i, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: checkout,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'Checkout',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
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

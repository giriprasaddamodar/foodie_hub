import 'package:flutter/material.dart';
import 'package:foodie_hub/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'services/notification_service.dart';
import 'screens/notification_screen.dart';
import 'screens/entry_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'dart:developer';

// ----------------- INTERSTITIAL -----------------
class AdHelper {
  static InterstitialAd? interstitialAd;
  static bool isLoaded = false;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Interstitial
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isLoaded = true;
          log("Interstitial Loaded!");
        },
        onAdFailedToLoad: (error) {
          log("Interstitial Failed: $error");
          isLoaded = false;
        },
      ),
    );
  }

  static void showAd() {
    if (isLoaded && interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadAd(); // reload next ad
            },
          );

      interstitialAd!.show();
      interstitialAd = null;
      isLoaded = false;
    } else {
      log("Interstitial not ready");
    }
  }
}

// ----------------- APP OPEN AD -----------------
class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;

  static void loadAndShowAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/3419835294', // Test App Open
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          log("App Open Ad Loaded ✅");

          // Show immediately after it loads
          showAd();
        },
        onAdFailedToLoad: (error) {
          log("App Open Ad Failed ❌: $error");
        },
      ),
    );
  }

  static void showAd() {
    if (_appOpenAd == null) {
      log("App Open Ad Not Ready");
      return;
    }

    _appOpenAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            log("App Open Ad Closed — Reloading...");
            loadAndShowAd(); // Reload next app open ad
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            log("App Open Ad Failed to Show ❌: $error");
            loadAndShowAd();
          },
        );

    _appOpenAd!.show();
    _appOpenAd = null;
  }
}

// ----------------- MAIN -----------------
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notifications
  await NotificationService.initialize(onTap: (String? payload) {
    navigatorKey.currentState?.pushNamed('/notifications');
  });

  await NotificationService.scheduleAllPending();

  HttpOverrides.global = MyHttpOverrides();

  // Initialize AdMob
  await MobileAds.instance.initialize();

  // Load and show App Open Ad automatically
  AppOpenAdManager.loadAndShowAd();

  // Load Interstitial Ad (your existing one)
  AdHelper.loadAd();

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
      },
    );
  }
}

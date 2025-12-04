import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../widgets/background_container.dart';

class VideoShortsScreen extends StatefulWidget {
  const VideoShortsScreen({super.key});

  @override
  State<VideoShortsScreen> createState() => _VideoShortsScreenState();
}

class _VideoShortsScreenState extends State<VideoShortsScreen> {
  final List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  ];

  final List<String> videoTitles = [
    "Elephants Dream",
    "For Bigger Blazes",
  ];

  late List<bool> isFavorite;
  late List<VideoPlayerController> controllers;
  int currentIndex = 0;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    // Initialize favorites
    isFavorite = List.generate(videoUrls.length, (_) => false);

    // Initialize video controllers
    controllers = videoUrls.map((url) {
      final controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          if (mounted) setState(() {});
        })
        ..setLooping(true)
        ..play();
      return controller;
    }).toList();

    void _onPageChanged(int index) {
      // Pause old, play new
      controllers[currentIndex].pause();
      currentIndex = index;
      controllers[currentIndex].play();

      // Show ad only on every 2nd video
      // if (index % 1 == 0) {
        _showInterstitialAd(() {});
      // }

      setState(() {});
    }


    // Load interstitial ad after build
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  Future<void> _loadInterstitialAd() async {
    final completer = Completer<void>();
    print("🎯🎯🎯Start loading");
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          completer.complete();
          print("🎯🎯🎯Ad loaded");
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load interstitial ad: $err');
          _isAdLoaded = false;
          completer.complete();
          print('🎯🎯🎯🎯Ad failed to load');
        },
      ),
    );

    await completer.future;
  }

  void _showInterstitialAd(VoidCallback onClosed) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onClosed();

              // Load next ad automatically
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onClosed();
            },
          );

      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      debugPrint("Ad not ready!");
      onClosed();
    }
  }


  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      controllers[currentIndex].pause();
      currentIndex = index;
      controllers[currentIndex].play();
      _showInterstitialAd(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controllers.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final controller = controllers[index];
            return controller.value.isInitialized
                ? Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite[index] = !isFavorite[index];
                      });
                    },
                    child: Icon(
                      isFavorite[index]
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Text(
                    videoTitles[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
                : const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

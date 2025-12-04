import 'package:flutter/material.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image with curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.cover,
                height: 70,
              ),
            ),
          ),

          Container(color: Colors.transparent.withOpacity(0.8)),

          // Icons
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(icon: Icons.home, index: 0),
                _navItem(icon: Icons.video_library_rounded, index: 1),
                _navItem(icon: Icons.favorite, index: 2),
                _navItem(icon: Icons.shopping_cart, index: 3),
                _navItem(icon: Icons.settings, index: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 60,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isSelected ? 20 : 0, // icon pop up
              child: AnimatedScale(
                scale: isSelected ? 2.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: Icon(
                  icon,
                  color: isSelected ? Colors.deepOrange : Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

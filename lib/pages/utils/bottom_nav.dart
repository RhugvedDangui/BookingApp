// bottom_nav.dart
import 'package:flutter/material.dart';

/// A custom bottom navigation bar with animated indicators for the selected tab.
/// 
/// This widget provides a stylized bottom navigation bar with visual feedback
/// for the currently selected item, including a colored indicator line.
class CustomBottomNav extends StatefulWidget {
  /// Callback function triggered when a navigation item is tapped.
  final Function(int) onItemTapped;
  
  /// The index of the currently selected item.
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.onItemTapped,
    required this.currentIndex,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onItemTapped,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          _buildNavItem(0, Icons.home, Icons.home_outlined, 'Home'),
          _buildNavItem(1, Icons.book, Icons.book_outlined, 'Bookings'),
          _buildNavItem(2, Icons.notifications, Icons.notifications_none_outlined, 'Notifications'),
          _buildNavItem(3, Icons.settings, Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }
  
  /// Builds a navigation item with appropriate styling based on selection state.
  BottomNavigationBarItem _buildNavItem(
    int index, 
    IconData selectedIcon, 
    IconData unselectedIcon, 
    String label
  ) {
    final bool isSelected = widget.currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: isSelected 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selectedIcon, size: 30),
                Container(
                  width: 8,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            )
          : Icon(unselectedIcon, size: 26),
      label: label,
    );
  }
}

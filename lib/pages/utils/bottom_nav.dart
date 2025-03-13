import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  final Function(int) onItemTapped;
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
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
        showUnselectedLabels:
            false, // Hide unselected labels for a cleaner look
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),

        items: [
          BottomNavigationBarItem(
            icon: widget.currentIndex == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, size: 30),
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
                : Icon(Icons.home_outlined, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: widget.currentIndex == 1
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book, size: 30),
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
                : Icon(Icons.book_outlined, size: 26),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: widget.currentIndex == 2
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications, size: 30),
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
                : Icon(Icons.notifications_none_outlined, size: 26),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: widget.currentIndex == 3
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 30),
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
                : Icon(Icons.settings_outlined, size: 26),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

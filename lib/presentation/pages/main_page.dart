import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../home.dart';
import 'profile_page.dart';
import 'drugs_page.dart';
import 'dashboard_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const HomePage(),
    const DashboardPage(),
    const DrugsPage(),
    const ProfilePage(),
  ];

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}

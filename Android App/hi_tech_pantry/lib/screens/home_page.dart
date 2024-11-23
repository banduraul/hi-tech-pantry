import 'package:flutter/material.dart';

import 'profile_page.dart';
import 'products_page.dart';

import '../utils/notification_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String homeName = 'home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  var _selectedIndex = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationServices.flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationServices.flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = const ProductsPage();
      case 1:
        page = const ProfilePage();
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) => Column(children: [
          Expanded(child: mainArea),
          SafeArea(
            top: false,
            child: BottomNavigationBar(
              selectedItemColor: Colors.black,
              backgroundColor: Colors.blue.shade300,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_grocery_store_rounded),
                  label: 'Products'
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile'
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
            ),
          ),
        ])
      ),
    );
  }
}
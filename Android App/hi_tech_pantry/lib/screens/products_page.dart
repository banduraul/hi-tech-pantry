import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../screens/profile_page.dart';

import '../utils/app_state.dart';
import '../utils/notification_services.dart';

import '../widgets/product_card.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  static const String productsName = 'products';

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isSearching = false;
  String _searchQuery = '';

  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    super.initState();
    NotificationServices.flutterLocalNotificationsPlugin.cancelAll();
    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        NotificationServices.flutterLocalNotificationsPlugin.cancelAll();
      },
    );
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) {
          final filteredProducts = appState.productInfo.where((product) => product.name.toLowerCase().contains(_searchQuery)).toList();
          final filteredProductsHasExpired = filteredProducts.any((product) => product.isExpired);
          return appState.productInfo.isEmpty
            ? Column(
              children: [
                AppBar(
                  title: Text('Products'),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          Icons.person_rounded,
                          size: 27,
                        ),
                        onPressed: () {
                          context.pushNamed(ProfilePage.profileName);
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      )
                    )
                  )
                ),
              ],
            )
            : Column(
              children: [
                Stack(
                  children: [
                    if (filteredProductsHasExpired)
                      Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          width: double.infinity,
                          height: 105,
                          decoration: BoxDecoration(
                            color: Colors.red.shade900,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Swipe left on the expired products to delete them',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    AppBar(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: child
                            );
                          },
                          child: _isSearching
                            ? TextField(
                                key: ValueKey('searchField'),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  filled: false,
                                ),
                                autofocus: true,
                              )
                            : Text(
                                'Products',
                                key: ValueKey('title'),
                              ),
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(
                          _isSearching
                            ? Icons.close
                            : Icons.search,
                          size: 27,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: Icon(
                              Icons.person_rounded,
                              size: 27,
                            ),
                            onPressed: () {
                              if (!_isSearching) {
                                context.pushNamed(ProfilePage.profileName);
                              } else {
                                setState(() {
                                  _isSearching = !_isSearching;
                                  _searchQuery = '';
                                });
                                Future.delayed(Duration(milliseconds: 600));
                                context.pushNamed(ProfilePage.profileName);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 0.0),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final productInfo = filteredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                          child: ProductCard(productInfo: productInfo),
                        );
                      }
                    ),
                  ),
              ],
            );
        }
      ),
    );
  }
}
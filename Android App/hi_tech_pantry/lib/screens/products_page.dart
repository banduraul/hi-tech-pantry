import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_state.dart';

import '../widgets/product_card.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isSearching = false;
  String _searchQuery = '';

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
                ),
                Expanded(
                  child: Center(
                    child: Text('No products found')
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
                            color: Colors.teal.shade400,
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
                        padding: const EdgeInsets.only(left: 70),
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
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
                                ),
                                autofocus: true,
                              )
                            : Text(
                                'Products',
                                key: ValueKey('title'),
                                style: TextStyle(color: Colors.blue.shade700)
                              ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: Icon(
                              _isSearching
                                ? Icons.close
                                : Icons.search,
                              color: Colors.black,
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
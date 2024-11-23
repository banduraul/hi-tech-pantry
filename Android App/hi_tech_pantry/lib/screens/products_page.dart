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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => appState.productInfo.isEmpty
        ? Center(child: Text('You have no products deposited'))
        : Stack(
          children: [
            ListView.builder(
              padding: EdgeInsets.only(top: appState.hasExpiredProducts ? 36.0 : 0.0),
              itemCount: appState.productInfo.length,
              itemBuilder: (context, index) {
                final productInfo = appState.productInfo[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child: ProductCard(productInfo: productInfo),
                );
              }
            ),

            if (appState.hasExpiredProducts)
              Positioned(
                top: 5,
                left: 16,
                right: 16,
                child: Container(
                  width: double.infinity,
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
              )
          ]
        )
      ),
    );
  }
}
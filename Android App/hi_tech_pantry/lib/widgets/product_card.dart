import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data_classes/product_info.dart';

import '../utils/database.dart';

import 'edit_product_info_dialog.dart';
import 'product_expiry_date_status.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productInfo,
  });

  final ProductInfo productInfo;

  @override
  Widget build(BuildContext context) {
    if (productInfo.finishedEditing) {
      final expiryDate = DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!);
      if (productInfo.isExpired) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Dismissible(
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete_forever_rounded, color: Colors.white),
            ),
            key: Key(productInfo.docId),
            direction: DismissDirection.endToStart,
            onDismissed: (_) async {
              final message = await Database.deleteProduct(docId: productInfo.docId);
              if (message.contains('Success')) {
                Fluttertoast.showToast(
                  msg: 'Product deleted successfully',
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
              ),
              child: Card(
                child: ListTile(
                  title: Text(productInfo.name),
                  subtitle: ProductExpiryDateStatus(
                    icon: Icons.error_outline_rounded,
                    expiryDate: 'Expired On: $expiryDate',
                    color: Colors.red.shade900
                  ),
                  trailing: Text(
                    productInfo.quantity.toString(),
                    style: TextStyle(
                      color: productInfo.quantity <= 3 ? Colors.red.shade900 : null
                    )
                  ),
                ),
              ),
            ),
          ),
        );
      }
      final isAfter = productInfo.expiryDate!.isAfter(
        DateFormat('dd/MM/yyyy').parse(
          DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))
        )
      );
      return Card(
        child: ListTile(
          title: Text(productInfo.name),
          subtitle: ProductExpiryDateStatus(
            icon: isAfter ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
            expiryDate: 'Expiry Date: $expiryDate',
            color: isAfter ? Colors.green.shade600
                           : Colors.orange.shade600
          ),
          trailing: Text(
            productInfo.quantity.toString(),
            style: TextStyle(
              color: productInfo.quantity <= 3 ? Colors.red.shade900 : null
            )
          ),
        ),
      );
    }
    return Card(
      child: ListTile(
        title: Text(productInfo.name),
        subtitle: Text(
          'Add an expiry date for this product and change product information if needed',
          style: TextStyle(color: Colors.blue.shade900)
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => EditProductInfoDialog(productInfo: productInfo),
            );
          },
        ),
      ),
    );
  }
}
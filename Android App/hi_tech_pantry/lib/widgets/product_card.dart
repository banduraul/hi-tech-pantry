import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../data_classes/product_info.dart';

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
      if (productInfo.expiryDate != null) {
        final expiryDate = DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!);
        if (productInfo.isExpired) {
          return Card(
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
            'No expiry date set for this product',
            style: TextStyle(color: Colors.blue.shade700)
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
        title: Text(productInfo.name.isEmpty ? 'Unknown Product' : productInfo.name),
        subtitle: Text(
          'Add an expiry date for this product and change product information if needed',
          style: TextStyle(color: Colors.blue.shade700)
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
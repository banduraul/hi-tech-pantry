import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../data_classes/product_info.dart';

import '../widgets/quantity_update_widget.dart';

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
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    if (productInfo.finishedEditing) {
      if (productInfo.expiryDate != null) {
        final expiryDate = DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!);
        if (productInfo.isExpired) {
          return Card(
            child: ListTile(
              title: Text(productInfo.name, style: TextStyle(color: isDarkMode ? Colors.white : null)),
              subtitle: ProductExpiryDateStatus(
                icon: Icons.cancel_outlined,
                expiryDate: 'Expired On: $expiryDate',
                color: Colors.red.shade800
              ),
              trailing: QuantityUpdateWidget(quantity: productInfo.quantity, docId: productInfo.docId),
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
            title: Text(productInfo.name, style: TextStyle(color: isDarkMode ? Colors.white : null)),
            subtitle: ProductExpiryDateStatus(
              icon: isAfter ? Icons.check_circle_outline_rounded
                            : Icons.access_time_rounded,
              expiryDate: 'Expiry Date: $expiryDate',
              color: isAfter ? Colors.green.shade600
                             : Colors.orange.shade600
            ),
            trailing: QuantityUpdateWidget(quantity: productInfo.quantity, docId: productInfo.docId),
          ),
        );
      }

      return Card(
        child: ListTile(
          title: Text(productInfo.name, style: TextStyle(color: isDarkMode ? Colors.white : null)),
          subtitle: Text(
            'No expiry date set for this product',
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w900)
          ),
          trailing: QuantityUpdateWidget(quantity: productInfo.quantity, docId: productInfo.docId),
        ),
      );
    }
    
    return Card(
      child: ListTile(
        title: Text(productInfo.name.isEmpty ? 'Unknown Product' : productInfo.name, style: TextStyle(color: isDarkMode ? Colors.white : null)),
        subtitle: Text(
          'New product. Tap to edit',
          style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w900)
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
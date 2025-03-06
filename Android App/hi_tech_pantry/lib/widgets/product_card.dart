import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../data_classes/product_info.dart';

import 'quantity_update_widget.dart';
import 'edit_product_info_dialog.dart';
import 'product_expiry_date_status.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productInfo,
    required this.isSelected,
  });

  final ProductInfo productInfo;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    if (productInfo.finishedEditing) {
      if (productInfo.expiryDate != null) {
        final expiryDate = DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!);
        if (productInfo.isExpired) {
          return Card(
            shape: isSelected ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.blue.shade700, width: 2)
            ) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(productInfo.name, style: TextStyle(color: isDarkMode ? Colors.white : null)),
                  subtitle: ProductExpiryDateStatus(
                    icon: Icons.cancel_outlined,
                    expiryDate: 'Expired On: $expiryDate',
                    color: Colors.red.shade800
                  ),
                  trailing: QuantityUpdateWidget(quantity: productInfo.quantity, docId: productInfo.docId),
                ),
                Visibility(
                  visible: productInfo.categories.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ListView.builder(
                        itemCount: productInfo.categories.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.shade700, width: 2)
                              ),
                              child: Text(
                                productInfo.categories[index],
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final isAfter = productInfo.expiryDate!.isAfter(
          DateFormat('dd/MM/yyyy').parse(
            DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))
          )
        );

        return Card(
          shape: isSelected ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: Colors.blue.shade700, width: 2)
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
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
              Visibility(
                visible: productInfo.categories.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ListView.builder(
                      itemCount: productInfo.categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade700, width: 2)
                            ),
                            child: Text(
                              productInfo.categories[index],
                              style: TextStyle(
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Card(
        shape: isSelected ? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Colors.blue.shade700, width: 2)
        ) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(productInfo.name, style: TextStyle(color: isDarkMode ? Colors.white : null)),
              subtitle: Text(
                'No expiry date',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w900)
              ),
              trailing: QuantityUpdateWidget(quantity: productInfo.quantity, docId: productInfo.docId),
            ),
            Visibility(
              visible: productInfo.categories.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ListView.builder(
                    itemCount: productInfo.categories.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade700, width: 2)
                          ),
                          child: Text(
                            productInfo.categories[index],
                            style: TextStyle(
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Card(
      shape: isSelected ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.blue.shade700, width: 2)
      ) : null,
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
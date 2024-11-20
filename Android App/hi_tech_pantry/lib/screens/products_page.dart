import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/database.dart';
import '../utils/app_state.dart';

import '../widgets/edit_product_info_dialog.dart';
import '../widgets/product_expiry_date_status.dart';

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
        title: const Text('Hi-Tech Pantry - Products'),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => appState.productInfo.isEmpty
        ? Center(child: Text('You have no products deposited'))
        : ListView.builder(
           itemCount: appState.productInfo.length,
           itemBuilder: (context, index) {
             final productInfo = appState.productInfo[index];
             return Padding(
               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
               child: Card(
                 color: Colors.grey.shade200,
                 elevation: 10,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(25.0),
                 ),
                 child: ListTile(
                   title: Text(
                     productInfo.name,
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87
                     ),
                   ),
                   subtitle: productInfo.finishedEditing
                     ? productInfo.expiryDate!.isAfter(DateFormat('dd/MM/yyyy').parse(DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))))
                       ? ProductExpiryDateStatus(
                           icon: Icons.check_circle_outline_rounded,
                           expiryDate: 'Expiry Date: ${DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!)}',
                           color: Colors.green.shade600
                         )
                       : productInfo.expiryDate!.isBefore(DateFormat('dd/MM/yyyy').parse(DateFormat('dd/MM/yyyy').format(DateTime.now())))
                         ? ProductExpiryDateStatus(
                             icon: Icons.error_outline_rounded,
                             expiryDate: 'Expired On: ${DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!)}',
                             color: Colors.red.shade600
                           )
                         : ProductExpiryDateStatus(
                             icon: Icons.warning_amber_rounded,
                             expiryDate: 'Expiry Date: ${DateFormat('dd/MM/yyyy').format(productInfo.expiryDate!)}',
                             color: Colors.orange.shade600
                           )
                     : Text('Please add an expiry date for this product', style: TextStyle(color: Colors.blue.shade900)),
                   trailing: productInfo.finishedEditing
                     ? Text(
                         productInfo.quantity.toString(),
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: Colors.black
                         )
                       )
                     : IconButton(
                         icon: const Icon(Icons.edit_rounded),
                         onPressed: () {
                           showDialog(
                             context: context,
                             builder: (context) => EditProductInfoDialog(productInfo: productInfo),
                           );
                         },
                       ),
                    leading: productInfo.finishedEditing && productInfo.expiryDate!.isBefore(DateFormat('dd/MM/yyyy').parse(DateFormat('dd/MM/yyyy').format(DateTime.now())))
                      ? IconButton(
                        icon: Icon(Icons.delete_forever_rounded,
                        color: Colors.red.shade600,
                        ),
                        onPressed: () async {
                          final message = await Database.deleteProduct(docId: productInfo.docId);
                          if (message.contains('Success')) {
                            Fluttertoast.showToast(
                              msg: 'Product deleted successfully',
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        },
                      )
                      : null,
                    ),
                 ),
             );
           }
           )
      )
    );
  }
}
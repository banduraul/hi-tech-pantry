import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hi_tech_pantry/utils/database.dart';

class QuantityUpdateWidget extends StatelessWidget {
  const QuantityUpdateWidget({super.key, required this.quantity, required this.docId});

  final int quantity;
  final String docId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: quantity > 1,
          child: IconButton(
            icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.red.shade800),
            onPressed: () async {
              final message = await Database.decrementQuantity(docId: docId);
          
              if (message.contains('Success')) {
                Fluttertoast.showToast(
                  msg: 'Product quantity decreased',
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            },
          ),
        ),
        Text(
          quantity.toString(),
          style: TextStyle(
            color: quantity <= 3 ? Colors.red.shade800 : null
          )
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline_rounded, color: Colors.green.shade800),
          onPressed: () async {
            final message = await Database.incrementQuantity(docId: docId);

            if (message.contains('Success')) {
              Fluttertoast.showToast(
                msg: 'Product quantity increased',
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          },
        ),
      ],
    );
  }
}
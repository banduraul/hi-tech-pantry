import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../utils/firebase_admin.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  String mode = 'deposit';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue.shade200,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(mode.toUpperCase(), style: Theme.of(context).textTheme.displayLarge),
                  ),
                  SizedBox(
                    width: 600.0,
                    child: TextFormField(
                      onFieldSubmitted: (value) async {
                        _focusNode.requestFocus();
                        _controller.clear();
                        if (value == 'Deposit/Withdraw') {
                          setState(() {
                            if (mode == 'deposit') {
                              mode = 'withdraw';
                            } else {
                              mode = 'deposit';
                            }
                          });
                        } else {
                          if (mode == 'deposit') {
                            final (result, title) = await FirebaseAdmin.addProduct(eancode: value);
                            if(!context.mounted) {
                              return;
                            }
                            if (result.contains('Success')) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('You have successfully deposited $title'),
                                duration: const Duration(seconds: 1),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result),
                                duration: const Duration(seconds: 1),
                              ));
                            }
                          } else {
                            final (result, title) = await FirebaseAdmin.removeProduct(eancode: value);
                            if (result.contains('Success')) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('You have successfully withdrawn $title'),
                                duration: const Duration(seconds: 1),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result),
                                duration: const Duration(seconds: 1),
                              ));
                            }
                          }
                        }
                      },
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Product Barcode',
                        hintText: 'Product Barcode',
                        alignLabelWithHint: false,
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        prefixIcon: const Icon(CupertinoIcons.barcode, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                      children: <TextSpan> [
                        const TextSpan(text: 'Scan the barcode of a product you want to '),
                        mode == 'deposit'
                        ? const TextSpan(text: 'deposit')
                        : const TextSpan(text: 'withdraw')
                      ]
                    )
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blue.shade300,
              child: const Center(
                child: Image(
                  image: AssetImage('lib/assets/icon.png'),
                  width: 300,
                  height: 300,
                ),
              )
            )
          )
        ],
      ),
    );
  }
}
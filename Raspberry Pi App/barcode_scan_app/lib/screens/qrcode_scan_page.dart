import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'barcode_scan_page.dart';

import '../utils/firebase_admin.dart';

class QrcodeScanPage extends StatefulWidget {
  const QrcodeScanPage({super.key});

  @override
  State<QrcodeScanPage> createState() => _QrcodeScanPageState();
}

class _QrcodeScanPageState extends State<QrcodeScanPage> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  String data = '';
  bool validQrCode = false;

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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Text('Hi-Tech Pantry', style: Theme.of(context).textTheme.displayLarge),
                  ),
                  SizedBox(
                    width: 600.0,
                    child: TextFormField(
                      onFieldSubmitted: (value) async {
                        final result = await FirebaseAdmin.getUid(email: value);
                        if(!context.mounted) {
                          return;
                        }
                        if (result.contains('Success')) {
                          setState(() {
                            validQrCode = true;
                            data = value;
                          });
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const BarcodeScanPage()
                                )
                              );
                            }
                          });
                        } else {
                          _focusNode.requestFocus();
                          _controller.clear();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result),
                            duration: const Duration(milliseconds: 1500),
                          ));
                        }
                      },
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'QR Code',
                        hintText: 'QR Code',
                        alignLabelWithHint: false,
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        prefixIcon: const Icon(Icons.qr_code_2_rounded, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Scan the QR Code from the Mobile App',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blue.shade300,
              child: Center(
                child:
                  !validQrCode
                  ? SizedBox(
                      width: 150.0,
                      height: 150.0,
                      child: CircularProgressIndicator(color: Colors.blue.shade900)
                    )
                  : QrImageView(
                      data: data,
                      version: QrVersions.auto,
                      size: 200.0,
                    )
                ),
            )
            )
        ],
      ),
    );
  }
}
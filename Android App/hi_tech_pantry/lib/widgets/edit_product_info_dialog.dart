import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

import '../data_classes/product_info.dart';

class EditProductInfoDialog extends StatefulWidget {
  const EditProductInfoDialog({super.key, required this.productInfo});

  final ProductInfo productInfo;

  @override
  State<EditProductInfoDialog> createState() => _EditProductInfoDialogState();
}

class _EditProductInfoDialogState extends State<EditProductInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expiryDateController = TextEditingController();

  final _focusName = FocusNode();
  final _focusQuantity = FocusNode();

  bool _isProcessing = false;
  bool doesItHaveExpiryDate = false;

  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.productInfo.quantity;
    _nameController.text = widget.productInfo.name;
    _quantityController.text = _quantity.toString();
    if (widget.productInfo.expiryDate != null) {
      doesItHaveExpiryDate = true;
      _expiryDateController.text = DateFormat('dd/MM/yyyy').format(widget.productInfo.expiryDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      title: Column(
        children: [
          Text(
            'Edit Product Info',
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
          ),
          if (widget.productInfo.name.isEmpty)
            Text(
              'EAN Code: ${widget.productInfo.eancode}',
              style: TextStyle(color: Colors.blue),
            ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          height: 310,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name',
                    prefixIcon: const Icon(Icons.abc_rounded, size: 24),  
                  ),
                  controller: _nameController,
                  validator: (value) => Validator.validateName(name: value),
                  focusNode: _focusName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Quantity',
                    prefixIcon: const Icon(Icons.numbers_rounded, size: 24),
                  ),
                  controller: _quantityController,
                  validator: (value) => Validator.validateQuantity(quantity: value),
                  focusNode: _focusQuantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: doesItHaveExpiryDate,
                      onChanged: (value) {
                        setState(() {
                          doesItHaveExpiryDate = value!;
                          if (!doesItHaveExpiryDate) {
                            _expiryDateController.clear();
                          }
                        });
                      }
                    ),
                    Text('Expiry Date', style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: doesItHaveExpiryDate ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                TextFormField(
                  enabled: doesItHaveExpiryDate,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'Expiry Date',
                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 24),
                  ),
                  controller: _expiryDateController,
                  readOnly: true,
                  validator: (value) => doesItHaveExpiryDate ? Validator.validateExpiryDate(expiryDate: value) : null,
                  onTap: () async {
                    DateTime? expiryDate = await showDatePicker(
                      context: context,
                      initialDate: widget.productInfo.expiryDate != null ? DateTime.now() : null,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2040),
                    );

                    if (expiryDate != null) {
                      setState(() {
                        _expiryDateController.text = DateFormat('dd/MM/yyyy').format(expiryDate);
                      });
                    }
                  },
                ),
                const Spacer(),
                _isProcessing
                  ? CircularProgressIndicator(color: Colors.blue.shade700)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isProcessing = true;
                          });

                          final message = await Database.updateProductInfo(
                            productInfo: ProductInfo(
                              docId: widget.productInfo.docId,
                              eancode: widget.productInfo.eancode,
                              name: _nameController.text,
                              finishedEditing: true,
                              isExpired: widget.productInfo.expiryDate != null ? _expiryDateController.text == DateFormat('dd/MM/yyyy').format(widget.productInfo.expiryDate!) ? widget.productInfo.isExpired : false : false,
                              quantity: int.parse(_quantityController.text),
                              expiryDate: _expiryDateController.text.isNotEmpty ? DateFormat('dd/MM/yyyy').parse(_expiryDateController.text) : null,
                            )
                          );
                          setState(() {
                            _isProcessing = false;
                          });
                          if (message.contains('Success')) {
                            Fluttertoast.showToast(
                              msg: 'Product info updated successfully',
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            if (context.mounted) {
                              context.pop();
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Failed to update product info. Please try again',
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        }
                      },
                      child: const Text('Update'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
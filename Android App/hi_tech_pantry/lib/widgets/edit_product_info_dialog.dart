import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';
import '../utils/app_state.dart';
import '../utils/validator.dart';

import 'image_dialog.dart';
import 'add_category_dialog.dart';
import 'categories_container.dart';

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

  final picker = ImagePicker();
  XFile? imageFile;

  final _focusName = FocusNode();
  final _focusQuantity = FocusNode();

  bool _isProcessing = false;
  bool doesItHaveExpiryDate = false;

  int _quantity = 0;

  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    _quantity = widget.productInfo.quantity;
    _nameController.text = widget.productInfo.name;
    _quantityController.text = _quantity.toString();
    selected = Set.from(widget.productInfo.categories);
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
      content: SingleChildScrollView(
        child: SizedBox(
          width: 280,
          height: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  onChanged: (value) {
                    setState(() {
                      _quantityController.value = TextEditingValue(text: _quantityController.text.replaceFirst(RegExp(r'^0+'), ''));
                    });
                  },
                  maxLength: 3,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'Quantity',
                    hintText: 'Quantity (1-999)',
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
                    Icon(Icons.category_rounded, size: 24, color: Colors.blue.shade700),
                    Text('Category:', style: TextStyle(fontSize: 18, color: Colors.blue.shade700)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.add_rounded, color: Colors.blue.shade700, size: 24),
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder:(context) => AddCategoryDialog(),
                        );

                        if (result[0] == true) {
                          setState(() {
                            selected.add(result[1]);
                          });
                        }
                      },
                    ),
                  ],
                ),
                Consumer<ApplicationState>(
                  builder: (context, appState, _) => Visibility(
                    visible: appState.productCategories.isNotEmpty,
                    child: CategoriesContainer(
                      categories: {...appState.productCategories, ...selected}.toList(),
                      selected: selected,
                      isDarkMode: isDarkMode,
                      onSelected: (category) {
                        setState(() {
                          if (selected.contains(category)) {
                            selected.remove(category);
                          } else {
                            selected.add(category);
                          }
                        });
                      },
                    ),
                  ),
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
                      barrierDismissible: false,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
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
                Row(
                  children: [
                    Text('Image:', style: TextStyle(fontSize: 18, color: Colors.blue.shade700)),
                    const SizedBox(width: 16),
                    Visibility(
                      visible: widget.productInfo.imageURL.isEmpty && imageFile == null,
                      child: Row(
                        children: [
                          Text('(Optional)', style: TextStyle(fontSize: 18, color: Colors.blue.shade700)),
                          IconButton(
                            icon: Icon(Icons.add_a_photo_rounded, color: Colors.blue.shade700, size: 20),
                            onPressed: () async {
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                preferredCameraDevice: CameraDevice.rear,
                              );
                
                              if (pickedFile != null) {
                                setState(() {
                                  imageFile = pickedFile;
                                });
                              }
                            },
                          ),
                        ],
                      )
                    ),
                    Visibility(
                      visible: widget.productInfo.imageURL.isNotEmpty || imageFile != null,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => imageFile != null ? ImageDialog(image: Image.file(File(imageFile!.path))) : ImageDialog(image: Image.network(widget.productInfo.imageURL)),
                              );
                            },
                            child: Text(
                              'See Image',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                color: Colors.blue.shade700,
                                decorationColor: Colors.blue.shade700
                              )
                            )
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.blue.shade700, size: 20),
                            onPressed: () {
                              setState(() {
                                widget.productInfo.imageURL = '';
                                imageFile = null;
                              });
                            },
                          ),
                        ],
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _isProcessing
                  ? CircularProgressIndicator(color: Colors.blue.shade700)
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                            context.pop();
                        },
                        child: Text('Cancel', style: TextStyle(fontSize: 24, color: Colors.blue.shade700)),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                            minimumSize: const Size(150, 50),
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
                                  categories: selected.toList(),
                                  imageURL: widget.productInfo.imageURL,
                                  name: _nameController.text,
                                  finishedEditing: true,
                                  isExpired: widget.productInfo.expiryDate != null ? _expiryDateController.text == DateFormat('dd/MM/yyyy').format(widget.productInfo.expiryDate!) ? widget.productInfo.isExpired : false : false,
                                  quantity: int.parse(_quantityController.text),
                                  expiryDate: _expiryDateController.text.isNotEmpty ? DateFormat('dd/MM/yyyy').parse(_expiryDateController.text) : null,
                                ),
                                image: imageFile != null ? File(imageFile!.path) : null,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
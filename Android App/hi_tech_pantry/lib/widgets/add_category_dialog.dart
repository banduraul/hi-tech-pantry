import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddCategoryDialog extends StatelessWidget {
  AddCategoryDialog({super.key});

  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      title: Text(
        'Add New Category',
        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 150,
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Category',
                    prefixIcon: const Icon(Icons.category_rounded, size: 24),
                  ),
                  controller: _categoryController,
                  validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.pop([false, null]);
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 20, color: Colors.blue.shade700)),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                          minimumSize: const Size(150, 50),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (context.mounted) {
                              context.pop([true, _categoryController.text.trim()]);
                              Fluttertoast.showToast(
                                msg: 'Category added successfully',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                          }
                        },
                        child: const Text('Add Category', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

class ChangeUsernameDialog extends StatefulWidget {
  const ChangeUsernameDialog({super.key});

  @override
  State<ChangeUsernameDialog> createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<ChangeUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  final _focusUsername = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Insert new username',
        style: TextStyle(color: Colors.blue),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          height: 150,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Username',
                    alignLabelWithHint: false,
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    prefixIcon: const Icon(Icons.person_rounded, size: 24),
                  ),
                  controller: _usernameController,
                  validator: (value) => Validator.validateUsername(username: _usernameController.text),
                  focusNode: _focusUsername,
                ),
                const Spacer(),
                _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isProcessing = true;
                          });
                          final message = await Database.updateUsername(username: _usernameController.text);
                          setState(() {
                            _isProcessing = false;
                          });
                          if (message.contains('Success')) {
                            if (context.mounted) {
                              context.pop();
                              Fluttertoast.showToast(
                                msg: 'Username changed successfully',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                          } else if (message.contains('username')) {
                            Fluttertoast.showToast(
                              msg: message,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        }
                    },
                    child: const Text('Change Username'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
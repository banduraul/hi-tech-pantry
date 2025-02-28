import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';

import '../screens/login_page.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialog();
}

class _DeleteAccountDialog extends State<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      title: Column(
        children: [
          Text(
            'This operation cannot be undone',
            style: TextStyle(color: Colors.red.shade700, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Insert password to delete account',
            style: TextStyle(color: Colors.red.shade700, fontSize: 20),
          ),
        ],
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
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                            if (_focusPassword.hasPrimaryFocus) return;
                            _focusPassword.canRequestFocus = false;
                          });
                        },
                        child: Icon(
                          _passwordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                          size: 24,
                        ),
                      ),
                    )
                  ),
                  controller: _passwordController,
                  focusNode: _focusPassword,
                ),
                const Spacer(),
                _isProcessing
                  ? CircularProgressIndicator(color: Colors.red.shade700)
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                            context.pop();
                        },
                        child: Text('Cancel', style: TextStyle(fontSize: 24, color: isDarkMode ? Colors.red.shade900 : Colors.red.shade700)),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isProcessing = true;
                              });
                              final message = await Database.reauthenticateUser(password: _passwordController.text);
                              setState(() {
                                _isProcessing = false;
                              });
                              if (message.contains('Success')) {
                                setState(() {
                                  _isProcessing = true;
                                });
                                final message = await Database.deleteAccount();
                                setState(() {
                                  _isProcessing = false;
                                });
                                if (message.contains('Success')) {
                                  Fluttertoast.showToast(
                                    msg: 'Account deleted successfully',
                                    toastLength: Toast.LENGTH_SHORT,
                                  );
                                  if (context.mounted) {
                                    context.goNamed(LoginPage.loginName);
                                  }
                                }
                              } else if (message.contains('password')) {
                                Fluttertoast.showToast(
                                  msg: message,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.red.shade900 : Colors.red.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 50),
                          ),
                          child: const Text('Delete'),
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
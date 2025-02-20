import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const String forgotPasswordName = 'forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();

  final _focusEmail = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Reset Password',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(email: _emailTextController.text),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.email_rounded, size: 24),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      _isProcessing
                        ? CircularProgressIndicator(color: Colors.blue.shade700)
                        : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isProcessing = true;
                                    });
                                    final message = await Database.sendPasswordResetLink(email: _emailTextController.text);
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    if (message != '') {
                                      if (message.contains('Success')) {
                                        Fluttertoast.showToast(
                                          msg: 'Email sent successfully',
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                        if (context.mounted) {
                                          context.pop();
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: message,
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text('Send Password Reset Link'),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
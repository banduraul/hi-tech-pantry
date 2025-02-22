import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/new_password_dialog.dart';

import '../utils/database.dart';

class ReauthenticateUserDialog extends StatefulWidget {
  const ReauthenticateUserDialog({super.key});

  @override
  State<ReauthenticateUserDialog> createState() => _ReauthenticateUserDialogState();
}

class _ReauthenticateUserDialogState extends State<ReauthenticateUserDialog> {
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
      title: Text(
        'Insert current password to continue',
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
                          final message = await Database.reauthenticateUser(password: _passwordController.text);
                          setState(() {
                            _isProcessing = false;
                          });
                          if (message.contains('Success')) {
                            if (context.mounted) {
                              context.pop();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const NewPasswordDialog();
                                },
                              );
                            }
                          } else if (message.contains('password')) {
                            Fluttertoast.showToast(
                              msg: message,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        }
                      },
                      child: const Text('Continue'),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
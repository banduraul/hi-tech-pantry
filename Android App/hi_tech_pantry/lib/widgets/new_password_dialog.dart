import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

import '../screens/login_page.dart';

class NewPasswordDialog extends StatefulWidget {
  const NewPasswordDialog({super.key});

  @override
  State<NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<NewPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  final _focusNewPassword = FocusNode();
  final _focusConfirmNewPassword = FocusNode();

  bool _isProcessing = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      title: Text(
        'Insert New Password',
        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 230,
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  obscureText: !_newPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _newPasswordVisible = !_newPasswordVisible;
                            if (_focusNewPassword.hasPrimaryFocus) return;
                            _focusNewPassword.canRequestFocus = false;
                          });
                        },
                        child: Icon(
                          _newPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                          size: 24,
                        ),
                      ),
                    )
                  ),
                  controller: _newPasswordController,
                  validator: (value) => Validator.validatePassword(password: _newPasswordController.text),
                  focusNode: _focusNewPassword,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: !_confirmNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _confirmNewPasswordVisible = !_confirmNewPasswordVisible;
                            if (_focusConfirmNewPassword.hasPrimaryFocus) return;
                            _focusConfirmNewPassword.canRequestFocus = false;
                          });
                        },
                        child: Icon(
                          _confirmNewPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                          size: 24,
                        ),
                      ),
                    )
                  ),
                  controller: _confirmNewPasswordController,
                  validator: (value) => Validator.validateConfirmPassword(password: _newPasswordController.text, confirmPassword: _confirmNewPasswordController.text),
                  focusNode: _focusConfirmNewPassword,
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
                          final message = await Database.updatePassword(newPassword: _newPasswordController.text);
                          setState(() {
                            _isProcessing = false;
                          });
                          if (message.contains('Success')) {
                            Fluttertoast.showToast(
                              msg: 'Password updated successfully',
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            final message = await Database.signOut();
                            if (message.contains('Success')) {
                              if (context.mounted) {
                                context.goNamed(LoginPage.loginName);
                              }
                            }
                          }
                        }
                      },
                      child: const Text('Change'),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
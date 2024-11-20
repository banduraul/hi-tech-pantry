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
    return AlertDialog(
      title: const Text(
        'Insert New Password',
        style: TextStyle(color: Colors.blue),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 182,
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
                    alignLabelWithHint: false,
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
                    alignLabelWithHint: false,
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        _isProcessing
        ? const CircularProgressIndicator(color: Colors.blue)
        : ElevatedButton(
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
            child: const Text(
              'Change',
              style: TextStyle(color: Colors.white),
            ),
          )
      ],
    );
  }
}
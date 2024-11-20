import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

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
    return AlertDialog(
      title: Text(
        'Insert password to delete account',
        style: TextStyle(color: Colors.red.shade700),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: TextFormField(
              obscureText: !_passwordVisible,
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
              validator: (value) => Validator.validatePassword(password: _passwordController.text),
              focusNode: _focusPassword,
            ),
          ),
        ),
      ),
      actions: [
        _isProcessing
        ? CircularProgressIndicator(color: Colors.red.shade700)
        : ElevatedButton(
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
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          )
      ],
    );
  }
}
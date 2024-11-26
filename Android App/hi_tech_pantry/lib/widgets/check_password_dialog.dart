import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/new_password_dialog.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

class CheckPasswordDialog extends StatefulWidget {
  const CheckPasswordDialog({super.key});

  @override
  State<CheckPasswordDialog> createState() => _CheckPasswordDialogState();
}

class _CheckPasswordDialogState extends State<CheckPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Insert current password to continue',
        style: TextStyle(color: Colors.blue),
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
                const Spacer(),
                _isProcessing
                  ? const CircularProgressIndicator()
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
                      child: const Text(
                        'Change',
                        style: TextStyle(color: Colors.white),
                      ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
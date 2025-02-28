import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

import '../screens/login_page.dart';

import 'password_requirements_card.dart';
import 'password_validation_indicator.dart';

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

  // Password requirements
  bool _hasDigit = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasMinLength = false;
  bool _hasSpecialCharacter = false;
  bool _allRequirementsMet = false;

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
      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      insetPadding: EdgeInsets.all(20.0),
      content: AnimatedSize(
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        child: SizedBox(
              height: _allRequirementsMet ? 230 : 280,
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      obscureText: !_newPasswordVisible,
                      onChanged: (value) {
                        setState(() {
                          _hasMinLength = value.length >= 8;
                          _hasDigit = RegExp(r'\d').hasMatch(value);
                          _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                          _hasLowercase = RegExp(r'[a-z]').hasMatch(value);
                          _hasSpecialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
            
                          _allRequirementsMet = _hasMinLength && _hasDigit && _hasUppercase && _hasLowercase && _hasSpecialCharacter;
                        });
                      },
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
                      focusNode: _focusNewPassword,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: !_allRequirementsMet 
                        ? PasswordRequirementsCard(
                          hasDigit: _hasDigit,
                          isDarkMode: isDarkMode,
                          hasMinLength: _hasMinLength,
                          hasUppercase: _hasUppercase,
                          hasLowercase: _hasLowercase,
                          hasSpecialCharacter: _hasSpecialCharacter
                        )
                        : Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
                          child: PasswordValidationIndicator(
                            text: 'All requirements met',
                            isValid: _allRequirementsMet,
                          ),
                        ),
                    ),
                    Visibility(
                      visible: _allRequirementsMet,
                      child: TextFormField(
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
                    ),
                    // const Spacer(),
                    const SizedBox(height: 20),
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
                                if (_formKey.currentState!.validate() && _allRequirementsMet) {
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
                            ),
                        ],
                      )
                  ],
                ),
              ),
            ),
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'products_page.dart';

import '../widgets/password_requirements_card.dart';
import '../widgets/password_validation_indicator.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String registerName = 'register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _usernameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();

  final _focusUsername = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  final _focusConfirmPassword = FocusNode();

  bool _isProcessing = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

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

    return GestureDetector(
      onTap: () {
        _focusUsername.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
        _focusConfirmPassword.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Create Account'),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.0, 100.0, 24.0, MediaQuery.of(context).viewInsets.bottom),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'Register',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: _usernameTextController,
                          focusNode: _focusUsername,
                          validator: (value) => Validator.validateUsername(
                              username: value,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Username',
                            prefixIcon: const Icon(Icons.person_rounded, size: 24)
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: _emailTextController,
                          focusNode: _focusEmail,
                          validator: (value) => Validator.validateEmail(
                            email: value,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email_rounded, size: 24)
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: _passwordTextController,
                          focusNode: _focusPassword,
                          obscureText: !_passwordVisible,
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
                            ),
                          ),
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
                            textCapitalization: TextCapitalization.words,
                            controller: _confirmPasswordTextController,
                            focusNode: _focusConfirmPassword,
                            obscureText: !_confirmPasswordVisible,
                            validator: (value) => Validator.validateConfirmPassword(
                              password: _passwordTextController.text,
                              confirmPassword: value,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _confirmPasswordVisible = !_confirmPasswordVisible;
                                      if (_focusConfirmPassword.hasPrimaryFocus) return;
                                      _focusConfirmPassword.canRequestFocus = false;
                                    });
                                  },
                                  child: Icon(
                                    _confirmPasswordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Colors.blue.shade700,
                                            width: 3
                                          ),
                                        ),
                                        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                                        foregroundColor: Colors.blue.shade700,
                                      ),
                                      onPressed: () async {
                                        if (_registerFormKey.currentState!.validate() && _allRequirementsMet) {
                                          setState(() {
                                            _isProcessing = true;
                                          });
                                          final isUsernameAvailable = await Database
                                              .isUsernameAvailable(
                                            username: _usernameTextController.text,
                                          );
                                          if (!isUsernameAvailable) {
                                            Fluttertoast.showToast(
                                              msg: 'Username is already taken',
                                              toastLength: Toast.LENGTH_SHORT,
                                            );
                                            setState(() {
                                              _isProcessing = false;
                                            });
                                            return;
                                          }
                                          final message = await Database
                                              .registerUsingEmailPassword(
                                            email: _emailTextController.text,
                                            password: _passwordTextController.text,
                                            username: _usernameTextController.text,
                                          );
          
                                          setState(() {
                                            _isProcessing = false;
                                          });
                                          if (message != null) {
                                            if (message.contains('Success')) {
                                              if (context.mounted) {
                                                context.goNamed(ProductsPage.productsName);
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
                                      child: const Text('Register'),
                                    ),
                                  ),
                                ],
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
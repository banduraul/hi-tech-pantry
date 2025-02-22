import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/password_validation_indicator.dart';
import 'products_page.dart';

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
  bool _passwordRequirementsVisible = false;

  // Password requirements
  bool _hasDigit = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasMinLength = false;
  bool _hasSpecialCharacter = false;
  bool _allRequirementsMet = false;

  @override
  void initState() {
    _focusPassword.addListener(() {
      setState(() {
        _passwordRequirementsVisible = _focusPassword.hasPrimaryFocus;        
      });
    });
    super.initState();
  }

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
                          onTap: () {
                            setState(() {
                              _passwordRequirementsVisible = true;
                            });
                          },
                          onTapOutside: (event) {
                            setState(() {
                              _passwordRequirementsVisible = false;
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
                        const SizedBox(height: 5.0),
                        Visibility(
                          visible: _passwordRequirementsVisible && !_allRequirementsMet,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password Requirements',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.yellow : Colors.orange),
                                  ),
                                  const SizedBox(height: 10.0),
                                  PasswordValidationIndicator(
                                    text: 'Minimum 8 characters',
                                    isValid: _hasMinLength,
                                  ),
                                  PasswordValidationIndicator(
                                    text: 'At least 1 uppercase letter',
                                    isValid: _hasUppercase,
                                  ),
                                  PasswordValidationIndicator(
                                    text: 'At least 1 lowercase letter',
                                    isValid: _hasLowercase,
                                  ),
                                  PasswordValidationIndicator(
                                    text: 'At least 1 digit',
                                    isValid: _hasDigit,
                                  ),
                                  PasswordValidationIndicator(
                                    text: 'At least 1 of the symbols: [!@#\$%^&*(),.?":{}|<>]',
                                    isValid: _hasSpecialCharacter,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _allRequirementsMet,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: PasswordValidationIndicator(
                              text: 'All requirements met',
                              isValid: _allRequirementsMet,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Visibility(
                          visible: _allRequirementsMet,
                          child: TextFormField(
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
                                        if (_registerFormKey.currentState!
                                            .validate()) {
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
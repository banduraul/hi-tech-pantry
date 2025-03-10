import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'products_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

import '../utils/database.dart';
import '../utils/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String loginName = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hi-Tech Pantry'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                        prefixIcon: const Icon(Icons.email_rounded, size: 24),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      controller: _passwordTextController,
                      focusNode: _focusPassword,
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
                    ),
                    const SizedBox(height: 24.0),
                    _isProcessing
                        ? CircularProgressIndicator(color: Colors.blue.shade700)
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                                  ),
                                  onPressed: () async {
                                    _focusEmail.unfocus();
                                    _focusPassword.unfocus();
                
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isProcessing = true;
                                      });
                
                                      final message = await Database
                                          .signInUsingEmailPassword(
                                        email: _emailTextController.text,
                                        password:
                                            _passwordTextController.text,
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
                                  child: const Text('Login'),
                                ),
                              ),
                              const SizedBox(width: 24.0),
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
                                  onPressed: () => context.pushNamed(RegisterPage.registerName),
                                  child: const Text('Register')
                                ),
                              ),
                            ],
                          ),
                      const SizedBox(height: 32.0),
                      InkWell(
                        onTap: () => context.pushNamed(ForgotPasswordPage.forgotPasswordName),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue.shade700,
                            color: Colors.blue.shade700
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        )
      ),
    );
  }
}
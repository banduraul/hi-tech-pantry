import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'home_page.dart';
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        SystemNavigator.pop();
      },
      child: GestureDetector(
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
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Email',
                          alignLabelWithHint: false,
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                          prefixIcon: const Icon(Icons.person_rounded, size: 24),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: !_passwordVisible,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
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
                      ),
                      const SizedBox(height: 24.0),
                      _isProcessing
                          ? const CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
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
                                              context.goNamed(HomePage.homeName);
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
                                        side: const BorderSide(
                                          color: Colors.blue,
                                          width: 3
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue,
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
                              decorationColor: Colors.blue.shade600,
                              color: Colors.blue.shade600
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
      ),
    );
  }
}
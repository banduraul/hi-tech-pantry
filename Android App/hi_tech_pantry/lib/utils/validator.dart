import 'package:bad_words/bad_words.dart';

class Validator {
  static String? validateName({required String? name}) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return 'Name cannot be empty';
    }

    return null;
  }

  static String? validateQuantity({required String? quantity}) {
    if (quantity == null) {
      return null;
    }

    if (quantity.isEmpty || quantity == '0') {
      return 'Quantity cannot be empty or 0';
    }

    return null;
  }

  static String? validateExpiryDate({required String? expiryDate}) {
    if (expiryDate == null) {
      return null;
    }

    if (expiryDate.isEmpty || expiryDate == '0') {
      return 'Expiry Date cannot be empty';
    }

    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email cannot be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Email address format is invalid';
    }

    return null;
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Minimum password length is 6 characters';
    }

    return null;
  }

  static String? validateConfirmPassword({required String password, required String? confirmPassword}) {
    if (confirmPassword == null) {
      return null;
    }

    if (confirmPassword.isEmpty) {
      return 'Confirm password cannot be empty';
    } else if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateUsername({required String? username}) {
    if (username == null) {
      return null;
    }

    if (username.isEmpty) {
      return 'Username cannot be empty';
    }

    if (username.length < 3 || username.length > 20) {
      return 'Username must be between 3 and 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-z0-9]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain lowercase letters, and numbers';
    }

    final filter = Filter();
    if (filter.isProfane(username)) {
      return 'Username contains inappropriate words';
    }

    return null;
  }
}
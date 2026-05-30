import 'package:flunexia_app/core/utils/validators.dart';

class AuthValidator {
  AuthValidator._();

  static String? validateLogin({String? email, String? password}) {
    return Validators.email(email) ?? Validators.password(password);
  }
}

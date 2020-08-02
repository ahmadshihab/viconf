import 'package:bubbleapp/models/user_model.dart';

import 'package:flutter/widgets.dart';
import 'package:bubbleapp/services/auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserModel _user;
  AuthMethods _authMethods = AuthMethods();

  UserModel get getUser => _user;

  Future<void> refreshUser() async {
    UserModel user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}

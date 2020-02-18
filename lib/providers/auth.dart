import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter((DateTime.now()))) return _token;
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String token) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$token?key=AIzaSyAfFsoHops6lG07m0HTirupdie5Gffjehk';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null)
        throw HttpException(responseBody['error']['message']);
      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody['expiresIn']),
        ),
      );
      _autoSignOut();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void signOut() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) _authTimer.cancel();
    notifyListeners();
  }

  void _autoSignOut() {
    if (_authTimer != null) _authTimer.cancel();
    final timeToSignOut = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToSignOut), signOut);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      preferences.setString('userData', userData);
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

  Future<bool> tryAutoSignIn() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) return false;
    final userData =
        json.decode(preferences.get('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return false;
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoSignOut();
    return true;
  }

  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) _authTimer.cancel();
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    preferences.remove('userData');
  }

  void _autoSignOut() {
    if (_authTimer != null) _authTimer.cancel();
    final timeToSignOut = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToSignOut), signOut);
  }
}

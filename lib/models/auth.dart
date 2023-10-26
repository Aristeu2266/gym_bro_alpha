// import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:gym_bro_alpha/data/store.dart';
// import 'package:gym_bro_alpha/exceptions/auth_exceptions.dart';
// import 'package:gym_bro_alpha/utils/api_key.dart' as api;
// import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  // String? _token;
  // String? _email;
  // String? _userId;
  // int? _expiresIn;
  // DateTime? _loginTime;

  // final String apiKey = api.key;

  // Future<void> _authenticate(String email, String password, String op) async {
  //   String url =
  //       'https://identitytoolkit.googleapis.com/v1/accounts:$op?key=$apiKey';

  //   final response = await http.post(
  //     Uri.parse(url),
  //     body: jsonEncode({
  //       'email': email,
  //       'password': password,
  //       'returnSecureToken': true,
  //     }),
  //   );

  //   final body = jsonDecode(response.body);

  //   if (body['error'] != null) {
  //     throw AuthException(body['error']['message']);
  //   } else {
  //     _token = body['idToken'];
  //     _email = body['email'];
  //     _userId = body['localId'];
  //     _expiresIn = int.parse(body['expiresIn']);
  //     _loginTime = DateTime.now();

  //     Store.saveMap('userData', {
  //       'token': _token,
  //       'email': _email,
  //       'userId': _userId,
  //       'expiresIn': _expiresIn,
  //       'loginTime': _loginTime!.toIso8601String(),
  //     });

  //     notifyListeners();
  //   }
  // }

  static Future<UserCredential> signIn(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signUp(String email, String password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }
}

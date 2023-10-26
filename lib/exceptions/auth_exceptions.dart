class AuthException implements Exception {
  static const Map<String, String> errors = {
    'INVALID_LOGIN_CREDENTIALS': 'Email or password provided is wrong',
    'too-many-requests': 'Too many failed login attempts!',
    'email-already-in-use': 'Email already in use',
    'weak-password': 'Password too weak',
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'An error occurred';
  }
}
final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class Validators {
  const Validators._();

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < minLength) return 'Password must be at least $minLength characters';
    return null;
  }

  static String? fullName(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Full name is required';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }
}

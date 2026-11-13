abstract final class Validators {
  static String? required(String? value, {String label = 'This field'}) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return valid ? null : 'Enter a valid email address.';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Use at least 8 characters.';
    return null;
  }

  static String? positiveNumber(String? value, {String label = 'Value'}) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return '$label must be greater than 0.';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String label = 'Value'}) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number < 0) return '$label cannot be negative.';
    return null;
  }
}

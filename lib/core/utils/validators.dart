// File: lib/core/utils/validators.dart
// Purpose: Reusable form-field validators. Final rule set is locked in Prompt 2.
// Used by: every form across features.

class Validators {
  static String? required(String? v, {String field = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
      return 'Enter a 10-digit phone number';
    }
    return null;
  }

  static String? minLength(String? v, int n, {String field = 'This field'}) {
    if (v == null || v.length < n) return '$field must be at least $n characters';
    return null;
  }

  static String? maxLength(String? v, int n, {String field = 'This field'}) {
    if (v != null && v.length > n) return '$field must be at most $n characters';
    return null;
  }

  // MPIN screens in the brief all show 4 boxes — locked to 4 digits.
  static String? mpin(String? v, {int digits = 4}) {
    if (v == null || v.length != digits) return 'Enter $digits digit MPIN';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'MPIN must be numeric';
    return null;
  }
}

/// Form and input validators.
class Validators {
  Validators._();

  /// Validate email format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  /// Validate password (min 8 chars, 1 uppercase, 1 number).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp('[A-Z]').hasMatch(value)) return 'Password harus mengandung huruf besar';
    if (!RegExp('[0-9]').hasMatch(value)) return 'Password harus mengandung angka';
    return null;
  }

  /// Validate non-empty field.
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validate phone number (Indonesian format).
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Nomor telepon tidak boleh kosong';
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');
    if (!phoneRegex.hasMatch(value)) return 'Format nomor telepon tidak valid';
    return null;
  }
}

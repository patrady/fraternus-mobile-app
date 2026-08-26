final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _otpRegExp = RegExp(r'^\d{6}$');

bool isValidEmail(String value) => _emailRegExp.hasMatch(value.trim());

bool isValidName(String value) => value.trim().length >= 2;

bool isValidPassword(String value) => value.length >= 12;

bool isValidOtpCode(String value) => _otpRegExp.hasMatch(value.trim());

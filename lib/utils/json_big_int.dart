class JsonBigInt {
  final String type;
  final String value;

  JsonBigInt(this.type, this.value);

  BigInt? _toBigInt() {
    if (type == "BigNumber") {
      return BigInt.tryParse(value.substring(2), radix: 16);
    }
    if (type == 'Int') {
      return BigInt.tryParse(value, radix: 10);
    }
    if (type == 'Double') {
      return BigInt.tryParse(value, radix: 10);
    }
    return null;
  }

  static JsonBigInt _fromJson(dynamic jsonVal) {
    if (jsonVal is int || _isNumeric(jsonVal)) {
      return JsonBigInt('Int', jsonVal.toString());
    }
    if (jsonVal is double) {
      return JsonBigInt('Double', jsonVal.toString());
    }
    return JsonBigInt(jsonVal['type'], jsonVal['hex']);
  }

  static BigInt? toBigInt(dynamic jsonVal) {
    return jsonVal != null ? _fromJson(jsonVal)._toBigInt() : null;
  }

  static bool _isNumeric(dynamic s) {
    if (s == null || s is! String) {
      return false;
    }
    return int.tryParse(s.trim(), radix: 10) != null ||
        BigInt.tryParse(s, radix: 10) != null;
  }
}

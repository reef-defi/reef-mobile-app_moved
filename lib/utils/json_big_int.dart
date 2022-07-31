class JsonBigInt {
  final String type;
  final String hex;
  JsonBigInt(this.type, this.hex);

  BigInt? _toBigInt (){
    if(type == "BigNumber") {
      return BigInt.tryParse(hex.substring(2), radix: 16);
    }
    return null;
  }

  static JsonBigInt _fromJson(dynamic jsonVal){
    return JsonBigInt(jsonVal['type'], jsonVal['hex']);
  }

  static BigInt? toBigInt(dynamic jsonVal){
    return jsonVal!=null ? _fromJson(jsonVal)._toBigInt() : null;
  }
}

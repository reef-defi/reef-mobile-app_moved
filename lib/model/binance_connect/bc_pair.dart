class BcPair {
  final String cryptoCurrency;
  final String fiatCurrency;
  final String? paymentMethod;
  final num? size;
  num? quotation;
  num? minLimit;
  num? maxLimit;

  BcPair(
      {required this.cryptoCurrency,
      required this.fiatCurrency,
      this.paymentMethod,
      this.size,
      this.quotation,
      this.minLimit,
      this.maxLimit});

  factory BcPair.fromJson(Map<String, dynamic> json) {
    return BcPair(
      cryptoCurrency: json['cryptoCurrency'],
      fiatCurrency: json['fiatCurrency'],
      paymentMethod: json['paymentMethod'],
      size: json['size'],
      quotation: json['quotation'],
      minLimit: json['minLimit'],
      maxLimit: json['maxLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cryptoCurrency': cryptoCurrency,
      'fiatCurrency': fiatCurrency,
      'paymentMethod': paymentMethod,
      'size': size,
      'quotation': quotation,
      'minLimit': minLimit,
      'maxLimit': maxLimit,
    };
  }
}

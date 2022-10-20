class BcNetwork {
  final String cryptoCurrency;
  final String name;
  final num? withdrawFee;
  final num? withdrawMax;
  final num? withdrawMin;

  BcNetwork(
      {required this.cryptoCurrency,
      required this.name,
      this.withdrawFee,
      this.withdrawMax,
      this.withdrawMin});

  factory BcNetwork.fromJson(Map<String, dynamic> json) {
    return BcNetwork(
      cryptoCurrency: json['cryptoCurrency'],
      name: json['name'],
      withdrawFee: json['withdrawFee'],
      withdrawMax: json['withdrawMax'],
      withdrawMin: json['withdrawMin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cryptoCurrency': cryptoCurrency,
      'name': name,
      'withdrawFee': withdrawFee,
      'withdrawMax': withdrawMax,
      'withdrawMin': withdrawMin,
    };
  }
}

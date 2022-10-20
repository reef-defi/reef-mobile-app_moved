class BcTradeResp {
  final String internalOrderId;
  final String address;
  final String orderId;
  final String eternalRedirectUrl;
  final bool? bindingStatus;
  final num? expiredTime;
  final String? token;

  BcTradeResp(
      {required this.internalOrderId,
      required this.address,
      required this.orderId,
      required this.eternalRedirectUrl,
      this.bindingStatus,
      this.expiredTime,
      this.token});

  factory BcTradeResp.fromJson(Map<String, dynamic> json) {
    return BcTradeResp(
      internalOrderId: json['internalOrderId'],
      address: json['address'],
      orderId: json['orderId'],
      eternalRedirectUrl: json['eternalRedirectUrl'],
      bindingStatus: json['bindingStatus'],
      expiredTime: json['expiredTime'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internalOrderId': internalOrderId,
      'address': address,
      'orderId': orderId,
      'eternalRedirectUrl': eternalRedirectUrl,
      'bindingStatus': bindingStatus,
      'expiredTime': expiredTime,
      'token': token,
    };
  }
}

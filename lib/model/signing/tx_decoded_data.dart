class TxDecodedData {
  String? chainName;
  String? genesisHash;
  String specVersion;
  String nonce;
  String? tip;
  String? lifetime;
  String? rawMethodData;
  String? methodName;
  String? args;
  String? info;

  TxDecodedData(
      {this.chainName,
      this.genesisHash,
      required this.specVersion,
      required this.nonce,
      this.tip,
      this.lifetime,
      this.rawMethodData,
      this.methodName,
      this.info});
}

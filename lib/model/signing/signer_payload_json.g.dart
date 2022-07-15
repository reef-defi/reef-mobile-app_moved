// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signer_payload_json.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SignerPayloadJSON on _SignerPayloadJSON, Store {
  late final _$addressAtom =
      Atom(name: '_SignerPayloadJSON.address', context: context);

  @override
  String get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  late final _$blockHashAtom =
      Atom(name: '_SignerPayloadJSON.blockHash', context: context);

  @override
  String get blockHash {
    _$blockHashAtom.reportRead();
    return super.blockHash;
  }

  @override
  set blockHash(String value) {
    _$blockHashAtom.reportWrite(value, super.blockHash, () {
      super.blockHash = value;
    });
  }

  late final _$blockNumberAtom =
      Atom(name: '_SignerPayloadJSON.blockNumber', context: context);

  @override
  String get blockNumber {
    _$blockNumberAtom.reportRead();
    return super.blockNumber;
  }

  @override
  set blockNumber(String value) {
    _$blockNumberAtom.reportWrite(value, super.blockNumber, () {
      super.blockNumber = value;
    });
  }

  late final _$eraAtom = Atom(name: '_SignerPayloadJSON.era', context: context);

  @override
  String get era {
    _$eraAtom.reportRead();
    return super.era;
  }

  @override
  set era(String value) {
    _$eraAtom.reportWrite(value, super.era, () {
      super.era = value;
    });
  }

  late final _$genesisHashAtom =
      Atom(name: '_SignerPayloadJSON.genesisHash', context: context);

  @override
  String get genesisHash {
    _$genesisHashAtom.reportRead();
    return super.genesisHash;
  }

  @override
  set genesisHash(String value) {
    _$genesisHashAtom.reportWrite(value, super.genesisHash, () {
      super.genesisHash = value;
    });
  }

  late final _$methodAtom =
      Atom(name: '_SignerPayloadJSON.method', context: context);

  @override
  String get method {
    _$methodAtom.reportRead();
    return super.method;
  }

  @override
  set method(String value) {
    _$methodAtom.reportWrite(value, super.method, () {
      super.method = value;
    });
  }

  late final _$nonceAtom =
      Atom(name: '_SignerPayloadJSON.nonce', context: context);

  @override
  String get nonce {
    _$nonceAtom.reportRead();
    return super.nonce;
  }

  @override
  set nonce(String value) {
    _$nonceAtom.reportWrite(value, super.nonce, () {
      super.nonce = value;
    });
  }

  late final _$specVersionAtom =
      Atom(name: '_SignerPayloadJSON.specVersion', context: context);

  @override
  String get specVersion {
    _$specVersionAtom.reportRead();
    return super.specVersion;
  }

  @override
  set specVersion(String value) {
    _$specVersionAtom.reportWrite(value, super.specVersion, () {
      super.specVersion = value;
    });
  }

  late final _$tipAtom = Atom(name: '_SignerPayloadJSON.tip', context: context);

  @override
  String get tip {
    _$tipAtom.reportRead();
    return super.tip;
  }

  @override
  set tip(String value) {
    _$tipAtom.reportWrite(value, super.tip, () {
      super.tip = value;
    });
  }

  late final _$transactionVersionAtom =
      Atom(name: '_SignerPayloadJSON.transactionVersion', context: context);

  @override
  String get transactionVersion {
    _$transactionVersionAtom.reportRead();
    return super.transactionVersion;
  }

  @override
  set transactionVersion(String value) {
    _$transactionVersionAtom.reportWrite(value, super.transactionVersion, () {
      super.transactionVersion = value;
    });
  }

  late final _$signedExtensionsAtom =
      Atom(name: '_SignerPayloadJSON.signedExtensions', context: context);

  @override
  List<String> get signedExtensions {
    _$signedExtensionsAtom.reportRead();
    return super.signedExtensions;
  }

  @override
  set signedExtensions(List<String> value) {
    _$signedExtensionsAtom.reportWrite(value, super.signedExtensions, () {
      super.signedExtensions = value;
    });
  }

  late final _$versionAtom =
      Atom(name: '_SignerPayloadJSON.version', context: context);

  @override
  int get version {
    _$versionAtom.reportRead();
    return super.version;
  }

  @override
  set version(int value) {
    _$versionAtom.reportWrite(value, super.version, () {
      super.version = value;
    });
  }

  @override
  String toString() {
    return '''
address: ${address},
blockHash: ${blockHash},
blockNumber: ${blockNumber},
era: ${era},
genesisHash: ${genesisHash},
method: ${method},
nonce: ${nonce},
specVersion: ${specVersion},
tip: ${tip},
transactionVersion: ${transactionVersion},
signedExtensions: ${signedExtensions},
version: ${version}
    ''';
  }
}

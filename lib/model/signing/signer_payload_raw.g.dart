// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signer_payload_raw.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SignerPayloadRaw on _SignerPayloadRaw, Store {
  late final _$addressAtom =
      Atom(name: '_SignerPayloadRaw.address', context: context);

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

  late final _$dataAtom =
      Atom(name: '_SignerPayloadRaw.data', context: context);

  @override
  String get data {
    _$dataAtom.reportRead();
    return super.data;
  }

  @override
  set data(String value) {
    _$dataAtom.reportWrite(value, super.data, () {
      super.data = value;
    });
  }

  late final _$typeAtom =
      Atom(name: '_SignerPayloadRaw.type', context: context);

  @override
  String get type {
    _$typeAtom.reportRead();
    return super.type;
  }

  @override
  set type(String value) {
    _$typeAtom.reportWrite(value, super.type, () {
      super.type = value;
    });
  }

  @override
  String toString() {
    return '''
address: ${address},
data: ${data},
type: ${type}
    ''';
  }
}

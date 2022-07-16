// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_request.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SignatureRequest on _SignatureRequest, Store {
  late final _$signatureIdentAtom =
      Atom(name: '_SignatureRequest.signatureIdent', context: context);

  @override
  String get signatureIdent {
    _$signatureIdentAtom.reportRead();
    return super.signatureIdent;
  }

  @override
  set signatureIdent(String value) {
    _$signatureIdentAtom.reportWrite(value, super.signatureIdent, () {
      super.signatureIdent = value;
    });
  }

  late final _$payloadAtom =
      Atom(name: '_SignatureRequest.payload', context: context);

  @override
  dynamic get payload {
    _$payloadAtom.reportRead();
    return super.payload;
  }

  @override
  set payload(dynamic value) {
    _$payloadAtom.reportWrite(value, super.payload, () {
      super.payload = value;
    });
  }

  @override
  String toString() {
    return '''
signatureIdent: ${signatureIdent},
payload: ${payload}
    ''';
  }
}

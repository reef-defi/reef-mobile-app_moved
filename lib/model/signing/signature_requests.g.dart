// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_requests.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SignatureRequests on _SignatureRequests, Store {
  late final _$sigRequestsAtom =
      Atom(name: '_SignatureRequests.sigRequests', context: context);

  @override
  ObservableList<dynamic> get sigRequests {
    _$sigRequestsAtom.reportRead();
    return super.sigRequests;
  }

  @override
  set sigRequests(ObservableList<dynamic> value) {
    _$sigRequestsAtom.reportWrite(value, super.sigRequests, () {
      super.sigRequests = value;
    });
  }

  late final _$_SignatureRequestsActionController =
      ActionController(name: '_SignatureRequests', context: context);

  @override
  void add(dynamic sigRequest) {
    final _$actionInfo = _$_SignatureRequestsActionController.startAction(
        name: '_SignatureRequests.addSignatureRequest');
    try {
      return super.add(sigRequest);
    } finally {
      _$_SignatureRequestsActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sigRequests: ${sigRequests}
    ''';
  }
}

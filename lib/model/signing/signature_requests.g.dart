// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_requests.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SignatureRequests on _SignatureRequests, Store {
  late final _$listAtom =
      Atom(name: '_SignatureRequests.list', context: context);

  @override
  ObservableList<SignatureRequest> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ObservableList<SignatureRequest> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  late final _$_SignatureRequestsActionController =
      ActionController(name: '_SignatureRequests', context: context);

  @override
  void add(SignatureRequest sigRequest) {
    final _$actionInfo = _$_SignatureRequestsActionController.startAction(
        name: '_SignatureRequests.add');
    try {
      return super.add(sigRequest);
    } finally {
      _$_SignatureRequestsActionController.endAction(_$actionInfo);
    }
  }

  @override
  void remove(String sigRequestIdent) {
    final _$actionInfo = _$_SignatureRequestsActionController.startAction(
        name: '_SignatureRequests.remove');
    try {
      return super.remove(sigRequestIdent);
    } finally {
      _$_SignatureRequestsActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
list: ${list}
    ''';
  }
}

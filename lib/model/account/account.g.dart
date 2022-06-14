// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Account on _Account, Store {
  late final _$selectedSignerAtom =
      Atom(name: '_Account.selectedSigner', context: context);

  @override
  ReefSigner? get selectedSigner {
    _$selectedSignerAtom.reportRead();
    return super.selectedSigner;
  }

  @override
  set selectedSigner(ReefSigner? value) {
    _$selectedSignerAtom.reportWrite(value, super.selectedSigner, () {
      super.selectedSigner = value;
    });
  }

  late final _$_AccountActionController =
      ActionController(name: '_Account', context: context);

  @override
  void setSelectedSigner(ReefSigner signer) {
    final _$actionInfo = _$_AccountActionController.startAction(
        name: '_Account.setSelectedSigner');
    try {
      return super.setSelectedSigner(signer);
    } finally {
      _$_AccountActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedSigner: ${selectedSigner}
    ''';
  }
}

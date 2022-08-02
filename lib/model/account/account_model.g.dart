// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AccountModel on _AccountModel, Store {
  late final _$selectedAddressAtom =
      Atom(name: '_AccountModel.selectedAddress', context: context);

  @override
  String? get selectedAddress {
    _$selectedAddressAtom.reportRead();
    return super.selectedAddress;
  }

  @override
  set selectedAddress(String? value) {
    _$selectedAddressAtom.reportWrite(value, super.selectedAddress, () {
      super.selectedAddress = value;
    });
  }

  late final _$signersAtom =
      Atom(name: '_AccountModel.signers', context: context);

  @override
  ObservableList<ReefSigner> get signers {
    _$signersAtom.reportRead();
    return super.signers;
  }

  @override
  set signers(ObservableList<ReefSigner> value) {
    _$signersAtom.reportWrite(value, super.signers, () {
      super.signers = value;
    });
  }

  late final _$loadingSignersAtom =
      Atom(name: '_AccountModel.loadingSigners', context: context);

  @override
  bool get loadingSigners {
    _$loadingSignersAtom.reportRead();
    return super.loadingSigners;
  }

  @override
  set loadingSigners(bool value) {
    _$loadingSignersAtom.reportWrite(value, super.loadingSigners, () {
      super.loadingSigners = value;
    });
  }

  late final _$_AccountModelActionController =
      ActionController(name: '_AccountModel', context: context);

  @override
  void setLoadingSigners(bool val) {
    final _$actionInfo = _$_AccountModelActionController.startAction(
        name: '_AccountModel.setLoadingSigners');
    try {
      return super.setLoadingSigners(val);
    } finally {
      _$_AccountModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedAddress(String addr) {
    final _$actionInfo = _$_AccountModelActionController.startAction(
        name: '_AccountModel.setSelectedAddress');
    try {
      return super.setSelectedAddress(addr);
    } finally {
      _$_AccountModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSigners(List<ReefSigner> signers) {
    final _$actionInfo = _$_AccountModelActionController.startAction(
        name: '_AccountModel.setSigners');
    try {
      return super.setSigners(signers);
    } finally {
      _$_AccountModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedAddress: ${selectedAddress},
signers: ${signers},
loadingSigners: ${loadingSigners}
    ''';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AccountModel on _AccountModel, Store {
  Computed<List<ReefAccount>>? _$accountsListComputed;

  @override
  List<ReefAccount> get accountsList => (_$accountsListComputed ??=
          Computed<List<ReefAccount>>(() => super.accountsList,
              name: '_AccountModel.accountsList'))
      .value;

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

  late final _$accountsFDMAtom =
      Atom(name: '_AccountModel.accountsFDM', context: context);

  @override
  StatusDataObject<List<StatusDataObject<ReefAccount>>> get accountsFDM {
    _$accountsFDMAtom.reportRead();
    return super.accountsFDM;
  }

  @override
  set accountsFDM(StatusDataObject<List<StatusDataObject<ReefAccount>>> value) {
    _$accountsFDMAtom.reportWrite(value, super.accountsFDM, () {
      super.accountsFDM = value;
    });
  }

  late final _$_AccountModelActionController =
      ActionController(name: '_AccountModel', context: context);

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
  void setAccountsFDM(
      StatusDataObject<List<StatusDataObject<ReefAccount>>> accounts) {
    final _$actionInfo = _$_AccountModelActionController.startAction(
        name: '_AccountModel.setAccountsFDM');
    try {
      return super.setAccountsFDM(accounts);
    } finally {
      _$_AccountModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedAddress: ${selectedAddress},
accountsFDM: ${accountsFDM},
accountsList: ${accountsList}
    ''';
  }
}

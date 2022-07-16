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

  late final _$signersAtom = Atom(name: '_Account.signers', context: context);

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
      Atom(name: '_Account.loadingSigners', context: context);

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

  late final _$_AccountActionController =
      ActionController(name: '_Account', context: context);

  @override
  void setLoadingSigners(bool val) {
    final _$actionInfo = _$_AccountActionController.startAction(
        name: '_Account.setLoadingSigners');
    try {
      return super.setLoadingSigners(val);
    } finally {
      _$_AccountActionController.endAction(_$actionInfo);
    }
  }

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
  void setSigners(List<ReefSigner> signers) {
    final _$actionInfo =
        _$_AccountActionController.startAction(name: '_Account.setSigners');
    try {
      return super.setSigners(signers);
    } finally {
      _$_AccountActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedSigner: ${selectedSigner},
signers: ${signers},
loadingSigners: ${loadingSigners}
    ''';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenModel on _TokenModel, Store {
  Computed<List<TokenWithAmount>>? _$selectedErc20ListComputed;

  @override
  List<TokenWithAmount> get selectedErc20List =>
      (_$selectedErc20ListComputed ??= Computed<List<TokenWithAmount>>(
              () => super.selectedErc20List,
              name: '_TokenModel.selectedErc20List'))
          .value;
  Computed<List<TokenNFT>>? _$selectedNFTListComputed;

  @override
  List<TokenNFT> get selectedNFTList => (_$selectedNFTListComputed ??=
          Computed<List<TokenNFT>>(() => super.selectedNFTList,
              name: '_TokenModel.selectedNFTList'))
      .value;

  late final _$selectedErc20sAtom =
      Atom(name: '_TokenModel.selectedErc20s', context: context);

  @override
  StatusDataObject<List<StatusDataObject<TokenWithAmount>>> get selectedErc20s {
    _$selectedErc20sAtom.reportRead();
    return super.selectedErc20s;
  }

  @override
  set selectedErc20s(
      StatusDataObject<List<StatusDataObject<TokenWithAmount>>> value) {
    _$selectedErc20sAtom.reportWrite(value, super.selectedErc20s, () {
      super.selectedErc20s = value;
    });
  }

  late final _$selectedNFTsAtom =
      Atom(name: '_TokenModel.selectedNFTs', context: context);

  @override
  StatusDataObject<List<StatusDataObject<TokenNFT>>> get selectedNFTs {
    _$selectedNFTsAtom.reportRead();
    return super.selectedNFTs;
  }

  @override
  set selectedNFTs(StatusDataObject<List<StatusDataObject<TokenNFT>>> value) {
    _$selectedNFTsAtom.reportWrite(value, super.selectedNFTs, () {
      super.selectedNFTs = value;
    });
  }

  late final _$txHistoryAtom =
      Atom(name: '_TokenModel.txHistory', context: context);

  @override
  StatusDataObject<List<TokenActivity>> get txHistory {
    _$txHistoryAtom.reportRead();
    return super.txHistory;
  }

  @override
  set txHistory(StatusDataObject<List<TokenActivity>> value) {
    _$txHistoryAtom.reportWrite(value, super.txHistory, () {
      super.txHistory = value;
    });
  }

  late final _$reefPriceAtom =
      Atom(name: '_TokenModel.reefPrice', context: context);

  @override
  double? get reefPrice {
    _$reefPriceAtom.reportRead();
    return super.reefPrice;
  }

  @override
  set reefPrice(double? value) {
    _$reefPriceAtom.reportWrite(value, super.reefPrice, () {
      super.reefPrice = value;
    });
  }

  late final _$_TokenModelActionController =
      ActionController(name: '_TokenModel', context: context);

  @override
  void setSelectedErc20s(
      StatusDataObject<List<StatusDataObject<TokenWithAmount>>> tknsFdm) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setSelectedErc20s');
    try {
      return super.setSelectedErc20s(tknsFdm);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedNFTs(
      StatusDataObject<List<StatusDataObject<TokenNFT>>> tknsFdm) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setSelectedNFTs');
    try {
      return super.setSelectedNFTs(tknsFdm);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTxHistory(StatusDataObject<List<TokenActivity>> historyFdm) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setTxHistory');
    try {
      return super.setTxHistory(historyFdm);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReefPrice(double value) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setReefPrice');
    try {
      return super.setReefPrice(value);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedErc20s: ${selectedErc20s},
selectedNFTs: ${selectedNFTs},
txHistory: ${txHistory},
reefPrice: ${reefPrice},
selectedErc20List: ${selectedErc20List},
selectedNFTList: ${selectedNFTList}
    ''';
  }
}

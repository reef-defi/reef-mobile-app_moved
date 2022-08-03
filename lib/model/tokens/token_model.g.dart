// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenModel on _TokenModel, Store {
  Computed<TokenWithAmount>? _$reefTokenComputed;

  @override
  TokenWithAmount get reefToken =>
      (_$reefTokenComputed ??= Computed<TokenWithAmount>(() => super.reefToken,
              name: '_TokenModel.reefToken'))
          .value;

  late final _$selectedSignerTokensAtom =
      Atom(name: '_TokenModel.selectedSignerTokens', context: context);

  @override
  ObservableList<TokenWithAmount> get selectedSignerTokens {
    _$selectedSignerTokensAtom.reportRead();
    return super.selectedSignerTokens;
  }

  @override
  set selectedSignerTokens(ObservableList<TokenWithAmount> value) {
    _$selectedSignerTokensAtom.reportWrite(value, super.selectedSignerTokens,
        () {
      super.selectedSignerTokens = value;
    });
  }

  late final _$tokenListAtom =
      Atom(name: '_TokenModel.tokenList', context: context);

  @override
  ObservableList<TokenWithAmount> get tokenList {
    _$tokenListAtom.reportRead();
    return super.tokenList;
  }

  @override
  set tokenList(ObservableList<TokenWithAmount> value) {
    _$tokenListAtom.reportWrite(value, super.tokenList, () {
      super.tokenList = value;
    });
  }

  late final _$selectedSignerNFTsAtom =
      Atom(name: '_TokenModel.selectedSignerNFTs', context: context);

  @override
  ObservableList<TokenNFT> get selectedSignerNFTs {
    _$selectedSignerNFTsAtom.reportRead();
    return super.selectedSignerNFTs;
  }

  @override
  set selectedSignerNFTs(ObservableList<TokenNFT> value) {
    _$selectedSignerNFTsAtom.reportWrite(value, super.selectedSignerNFTs, () {
      super.selectedSignerNFTs = value;
    });
  }

  late final _$activityAtom =
      Atom(name: '_TokenModel.activity', context: context);

  @override
  ObservableList<TokenActivity> get activity {
    _$activityAtom.reportRead();
    return super.activity;
  }

  @override
  set activity(ObservableList<TokenActivity> value) {
    _$activityAtom.reportWrite(value, super.activity, () {
      super.activity = value;
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
  void setSelectedSignerTokens(List<TokenWithAmount> tkns) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setSelectedSignerTokens');
    try {
      return super.setSelectedSignerTokens(tkns);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTokenList(List<TokenWithAmount> tkns) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setTokenList');
    try {
      return super.setTokenList(tkns);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedSignerNFTs(List<TokenNFT> tkns) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setSelectedSignerNFTs');
    try {
      return super.setSelectedSignerNFTs(tkns);
    } finally {
      _$_TokenModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTokenActivity(List<TokenActivity> items) {
    final _$actionInfo = _$_TokenModelActionController.startAction(
        name: '_TokenModel.setTokenActivity');
    try {
      return super.setTokenActivity(items);
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
selectedSignerTokens: ${selectedSignerTokens},
tokenList: ${tokenList},
selectedSignerNFTs: ${selectedSignerNFTs},
activity: ${activity},
reefPrice: ${reefPrice},
reefToken: ${reefToken}
    ''';
  }
}

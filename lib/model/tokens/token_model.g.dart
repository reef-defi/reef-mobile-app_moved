// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenModel on _TokenModel, Store {
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
  String toString() {
    return '''
selectedSignerTokens: ${selectedSignerTokens}
    ''';
  }
}
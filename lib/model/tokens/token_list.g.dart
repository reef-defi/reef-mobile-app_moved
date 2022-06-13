// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_list.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenList on _TokenList, Store {
  late final _$tokensAtom = Atom(name: '_TokenList.tokens', context: context);

  @override
  ObservableList<Token> get tokens {
    _$tokensAtom.reportRead();
    return super.tokens;
  }

  @override
  set tokens(ObservableList<Token> value) {
    _$tokensAtom.reportWrite(value, super.tokens, () {
      super.tokens = value;
    });
  }

  late final _$_TokenListActionController =
      ActionController(name: '_TokenList', context: context);

  @override
  void setTokens(List<Token> tkns) {
    final _$actionInfo =
        _$_TokenListActionController.startAction(name: '_TokenList.setTokens');
    try {
      return super.setTokens(tkns);
    } finally {
      _$_TokenListActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
tokens: ${tokens}
    ''';
  }
}

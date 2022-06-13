// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Token on _Token, Store {
  late final _$symbolAtom = Atom(name: '_Token.symbol', context: context);

  @override
  String get symbol {
    _$symbolAtom.reportRead();
    return super.symbol;
  }

  @override
  set symbol(String value) {
    _$symbolAtom.reportWrite(value, super.symbol, () {
      super.symbol = value;
    });
  }

  @override
  String toString() {
    return '''
symbol: ${symbol}
    ''';
  }
}

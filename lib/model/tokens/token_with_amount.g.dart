// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_with_amount.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenWithAmount on _TokenWithAmount, Store {
  late final _$addressAtom =
      Atom(name: '_TokenWithAmount.address', context: context);

  @override
  String get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  late final _$amountAtom =
      Atom(name: '_TokenWithAmount.amount', context: context);

  @override
  String get amount {
    _$amountAtom.reportRead();
    return super.amount;
  }

  @override
  set amount(String value) {
    _$amountAtom.reportWrite(value, super.amount, () {
      super.amount = value;
    });
  }

  late final _$decimalsAtom =
      Atom(name: '_TokenWithAmount.decimals', context: context);

  @override
  int get decimals {
    _$decimalsAtom.reportRead();
    return super.decimals;
  }

  @override
  set decimals(int value) {
    _$decimalsAtom.reportWrite(value, super.decimals, () {
      super.decimals = value;
    });
  }

  @override
  String toString() {
    return '''
address: ${address},
amount: ${amount},
decimals: ${decimals}
    ''';
  }
}

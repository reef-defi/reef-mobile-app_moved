// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_balance.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BalanceModel on _BalanceModel, Store {
  late final _$displayBalanceAtom =
      Atom(name: '_BalanceModel.displayBalance', context: context);

  @override
  bool get displayBalance {
    _$displayBalanceAtom.reportRead();
    return super.displayBalance;
  }

  @override
  set displayBalance(bool value) {
    _$displayBalanceAtom.reportWrite(value, super.displayBalance, () {
      super.displayBalance = value;
    });
  }

  late final _$_BalanceModelActionController =
      ActionController(name: '_BalanceModel', context: context);

  @override
  void toggle() {
    final _$actionInfo = _$_BalanceModelActionController.startAction(
        name: '_BalanceModel.toggle');
    try {
      return super.toggle();
    } finally {
      _$_BalanceModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
displayBalance: ${displayBalance}
    ''';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppConfigModel on _AppConfigModel, Store {
  late final _$displayBalanceAtom =
      Atom(name: '_AppConfigModel.displayBalance', context: context);

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

  late final _$navigateOnAccountSwitchAtom =
      Atom(name: '_AppConfigModel.navigateOnAccountSwitch', context: context);

  @override
  bool get navigateOnAccountSwitch {
    _$navigateOnAccountSwitchAtom.reportRead();
    return super.navigateOnAccountSwitch;
  }

  @override
  set navigateOnAccountSwitch(bool value) {
    _$navigateOnAccountSwitchAtom
        .reportWrite(value, super.navigateOnAccountSwitch, () {
      super.navigateOnAccountSwitch = value;
    });
  }

  late final _$isBiometricAuthEnabledAtom =
      Atom(name: '_AppConfigModel.isBiometricAuthEnabled', context: context);

  @override
  bool get isBiometricAuthEnabled {
    _$isBiometricAuthEnabledAtom.reportRead();
    return super.isBiometricAuthEnabled;
  }

  @override
  set isBiometricAuthEnabled(bool value) {
    _$isBiometricAuthEnabledAtom
        .reportWrite(value, super.isBiometricAuthEnabled, () {
      super.isBiometricAuthEnabled = value;
    });
  }

  late final _$_AppConfigModelActionController =
      ActionController(name: '_AppConfigModel', context: context);

  @override
  void setDisplayBalance(bool val) {
    final _$actionInfo = _$_AppConfigModelActionController.startAction(
        name: '_AppConfigModel.setDisplayBalance');
    try {
      return super.setDisplayBalance(val);
    } finally {
      _$_AppConfigModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNavigateOnAccountSwitch(bool val) {
    final _$actionInfo = _$_AppConfigModelActionController.startAction(
        name: '_AppConfigModel.setNavigateOnAccountSwitch');
    try {
      return super.setNavigateOnAccountSwitch(val);
    } finally {
      _$_AppConfigModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBiometricAuthentication(bool val) {
    final _$actionInfo = _$_AppConfigModelActionController.startAction(
        name: '_AppConfigModel.setBiometricAuthentication');
    try {
      return super.setBiometricAuthentication(val);
    } finally {
      _$_AppConfigModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
displayBalance: ${displayBalance},
navigateOnAccountSwitch: ${navigateOnAccountSwitch},
isBiometricAuthEnabled: ${isBiometricAuthEnabled}
    ''';
  }
}

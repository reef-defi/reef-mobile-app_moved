// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NetworkModel on _NetworkModel, Store {
  late final _$selectedNetworkSwitchingAtom =
      Atom(name: '_NetworkModel.selectedNetworkSwitching', context: context);

  @override
  bool get selectedNetworkSwitching {
    _$selectedNetworkSwitchingAtom.reportRead();
    return super.selectedNetworkSwitching;
  }

  @override
  set selectedNetworkSwitching(bool value) {
    _$selectedNetworkSwitchingAtom
        .reportWrite(value, super.selectedNetworkSwitching, () {
      super.selectedNetworkSwitching = value;
    });
  }

  late final _$selectedNetworkNameAtom =
      Atom(name: '_NetworkModel.selectedNetworkName', context: context);

  @override
  String? get selectedNetworkName {
    _$selectedNetworkNameAtom.reportRead();
    return super.selectedNetworkName;
  }

  @override
  set selectedNetworkName(String? value) {
    _$selectedNetworkNameAtom.reportWrite(value, super.selectedNetworkName, () {
      super.selectedNetworkName = value;
    });
  }

  late final _$_NetworkModelActionController =
      ActionController(name: '_NetworkModel', context: context);

  @override
  void setSelectedNetworkSwitching(bool val) {
    final _$actionInfo = _$_NetworkModelActionController.startAction(
        name: '_NetworkModel.setSelectedNetworkSwitching');
    try {
      return super.setSelectedNetworkSwitching(val);
    } finally {
      _$_NetworkModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedNetworkName(String network) {
    final _$actionInfo = _$_NetworkModelActionController.startAction(
        name: '_NetworkModel.setSelectedNetworkName');
    try {
      return super.setSelectedNetworkName(network);
    } finally {
      _$_NetworkModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedNetworkSwitching: ${selectedNetworkSwitching},
selectedNetworkName: ${selectedNetworkName}
    ''';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homepage_navigation_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomePageNavigationModel on _HomePageNavigationModel, Store {
  late final _$currentIndexAtom =
      Atom(name: '_HomePageNavigationModel.currentIndex', context: context);

  @override
  int get currentIndex {
    _$currentIndexAtom.reportRead();
    return super.currentIndex;
  }

  @override
  set currentIndex(int value) {
    _$currentIndexAtom.reportWrite(value, super.currentIndex, () {
      super.currentIndex = value;
    });
  }

  late final _$_HomePageNavigationModelActionController =
      ActionController(name: '_HomePageNavigationModel', context: context);

  @override
  void navigate(int index, {dynamic data}) {
    final _$actionInfo = _$_HomePageNavigationModelActionController.startAction(
        name: '_HomePageNavigationModel.navigate');
    try {
      return super.navigate(index, data: data);
    } finally {
      _$_HomePageNavigationModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentIndex: ${currentIndex}
    ''';
  }
}

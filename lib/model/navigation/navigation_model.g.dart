// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NavigationModel on _NavigationModel, Store {
  late final _$currentPageAtom =
      Atom(name: '_NavigationModel.currentPage', context: context);

  @override
  NavigationPage get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(NavigationPage value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$_NavigationModelActionController =
      ActionController(name: '_NavigationModel', context: context);

  @override
  void navigate(NavigationPage page, {dynamic data}) {
    final _$actionInfo = _$_NavigationModelActionController.startAction(
        name: '_NavigationModel.navigate');
    try {
      return super.navigate(page, data: data);
    } finally {
      _$_NavigationModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentPage: ${currentPage}
    ''';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_settings.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SwapSettings on _SwapSettings, Store {
  late final _$deadlineAtom =
      Atom(name: '_SwapSettings.deadline', context: context);

  @override
  int get deadline {
    _$deadlineAtom.reportRead();
    return super.deadline;
  }

  @override
  set deadline(int value) {
    _$deadlineAtom.reportWrite(value, super.deadline, () {
      super.deadline = value;
    });
  }

  late final _$slippageToleranceAtom =
      Atom(name: '_SwapSettings.slippageTolerance', context: context);

  @override
  double get slippageTolerance {
    _$slippageToleranceAtom.reportRead();
    return super.slippageTolerance;
  }

  @override
  set slippageTolerance(double value) {
    _$slippageToleranceAtom.reportWrite(value, super.slippageTolerance, () {
      super.slippageTolerance = value;
    });
  }

  @override
  String toString() {
    return '''
deadline: ${deadline},
slippageTolerance: ${slippageTolerance}
    ''';
  }
}

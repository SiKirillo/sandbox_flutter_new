part of '../common.dart';

abstract class BlocState {
  final bool isProcessing;
  final bool isReady;

  const BlocState({
    required this.isProcessing,
    required this.isReady,
  });

  BlocState copyWith();
  BlocState copyWithForced();
}

class BlocEventResponse<Failure, T> {
  final Function(Failure)? onFailure;
  final Function(T)? onResult;
  final Function(dynamic)? onFinish;

  const BlocEventResponse({
    this.onFailure,
    this.onResult,
    this.onFinish,
  });
}

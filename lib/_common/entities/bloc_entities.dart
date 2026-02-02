part of '../common.dart';

/// Base Bloc that keeps a list of events currently being processed and
/// prevents the same event type from running concurrently by default.
abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState);

  final List<E> _processingEvents = [];

  @override
  void on<T extends E>(EventHandler<T, S> handler, {EventTransformer<T>? transformer}) {
    super.on<T>(
      handler,
      transformer: transformer ?? _dropConcurrentSameType<T>(),
    );
  }

  /// Default: same event type can't run twice at once. Use [allowConcurrent] to opt out.
  EventTransformer<T> _dropConcurrentSameType<T extends E>() => (events, mapper) {
    return events.asyncExpand((event) {
      if (_processingEvents.any((e) => e.runtimeType == event.runtimeType)) {
        return Stream<T>.empty();
      }
      _processingEvents.add(event);
      return mapper(event).transform(
        StreamTransformer<T, T>.fromHandlers(
          handleData: (data, sink) => sink.add(data),
          handleDone: (sink) {
            _processingEvents.remove(event);
            sink.close();
          },
          handleError: (error, stackTrace, sink) {
            _processingEvents.remove(event);
            sink.addError(error, stackTrace);
          },
        ),
      );
    });
  };

  /// Use for events that may run concurrently (e.g. status updates).
  EventTransformer<E> get allowConcurrent => (events, mapper) => events.asyncExpand(mapper);
}


/// Base state for BLoC states; provides [isProcessing] and [isReady] flags
/// and requires [copyWith]/[copyWithForced] for immutable updates.
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

/// Optional callbacks for handling BLoC event outcomes: failure, success, or finish.
/// Used when dispatching events that need UI feedback (e.g. snackbar on failure).
class BlocEventResponse<E, T> {
  final Function(E)? onFailure;
  final Function(T)? onResult;
  final Function(dynamic)? onFinish;

  const BlocEventResponse({
    this.onFailure,
    this.onResult,
    this.onFinish,
  });
}

import 'dart:async';

import '../result_dart.dart';

/// `AsyncResult<S, E>` represents an asynchronous computation.
typedef AsyncResult<S, F> = Future<Result<S, F>>;

/// `AsyncResult<S, E>` represents an asynchronous computation.
extension AsyncResultExtension<S extends Object, F extends Object> //
    on AsyncResult<S, F> {
  /// Returns a new `Result`, mapping any `Success` value
  /// using the given transformation and unwrapping the produced `Result`.
  AsyncResult<W, F> flatMap<W extends Object>(
    FutureOr<Result<W, F>> Function(S success) fn,
  ) {
    return then((result) => result.fold(fn, Failure.new));
  }

  /// Returns a new `Result`, mapping any `Error` value
  /// using the given transformation and unwrapping the produced `Result`.
  AsyncResult<S, W> flatMapError<W extends Object>(
    FutureOr<Result<S, W>> Function(F error) fn,
  ) {
    return then((result) => result.fold(Success.new, fn));
  }

  /// Returns a new `AsyncResult`, mapping any `Success` value
  /// using the given transformation.
  AsyncResult<W, F> map<W extends Object>(
    FutureOr<W> Function(S success) fn,
  ) {
    return then(
      (result) => result.map(fn).fold(
        (success) async {
          return Success(await success);
        },
        (failure) {
          return Failure(failure);
        },
      ),
    );
  }

  /// Returns a new `Result`, mapping any `Error` value
  /// using the given transformation.
  AsyncResult<S, W> mapError<W extends Object>(
    FutureOr<W> Function(F error) fn,
  ) {
    return then(
      (result) => result.mapError(fn).fold(
        (success) {
          return Success(success);
        },
        (failure) async {
          return Failure(await failure);
        },
      ),
    );
  }

  /// Change a [Success] value.
  AsyncResult<W, F> pure<W extends Object>(W success) {
    return then((result) => result.pure(success));
  }

  /// Change the [Failure] value.
  AsyncResult<S, W> pureError<W extends Object>(W error) {
    return mapError((_) => error);
  }

  /// Swap the values contained inside the [Success] and [Failure]
  /// of this [AsyncResult].
  AsyncResult<F, S> swap() {
    return then((result) => result.swap());
  }

  /// Returns the Future result of onSuccess for the encapsulated value
  /// if this instance represents `Success` or the result of onError function
  /// for the encapsulated value if it is `Error`.
  Future<W> fold<W>(
    W Function(S success) onSuccess,
    W Function(F error) onError,
  ) {
    return then<W>((result) => result.fold(onSuccess, onError));
  }

  /// Returns the future value of [S] if any.
  Future<S?> getOrNull() {
    return then((result) => result.getOrNull());
  }

  /// Returns the future value of [F] if any.
  Future<F?> exceptionOrNull() {
    return then((result) => result.exceptionOrNull());
  }

  /// Returns true if the current result is an [Failure].
  Future<bool> isError() {
    return then((result) => result.isError());
  }

  /// Returns true if the current result is a [Success].
  Future<bool> isSuccess() {
    return then((result) => result.isSuccess());
  }

  /// Returns the success value as a throwing expression.
  Future<S> getOrThrow() {
    return then((result) => result.getOrThrow());
  }

  /// Returns the encapsulated value if this instance represents `Success`
  /// or the result of `onFailure` function for
  /// the encapsulated a `Failure` value.
  Future<S> getOrElse(S Function(F) onFailure) {
    return then((result) => result.getOrElse(onFailure));
  }

  /// Returns the encapsulated value if this instance represents
  /// `Success` or the `defaultValue` if it is `Failure`.
  Future<S> getOrDefault(S defaultValue) {
    return then((result) => result.getOrDefault(defaultValue));
  }

  /// Returns the encapsulated `Result` of the given transform function
  /// applied to the encapsulated a `Failure` or the original
  /// encapsulated value if it is success.
  AsyncResult<S, R> recover<R extends Object>(
    FutureOr<Result<S, R>> Function(F failure) onFailure,
  ) {
    return then((result) => result.fold(Success.new, onFailure));
  }

  /// Performs the given action on the encapsulated Throwable
  /// exception if this instance represents failure.
  /// Returns the original Result unchanged.
  AsyncResult<S, F> onFailure<W>(void Function(F failure) onFailure) {
    return then((result) => result.onFailure(onFailure));
  }

  /// Performs the given action on the encapsulated value if this
  /// instance represents success. Returns the original Result unchanged.
  AsyncResult<S, F> onSuccess<W>(void Function(S success) onSuccess) {
    return then((result) => result.onSuccess(onSuccess));
  }
}

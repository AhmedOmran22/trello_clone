import '../errors/failures.dart';

class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  factory Result.success(T data) => Result._(data: data);
  factory Result.error(Failure failure) => Result._(failure: failure);

  bool get isSuccess => data != null;
  bool get isError => failure != null;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    if (isSuccess) return success(data as T);
    return error(failure!);
  }
}
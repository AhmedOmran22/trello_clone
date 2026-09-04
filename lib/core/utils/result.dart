import '../errors/failures.dart';

class Result<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;

  const Result._({this.data, this.failure, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.error(Failure failure) =>
      Result._(failure: failure, isSuccess: false);

  bool get isError => !isSuccess;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    if (isSuccess) return success(data as T);
    return error(failure!);
  }
}
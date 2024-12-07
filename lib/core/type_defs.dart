import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/failure.dart';
// Install: flutter pub add fpdart

typedef FutureEither<T> = Future<Either<Failure, T>>;

typedef FutureVoid = FutureEither<void>;

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendConfirmation {
  final AuthRepository repository;
  ResendConfirmation(this.repository);

  Future<Either<Failure, void>> call(String email) =>
      repository.resendConfirmation(email);
}

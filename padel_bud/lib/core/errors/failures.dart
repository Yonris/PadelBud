class Failure {
  final String message;
  Failure(this.message);
}

class BookingConflictFailure extends Failure {
  BookingConflictFailure() : super('Time slot already taken');
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure(String msg) : super(msg);
}

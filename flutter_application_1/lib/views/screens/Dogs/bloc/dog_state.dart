abstract class DogState {}

class DogInitial extends DogState {}

class DogLoading extends DogState {}

class DogSuccess extends DogState {}

class DogError extends DogState {
  final String message;

  DogError(this.message);
}

class AdoptionProcessed extends DogState {}

class DogDeleted extends DogState {}
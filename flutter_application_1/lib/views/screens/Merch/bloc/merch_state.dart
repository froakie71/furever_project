import 'package:flutter_application_1/models/merch_model.dart';

abstract class MerchState {}

class MerchInitial extends MerchState {}

class MerchLoading extends MerchState {}

class MerchLoaded extends MerchState {
  final List<MerchModel> merch;
  MerchLoaded(this.merch);
}

class MerchError extends MerchState {
  final String message;
  MerchError(this.message);
}
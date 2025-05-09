import 'package:flutter_application_1/models/merch_model.dart';

abstract class MerchEvent {}

class AddMerch extends MerchEvent {
  final MerchModel merch;
  AddMerch(this.merch);
}

class DeleteMerch extends MerchEvent {
  final String merchId;
  DeleteMerch(this.merchId);
}

class LoadMerch extends MerchEvent {}
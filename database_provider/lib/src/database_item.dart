import 'package:equatable/equatable.dart';

abstract class DatabaseItem extends Equatable {
  final int id;
  static const String idColumnName = "id";

  const DatabaseItem(this.id) : super();

  Map<String, dynamic> toMap();
}

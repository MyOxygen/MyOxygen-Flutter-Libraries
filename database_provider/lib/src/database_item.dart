import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class DatabaseItem extends Equatable {
  final int id;
  static const String idColumnName = "id";

  DatabaseItem({@required this.id}) : super();

  Map<String, dynamic> toMap();
}

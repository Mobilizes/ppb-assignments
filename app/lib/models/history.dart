import 'package:isar/isar.dart';

part 'history.g.dart';

@collection
class History {
  Id id = Isar.autoIncrement;

  double? maxDb;

  DateTime created = DateTime.now();
}

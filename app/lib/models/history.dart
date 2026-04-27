class History {
  String id;
  double maxDb;
  DateTime created;

  History({
    required this.id,
    required this.maxDb,
    required this.created,
  });

  factory History.fromMap(String id, Map<String, dynamic> map) {
    return History(
      id: id,
      maxDb: (map['maxDb'] as num).toDouble(),
      created: map['created'] != null 
          ? (map['created'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
}
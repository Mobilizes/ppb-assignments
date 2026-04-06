import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'package:app/models/history.dart';
import 'package:path_provider/path_provider.dart';

class HistoryRepository extends ChangeNotifier {
  static late Isar isar;
  final List<History> currentHistory = [];

  static Future<void> initialize() async {
    late Directory dir;
    if (Platform.isAndroid) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getTemporaryDirectory();
    }

    isar = await Isar.open([HistorySchema], directory: dir.path);
  }

  Future<void> addHistory(double maxDb) async {
    final history = History()..maxDb = maxDb;

    await isar.writeTxn(() async {
      await isar.historys.put(history);
    });

    fetchHistory();
  }

  Future<void> fetchHistory() async {
    List<History> histories = await isar.historys.where().findAll();

    currentHistory.clear();
    currentHistory.setAll(0, histories);

    notifyListeners();
  }

  Future<void> updateHistory(int id, double maxDb) async {
    final history = await isar.historys.get(id);
    if (history == null) {
      return;
    }

    await isar.writeTxn(() async {
      history.maxDb = maxDb;
    });

    await fetchHistory();
  }

  Future<void> deleteHistory(int id) async {
    await isar.writeTxn(() async {
      if (!await isar.historys.delete(id)) {
        throw Exception("Failed to delete history id $id!");
      }
    });

    fetchHistory();
  }
}

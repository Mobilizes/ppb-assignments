import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:app/models/history.dart';

class HistoryRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<History> currentHistory = [];

  Future<void> addHistory(double maxDb) async {
    await _firestore.collection('histories').add({
      'maxDb': maxDb,
      'created': FieldValue.serverTimestamp(),
    });
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    final snapshot = await _firestore.collection('histories')
        .orderBy('created', descending: true)
        .get();

    currentHistory.clear();
    for (var doc in snapshot.docs) {
      currentHistory.add(History.fromMap(doc.id, doc.data()));
    }

    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    await _firestore.collection('histories').doc(id).delete();
    await fetchHistory();
  }

  Future<void> deleteHistories(List<String> ids) async {
    final batch = _firestore.batch();
    for (String id in ids) {
      final docRef = _firestore.collection('histories').doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
    await fetchHistory();
  }
}

import 'package:app/models/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<History> currentHistory = [];
  String? _userId;

  Future<void> addHistory(double maxDb) async {
    if (_userId == null) return;
    await _firestore.collection('histories').add({
      'maxDb': maxDb,
      'created': FieldValue.serverTimestamp(),
      'userId': _userId,
    });
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

  Future<void> deleteHistory(String id) async {
    await _firestore.collection('histories').doc(id).delete();
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    if (_userId == null) {
      currentHistory.clear();
      notifyListeners();
      return;
    }

    try {
      final snapshot = await _firestore.collection('histories')
          .where('userId', isEqualTo: _userId)
          .orderBy('created', descending: true)
          .get();

      currentHistory.clear();
      for (var doc in snapshot.docs) {
        currentHistory.add(History.fromMap(doc.id, doc.data()));
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch history: $e");
    }
  }

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      fetchHistory();
    }
  }
}

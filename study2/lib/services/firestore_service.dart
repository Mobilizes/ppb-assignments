import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;
  late CollectionReference users = db.collection("users");
  late CollectionReference twats = db.collection("twats");
  late CollectionReference votes = db.collection("votes");

  Future<void> addUser(String username, String password) {
    return users.add({"username": username, "password": password});
  }

  Future<String> fetchUsername(String userId) async {
    final userDoc = await users.doc(userId).get();
    if (!userDoc.exists) {
      return "";
    }

    return (userDoc.data() as Map<String, dynamic>)["username"];
  }

  Future<Map<String, int>> fetchTwatVotes(String userId) async {
    final votesDoc = await votes.where("userId", isEqualTo: userId).get();

    Map<String, int> userVotesMap = {};

    for (var doc in votesDoc.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String twatId = data["twatId"];
      final int voteType = data["voteType"];

      userVotesMap[twatId] = voteType;
    }

    return userVotesMap;
  }

  Future<void> addTwat(String userId, String text) async {
    final String username = await fetchUsername(userId);

    await twats.add({
      "userId": userId,
      "userName": username,
      "text": text,
      "createdAt": DateTime.now(),
      "upvotes": 0,
      "downvotes": 0,
    });
  }

  Stream<QuerySnapshot> fetchTwats(int limit) {
    return twats
        .orderBy("createdAt", descending: true)
        .limit(limit)
        .snapshots();
  }

  // 1 = upvote, -1 = downvote
  Future<void> voteTwat(String twatId, String userId, int voteType) {
    final twatRef = twats.doc(twatId);
    final voteRef = votes.doc("twat_${twatId}_user_$userId");

    return db.runTransaction((transaction) async {
      final twatSnapshot = await transaction.get(twatRef);
      if (!twatSnapshot.exists) {
        return;
      }

      final voteSnapshot = await transaction.get(voteRef);
      Map<String, dynamic> twatUpdates = {};

      if (!voteSnapshot.exists) {
        transaction.set(voteRef, {
          "twatId": twatId,
          "userId": userId,
          "voteType": voteType,
          "votedAt": FieldValue.serverTimestamp(),
        });

        twatUpdates[voteType == 1 ? "upvotes" : "downvotes"] =
            FieldValue.increment(1);
      } else {
        final data = voteSnapshot.data() as Map<String, dynamic>;
        final currentVoteType = data["voteType"] as int;

        if (currentVoteType == voteType) {
          transaction.delete(voteRef);
          twatUpdates[voteType == 1 ? "upvotes" : "downvotes"] =
              FieldValue.increment(-1);
        } else {
          transaction.update(voteRef, {
            "voteType": voteType,
            "votedAt": FieldValue.serverTimestamp(),
          });

          twatUpdates[voteType == 1 ? "upvotes" : "downvotes"] =
              FieldValue.increment(1);
          twatUpdates[currentVoteType == 1 ? "upvotes" : "downvotes"] =
              FieldValue.increment(-1);
        }
      }

      if (twatUpdates.isNotEmpty) {
        transaction.update(twatRef, twatUpdates);
      }
    });
  }
}

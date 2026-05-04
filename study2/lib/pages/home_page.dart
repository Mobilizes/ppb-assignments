import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study2/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final twatTextController = TextEditingController();

  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    if (firestoreService.auth.currentUser == null) {
      Navigator.popUntil(context, (Route<dynamic> route) {
        return route.settings.name == "/login";
      });
    }

    final user = firestoreService.auth.currentUser!;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.blind),
        title: const Text("Twatter"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: .circular(20)),
                      hintText: "Go on, don't be shy!",
                      labelText: "What do you want to say today?",
                    ),
                    controller: twatTextController,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (twatTextController.text.isEmpty) {
                      return;
                    }
                    firestoreService.addTwat(user.uid, twatTextController.text);
                    twatTextController.clear();
                  },
                  icon: Icon(Icons.keyboard_return),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.fetchTwats(20),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No twats yet :(");
                  }

                  final twatsList = snapshot.data!.docs;

                  return FutureBuilder(
                    future: firestoreService.fetchTwatVotes(user.uid),
                    builder: (context, voteSnapshot) {
                      if (voteSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final votedTwats = voteSnapshot.data ?? {};

                      return ListView.builder(
                        itemCount: twatsList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TwatView(
                              userUid: user.uid,
                              twatId: twatsList[index].id,
                              twatData:
                                  twatsList[index].data()
                                      as Map<String, dynamic>,
                              votedTwats: votedTwats,
                              firestoreService: firestoreService,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TwatView extends StatefulWidget {
  final String userUid;
  final String twatId;
  final Map<String, dynamic> twatData;
  final Map<String, int> votedTwats;
  final FirestoreService firestoreService;

  const TwatView({
    super.key,
    required this.userUid,
    required this.twatId,
    required this.twatData,
    required this.votedTwats,
    required this.firestoreService,
  });

  @override
  State<StatefulWidget> createState() {
    return _TwatViewState();
  }
}

class _TwatViewState extends State<TwatView> {
  late int localVoteStatus;

  @override
  void initState() {
    super.initState();
    localVoteStatus = widget.votedTwats[widget.twatId] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    bool upvoted = localVoteStatus == 1;
    bool downvoted = localVoteStatus == -1;

    Icon upvoteIcon = Icon(Icons.arrow_upward_rounded);
    Icon downvoteIcon = Icon(Icons.arrow_downward_rounded);

    int upvoteCount = widget.twatData["upvotes"];
    int downvoteCount = widget.twatData["downvotes"];

    Text upvoteText = Text(upvoteCount.toString());
    Text downvoteText = Text(downvoteCount.toString());

    if (upvoted) {
      upvoteIcon = Icon(Icons.arrow_upward, color: Colors.red);
      upvoteText = Text(
        upvoteCount.toString(),
        style: TextStyle(color: Colors.red),
      );
    }
    if (downvoted) {
      downvoteIcon = Icon(Icons.arrow_downward, color: Colors.blue);
      downvoteText = Text(
        downvoteCount.toString(),
        style: TextStyle(color: Colors.blue),
      );
    }

    DateTime timePosted = widget.twatData["createdAt"].toDate();

    return FutureBuilder(
      future: widget.firestoreService.fetchTwatVotes(widget.userUid),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(border: Border.all()),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(widget.twatData["userName"]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
                child: Text(widget.twatData["text"]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 20, 10),
                child: Text(DateFormat.yMMMMd().format(timePosted)),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  mainAxisAlignment: .spaceAround,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: upvoteIcon,
                          onPressed: () => {
                            setState(() {
                              localVoteStatus = localVoteStatus == 1 ? 0 : 1;
                            }),
                            widget.firestoreService.voteTwat(
                              widget.twatId,
                              widget.userUid,
                              1,
                            ),
                          },
                        ),
                        SizedBox(width: 0.0),
                        upvoteText,
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: downvoteIcon,
                          onPressed: () => {
                            setState(() {
                              localVoteStatus = localVoteStatus == -1 ? 0 : -1;
                            }),
                            widget.firestoreService.voteTwat(
                              widget.twatId,
                              widget.userUid,
                              -1,
                            ),
                          },
                        ),
                        SizedBox(width: 0.0),
                        downvoteText,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

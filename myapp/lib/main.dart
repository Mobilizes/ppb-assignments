import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text('my first app'),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageCard(image: AssetImage("assets/windows-xp.jpeg")),
              QuestionCard(text: Text("What image is that")),
              AnswerCard(options: [
                AnswerCardOption(
                    icon: Icon(Icons.food_bank), text: Text("Food")),
                AnswerCardOption(
                    icon: Icon(Icons.landscape), text: Text("Scenery")),
                AnswerCardOption(
                    icon: Icon(Icons.people), text: Text("People")),
              ]),
              CounterCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final AssetImage image;

  const ImageCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        image: image,
        fit: BoxFit.cover,
      ),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
      color: Colors.lightBlue.shade100,
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Text text;

  const QuestionCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: text,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
      color: Colors.red.shade200,
      width: double.infinity,
    );
  }
}

class AnswerCard extends StatelessWidget {
  final List<AnswerCardOption> options;

  const AnswerCard({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options,
      ),
      margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
      padding: EdgeInsets.all(20),
      color: Colors.yellow.shade200,
    );
  }
}

class AnswerCardOption extends StatefulWidget {
  final Icon icon;
  final Text text;

  const AnswerCardOption({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnswerCardOptionState();
  }
}

class _AnswerCardOptionState extends State<AnswerCardOption> {
  _AnswerCardOptionState();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Column(
        children: [widget.icon, widget.text],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      foregroundColor: Colors.black,
      backgroundColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      enableFeedback: false,
      onPressed: () {},
    );
  }
}

class CounterCard extends StatefulWidget {
  const CounterCard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CounterCardState();
  }
}

class _CounterCardState extends State<CounterCard> {
  int _count = 0;

  void _incrementCount() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Counter here: $_count"),
          FloatingActionButton(
            elevation: 0,
            highlightElevation: 0,
            hoverElevation: 0,
            focusElevation: 0,
            child: const Icon(Icons.add),
            backgroundColor: Colors.cyan.shade300,
            onPressed: _incrementCount,
            shape: ContinuousRectangleBorder(),
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
      padding: EdgeInsets.all(20),
      color: Colors.cyan.shade200,
    );
  }
}

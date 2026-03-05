import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.amber,
      title: Text('my first app'),
      centerTitle: true,
    ),
    body: Center(
      child: Text(
        'Alpro the best',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontFamily: 'IndieFlower',
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          color: Colors.blueAccent
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      backgroundColor: Colors.blue,
      onPressed: () {},
    ),
  )
));



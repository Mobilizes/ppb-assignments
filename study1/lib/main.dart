import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
	home: Scaffold(
            appBar: AppBar(title: const Center(child: Text("Flutter demo"))),
	    body: Column(
		children: [
		    Image.network("https://picsum.photos/id/16/2500/1667"),
		    Column(
			children: [
			    TitleLocationSection(),
			    ActionSection(),
			    DescriptionSection(),
			],
		    ),			   
		],
   	    ),
      	),
    );
  }
}

class TitleLocationSection extends StatelessWidget {
    const TitleLocationSection({super.key});

    @override
    Widget build(BuildContext context) {
	return Padding(
	    padding: const EdgeInsets.all(32.0),
	    child: Row(
		children: [
		    Expanded(
			child: Column(
			    crossAxisAlignment: .start,
			    children: [
				Padding(
				    padding: const EdgeInsets.only(bottom: 8),
				    child: Text(
					"Oeschinen Lake Campground",
					style: TextStyle(fontWeight: .bold),
				    ),
				),
				Text(
				    "Kandersteg, Switzerland",
				    style: TextStyle(color: Colors.grey[500]),
				),
			    ],
			),
		    ),
		    Icon(Icons.star, color: Colors.red[500]),
		    Text("41"),
		],
	    ),
	);
    }
}

class ActionSection extends StatelessWidget {
    const ActionSection({super.key});

    @override
    Widget build(BuildContext context) {
	Color color = Theme.of(context).primaryColor;
	return Row(
	    mainAxisAlignment: .spaceEvenly,
	    children: [
		Column(
		    children: [
			Icon(Icons.call, color: color),
			Text(
			    "CALL",
			    style: TextStyle(color: color),
			),
		    ],
		),
		Column(
		    children: [
			Icon(Icons.near_me, color: color),
			Text(
			    "ROUTE",
			    style: TextStyle(color: color),
			),
		    ],
		),
		Column(
		    children: [
			Icon(Icons.share, color: color),
			Text(
			    "SHARE",
			    style: TextStyle(color: color),
			),
		    ],
		),
	    ],
	);
    }
}

class DescriptionSection extends StatelessWidget {
    const DescriptionSection({super.key});

    @override
    Widget build(BuildContext context) {
	return Padding(
	    padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
	    child: Text(
		'Lake Oeschinen lies at the foot of the Blüemlisalp in the '
		'Bernese Alps. Situated 1,578 meters above sea level, it '
		'is one of the larger Alpine Lakes. A gondola ride from '
		'Kandersteg, followed by a half-hour walk through pastures '
		'and pine forest, leads you to the lake, which warms to 20 '
		'degrees Celsius in the summer. Activities enjoyed here '
		'include rowing, and riding the summer toboggan run.',
	    ),
	);
    }
}

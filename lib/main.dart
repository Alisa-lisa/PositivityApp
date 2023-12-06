import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color generateRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }
  String generateRandomText() {
    List<String> texts = ['A', 'B', 'C', 'D', 'E'];
    Random random = Random();
    return texts[random.nextInt(texts.length)];
  }

	// const
  List<String> tags = ["social", "family", "romantic", "health", "career"];
  List<String> difficulty = ["simple", "neutral", "hard"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
		  // mainAxisAlignment: MainAxisAlignment.center,
		  children: [
			// First child: Row with 5 clickable buttons
			SizedBox(height: 10), // Spacer
			Text("Area:"),
				 Wrap(
					spacing: 2.0,
					runSpacing: 5.0,
			  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
			  children: List.generate(
				5,
				(index) => ElevatedButton(
				  onPressed: () {
					// Handle button click
					print('Button $index Clicked');
				  },
				  style: ElevatedButton.styleFrom(
					primary: Colors.grey,
				  ),
				  child: Text(tags[index]),
				),
			  ),
			),
			SizedBox(height: 10), // Spacer
			// Second child: Row with 3 clickable buttons with icons
			Text("Difficulty:"),
			Row(
			  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
			  children: List.generate(
				3,
				(index) => ElevatedButton(
					onPressed: () {},
					style: ElevatedButton.styleFrom(
						primary: Colors.blue,	
					),
					child: Text(difficulty[index])
					)
				  )
			),
			SizedBox(height: 20), // Spacer
			// Third child: Button in the center of the screen
			ElevatedButton(
			  onPressed: () {
				// Handle button click
				print('Generate Scenario Clicked');
			  },
			  style: ElevatedButton.styleFrom(
				primary: Colors.blue, // You can set a specific color
			  ),
			  child: Text('Generate Scenario'),
			),
		  ],
	),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

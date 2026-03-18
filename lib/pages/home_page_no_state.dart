import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          _counter.toString(), 
        style: TextStyle(fontSize: 50)
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _counter++;
          print(_counter);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

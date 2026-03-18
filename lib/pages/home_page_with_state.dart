import 'package:flutter/material.dart';

class HomePageWithState extends StatefulWidget {
  HomePageWithState({super.key});

  int _counter = 0;

  @override
  State<HomePageWithState> createState() => _HomePageWithStateState();
}

class _HomePageWithStateState extends State<HomePageWithState> {
  int _counter2 = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(_counter2.toString(), style: TextStyle(fontSize: 50)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget._counter++;
            _counter2++;
          });
          widget._counter++;
          _counter2++;

          print(_counter2);
          print(widget._counter);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

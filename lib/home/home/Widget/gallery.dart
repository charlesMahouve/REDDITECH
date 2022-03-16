import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  State<StatefulWidget> createState() {
    return _Gallery();
  }
}

class _Gallery extends State<Gallery> {
  int selected = 0;

  void forward() {
    setState(() {
      selected += 1;
    });
    if (selected >= widget.data.lenght) {
      setState(() {
        selected = 0;
      });
    }
  }

  void back() {
    setState(() {
      selected -= 1;
    });
    if (selected < 0) {
      setState(() {
        selected = widget.data.lenght - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.network(widget.data[0]),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                back();
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            IconButton(
              onPressed: () {
                forward();
              },
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ],
    );
  }
}

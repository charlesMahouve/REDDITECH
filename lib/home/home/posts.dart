import 'Widget/card_post.dart';
import 'package:flutter/material.dart';

class Posts extends StatefulWidget {
  const Posts({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  State<StatefulWidget> createState() {
    return _Posts();
  }
}

class _Posts extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        title: Text(
          widget.data.subredditNamePrefixed,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardPosts(
                data: widget.data,
                isDisableComment: true,
                isDisableSubAction: false),
          ],
        ),
      ),
    );
  }
}

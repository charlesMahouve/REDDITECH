import '../request/hot_posts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'card_post.dart';
import 'dart:async';
import 'dart:convert';

class PostsSubreddit extends StatefulWidget {
  const PostsSubreddit({Key? key, required this.idSub}) : super(key: key);

  final String idSub;

  @override
  State<StatefulWidget> createState() {
    return _PostsSubreddit();
  }
}

class _PostsSubreddit extends State<PostsSubreddit> {
  List<HotPosts> hotPosts = [];
  String after = '';
  String dropdownValue = '/hot';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData(10);
  }

  Future loadData(limit) async {
    setState(() {
      isLoading = false;
    });
    final LocalStorage storage = LocalStorage('user');
    final response = await get(
        Uri.parse(
            'https://oauth.reddit.com/${widget.idSub}$dropdownValue?limit=$limit&g=GLOBAL&sr_detail=true&after=$after&row_json=1'),
        headers: {'authorization': 'Bearer ${storage.getItem('token')}'});
    List<HotPosts> list;

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var rest = data['data'];
      var deep = rest['children'] as List;

      list = deep.map<HotPosts>((json) => HotPosts.fromJson(json)).toList();
      setState(() {
        isLoading = false;
        hotPosts.addAll(list);
        after = rest['after'];
      });
      return;
    } else {
      debugPrint('/subreddits/popular?limit=$limit: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: hotPosts.length,
            itemBuilder: (context, index) {
              return CardPosts(
                  data: hotPosts[index],
                  isDisableComment: false,
                  isDisableSubAction: true);
            },
          ),
          onNotification: (ScrollNotification scrollInfo) {
            if (!isLoading &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              loadData(10);
              setState(() {
                isLoading = true;
              });
            }
            return true;
          }),
    );
  }
}

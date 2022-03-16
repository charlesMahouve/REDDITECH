import 'Widget/card_post.dart';
import 'request/hot_posts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  List<HotPosts> hotPosts = [];
  String dropdownValue = '/hot';
  String after = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDataPosts(10);
  }

  Future loadDataPosts(limit) async {
    final LocalStorage storage = LocalStorage('user');
    final response = await get(
        Uri.parse(
            'https://oauth.reddit.com$dropdownValue?limit=$limit&g=GLOBAL&sr_detail=true&after=$after&row_json=1'),
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
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                contentPadding: const EdgeInsets.all(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.search),
                  isDense: true,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: '/hot',
                      child: Text("Hot"),
                    ),
                    DropdownMenuItem(
                      value: '/best',
                      child: Text("Best"),
                    ),
                    DropdownMenuItem(
                      value: '/new',
                      child: Text("New"),
                    ),
                    DropdownMenuItem(
                      value: '/random',
                      child: Text("Random"),
                    ),
                    DropdownMenuItem(
                      value: '/rising',
                      child: Text("Rising"),
                    ),
                    DropdownMenuItem(
                      value: '/top',
                      child: Text("Top"),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      after = '';
                      dropdownValue = newValue!;
                      isLoading = true;
                    });
                    hotPosts.removeAt(0);
                    loadDataPosts(10);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: hotPosts.length,
                  itemBuilder: (context, index) {
                    return CardPosts(
                        data: hotPosts[index],
                        isDisableComment: false,
                        isDisableSubAction: false);
                  },
                ),
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    loadDataPosts(10);
                    setState(() {
                      isLoading = true;
                    });
                  }
                  return true;
                }),
          ),
          Container(
            height: isLoading ? 50.0 : 0,
            color: Colors.transparent,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

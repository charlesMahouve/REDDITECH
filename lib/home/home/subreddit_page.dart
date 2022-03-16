import 'dart:convert';

import 'request/hot_posts.dart';
import 'request/subreddit.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart';

import 'Widget/card_post.dart';

class SubredditPage extends StatefulWidget {
  const SubredditPage({Key? key, required this.idSub}) : super(key: key);

  final idSub;

  @override
  State<StatefulWidget> createState() {
    return _SubredditPage();
  }
}

class _SubredditPage extends State<SubredditPage> {
  bool selected = false;
  bool isLoading = false;
  bool isSubLoading = false;
  bool isLoadingPosts = false;
  List<HotPosts> hotPosts = [];
  String dropdownValue = '/hot';
  String after = '';
  late Subreddit data;

  List<Widget> widFirstIno = [];

  @override
  void initState() {
    super.initState();
    loadData();
    loadDataPosts(10);
  }

  Future loadDataPosts(limit) async {
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
        isLoadingPosts = false;
        hotPosts.addAll(list);
        after = rest['after'];
      });
      return;
    } else {
      debugPrint('/subreddits/popular?limit=$limit: ${response.statusCode}');
      setState(() {
        isLoadingPosts = false;
      });
    }
  }

  Future loadData() async {
    setState(() {
      isLoading = true;
    });
    data = await fetchSubreddit(widget.idSub);
    setState(() {
      isLoading = false;
    });
  }

  Future onSubPressed() async {
    final LocalStorage storage = LocalStorage('user');
    setState(() {
      isSubLoading = true;
    });
    final response = await post(
        Uri.parse(
            'https://oauth.reddit.com/api/subscribe?sr_name=${data.name}&action=${data.isSubscriber ? 'unsub' : 'sub'}'),
        headers: {'authorization': 'Bearer ${storage.getItem('token')}'});
    if (response.statusCode == 200) {
      data = await fetchSubreddit(widget.idSub);
    } else {
      print(
          "error: /subscribe?sr_name=${data.name}&action=${data.isSubscriber ? 'unsub' : 'sub'}");
    }
    setState(() {
      isSubLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black, //change your color here
              ),
              elevation: 0,
              title: Text(
                widget.idSub,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white),
          body: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ));
    }

    Widget getCardPosts() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                        isLoadingPosts = true;
                      });
                      hotPosts.removeAt(0);
                      loadDataPosts(10);
                    },
                  ),
                ),
              ),
            ),
            for (var item in hotPosts)
              CardPosts(
                  data: item,
                  isDisableComment: false,
                  isDisableSubAction: true),
            Container(
              height: isLoadingPosts ? 50.0 : 0,
              color: Colors.transparent,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
    }

    Widget getTabBody() {
      if (selected == false) {
        return getCardPosts();
      }
      return const Text("a propos");
    }

    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          elevation: 0,
          title: Text(
            widget.idSub,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                        color: Colors.grey,
                        child: ((data.urlBanner != null && data.urlBanner != '')
                            ? Image.network(
                                data.urlBanner,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                height: 150,
                              )
                            : Container(
                                height: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                              )),
                      ),
                      Positioned(
                          top: 150 - 60,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey.shade800,
                                backgroundImage: NetworkImage(
                                  data.urlIconImg,
                                )),
                          ))
                    ],
                  ),
                  const SizedBox(
                    width: double.infinity,
                    height: 70,
                  ),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.idSub,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      data.description,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: RichText(
                      text: TextSpan(
                        text: data.subscribers.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: ' membres ',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '- ${data.activeAccount.toString()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const TextSpan(
                            text: ' members ',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: isSubLoading ? 50.0 : 0,
                    color: Colors.transparent,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  (data.isSubscriber
                      ? OutlinedButton(
                          onPressed: () {
                            onSubPressed();
                          },
                          child: Text("Unsubscribe to ${data.name}"),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            onSubPressed();
                          },
                          child: Text("Subscribe to ${data.name}"),
                        )),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    selected = !selected;
                                  });
                                },
                                icon: Icon(!selected
                                    ? Icons.add_comment
                                    : Icons.add_comment_outlined)),
                            Container(
                              color:
                                  !selected ? Colors.black : Colors.transparent,
                              height: 2,
                              width: 55,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    selected = !selected;
                                  });
                                },
                                icon: Icon(!selected
                                    ? Icons.info_outline
                                    : Icons.info)),
                            Container(
                              color:
                                  !selected ? Colors.transparent : Colors.black,
                              height: 2,
                              width: 55,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  getTabBody(),
                ],
              ),
            ),
            onNotification: (ScrollNotification scrollInfo) {
              if (!isLoadingPosts &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                setState(() {
                  isLoadingPosts = true;
                });
                loadDataPosts(5);
              }
              return true;
            }),
      ),
    );
  }
}

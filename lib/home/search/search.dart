import '../home/subreddit_page.dart';
import 'request/data_search.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Search();
  }
}

class _Search extends State<Search> {
  bool isLoading = true;
  String searchValue = "";
  List<DataSearch> sub = [];

  @override
  void initState() {
    super.initState();
    loadSearch();
  }

  Future loadSearch() async {
    final LocalStorage storage = LocalStorage('user');
    final response = await post(
        Uri.parse(
            'https://oauth.reddit.com/api/search_subreddits?query=$searchValue'),
        headers: {'authorization': 'Bearer ${storage.getItem('token')}'});
    List<DataSearch> list;

    if (sub.isNotEmpty) {
      setState(() {
        sub = [];
      });
    }
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var rest = data['subreddits'];

      list = rest.map<DataSearch>((json) => DataSearch.fromJson(json)).toList();
      setState(() {
        isLoading = false;
        sub.addAll(list);
      });
      return;
    } else {
      debugPrint(
          '/api/search_subreddits?query=$searchValue: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                cursorColor: Colors.black,
                onChanged: (String value) {
                  setState(() {
                    searchValue = value;
                  });
                  loadSearch();
                },
                decoration: const InputDecoration(
                  hoverColor: Colors.black,
                  focusColor: Colors.black,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: 'Search',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: sub.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: ((sub[index].imgIcon != null &&
                            sub[index].imgIcon != '')
                        ? Image.network(sub[index].imgIcon)
                        : const Text(
                            "?",
                            style: TextStyle(color: Colors.white),
                          )),
                  ),
                  title: Text(sub[index].name),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SubredditPage(idSub: 'r/${sub[index].name}')));
                  },
                );
              },
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
      ),
    );
  }
}

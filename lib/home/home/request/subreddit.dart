import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';

Future<Subreddit> fetchSubreddit(var urlReddit) async {
  final LocalStorage storage = LocalStorage('user');
  final response = await get(
      Uri.parse('https://oauth.reddit.com/$urlReddit/about'),
      headers: {'authorization': 'Bearer ${storage.getItem('token')}'});

  if (response.statusCode == 200) {
    return Subreddit.fromJson(jsonDecode(response.body));
  } else {
    debugPrint('/$urlReddit/about: ${response.statusCode}');
    throw Exception('Failed to load subreddit');
  }
}

class Subreddit {
  final String urlIconImg;
  final String name;
  final String title;
  final int subscribers;
  final int activeAccount;
  final String description;
  final String urlBanner;
  final bool isSubscriber;

  Subreddit({
    required this.urlIconImg,
    required this.name,
    required this.title,
    required this.subscribers,
    required this.description,
    required this.urlBanner,
    required this.isSubscriber,
    required this.activeAccount,
  });

  factory Subreddit.fromJson(Map<String, dynamic> json) {
    var data = json['data'];

    return Subreddit(
      urlIconImg: data['icon_img'].replaceAll("amp;", ""),
      name: data['display_name'],
      title: data['title'],
      subscribers: data['subscribers'],
      description: data['public_description'],
      urlBanner: data['mobile_banner_image'].replaceAll("amp;", ""),
      isSubscriber: data['user_is_subscriber'],
      activeAccount: data['accounts_active'],
    );
  }
}

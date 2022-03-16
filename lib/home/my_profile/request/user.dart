import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';

Future<User> fetchUser() async {
  final LocalStorage storage = LocalStorage('user');
  final response = await get(Uri.parse('https://oauth.reddit.com/api/v1/me'),
      headers: {'authorization': 'Bearer ${storage.getItem('token')}'});

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    debugPrint('/api/v1/me: ${response.statusCode}');
    throw Exception('Failed to load user information');
  }
}

class User {
  final String displayName;
  final String avatarUrl;
  final String idUser;
  final String bannerImg;
  final String description;
  final int coins;
  final int karma;
  final int numberFriend;
  final bool autoplay;
  final bool acceptFollowers;
  final bool showMedia;
  final bool showPresence;
  final bool nsfw;

  User({
    required this.displayName,
    required this.avatarUrl,
    required this.idUser,
    required this.coins,
    required this.karma,
    required this.numberFriend,
    required this.description,
    required this.autoplay,
    required this.acceptFollowers,
    required this.showMedia,
    required this.showPresence,
    required this.nsfw,
    required this.bannerImg,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var data = json['subreddit'];
    var avatar = json['icon_img'].replaceAll("amp;", "");
    var banner = data['banner_img'].replaceAll("amp;", "");

    return User(
      bannerImg: banner,
      displayName: json['name'],
      avatarUrl: avatar,
      idUser: json['id'],
      coins: json['coins'],
      karma: json['total_karma'],
      numberFriend: json['num_friends'],
      description: data['public_description'],
      autoplay: json['pref_video_autoplay'],
      acceptFollowers: json['accept_followers'],
      showMedia: data['show_media'],
      showPresence: json['pref_show_presence'],
      nsfw: json['over_18'],
    );
  }
}

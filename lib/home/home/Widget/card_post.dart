import '../Widget/gallery.dart';
import '../Widget/video.dart';
import '../posts.dart';
import '../subreddit_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';

class CardPosts extends StatefulWidget {
  const CardPosts(
      {Key? key,
      required this.data,
      required this.isDisableComment,
      required this.isDisableSubAction})
      : super(key: key);

  final data;
  final bool isDisableComment;
  final bool isDisableSubAction;

  @override
  State<StatefulWidget> createState() {
    return _CardPosts();
  }
}

class _CardPosts extends State<CardPosts> {
  bool isSaved = true;
  int valueVote = 0;
  int totalVote = 0;

  @override
  void initState() {
    super.initState();
    isSaved = widget.data.isSaved;
    valueVote = widget.data.likes;
    totalVote = widget.data.score;
  }

  Widget _getGallery() {
    if (widget.data.listUrlGallery.isNotEmpty) {
      return Gallery(data: widget.data.listUrlGallery);
    }
    return Container();
  }

  List<Widget> _getImage(elem) {
    if (widget.data.listUrlVideo.length == 0) {
      return elem
          .map<Widget>((i) => Padding(
              padding: const EdgeInsets.all(10.0), child: Image.network(i)))
          .toList();
    } else if (widget.data.listUrlGif.length != 0) {
      return widget.data.listUrlGif
          .map<Widget>((i) => Padding(
              padding: const EdgeInsets.all(10.0), child: Image.network(i)))
          .toList();
    }
    return widget.data.listUrlVideo
        .map<Widget>((i) => Padding(
              padding: const EdgeInsets.all(10.0),
              child: Video(url: i),
            ))
        .toList();
  }

  Widget _getSelfText() {
    var unescape = HtmlUnescape();

    if (widget.data.selfTextHtml != null && widget.data.selfTextHtml != "") {
      return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Html(data: unescape.convert(widget.data.selfTextHtml)));
    }
    if (widget.data.selfTextHtml != null && widget.data.selfTextHtml != "") {
      return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(widget.data.selfText));
    }
    return const Text("");
  }

  Future saveOrNot() async {
    final LocalStorage storage = LocalStorage('user');
    final response;

    if (isSaved) {
      response = await post(
          Uri.parse('https://oauth.reddit.com/api/unsave?id=${widget.data.id}'),
          headers: {'authorization': 'Bearer ${storage.getItem('token')}'});
    } else {
      response = await post(
          Uri.parse('https://oauth.reddit.com/api/save?id=${widget.data.id}'),
          headers: {'authorization': 'Bearer ${storage.getItem('token')}'});
    }

    if (response.statusCode == 200) {
      setState(() {
        isSaved = !isSaved;
      });
    } else {
      print("error: /api/save?id=${widget.data.id} : ${response.statusCode}");
    }
  }

  Future votePosts(int value) async {
    if (value == valueVote) {
      value = 0;
    }
    final LocalStorage storage = LocalStorage('user');
    final response = await post(
        Uri.parse(
            'https://oauth.reddit.com/api/vote?id=${widget.data.id}&dir=$value'),
        headers: {'authorization': 'Bearer ${storage.getItem('token')}'});

    if (response.statusCode == 200) {
      setState(() {
        if (value == -1 || value == 0) {
          totalVote -= 1;
        } else {
          totalVote += 1;
        }
        valueVote = value;
      });
    } else {
      print(
          "error: /api/vote?id=${widget.data.id}&dir=$value : ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                child: (widget.data.urlAvatarSubreddit != null &&
                        widget.data.urlAvatarSubreddit != '')
                    ? Image.network(widget.data.urlAvatarSubreddit)
                    : const Text(
                        "?",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.topLeft,
                    ),
                    onPressed: !widget.isDisableSubAction
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SubredditPage(
                                          idSub:
                                              widget.data.subredditNamePrefixed,
                                        )));
                          }
                        : null,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(widget.data.subredditNamePrefixed,
                          style: const TextStyle(height: 1.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Posted by u/${widget.data.author}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Text(widget.data.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _getSelfText(),
        ..._getImage(widget.data.listUrlImage),
        _getGallery(),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                child: Chip(
                  avatar: const Icon(
                    Icons.add_comment_outlined,
                    size: 18,
                  ),
                  label: Text(widget.data.numComments.toString()),
                ),
                onTap: !widget.isDisableComment
                    ? () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => Posts(data: widget.data)));
                      }
                    : null,
              ),
            ),
            Expanded(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: IconButton(
                      iconSize: 20,
                      tooltip: 'like',
                      icon: FaIcon(valueVote == 1
                          ? FontAwesomeIcons.solidThumbsUp
                          : FontAwesomeIcons.thumbsUp),
                      onPressed: () {
                        votePosts(1);
                      },
                    )),
                    Expanded(child: Text(totalVote.toString())),
                    Expanded(
                        child: IconButton(
                      iconSize: 20,
                      tooltip: 'dislike',
                      icon: FaIcon(valueVote == -1
                          ? FontAwesomeIcons.solidThumbsDown
                          : FontAwesomeIcons.thumbsDown),
                      onPressed: () {
                        votePosts(-1);
                      },
                    )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                  onPressed: () {
                    saveOrNot();
                  },
                  icon: Icon(isSaved ? Icons.star : Icons.star_border,
                      color: Colors.yellow)),
            ),
          ],
        ),
        const Divider(
          thickness: 5,
        )
      ],
    );
  }
}

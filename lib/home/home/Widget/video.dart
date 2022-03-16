import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  const Video({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<StatefulWidget> createState() {
    return _Video();
  }
}

class _Video extends State<Video> {
  late VideoPlayerController _videoPlayerController;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _videoPlayerController.setLooping(true);
          _videoPlayerController.pause();
          isPlay = false;
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController))
            : Container(
                height: 50.0,
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        Container(
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: Row(
            children: [
              IconButton(
                  iconSize: 20,
                  onPressed: () {
                    if (isPlay) {
                      _videoPlayerController.pause();
                      setState(() {
                        isPlay = false;
                      });
                    } else {
                      _videoPlayerController.play();
                      setState(() {
                        isPlay = true;
                      });
                    }
                  },
                  icon: Icon(
                    isPlay ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

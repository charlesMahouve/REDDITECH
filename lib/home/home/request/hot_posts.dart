class HotPosts {
  final String title;
  final String subreddit;
  final String selfText;
  final void selfTextHtml;
  final String subredditNamePrefixed;
  final String urlSubredditToPost;
  final int numComments;
  final int score;
  final String permalink;
  final String id;
  final String author;
  final bool isSaved;
  final int likes;
  late final String urlAvatarSubreddit;
  final List<dynamic> listUrlImage;
  final List<dynamic> listUrlGif;
  final List<dynamic> listUrlVideo;
  final List<dynamic> listUrlGallery;

  HotPosts({
    required this.listUrlGif,
    required this.title,
    required this.score,
    required this.subreddit,
    required this.selfText,
    required this.selfTextHtml,
    required this.subredditNamePrefixed,
    required this.urlSubredditToPost,
    required this.numComments,
    required this.permalink,
    required this.author,
    required this.listUrlImage,
    required this.listUrlVideo,
    required this.urlAvatarSubreddit,
    required this.likes,
    required this.id,
    required this.isSaved,
    required this.listUrlGallery,
  });

  factory HotPosts.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    var listUrlImageConstructor = [];
    var listUrlGifConstructor = [];
    var listUrlImageConstructorTmp = [];
    var listUrlVideoConstructor = [];
    var listGallery = [];
    var galleryData = [];
    var urlLogoSub = '';
    int luke = 0;

    if (data['likes'] != null) {
      if (data['likes'] == true) {
        luke = 1;
      } else {
        luke = -1;
      }
    }

    if (data['preview'] != null) {
      if (data['preview']['images'] != null) {
        data['preview']['images'].forEach(
            (item) => listUrlImageConstructor.add(item['source']['url']));
        for (var element in listUrlImageConstructor) {
          listUrlImageConstructorTmp.add(element.replaceAll("amp;", ""));
        }
      }
    }

    if (data['secure_media'] != null) {
      if (data['secure_media']['reddit_video'] != null) {
        if (data['secure_media']['reddit_video']['is_gif'] == true) {
          listUrlGifConstructor
              .add(data['secure_media']['reddit_video']['fallback_url']);
        } else {
          listUrlVideoConstructor
              .add(data['secure_media']['reddit_video']['fallback_url']);
        }
      }
    }

    if (data['gallery_data'] != null) {
      if (data['gallery_data']['items'] != null) {
        data['gallery_data']['items']
            .map((item) => galleryData.add(item.media_id));
      }
    }

    if (galleryData.isNotEmpty) {
      for (var elem in galleryData) {
        var url = data['media_metadata'][elem]['s']['u'];
        listGallery.add(url.replaceAll("amp;", ""));
      }
    }

    if (data['sr_detail'] != null) {
      urlLogoSub = data['sr_detail']['icon_img'];
    }

    return HotPosts(
      listUrlGallery: listGallery,
      score: data['score'],
      id: data['name'],
      title: data['title'],
      subreddit: data['subreddit'],
      selfText: data['selftext'],
      selfTextHtml: data['selftext_html'],
      subredditNamePrefixed: data['subreddit_name_prefixed'],
      urlSubredditToPost: data['url'],
      permalink: data['permalink'],
      numComments: data['num_comments'],
      author: data['author'],
      listUrlImage: listUrlImageConstructorTmp,
      listUrlGif: listUrlGifConstructor,
      listUrlVideo: listUrlVideoConstructor,
      urlAvatarSubreddit: urlLogoSub,
      likes: luke,
      isSaved: data['saved'],
    );
  }
}

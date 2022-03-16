class DataSearch {
  final String name;
  final String imgIcon;

  DataSearch({
    required this.name,
    required this.imgIcon,
  });

  factory DataSearch.fromJson(Map<String, dynamic> json) {
    return DataSearch(
      name: json['name'],
      imgIcon: json['icon_img'],
    );
  }
}

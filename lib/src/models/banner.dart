part of saaf.models;

class BannerAd {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final bool imageOnly;
  final bool isPlusAd;
  final double score;

  BannerAd.fromJson(Map json)
      : id = json["id"],
        title = json["title"],
        subtitle = json["subtitle"],
        description = json["description"],
        image = json["image"],
        imageOnly = json["imageOnly"],
        isPlusAd = json["isPlusAd"],
        score = json["score"];
}

class BannerAdStyle {
  final Color backgroundColor;
  final Color primaryColor;
  final Color titleColor;
  final Color textColor;
  final int titleMaxLines;
  final int subtitleMaxLines;

  const BannerAdStyle({
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 1),
    this.primaryColor = const Color.fromRGBO(79, 70, 229, 1),
    this.titleColor = const Color.fromRGBO(0, 0, 0, 1),
    this.textColor = const Color.fromARGB(255, 32, 32, 32),
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 2,
  });
}

class BannerAdRequest {
  List<String> genres;
  List<String> artists;
  List<String> languages;
  bool explicit;
  List<String> exclude;
  String platform;
  int saafVersion;

  BannerAdRequest({
    this.genres = const [],
    this.artists = const [],
    this.languages = const [],
    this.explicit = false,
    this.exclude = const [],
    required this.platform,
    required this.saafVersion,
  });

  Map<String, dynamic> toJson() => {
        'genres': this.genres,
        'artists': this.artists,
        'languages': this.languages,
        'explicit': this.explicit,
        'exclude': this.exclude,
        'platform': this.platform,
        'saafVersion': this.saafVersion,
      };
}

class BannerAdResponse {
  final String requestId;
  final BannerAd banner;

  BannerAdResponse.fromJson(Map json)
      : requestId = json["requestId"],
        banner = BannerAd.fromJson(json["banner"]);
}

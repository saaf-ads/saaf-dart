part of saaf.models;

class TakeoverAd {
  final String id;
  final String shout;
  final String title;
  final String subtitle;
  final String description;
  final String ctaText;
  final String? inAppNavigate;
  final String image;
  final double score;

  TakeoverAd.fromJson(Map json)
      : id = json["id"],
        shout = json["shout"],
        title = json["title"],
        subtitle = json["subtitle"],
        description = json["description"],
        image = json["image"],
        ctaText = json["ctaText"],
        inAppNavigate = json["inAppNavigate"],
        score = json["score"];
}

class TakeoverAdStyle {
  final Color backgroundColor;
  final Color primaryColor;
  final Color titleColor;
  final Color textColor;

  const TakeoverAdStyle({
    this.backgroundColor = const Color.fromARGB(255, 147, 84, 84),
    this.primaryColor = const Color.fromRGBO(79, 70, 229, 1),
    this.titleColor = const Color.fromRGBO(0, 0, 0, 1),
    this.textColor = const Color.fromARGB(255, 32, 32, 32),
  });
}

class TakeoverAdResponse {
  final String requestId;
  final TakeoverAd takeover;

  TakeoverAdResponse.fromJson(Map json)
      : requestId = json["requestId"],
        takeover = TakeoverAd.fromJson(json["takeover"]);
}

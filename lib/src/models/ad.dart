part of saaf.models;

class AdRequest {
  List<String> genres;
  List<String> artists;
  List<String> languages;
  bool explicit;
  List<String> exclude;
  String platform;
  int saafVersion;

  AdRequest({
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

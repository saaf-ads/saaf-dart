part of saaf;

class BannerAd extends StatefulWidget {
  final BannerAdRequest request;
  final BannerAdStyle style;
  BannerAd({
    Key key,
    @required this.request,
    this.style = const BannerAdStyle(),
  }) : super(key: key);

  @override
  State<BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> {
  BannerAdResponse adResponse;

  @override
  void initState() {
    super.initState();
    this.load();
  }

  Future<BannerAdResponse> load() async {
    print(json.encode(widget.request.toJson()));
    final response = await http.post(
      Uri.parse("https://saaf-api.backtrack.dev/banners/query"),
      body: json.encode(widget.request.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) throw new Exception('failed to load ad');
    this.adResponse = BannerAdResponse.fromJson(json.decode(response.body));
    impression();

    return this.adResponse;
  }

  void impression() async {
    if (this.adResponse == null) return;

    await http.post(
      Uri.parse(
          "https://saaf-api.backtrack.dev/impressions/${adResponse.requestId}"),
      body: json.encode({
        "app": "backtrack",
        "platform": Platform.operatingSystem,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void click() async {
    if (this.adResponse == null) return;

    launch("https://saaf-api.backtrack.dev/clicks/${adResponse.requestId}",
        forceSafariVC: false, forceWebView: false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.5),
      color: widget.style.backgroundColor,
      child: FutureBuilder<BannerAdResponse>(
        future: load(),
        builder: (context, snapshot) {
          Widget child;

          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            child = InkWell(
              borderRadius: BorderRadius.circular(12.5),
              onTap: click,
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7.5),
                          child: CachedNetworkImage(
                            imageUrl: adResponse.banner.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      adResponse.banner.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: widget.style.titleMaxLines,
                                      softWrap: true,
                                      style: TextStyle(
                                        color: widget.style.textColor,
                                        height: 1.1,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              AutoSizeText(
                                adResponse.banner.subtitle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: widget.style.subtitleMaxLines,
                                softWrap: true,
                                style: TextStyle(
                                  color: widget.style.textColor,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.style.backgroundColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.style.primaryColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            "AD",
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.style.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            child = Padding(
              padding: EdgeInsets.all(7),
              child: Center(
                child: Text(
                  "No suitable ad found :‎(",
                  style: TextStyle(
                    color: widget.style.textColor.withOpacity(.5),
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          } else {
            child = ClipRRect(
              borderRadius: BorderRadius.circular(12.5),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "Searching for a relevant ad...",
                      style: TextStyle(
                        color: widget.style.textColor.withOpacity(.5),
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: LinearProgressIndicator(
                      backgroundColor:
                          widget.style.primaryColor.withOpacity(.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.style.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: child,
          );
        },
      ),
    );
  }
}

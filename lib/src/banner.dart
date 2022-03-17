part of saaf;

class BannerAd extends StatelessWidget {
  final BannerAdRequest request;
  final BannerAdStyle style;
  final Function(BannerAdRequest request) onLoad;
  final Function(BannerAdResponse response) onImpression;
  final Function(BannerAdResponse response) onClick;
  final String baseUrl;
  final Widget errorWidget;

  BannerAd({
    Key key,
    @required this.request,
    this.style = const BannerAdStyle(),
    this.onLoad,
    this.onImpression,
    this.onClick,
    this.baseUrl = "https://api.stats.fm/api/v1/saaf",
    @required this.errorWidget,
  }) : super(key: key);

  Future<BannerAdResponse> load() async {
    if (this.onLoad is Function) this.onLoad(this.request);

    final response = await http.post(
      Uri.parse("${this.baseUrl}/banners/query"),
      body: json.encode(this.request.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      print(response.request.url);
      print(response.body);
      throw new Exception('failed to load ad');
    }
    BannerAdResponse adResponse =
        BannerAdResponse.fromJson(json.decode(response.body));
    impression(adResponse);

    return adResponse;
  }

  void impression(adResponse) async {
    if (adResponse == null) return;

    if (this.onImpression is Function) this.onImpression(adResponse);

    await http.post(
      Uri.parse("${this.baseUrl}/impressions/${adResponse.requestId}"),
      body: json.encode({
        "app": "statsfm",
        "platform": Platform.operatingSystem,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void click(adResponse) async {
    if (adResponse == null) return;

    if (this.onClick is Function) this.onClick(adResponse);

    launch("${this.baseUrl}/clicks/${adResponse.requestId}",
        forceSafariVC: false, forceWebView: false);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 70.0 + 7.0 + 7.0,
      ),
      child: FutureBuilder<BannerAdResponse>(
        future: load(),
        builder: (context, snapshot) {
          Widget child;

          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            BannerAdResponse adResponse = snapshot.data;

            if ((adResponse.banner.id ==
                    'd4264616-bd7d-4ec7-b0d6-12046af093a9' ||
                adResponse.banner.id ==
                    '6ec2bc44-3b43-469d-84ec-c062e194f94b' ||
                adResponse.banner.id ==
                    '5c778117-87bd-495f-93d9-7b60f917ea79' ||
                adResponse.banner.id ==
                    'f3323899-c40e-418f-a3f5-c998688e80f5')) {
              if (this.request.genres.indexOf('groovifi-large') > -1) {
                child = buildGroovifiLarge(context, adResponse);
              } else {
                child = buildGroovifiSmall(context, adResponse);
              }
            } else {
              child = Material(
                borderRadius: BorderRadius.circular(12.5),
                color: this.style.backgroundColor,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.5),
                  onTap: () => click(adResponse),
                  child: Padding(
                    padding: EdgeInsets.all(7),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(7.5),
                              child: CachedNetworkImage(
                                imageUrl: adResponse.banner.image,
                                fit: BoxFit.cover,
                                height: 70,
                                width: 70,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: adResponse.banner.title + "\n",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          .copyWith(
                                            color: this.style.titleColor,
                                            height: 1.1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                    ),
                                    TextSpan(
                                      text: adResponse.banner.subtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                            color: this.style.textColor,
                                            height: 1.1,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: this.style.backgroundColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5,
                                  color: this.style.backgroundColor,
                                  offset: Offset(-5, 0),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: this.style.primaryColor.withOpacity(.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.5, vertical: 1.4),
                              child: Text(
                                "AD",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: this.style.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = this.errorWidget;
            // Container(
            //   padding: EdgeInsets.all(7),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(12.5),
            //     color: this.style.backgroundColor,
            //   ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     mainAxisSize: MainAxisSize.max,
            //     children: [
            //       Text(
            //         "Get Spotistats Plus to remove ads",
            //         style: TextStyle(
            //           color: this.style.textColor.withOpacity(.75),
            //           height: 1.1,
            //           fontWeight: FontWeight.bold,
            //           fontSize: 16,
            //         ),
            //       ),
            //       SizedBox(height: 10),
            //       Text(
            //         "No suitable ad found :‎(",
            //         style: TextStyle(
            //           color: this.style.textColor.withOpacity(.5),
            //           height: 1.1,
            //           fontWeight: FontWeight.w500,
            //           fontSize: 14,
            //         ),
            //       ),
            //     ],
            //   ),
            // );
          } else {
            child = Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.5),
                color: this.style.backgroundColor,
              ),
              width: double.infinity,
              height: 70.0 + 7.0 + 7.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.5),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "Searching for a relevant ad...",
                        style: TextStyle(
                          color: this.style.textColor.withOpacity(.5),
                          height: 1.1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            this.style.primaryColor.withOpacity(.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          this.style.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget buildGroovifiSmall(BuildContext context, BannerAdResponse adResponse) {
    return GestureDetector(
      onTap: () => click(adResponse),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: this.style.backgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    "Fine-tune your playlists with",
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: this.style.titleColor,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CachedNetworkImage(
                  imageUrl:
                      'https://cdn.stats.fm/file/saafimages/groovifi.webp',
                  height: 35,
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AutoSizeText(
                    "Turn an ordinary music search engine into a tailored journey that's like music to your ears.",
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: this.style.textColor,
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CachedNetworkImage(
                  imageUrl:
                      'https://cdn.stats.fm/file/saafimages/apple_appstore_badge.webp',
                  height: 30,
                ),
                SizedBox(width: 5),
                CachedNetworkImage(
                  imageUrl:
                      'https://cdn.stats.fm/file/saafimages/google_play_badge.webp',
                  height: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGroovifiLarge(BuildContext context, BannerAdResponse adResponse) {
    return GestureDetector(
      onTap: () => click(adResponse),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: this.style.backgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    "Tune your Spotify with",
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: this.style.titleColor,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CachedNetworkImage(
                  imageUrl:
                      'https://cdn.stats.fm/file/saafimages/groovifi.webp',
                  height: 35,
                )
              ],
            ),
            AutoSizeText(
              "Turn an ordinary music search engine into a tailored journey that's like music to your ears.",
              maxLines: 2,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: this.style.textColor,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl:
                    'https://cdn.stats.fm/file/saafimages/groovifi_screenshot.webp',
                width: double.infinity,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      'https://cdn.stats.fm/file/saafimages/apple_appstore_badge.webp',
                  height: 30,
                ),
                SizedBox(width: 5),
                CachedNetworkImage(
                  imageUrl:
                      'https://cdn.stats.fm/file/saafimages/google_play_badge.webp',
                  height: 30,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: this.style.backgroundColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            color: this.style.backgroundColor,
                            offset: Offset(-5, 0),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: this.style.primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.5, vertical: 1.4),
                        child: Text(
                          "AD",
                          style: TextStyle(
                            fontSize: 9,
                            color: this.style.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

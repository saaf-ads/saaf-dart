part of saaf;

class BannerAd extends StatelessWidget {
  final BannerAdRequest request;
  final BannerAdStyle style;
  final Function(BannerAdRequest request)? onLoad;
  final Function(BannerAdResponse response)? onImpression;
  final Function(BannerAdResponse response)? onClick;
  final Function(BannerAdResponse response) onReport;
  final String baseUrl;
  final Widget errorWidget;

  BannerAd({
    Key? key,
    required this.request,
    this.style = const BannerAdStyle(),
    this.onLoad,
    this.onImpression,
    this.onClick,
    required this.onReport,
    this.baseUrl = "https://api.stats.fm/api/v1/saaf",
    required this.errorWidget,
  }) : super(key: key);

  Future<BannerAdResponse> load() async {
    if (this.onLoad != null) this.onLoad!(this.request);
    
    print('SAAF: Looking for ad...');

    final response = await http.post(
      Uri.parse("${this.baseUrl}/banners/query"),
      body: json.encode(this.request.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      print(response.request?.url);
      print(response.body);
      throw new Exception('failed to load ad');
    }
    BannerAdResponse adResponse =
        BannerAdResponse.fromJson(json.decode(response.body));
    impression(adResponse);

    print('SAAF: Ad found (HTTP:${response.statusCode})');

    return adResponse;
  }

  void impression(adResponse) async {
    if (adResponse == null) return;

    if (this.onImpression != null) this.onImpression!(adResponse);

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

    if (this.onClick != null) this.onClick!(adResponse);

    if ((adResponse.banner.isPlusAd ?? false) != true) {
      launchUrl(
        Uri.parse("${this.baseUrl}/clicks/${adResponse.requestId}"),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await http.get(
        Uri.parse("${this.baseUrl}/clicks/${adResponse.requestId}"),
      );
    }
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
          Widget child = const SizedBox();

          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            BannerAdResponse? adResponse = snapshot.data;
            // adResponse = BannerAdResponse.fromJson(
            //   {
            //     "requestId": "000",
            //     "banner": {
            //       "id": "",
            //       "title":
            //           "Tate McRae's new single \"she's all i wanna be\" is out now!",
            //       "subtitle": "Click here to listen and explore :‎)",
            //       "description": "",
            //       "image":
            //           "https://i.scdn.co/image/ab67616d0000b273f7916a35ffdd6cb90bbbdf2f",
            //       "imageOnly": false,
            //       "isPlusAd": false,
            //       "score": 1.0
            //     }
            //   },
            // );
            if (adResponse == null) {
              child = this.errorWidget;
            }

            if (adResponse != null) {
              if (adResponse.banner.imageOnly) {
                child = buildImageAd(context, adResponse);
              } else {
                child = buildAd(context, adResponse);
              }
            }
          } else if (snapshot.hasError) {
            child = this.errorWidget;
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

  Widget buildImageAd(BuildContext context, BannerAdResponse adResponse) {
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
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl: adResponse.banner.image,
                width: double.infinity,
              ),
            ),
            if (adResponse.banner.isPlusAd != true)
              GestureDetector(
                onTap: () => this.onReport(adResponse),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin:
                        EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 4),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.4),
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
      ),
    );
  }

  Widget buildAd(BuildContext context, BannerAdResponse adResponse) {
    return Material(
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
                            style:
                                Theme.of(context).textTheme.headline1!.copyWith(
                                      color: this.style.titleColor,
                                      height: 1.1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                          ),
                          TextSpan(
                            text: adResponse.banner.subtitle,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
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
              if (adResponse.banner.isPlusAd != true)
                GestureDetector(
                  onTap: () => this.onReport(adResponse),
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
        ),
      ),
    );
  }
}

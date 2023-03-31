# Saaf SDK for Flutter

Docs W.I.P.

## Usage

### Simple Example

#### Code

```dart
Widget buildBannerAd() {
    return SizedBox(
        height: 85,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: BannerAd(
            request: AdRequest(
              genres: ['hiphop'],
              artists: ['0gxyHStUsqpMadRV0Di1Qt', '2iEvnFsWxR0Syqu2JNopAd'],
              languages: ['NL', 'EN'],
              explicit: true,
              exclude: []
            ),
            style: BannerAdStyle(
                backgroundColor: Colors.white,
                textColor: Colors.black,
                primaryColor: Colors.green,
                titleMaxLines: 2,
                subtitleMaxLines: 2,
            ),
        ),
    );
}
```

#### Result

![https://media.discordapp.net/attachments/858019685119295488/928837843239985182/Screenshot_2022-01-07_at_03.29.35.png](image)

## License

[BSD 3-Clause License](./LICENSE)

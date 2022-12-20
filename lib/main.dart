import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';

import 'data.dart';
import 'notification_service.dart';
import 'sabitler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  NotificationService().initNotification();

  runApp(
    MaterialApp(home: AnaSayfa('', false), navigatorKey: navigatorKey),
  );
}

class AnaSayfa extends StatefulWidget {
  String bildirimQuote = '';
  bool bildirimmi = false;
  AnaSayfa(this.bildirimQuote, this.bildirimmi);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

/*void onSelectNotification(String? payload) async {}*/

class _AnaSayfaState extends State<AnaSayfa> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;
  var index = 0;
  int quoteindex = 1;

  final grey = Colors.blueGrey[800];

  void initState() {
    super.initState();

    loadBanneAds();
    Random rnd = new Random();
    index = rnd.nextInt(quoteslist.length - 1);
    NotificationService().showNotification(1, 'Elvis Quote of the Day', 'Body');
    _createInterstitialAd();
  }

  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
  }

  void loadBanneAds() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: elvisbanner,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          print('Failed to load Banner Ad${error.message}');
          _isBannerAdReady = false;
          ad.dispose();
        }),
        request: AdRequest())
      ..load();
  }

  //
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: elvisggecis,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _createInterstitialAd();
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  bildirimsifirla() {
    widget.bildirimmi = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: grey,
        body: Container(
          child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset('assets/images/elv.jpg', fit: BoxFit.cover),
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.6, 1],
                        colors: [
                          grey!.withAlpha(70),
                          grey!.withAlpha(220),
                          grey!.withAlpha(255),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SingleChildScrollView(
                                  child: Text(
                                widget.bildirimmi
                                    ? widget.bildirimQuote
                                    : quoteslist[index],
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    fontFamily: "Ic",
                                    fontSize: 22,
                                    color: Colors.white),
                              )),
                              Text(
                                '-Elvis Presley',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontFamily: "Ic",
                                    fontSize: 22,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: navigationDetay(
                                context,
                                quoteslist.length - 1,
                                widget.bildirimmi
                                    ? widget.bildirimQuote
                                    : quoteslist[index]),
                          ),
                        ),
                      ],
                    )),
              ]),
        ),
        bottomNavigationBar: Container(
          height: _bannerAd.size.height.toDouble(),
          //  width: _bannerAd.size.width.toDouble(),
          width: double.infinity,
          child: _isBannerAdReady
              ? AdWidget(
                  ad: _bannerAd,
                )
              : Text(''),
          //  child: Text(_isBannerAdReady.toString() +
          //      'BANNER REKLAM BURADA OLACAK'),
        ),
      ),
    );
  }

  Row navigationDetay(BuildContext context, int maximum, String quote) {
    Random random = new Random();
    // int randomNumber;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            if (quoteindex % 15 == 0) {
              _showInterstitialAd();
            }
            setState(() {
              bildirimsifirla();
              quotearttir();
              index = random.nextInt(maximum);
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () async {
            //  final directory = getApplicationDocumentsDirectory().toString();
            Share.share(quote + ' -Elvis Presley');
            //    shareQuote();
            //  Share.shareFiles(['${directory.path}/image.jpg'],
            //   text: 'Great picture');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.navigate_before,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              bildirimsifirla();
              quoteindex--;
              index > 0 ? index-- : index;
            });
          },
        ),
        TextButton(
          onPressed: () {},
          child: Text(index.toString() + ' / ' + maximum.toString(),
              style: TextStyle(fontSize: 20)),
        ),
        IconButton(
          icon: Icon(
            Icons.navigate_next_outlined,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            if (quoteindex % 15 == 0) {
              _showInterstitialAd();
            }
            setState(() {
              bildirimsifirla();
              quotearttir();
              index < maximum + -1 ? index++ : index;
            });
          },
        ),
      ],
    );
  }

  void quotearttir() {
    quoteindex++;
  }
}

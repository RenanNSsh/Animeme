import 'package:animemes/core/utils/ad_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:animemes/core/utils/constants.dart';
import 'package:animemes/core/viewmodels/grid_wallpaper_state.dart';
import '../views/wallpaper.dart';
import '../../core/utils/models/response.dart';

class WallpaperList extends StatefulWidget {
  final List<Post> posts;
  final ThemeData themeData;

  WallpaperList({@required this.posts, @required this.themeData});

  @override
  _WallpaperListState createState() => _WallpaperListState();
}

class _WallpaperListState extends State<WallpaperList> {
    static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;
  NativeAd _nativeAd;
  InterstitialAd _interstitialAd;
  int _coins = 0;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }



  @override
  void initState() {
    super.initState(); 
    FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    _interstitialAd = createInterstitialAd();
  }



  @override
  Widget build(BuildContext context) {
    
    return widget.posts.length == 0
        ? SizedBox(
            height: 200,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(FontAwesomeIcons.sadCry,
                      size: 30, color: widget.themeData.accentColor),
                ),
                Text(
                  'Seems like what you are looking for, is empty.',
                  style: widget.themeData.textTheme.bodyText1,
                )
              ],
            ),
          )
        : wallpaperGrid(widget.posts);
  }

  Widget wallpaperGrid(List<Post> list) {
    final dataState = Provider.of<GridWallpaperState>(context);
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.7),
      padding: const EdgeInsets.all(0),
      itemCount: list.length + (dataState.state == kdataFetchState.IS_LOADING ? 1 : 0),
      shrinkWrap: true,
      physics: ScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        if(index < list.length){
          return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                  createBannerAd()
                    ..load()
                    ..show(
                      anchorType: AnchorType.bottom,
                      anchorOffset: 0.0,
                      horizontalCenterOffset: 0.0,
                    );
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WallpaperPage(
                            heroId: 'popular${list[index].name}',
                            posts: list,
                            index: index,
                            dataState: dataState,
                          )));
            },
            child: Hero(
              tag: 'popular${list[index].name}',
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Icon(
                          Icons.error,
                          color: widget.themeData.accentColor,
                        ),
                      ),
                    ),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: widget.themeData.primaryColorDark,
                          child: Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                widget.themeData.accentColor),
                          ))),
                    ),
                    imageUrl:
                        list[index].preview.images[0].resolutions.length <= 3
                            ? widget
                                .posts[index]
                                .preview
                                .images[0]
                                .resolutions[list[index]
                                        .preview
                                        .images[0]
                                        .resolutions
                                        .length -
                                    1]
                                .url
                                .replaceAll('amp;', '')
                            : list[index]
                                .preview
                                .images[0]
                                .resolutions[3]
                                .url
                                .replaceAll('amp;', ''),
                  ),
                ),
              ),
            ),
          ),
        );
        }else{
          return Center(
            child:CircularProgressIndicator()
          );
        }
        // return Container(
        //   height: 30,
        //   width: 30,
        //   child: Center(
        //     child: RaisedButton(child: Text('Load More'),onPressed: (){
        //       dataState.fetchWallPapers();
        //     },),
        //   ),
        // );
      },
    );
  }
}

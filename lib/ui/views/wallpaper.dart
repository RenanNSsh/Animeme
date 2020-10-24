import 'dart:io';

import 'package:animemes/core/utils/ad_manager.dart';
import 'package:animemes/core/viewmodels/grid_wallpaper_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:animemes/core/utils/theme.dart';
import 'web_page.dart';
import '../../core/utils/dialog_utils.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/general.dart';
import 'package:share/share.dart';
import '../../core/utils/models/response.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';

import 'package:http/http.dart' as http;

class WallpaperPage extends StatefulWidget {
  final String heroId;
  final List<Post> posts;
  final int index;
  final GridWallpaperState dataState;

  WallpaperPage(
      {@required this.heroId, @required this.posts, @required this.index, this.dataState});
  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  BoxFit fit = BoxFit.contain;
  Post currentPost;
  static const platform = const MethodChannel('com.renannnsh.animemes/wallpaper');
  PageController _pageController;
  InterstitialAd _interstitialAd;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    childDirected: true,
    nonPersonalizedAds: true,
  );

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
    currentPost = widget.posts[widget.index];
    _interstitialAd = createInterstitialAd();
    _pageController = PageController(
      initialPage: widget.index,
    );
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
                _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeNotifier>(context);
    final themeData = themeState.getTheme();
    return Scaffold(
      body: wallpaperBody(themeData),
    );
  }

  void downloadImage() async {
    try {
      PermissionStatus status = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);

      if (status == PermissionStatus.granted) {
        try {
          showToast('Cheque a barra de notificações para ver o progresso.');
          var directoryPath = (await getExternalStorageDirectory()).path;
          var imageId = await ImageDownloader.downloadImage(currentPost.url,
              destination: AndroidDestinationType.custom(directory: '$directoryPath/Animeme${DateTime.now().toIso8601String()}.png'));
          if (imageId == null) {
            return;
          }
        } on PlatformException catch (error) {
          print(error);
        }
      } else {
        askForPermission();
      }
    } catch (e) {
      print(e);
    }
  }

  void askForPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (status == PermissionStatus.granted) {
      downloadImage();
    } else {
      showToast('Por favor, conceda permissão de armazenamento.');
    }
  }

  void _setWallpaper() async {
    var file = await DefaultCacheManager().getSingleFile(currentPost.url);
    try {
      final int result = await platform.invokeMethod('setWallpaper', file.path);
      print('Wallpaer Updated.... $result');
    } on PlatformException catch (e) {
      print("Failed to Set Wallpaer: '${e.message}'.");
    }
    Navigator.pop(context);
  }

  void showToast(String content) => Fluttertoast.showToast(
      msg: content,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);

  Widget bottomSheet(ThemeData themeData) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
        color: themeData.primaryColorDark.withOpacity(0.9),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Text(
          //   currentPost.title,
          //   style: themeData.textTheme.bodyText2,
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
          // Text(
          //   'Posted on r/${currentPost.subreddit} by u/${currentPost.author}',
          //   style: themeData.textTheme.bodyText1,
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
          Row(
            children: <Widget>[
              // ColButton(
              //   title: 'Set Wallpaper',
              //   icon: Icons.wallpaper,
              //   onTap: () async {
              //     showLoadingDialog(context);
              //     await Future.delayed(Duration(seconds: 1));
              //     _setWallpaper();
              //   },
              // ),
              ColButton(
                title: 'Download',
                icon: Icons.file_download,
                onTap: downloadImage,
              ),
              ColButton(
                title: 'Compartilhar',
                icon: Icons.share,
                onTap: () {
                  saveAndShare(currentPost.url, currentPost.title);
                },
              ),
              // ColButton(
              //   title: 'Source',
              //   icon: Icons.open_in_browser,
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => WebPage(
              //                   title: currentPost.title,
              //                   initialPage: 'https://www.reddit.com' +
              //                       currentPost.permalink,
              //                 )));
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  String getFileName(String imageUrl, String imageName ){
    imageName = imageName.replaceAll(' ', '');
    imageName = imageName.replaceAll('/', '');
    var nameIndex = imageUrl.lastIndexOf('/');
    String fileName = '${imageName}.png';
    if(nameIndex != -1 && nameIndex != imageName.length-1){
      var fileNameImage = imageUrl.substring(nameIndex+1, imageUrl.length);
      if(fileNameImage.isNotEmpty){
        fileName = fileNameImage;
      }
    }
    return fileName;
  }

  Future<Null> saveAndShare(String imageUrl, String imageName) async {
    String fileName = getFileName(imageUrl,imageName);

    final RenderBox box = context.findRenderObject();
    if (Platform.isAndroid) {
      var url = imageUrl;
      var response = await http.get(url);
      final documentDirectory = (await getExternalStorageDirectory()).path;
      File imgFile = new File('$documentDirectory/$fileName');
      imgFile.writeAsBytesSync(response.bodyBytes);

      Share.shareFile(File('$documentDirectory/$fileName'),
          subject: 'Meme do APP Animeme',
          text: 'Ei, olha só esse meme que vi no app "Animeme"',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      Share.share('Meme do APP Animeme',
          subject: 'Ei, olha só esse meme que vi no app "Animeme"',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  Widget wallpaperBody(ThemeData themeData) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (_controller.isCompleted) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            },
            child: Hero(
              tag: widget.heroId,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: themeData.primaryColor,
                child: PageView(
                  controller: _pageController,
                  physics: BouncingScrollPhysics(),
                  onPageChanged: (index) async{
                    createInterstitialAd()
                      ..load()
                      ..show(
                        anchorType: AnchorType.bottom,
                        anchorOffset: 0.0,
                        horizontalCenterOffset: 0.0,
                    );
                    if(index >= widget.posts.length -5){
                      await widget.dataState.fetchWallPapers();
                    }
                    setState(() {
                      currentPost = widget.posts[index];
                    });
                  },
                  children: widget.dataState.posts
                      .map(
                        (item) => 
                        CachedNetworkImage(
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                                child: Icon(
                              Icons.error,
                              color: themeData.accentColor,
                            )),
                          ),
                          fit: fit,
                          placeholder: (context, url) => Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              // PhotoView(
                              //   imageProvider: NetworkImage(
                              //     item.preview.images[0].resolutions[0].url,
                                  
                              //   ),
                                
                              // ),
                              Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      themeData.accentColor),
                                ),
                              ),
                            ],
                          ),
                          imageUrl: item.url,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Transform.translate(
                  offset: Offset(0, -_controller.value * 80),
                  child: Container(
                    height: 80.0,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: themeData.primaryColorDark.withOpacity(0.9),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: themeData.textTheme.bodyText2.color,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        // IconButton(
                        //   icon: Icon(
                        //     fit == BoxFit.contain
                        //         ? Icons.fullscreen
                        //         : Icons.fullscreen_exit,
                        //     color: themeData.textTheme.bodyText2.color,
                        //   ),
                        //   onPressed: () {
                        //     if (fit == BoxFit.contain) {
                        //       fit = BoxFit.cover;
                        //     } else {
                        //       fit = BoxFit.contain;
                        //     }
                        //     setState(() {});
                        //   },
                        // )
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, _controller.value * 150),
                  child: bottomSheet(themeData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

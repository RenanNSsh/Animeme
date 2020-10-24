import 'package:provider/provider.dart';
import 'package:animemes/core/utils/constants.dart';
import 'package:animemes/core/viewmodels/carousel_wallpaper_state.dart';
import 'package:animemes/core/viewmodels/grid_wallpaper_state.dart';
import '../widgets/new.dart';
import '../widgets/popular.dart';
import 'package:flutter/material.dart';

class MainBody extends StatefulWidget {
  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody>
    with AutomaticKeepAliveClientMixin<MainBody> {

  ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() { 
    super.initState();
    _scrollController.addListener(() { 
      if(_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent * 0.7)){
        print('atual: ${_scrollController.position.pixels}');
        print('max: ${_scrollController.position.maxScrollExtent}');
        final dataState = Provider.of<GridWallpaperState>(context);
        dataState.fetchWallPapers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      shrinkWrap: true,
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        ChangeNotifierProvider(
          builder: (_) =>
              CarouselWallpaperState(kdataFetchState.IS_LOADING, null),
          child: NewWallpapers(),
        ),
        PopularWallpapers(),
        
      ],
    );
  }
}

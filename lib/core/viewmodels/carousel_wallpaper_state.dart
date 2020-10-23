import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:re_walls/core/utils/api_endpoints.dart';
import 'package:re_walls/core/utils/subreddits.dart';
import 'package:re_walls/models/video.dart';
import 'package:re_walls/ui/views/selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/models/response.dart';
import 'package:http/http.dart' as http;

const SEARCH = 'Best of Anime Crack';
const API_KEY = 'AIzaSyAWUZK3RVI8-VQkf_8UwBRzA08n5h7HWco';

class CarouselWallpaperState extends ChangeNotifier {
  List<Post> _posts;
  List<Video> _videos;
  kdataFetchState _fetchState;

  int _selectedFilter;
  List<String> _subreddits, _selectedSubreddit;

  CarouselWallpaperState(this._fetchState, this._posts) {
    prepareSharedPrefs();
  }

  get posts => _posts;
  get videos => _videos;
  get state => _fetchState;
  get selectedSubreddit => _selectedSubreddit;
  get selectedFilter => _selectedFilter;
  get subreddits => _subreddits;

  prepareSharedPrefs() async {
    SharedPreferences.getInstance().then((preferences) {
      _subreddits =
          preferences.getStringList('subredditsList') ?? initialSubredditsList;
      _selectedFilter = preferences.getInt('carousel_filter') ?? 0;
      _selectedSubreddit = preferences.getStringList('carousel_subreddit') ??
          [_subreddits[0], _subreddits[1]];

      fetchWallPapers(EndPoints.getPosts(_selectedSubreddit.join('+'),
          kfilterValues[_selectedFilter].toLowerCase()));
    });
  }

  fetchWallPapers(String subreddit) async {
    _fetchState = kdataFetchState.IS_LOADING;
    notifyListeners();
    try {
      const YOUTUBE_API = 'https://www.googleapis.com/youtube/v3/search?regionCode=US&part=snippet&q=$SEARCH&type=video&key=$API_KEY&maxResults=20';
      http.get(YOUTUBE_API).then((res) {
        _videos =_decode(res);
        _fetchState = kdataFetchState.IS_LOADED;
        notifyListeners();
      
      });
    } catch (e) {
      _fetchState = kdataFetchState.ERROR_ENCOUNTERED;
      notifyListeners();
    }
  }


  fetchNextVideos(String subreddit) async {
    _fetchState = kdataFetchState.IS_LOADING;
    notifyListeners();
    try {
      const YOUTUBE_API = 'https://www.googleapis.com/youtube/v3/search?regionCode=US&part=snippet&q=$SEARCH&type=video&key=$API_KEY&maxResults=20';
      http.get(YOUTUBE_API).then((res) {
        _videos =_decode(res);
        _fetchState = kdataFetchState.IS_LOADED;
        notifyListeners();
      
      });
    } catch (e) {
      _fetchState = kdataFetchState.ERROR_ENCOUNTERED;
      notifyListeners();
    }
  }

  


  List<Video> _decode(http.Response response){
    if(response.statusCode == 200){
      var decoded = json.decode(response.body);
      List<Video> videos = decoded['items'].map<Video>(
        (map){
          return Video.fromJson(map);
        }
      ).toList();
      return videos;
    }else {
      _fetchState = kdataFetchState.ERROR_ENCOUNTERED;
      notifyListeners();
    }
  }

  changeSelected(SelectorCallback selected) {
    _selectedFilter = selected.selectedFilter;
    _selectedSubreddit = selected.selectedSubreddits;
    SharedPreferences.getInstance().then((preferences) {
      preferences.setInt('carousel_filter', _selectedFilter);
      preferences.setStringList('carousel_subreddit', _selectedSubreddit);
      prepareSharedPrefs();
    });
  }
}

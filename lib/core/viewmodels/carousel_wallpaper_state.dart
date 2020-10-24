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

const SEARCH = 'Novos Memes';
const API_KEY = 'AIzaSyAWUZK3RVI8-VQkf_8UwBRzA08n5h7HWco';

class CarouselWallpaperState extends ChangeNotifier {
  List<Post> _posts;
  List<Video> _videos;
  String search = '';
  kdataFetchState _fetchState;

  int _selectedFilter;
  int currentCall = 0;
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
      _selectedFilter = preferences.getInt('carousel_filter') ?? 1;
      _selectedSubreddit = preferences.getStringList('carousel_subreddit') ??
          ['AnimemeBR'];

      fetchWallPapers(EndPoints.getPosts(_selectedSubreddit.join('+'),
          kfilterValues[_selectedFilter].toLowerCase()));
    });
  }

  fetchMemes(String endpoint){

    currentCall++;
    var lastCall = currentCall;
    Future.delayed(Duration(milliseconds: 500)).then((x){

      if(lastCall == currentCall){
        _fetchState = kdataFetchState.IS_LOADING;
        
        notifyListeners();
        try {
          http.get(endpoint).then((res) {
            if (res.statusCode == 200) {
              var decodeRes = jsonDecode(res.body);
              Reddit temp = Reddit.fromJson(decodeRes);

              if(posts == null){ 
                _posts = [];  
              }
              temp.data.children.forEach((children) {
                if (children.post.postHint == 'image') {
                  if(posts.any((x){return x.name == children.post.name;}) ){
                    children.post.name = '${children.post.name}$currentCall';
                  }
                  posts.add(children.post);
                }
              });
            

              _fetchState = kdataFetchState.IS_LOADED;
              print('notify: ${posts.length}');
              notifyListeners();
            } else {
              _fetchState = kdataFetchState.ERROR_ENCOUNTERED;
              notifyListeners();
            }
          });
        } catch (e) {
          _fetchState = kdataFetchState.ERROR_ENCOUNTERED;
          notifyListeners();
        }
      }
    });
  }

  fetchWallPapers([String subreddit]) async {
    if(subreddit != null){
      search = subreddit;
    }
    var page = 'limit=15';
    fetchMemes('$search?$page');
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

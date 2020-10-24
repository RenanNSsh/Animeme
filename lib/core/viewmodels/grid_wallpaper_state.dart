import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:animemes/core/utils/api_endpoints.dart';
import 'package:animemes/core/utils/subreddits.dart';
import 'package:animemes/ui/views/selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/models/response.dart';
import 'package:http/http.dart' as http;

class GridWallpaperState extends ChangeNotifier {
  Data _data;
  List<Post> posts;
  int currentCall = 0;
  String search;
  kdataFetchState _fetchState;

  int _selectedFilter;
  List<String> _subreddits, _selectedSubreddit;

  GridWallpaperState(this._fetchState) {
    prepareSharedPrefs();
  }

  get state => _fetchState;
  get selectedSubreddit => _selectedSubreddit;
  get selectedFilter => _selectedFilter;
  get subreddits => _subreddits;

  prepareSharedPrefs() async {
    SharedPreferences.getInstance().then((preferences) {
      _subreddits =
          preferences.getStringList('subredditsList') ?? initialSubredditsList;
      _selectedFilter = preferences.getInt('list_filter') ?? 0;
      _selectedSubreddit = preferences.getStringList('list_subreddit') ??
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
                posts = [];  
              }
              if(_data== null || _data.after != temp.data.after){
                _data = temp.data;
                temp.data.children.forEach((children) {
                  if (children.post.postHint == 'image') {
                    if(posts.any((x){return x.name == children.post.name;}) ){
                      children.post.name = '${children.post.name}$currentCall';
                    }
                    posts.add(children.post);
                  }
                });

              }

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
    var page = '';
    if(_data != null && _data.after != null && _data.after.isNotEmpty ){
      page = 'after=${_data.after}';
    }
    fetchMemes('$search?$page');
  }

  changeSelected(SelectorCallback selected) {
    _selectedFilter = selected.selectedFilter;
    _selectedSubreddit = selected.selectedSubreddits;
    SharedPreferences.getInstance().then((preferences) {
      preferences.setInt('list_filter', _selectedFilter);
      preferences.setStringList('list_subreddit', _selectedSubreddit);
      prepareSharedPrefs();
    });
  }
}

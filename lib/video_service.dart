import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:animemes/models/video.dart';

const API_KEY = 'AIzaSyAWUZK3RVI8-VQkf_8UwBRzA08n5h7HWco';

class VideoService{
  search(String search) async{
    http.Response response = await http.get('https://www.googleapis.com/youtube/v3/search?part=snippet&q=$search&type=video&key=$API_KEY&maxResults=10');
    _decode(response);
  }

  _decode(http.Response response){
    if(response.statusCode == 200){
      var decoded = json.decode(response.body);
      List<Video> videos = decoded['items'].map<Video>(
        (map){
          return Video.fromJson(map);
        }
      ).toList();
      print(videos.first.thumb);
    }
  }
}
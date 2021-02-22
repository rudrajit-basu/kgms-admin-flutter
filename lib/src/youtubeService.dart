import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'model/youtubeModel.dart';

const channelIdY = 'UCuS-pL1W9DnAgw0ju4rDOKA';
const playlistsYUrl = 'https://www.googleapis.com/youtube/v3/playlists';
// ?part=snippet&channelId=$channelIdY&maxResults=8
const playlistItemsYUrl = 'https://www.googleapis.com/youtube/v3/playlistItems';
const uploadItemYurl = 'https://www.googleapis.com/upload/youtube/v3/videos';
const updateItemYurl = 'https://www.googleapis.com/youtube/v3/videos';
//const insertPlaylistItemYurl = 'https://www.googleapis.com/youtube/v3/playlistItems';
//const deletePlaylistItemYurl = 'https://www.googleapis.com/youtube/v3/playlistItems';

//[
//'https://www.googleapis.com/auth/youtube.readonly',
//'https://www.googleapis.com/auth/youtube.upload',
//'https://www.googleapis.com/auth/youtubepartner'
//]

class YoutubeServ {
  OAuth2Helper _oauth2Helper;

  Future<OAuth2Helper> get oauth2Helper async {
    if (_oauth2Helper == null) {
      GoogleOAuth2Client client = GoogleOAuth2Client(
          customUriScheme:
              'com.googleusercontent.apps.817681647082-tc6afavlps6e81u3ckdrd4h9o252phr7',
          redirectUri:
              'com.googleusercontent.apps.817681647082-tc6afavlps6e81u3ckdrd4h9o252phr7:/oauth2redirect');

      print('GoogleOAuth2Client completed -->');

      try {
        _oauth2Helper = OAuth2Helper(client,
            grantType: OAuth2Helper.AUTHORIZATION_CODE,
            clientId:
                '817681647082-tc6afavlps6e81u3ckdrd4h9o252phr7.apps.googleusercontent.com',
            scopes: [
              'https://www.googleapis.com/auth/youtube',
              'https://www.googleapis.com/auth/youtube.upload',
              'https://www.googleapis.com/auth/youtubepartner',
            ]);

        print('OAuth2Helper completed -->');
      } catch (e) {
        _oauth2Helper = null;
        print('OAuth2Helper error --> $e');
      }
    }
    return _oauth2Helper;
  }

  bool get isOauthValid => _oauth2Helper != null ? true : false;

  Future<String> getYtPlaylist(String classId) async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      final playlistsReqStr =
          playlistsYUrl + '?part=snippet&channelId=$channelIdY&maxResults=20';
      var resp = await _oHelper.get(playlistsReqStr);
      print('resp completed -->');
      if (resp.statusCode == 200) {
        print('resp status code 200');
        var jsonResp = null;
        try {
          jsonResp = convert.jsonDecode(resp.body);
        } on FormatException catch (e) {
          print('jsonResp is not valid json');
        }
        if (jsonResp != null) {
          //String _playlistsEtag = jsonResp['etag'] as String;
          //print('playList etag ---> ${_playlistsEtag}');
          var jsonArr = jsonResp['items'] as List;
          List<VideoListTag> _tags =
              jsonArr.map((tagJson) => VideoListTag.fromJson(tagJson)).toList();
          //cacheServ.setEtag(playlistsYUrl, _playlistsEtag);
          //databaseServ.insertPlaylist(_tags);
          var _playlistId = null;
          for (final tag in _tags) {
            if (tag.snippet.title == classId) {
              _playlistId = tag.id;
              //print(tag.toString());
              break;
            }
          }
          return _playlistId;
        }
      } else {
        print('resp status --> ${resp.statusCode}');
        print('resp headers --> ${resp.headers}');
        print('resp body --> ${resp.body}');
      }
    }
    return null;
  }

  Future<String> getYtPlaylistItem(String playlistID) async {
    //String playlistID = await _getYtPlaylist(classId);
    final _oHelper = await oauth2Helper;
    if (playlistID != null) {
      if (_oHelper != null) {
        final playlistItemsReqStr = playlistItemsYUrl +
            '?part=snippet&part=status&playlistId=$playlistID&maxResults=20';
        print('playlistItems req str --> $playlistItemsReqStr');
        var resp = await _oHelper.get(playlistItemsReqStr);
        if (resp.statusCode == 200) {
          var jsonResp = null;
          try {
            jsonResp = convert.jsonDecode(resp.body);
          } on FormatException catch (e) {
            print('jsonResp is not valid json');
          }
          if (jsonResp != null) {
            var jsonArr = jsonResp['items'] as List;
            List<VideoItemTag> _tags = jsonArr
                .map((tagJson) => VideoItemTag.fromJson(tagJson))
                .toList();
            String jsonTags = convert.jsonEncode(_tags);
            return jsonTags;
          } else {
            print('jsonResp is null');
            return 'Play List Item json is null';
          }
        } else {
          print('resp status --> ${resp.statusCode}');
          print('resp headers --> ${resp.headers}');
          print('resp body --> ${resp.body}');
          return 'status code not 200';
        }
      } else {
        return 'oauth is null';
      }
    } else {
      return 'playlistId is null';
    }
  }

  Future<String> uploadFileToYoutube(String filePath, String userAgent) async {
    final _oHelper = await oauth2Helper;

    print('url --> $uploadItemYurl');
    //print('body --> $data');
    print('file path --> $filePath');
    //print('user Agent(uploadFileToYoutube) --> $userAgent');

    if (_oHelper != null) {
      try {
        final File _videoFile = File(filePath);
        var strm = await _videoFile.readAsBytes();
        var strmLen = _videoFile.lengthSync();
        print('video len --> $strmLen');
        Map<String, String> headers = <String, String>{
          'Content-Type': 'application/octet-stream',
          'Content-Length': '$strmLen',
          'User-Agent': userAgent
        };
        var resp = await _oHelper.post(uploadItemYurl,
            headers: headers, body: strm.toList());
        //var resp = await this._oauth2Helper.post();
        print('resp from upload completed');
        if (resp.statusCode == 200) {
          print('status code is 200');
          //print(resp.headers);
          //print(resp.body);
          var jsonResp = null;
          try {
            jsonResp = convert.jsonDecode(resp.body);
          } on FormatException catch (e) {
            print('jsonResp is not valid json');
          }
          if (jsonResp != null) {
            String _videoId = jsonResp['id'] as String;
            print('video insert id --> $_videoId');
            return _videoId;
          }
        } else {
          print('status code is not 200');
          print(resp.headers);
          print(resp.body);
        }
      } catch (e) {
        print('error during upload --> $e');
      }
    } else {
      print('oauth is null');
    }
    return null;
  }

  Future<bool> updateYtVideo(
      String vid, String title, String className, String userAgent) async {
    //print('user Agent(updateYtVideo) --> $userAgent');
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      var vSnippetTag = UploadVideoSnippetTag(title, className);
      var vUpdateTag =
          UploadVideoUpdateTag(vid, vSnippetTag, UploadVideoStatusTag());
      String jsonStr = convert.jsonEncode(vUpdateTag);
      print('jsonStr --> $jsonStr');
      final updateItemYurlStr = updateItemYurl + '?part=snippet%2Cstatus';
      http.Response resp =
          await ytPutMethod(updateItemYurlStr, _oHelper, jsonStr, userAgent);
      print('resp from update completed');
      if (resp != null) {
        if (resp.statusCode == 200) {
          print('status code is 200');
          print(resp.headers);
          print(resp.body);
          return true;
        } else {
          print('status code is ${resp.statusCode}');
          print(resp.headers);
          print(resp.body);
        }
      } else {
        print('resp is null');
      }
    }
    return false;
  }

  Future<http.Response> ytPutMethod(String url, OAuth2Helper oHelper,
      String jsonStr, String userAgent) async {
    var tknResp = await oHelper.getToken();
    http.Response resp;
    try {
      var headers1 = getHeaders1(tknResp.accessToken, userAgent);
      resp = await http.Client().put(url, headers: headers1, body: jsonStr);
      if (resp.statusCode == 401) {
        print('ytPutMethod status = 401');
        if (tknResp.hasRefreshToken()) {
          tknResp = await oHelper.refreshToken(tknResp.refreshToken);
        } else {
          tknResp = await oHelper.fetchToken();
        }

        if (tknResp != null) {
          var headers2 = getHeaders1(tknResp.accessToken, userAgent);
          resp = await http.Client().put(url, headers: headers2, body: jsonStr);
        }
      }
      return resp;
    } catch (e) {
      print('error ytPutMethod --> $e');
    }
    return null;
  }

  Map<String, String> getHeaders1(String token, String userAgent) {
    Map<String, String> headers = Map<String, String>();
    headers['Authorization'] = 'Bearer ' + token;
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    headers['User-Agent'] = userAgent;
    return headers;
  }

  Future<String> getYtRecyclePlaylist(String classId) async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      final playlistsReqStr =
          playlistsYUrl + '?part=snippet&channelId=$channelIdY&maxResults=20';
      var resp = await _oHelper.get(playlistsReqStr);
      if (resp.statusCode == 200) {
        print('status code is 200');
        var jsonResp = null;
        try {
          jsonResp = convert.jsonDecode(resp.body);
        } on FormatException catch (e) {
          print('jsonResp is not valid json');
        }
        if (jsonResp != null) {
          var jsonArr = jsonResp['items'] as List;
          List<VideoListTag> _tags =
              jsonArr.map((tagJson) => VideoListTag.fromJson(tagJson)).toList();
          var _playlistId = null;
          final pTitle = classId + '_recycle_bin';
          for (final tag in _tags) {
            if (tag.snippet.title == pTitle) {
              _playlistId = tag.id;
              break;
            }
          }
          return _playlistId;
        }
      } else {
        print('resp status --> ${resp.statusCode}');
        print('resp headers --> ${resp.headers}');
        print('resp body --> ${resp.body}');
      }
    } else {
      print('oauth is null');
    }
    return null;
  }

  Future<String> setYtVideoToPlaylist(
      String playlistId, String videoId, String userAgent) async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      var _vResourceTag = UpdateVideoPlaylistResourceTag(videoId);
      var _vSnippetTag =
          UpdateVideoPlaylistSnippetTag(playlistId, _vResourceTag);
      var _vUpdatePlaylistTag = UpdateVideoPlaylistTag(_vSnippetTag);
      String jsonStr = convert.jsonEncode(_vUpdatePlaylistTag);
      print('setYtVideoToPlaylist --> $jsonStr');
      final postReqStr = playlistItemsYUrl + '?part=snippet%2Cstatus';
      print('postReqStr --> $postReqStr');
      Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': userAgent
      };
      var resp =
          await _oHelper.post(postReqStr, headers: headers, body: jsonStr);
      print('setYtVideoToPlaylist req completed !');
      if (resp.statusCode == 200) {
        print('status code is 200');
        //print('resp headers --> ${resp.headers}');
        //print('resp body --> ${resp.body}');
        var jsonResp = null;
        try {
          jsonResp = convert.jsonDecode(resp.body);
        } on FormatException catch (e) {
          print('jsonResp is not valid json');
        }
        if (jsonResp != null) {
          VideoItemTag itemTag = VideoItemTag.fromJson(jsonResp);
          String itemTagStr = convert.jsonEncode(itemTag);
          print('itemTagStr --> $itemTagStr');
          return itemTagStr;
        }
        //return true;
      } else {
        print('resp status --> ${resp.statusCode}');
        print('resp headers --> ${resp.headers}');
        print('resp body --> ${resp.body}');
      }
    }
    return null;
  }

  Future<bool> removeYtVideoFromPlaylist(String id, String userAgent) async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      final delReqStr = playlistItemsYUrl + '?id=$id';
      print('delReqStr --> $delReqStr');
      Map<String, String> headers = <String, String>{
        'Accept': 'application/json',
        'User-Agent': userAgent
      };
      var resp = await _oHelper.delete(delReqStr, headers: headers);
      print('removeYtVideoFromPlaylist req completed !');
      if (resp.statusCode == 204) {
        print('status code is 204');
        return true;
      } else {
        print('resp status --> ${resp.statusCode}');
        print('resp headers --> ${resp.headers}');
      }
    }
    return false;
  }
}

YoutubeServ yServ = new YoutubeServ();

//Map<String, Object> body = {
//  "id": "$vid",
//  "snippet": {
//    "categoryId": "22",
//    "description": "This description is in English.",
//    "title": "There is nothing to see here."
//  },
//  "status": {
//    "privacyStatus": "unlisted",
//    "selfDeclaredMadeForKids": true,
//    "embeddable": true
//  }
//};

//Future<bool> updateYtVideo(
//      String vid, String title, String className, String userAgent) async {
//    //print('user Agent(updateYtVideo) --> $userAgent');
//    final _oHelper = await oauth2Helper;
//    if (_oHelper != null) {
//      var vSnippetTag = UploadVideoSnippetTag(title, className);
//      var vUpdateTag =
//          UploadVideoUpdateTag(vid, vSnippetTag, UploadVideoStatusTag());
//      String jsonStr = convert.jsonEncode(vUpdateTag);
//      print('jsonStr --> $jsonStr');
//      final updateItemYurlStr = updateItemYurl + '?part=snippet%2Cstatus';
//      //yHttpClient = http.Client();
//      var tknResp = await _oHelper.getToken();
//      http.Response resp;
//      try {
//        var headers1 = getHeaders1(tknResp.accessToken, userAgent);
//        //print('headers --> $headers');
//        resp = await http.Client()
//            .put(updateItemYurlStr, headers: headers1, body: jsonStr);

//        if (resp.statusCode == 401) {
//          print('updateYtVideo status = 401');
//          if (tknResp.hasRefreshToken()) {
//            tknResp = await _oHelper.refreshToken(tknResp.refreshToken);
//          } else {
//            tknResp = await _oHelper.fetchToken();
//          }

//          if (tknResp != null) {
//            var headers2 = getHeaders1(tknResp.accessToken, userAgent);
//            resp = await http.Client()
//                .put(updateItemYurlStr, headers: headers2, body: jsonStr);
//          }
//        }
//      } catch (e) {
//        print('error update --> $e');
//      }
//      print('resp from update completed');
//      if (resp.statusCode == 200) {
//        print('status code is 200');
//        print(resp.headers);
//        print(resp.body);
//        return true;
//      } else {
//        print('status code is ${resp.statusCode}');
//        print(resp.headers);
//        print(resp.body);
//      }
//    }
//    return false;
//  }

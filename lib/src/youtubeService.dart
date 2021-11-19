import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'model/youtubeModel.dart';
import 'localFileStorageService.dart';
import 'dart:core';
import 'package:async/async.dart' show AsyncCache;

const _channelIdY = 'UCuS-pL1W9DnAgw0ju4rDOKA';
const _playlistsYUrl = 'https://www.googleapis.com/youtube/v3/playlists';
// ?part=snippet&channelId=$_channelIdY&maxResults=8
const _playlistItemsYUrl =
    'https://www.googleapis.com/youtube/v3/playlistItems';
const _uploadItemYurl = 'https://www.googleapis.com/upload/youtube/v3/videos';
const _updateItemYurl = 'https://www.googleapis.com/youtube/v3/videos';
const _recycleBinPlaylistId = 'PLyjpT0r_xK0dFPjDs9Hgi7qTs_S5VkFBO';
const _userChannelUploadedVideoYurl =
    'https://www.googleapis.com/youtube/v3/channels';
//const _recycleBinPlaylistId = 'PLBCF2DAC6FFB574DE';
//const insertPlaylistItemYurl = 'https://www.googleapis.com/youtube/v3/playlistItems';
//const deletePlaylistItemYurl = 'https://www.googleapis.com/youtube/v3/playlistItems';

//[
//'https://www.googleapis.com/auth/youtube.readonly',
//'https://www.googleapis.com/auth/youtube.upload',
//'https://www.googleapis.com/auth/youtubepartner'
//]

final _getYtPlaylistIdsCache = AsyncCache<String>(const Duration(minutes: 45));

class YoutubeServ {
  OAuth2Helper _oauth2Helper;
  String _userChannelUploadedVideoPlaylistId;

  Future<OAuth2Helper> get oauth2Helper async {
    if (_oauth2Helper == null) {
      GoogleOAuth2Client client = GoogleOAuth2Client(
          customUriScheme:
              'com.googleusercontent.apps.817681647082-tc6afavlps6e81u3ckdrd4h9o252phr7',
          redirectUri:
              'com.googleusercontent.apps.817681647082-tc6afavlps6e81u3ckdrd4h9o252phr7:/oauth2redirect');

      //print('GoogleOAuth2Client completed -->');

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

        //print('OAuth2Helper completed -->');
      } catch (e) {
        _oauth2Helper = null;
        print('OAuth2Helper error --> $e');
      }
    }
    return _oauth2Helper;
  }

  bool get isOauthValid => _oauth2Helper != null ? true : false;

  Future<String> get getYtPlaylistIdsCache =>
      _getYtPlaylistIdsCache.fetch(() => _getYtPlaylistIds());

  void resetYtPlaylistIdsCache() {
    _getYtPlaylistIdsCache.invalidate();
  }

  Future<String> _getYtPlaylistIds() async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      final playlistsReqStr =
          _playlistsYUrl + '?part=snippet&channelId=$_channelIdY&maxResults=20';
      var resp = await _oHelper.get(playlistsReqStr);
      //print('resp completed -->');
      if (resp.statusCode == 200) {
        //print('resp status code 200');
        var jsonResp = null;
        try {
          jsonResp = convert.jsonDecode(resp.body);
        } on FormatException catch (e) {
          print('jsonResp is not valid json');
        }
        if (jsonResp != null) {
          var jsonArr = jsonResp['items'] as List;
          final List<VideoListTag> _tags =
              jsonArr.map((tagJson) => VideoListTag.fromJson(tagJson)).toList();

          String _jsonArrStr = convert.jsonEncode(_tags);

          return _jsonArrStr;
        }
      } else {
        print('resp status --> ${resp.statusCode}');
        //print('resp headers --> ${resp.headers}');
        //print('resp body --> ${resp.body}');
      }
    }
    return null;
  }

  //Future<String> getYtPlaylist(String classId) async {
  //  final _oHelper = await oauth2Helper;
  //  if (_oHelper != null) {
  //    final playlistsReqStr =
  //        _playlistsYUrl + '?part=snippet&channelId=$_channelIdY&maxResults=20';
  //    var resp = await _oHelper.get(playlistsReqStr);
  //    //print('resp completed -->');
  //    if (resp.statusCode == 200) {
  //      //print('resp status code 200');
  //      var jsonResp = null;
  //      try {
  //        jsonResp = convert.jsonDecode(resp.body);
  //      } on FormatException catch (e) {
  //        print('jsonResp is not valid json');
  //      }
  //      if (jsonResp != null) {
  //        //String _playlistsEtag = jsonResp['etag'] as String;
  //        //print('playList etag ---> ${_playlistsEtag}');
  //        var jsonArr = jsonResp['items'] as List;
  //        List<VideoListTag> _tags =
  //            jsonArr.map((tagJson) => VideoListTag.fromJson(tagJson)).toList();
  //        //cacheServ.setEtag(_playlistsYUrl, _playlistsEtag);
  //        //databaseServ.insertPlaylist(_tags);
  //        String jsonArrStr = convert.jsonEncode(_tags);
  //        var _playlistId = null;
  //        for (final tag in _tags) {
  //          if (tag.snippet.title == classId) {
  //            _playlistId = tag.id;
  //            //print(tag.toString());
  //            break;
  //          }
  //        }
  //        //print('getYtPlaylist json str ---> $jsonArrStr');
  //        fileServ.writeKeyWithData('classesAndPlaylistId', jsonArrStr);
  //        //.then(
  //        //    (result) => print(
  //        //        'writeKeyWithData = key classesAndPlaylistId --> $result'));
  //        return _playlistId;
  //      }
  //    } else {
  //      print('resp status --> ${resp.statusCode}');
  //      //print('resp headers --> ${resp.headers}');
  //      //print('resp body --> ${resp.body}');
  //    }
  //  }
  //  return null;
  //}

  Future<String> getYtPlaylistItem(String playlistID, String pageToken) async {
    //String playlistID = await _getYtPlaylist(classId);
    final _oHelper = await oauth2Helper;
    if (playlistID != null) {
      if (_oHelper != null) {
        var playlistItemsReqStr = _playlistItemsYUrl +
            '?part=snippet&part=status&playlistId=$playlistID&maxResults=10';
        if (pageToken != null) {
          playlistItemsReqStr = playlistItemsReqStr + '&pageToken=$pageToken';
        }
        //print('playlistItems req str --> $playlistItemsReqStr');
        var resp = await _oHelper.get(playlistItemsReqStr);
        if (resp.statusCode == 200) {
          var jsonResp = null;
          try {
            jsonResp = convert.jsonDecode(resp.body);
          } on FormatException catch (e) {
            print('jsonResp is not valid json');
          }
          if (jsonResp != null) {
            var _nextToken = jsonResp['nextPageToken'] as String;
            var _prevToken = jsonResp['prevPageToken'] as String;
            var _totResults = jsonResp['pageInfo']['totalResults'] as int;
            //print('nextToken --> $_nextToken & prevToken --> $_prevToken');
            var jsonArr = jsonResp['items'] as List;
            List<VideoItemTag> _tags = jsonArr
                .map((tagJson) => VideoItemTag.fromJson(tagJson))
                .toList();
            //String jsonTags = convert.jsonEncode(_tags);
            var viTag =
                VideoItemListTag(_nextToken, _prevToken, _tags, _totResults);
            String jsonStr = convert.jsonEncode(viTag);
            //print('json string --> $jsonStr');
            return jsonStr;
          } else {
            //print('jsonResp is null');
            return 'Play List Item json is null';
          }
        } else {
          print('resp status --> ${resp.statusCode}');
          //print('resp headers --> ${resp.headers}');
          //print('resp body --> ${resp.body}');
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

    //print('url --> $_uploadItemYurl');
    //print('body --> $data');
    //print('file path --> $filePath');
    //print('user Agent(uploadFileToYoutube) --> $userAgent');

    if (_oHelper != null) {
      try {
        final File _videoFile = File(filePath);
        var strm = await _videoFile.readAsBytes();
        var strmLen = _videoFile.lengthSync();
        //print('video len --> $strmLen');
        Map<String, String> headers = <String, String>{
          'Content-Type': 'application/octet-stream',
          'Content-Length': '$strmLen',
          'User-Agent': userAgent
        };
        var resp = await _oHelper.post(_uploadItemYurl,
            headers: headers, body: strm.toList());
        //var resp = await this._oauth2Helper.post();
        //print('resp from upload completed');
        if (resp.statusCode == 200) {
          //print('status code is 200');
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
            //print('video insert id --> $_videoId');
            return _videoId;
          }
        } else {
          print('status code is ${resp.statusCode}');
          //print(resp.headers);
          //print(resp.body);
        }
      } catch (e) {
        print('error during upload --> $e');
      }
    } else {
      //print('oauth is null');
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
      //print('jsonStr --> $jsonStr');
      final updateItemYurlStr = _updateItemYurl + '?part=snippet%2Cstatus';
      http.Response resp =
          await _ytPutMethod(updateItemYurlStr, _oHelper, jsonStr, userAgent);
      //print('resp from update completed');
      if (resp != null) {
        if (resp.statusCode == 200) {
          //print('status code is 200');
          //print(resp.headers);
          //print(resp.body);
          return true;
        } else {
          print('status code is ${resp.statusCode}');
          //print(resp.headers);
          //print(resp.body);
        }
      } else {
        print('resp is null');
      }
    }
    return false;
  }

  Future<http.Response> _ytPutMethod(String url, OAuth2Helper oHelper,
      String jsonStr, String userAgent) async {
    var tknResp = await oHelper.getToken();
    http.Response resp;
    try {
      var headers1 = _getHeaders1(tknResp.accessToken, userAgent);
      resp = await http.Client()
          .put(Uri.parse(url), headers: headers1, body: jsonStr);
      if (resp.statusCode == 401) {
        print('_ytPutMethod status = 401');
        if (tknResp.hasRefreshToken()) {
          tknResp = await oHelper.refreshToken(tknResp.refreshToken);
        } else {
          tknResp = await oHelper.fetchToken();
        }

        if (tknResp != null) {
          var headers2 = _getHeaders1(tknResp.accessToken, userAgent);
          resp = await http.Client()
              .put(Uri.parse(url), headers: headers2, body: jsonStr);
        }
      }
      return resp;
    } catch (e) {
      print('error _ytPutMethod --> $e');
    }
    return null;
  }

  Map<String, String> _getHeaders1(String token, String userAgent) {
    Map<String, String> headers = Map<String, String>();
    headers['Authorization'] = 'Bearer ' + token;
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    headers['User-Agent'] = userAgent;
    return headers;
  }

  String get recycleBinPlaylistId => _recycleBinPlaylistId;

  Future<String> setYtVideoToPlaylist(
      String playlistId, String videoId, String userAgent) async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      var _vResourceTag = UpdateVideoPlaylistResourceTag(videoId);
      var _vSnippetTag =
          UpdateVideoPlaylistSnippetTag(playlistId, _vResourceTag);
      var _vUpdatePlaylistTag = UpdateVideoPlaylistTag(_vSnippetTag);
      String jsonStr = convert.jsonEncode(_vUpdatePlaylistTag);
      //print('setYtVideoToPlaylist --> $jsonStr');
      final postReqStr = _playlistItemsYUrl + '?part=snippet%2Cstatus';
      print('postReqStr --> $postReqStr');
      Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': userAgent
      };
      var resp =
          await _oHelper.post(postReqStr, headers: headers, body: jsonStr);
      //print('setYtVideoToPlaylist req completed !');
      if (resp.statusCode == 200) {
        //print('status code is 200');
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
          //print('itemTagStr --> $itemTagStr');
          return itemTagStr;
        }
        //return true;
      } else {
        print('resp status --> ${resp.statusCode}');
        //print('resp headers --> ${resp.headers}');
        //print('resp body --> ${resp.body}');
      }
    }
    return null;
  }

  Future<bool> removeYtVideoFromPlaylist(String id, String userAgent) async {
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      final delReqStr = _playlistItemsYUrl + '?id=$id';
      //print('delReqStr --> $delReqStr');
      Map<String, String> headers = <String, String>{
        'Accept': 'application/json',
        'User-Agent': userAgent
      };
      var resp = await _oHelper.delete(delReqStr, headers: headers);
      //print('removeYtVideoFromPlaylist req completed !');
      if (resp.statusCode == 204) {
        //print('status code is 204');
        return true;
      } else {
        print('resp status --> ${resp.statusCode}');
        //print('resp headers --> ${resp.headers}');
      }
    }
    return false;
  }

  Future<String> getUserChannelUploadPlaylistId() async {
    if (_userChannelUploadedVideoPlaylistId == null) {
      final _oHelper = await oauth2Helper;
      if (_oHelper != null) {
        final channelUploadPlaylistReqStr =
            _userChannelUploadedVideoYurl + '?part=contentDetails&mine=true';
        var resp = await _oHelper.get(channelUploadPlaylistReqStr);
        if (resp.statusCode == 200) {
          var jsonResp = null;
          try {
            jsonResp = convert.jsonDecode(resp.body);
          } on FormatException catch (e) {
            print('jsonResp is not valid json');
          }
          if (jsonResp != null) {
            var jsonArr = jsonResp['items'] as List;
            try {
              _userChannelUploadedVideoPlaylistId = jsonArr[0]['contentDetails']
                  ['relatedPlaylists']['uploads'] as String;
              print('getUserChannelUploadPlaylistId from http req !');
            } catch (e) {
              _userChannelUploadedVideoPlaylistId = null;
            }
          }
        }
      }
    }
    return _userChannelUploadedVideoPlaylistId;
  }

  Future<List<String>> getPlaylistMatchingVideo(
      List<dynamic> playListItems, String videoId) async {
    final List<String> playLists = [];
    final _oHelper = await oauth2Helper;
    if (_oHelper != null) {
      await Future.wait(playListItems.map((item) async {
        var playlistItemsReqStr = _playlistItemsYUrl +
            '?part=contentDetails&maxResults=1&playlistId=${item['id'] as String}&videoId=$videoId';
        //print('playlistItemsReqStr --> $playlistItemsReqStr');
        var resp = await _oHelper.get(playlistItemsReqStr);
        if (resp.statusCode == 200) {
          try {
            var jsonResp = convert.jsonDecode(resp.body);
            var totRes = jsonResp['pageInfo']['totalResults'] as int;
            if (totRes > 0) {
              playLists.add(item['title'] as String);
            }
          } on FormatException catch (e) {
            print('jsonResp is not valid json');
          } catch (e) {
            print('getPlaylistMatchingVideo error --> $e');
          }
        } else {
          print(
              'for ${item['title'] as String} resp status --> ${resp.statusCode}');
        }
      }).toList());
    }
    return playLists;
  }

  Future<List<String>> setYtVideoToMultiplePlaylist(
      String playlistsEncoded, String videoId, String userAgent) async {
    //print('user agent --> $userAgent');
    final List<String> errorClassList = [];
    List<dynamic> _jsonArr = null;
    try {
      _jsonArr = convert.jsonDecode(playlistsEncoded) as List;
    } on FormatException catch (e) {
      print('playlistsEncoded is not valid json');
    }
    if (_jsonArr != null) {
      final _oHelper = await oauth2Helper;
      if (_oHelper != null) {
        final postReqStr = _playlistItemsYUrl + '?part=snippet';
        await Future.wait(_jsonArr.map((item) async {
          var _vResourceTag = UpdateVideoPlaylistResourceTag(videoId);
          var _vSnippetTag = UpdateVideoPlaylistSnippetTag(
              item['playlistId'] as String, _vResourceTag);
          var _vUpdatePlaylistTag = UpdateVideoPlaylistTag(_vSnippetTag);
          String jsonStr = convert.jsonEncode(_vUpdatePlaylistTag);
          //print('$jsonStr');
          Map<String, String> headers = <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': userAgent
          };
          var resp =
              await _oHelper.post(postReqStr, headers: headers, body: jsonStr);
          if (resp.statusCode != 200) {
            errorClassList.add(item['className'] as String);
          }
        }).toList());
      }
    }
    return errorClassList;
  }
}

final YoutubeServ yServ = YoutubeServ();

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
//      final updateItemYurlStr = _updateItemYurl + '?part=snippet%2Cstatus';
//      //yHttpClient = http.Client();
//      var tknResp = await _oHelper.getToken();
//      http.Response resp;
//      try {
//        var headers1 = _getHeaders1(tknResp.accessToken, userAgent);
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
//            var headers2 = _getHeaders1(tknResp.accessToken, userAgent);
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

//Future<String> getYtRecyclePlaylist(String classId) async {
//    final _oHelper = await oauth2Helper;
//    if (_oHelper != null) {
//      final playlistsReqStr =
//          _playlistsYUrl + '?part=snippet&channelId=$_channelIdY&maxResults=20';
//      var resp = await _oHelper.get(playlistsReqStr);
//      if (resp.statusCode == 200) {
//        print('status code is 200');
//        var jsonResp = null;
//        try {
//          jsonResp = convert.jsonDecode(resp.body);
//        } on FormatException catch (e) {
//          print('jsonResp is not valid json');
//        }
//        if (jsonResp != null) {
//          var jsonArr = jsonResp['items'] as List;
//          List<VideoListTag> _tags =
//              jsonArr.map((tagJson) => VideoListTag.fromJson(tagJson)).toList();
//          var _playlistId = null;
//          final pTitle = classId + '_recycle_bin';
//          for (final tag in _tags) {
//            if (tag.snippet.title == pTitle) {
//              _playlistId = tag.id;
//              break;
//            }
//          }
//          return _playlistId;
//        }
//      } else {
//        print('resp status --> ${resp.statusCode}');
//        print('resp headers --> ${resp.headers}');
//        print('resp body --> ${resp.body}');
//      }
//    } else {
//      print('oauth is null');
//    }
//    return null;
//  }

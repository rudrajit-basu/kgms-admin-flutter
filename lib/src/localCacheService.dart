import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:async/async.dart' show AsyncCache;

final _classImgUrlCache =
    AsyncCache<Map<String, Map<String, String>>>(const Duration(hours: 1));

class LocalCacheServ {
  SharedPreferences _preference;

  Future<SharedPreferences> get preference async {
    if (_preference == null) {
      _preference = await SharedPreferences.getInstance();
    }
    return _preference;
  }

  Future<bool> setUserName(String userName) async {
    final _pref = await preference;
    if (userName != null && !userName.isEmpty) {
      return _pref.setString('kUserName', userName);
    }
    return false;
  }

  Future<String> getUserName() async {
    final _pref = await preference;
    return _pref.getString('kUserName') ?? '';
  }

  Future<bool> setJsonData(String key, String data) async {
    final _pref = await preference;
    try {
      if (key != null && data != null) {
        return _pref.setString(key, data);
      }
    } catch (e) {
      print('LocalCacheServ --> setJsonData --> $e');
    }
    return false;
  }

  Future<String> getJsonData(String key) async {
    final _pref = await preference;
    return _pref.getString(key) ?? '';
  }

  //Future<bool> setEtag(String url, String value) async {
  //  final _pref = await preference;
  //  if (url != null && !url.isEmpty && value != null && !value.isEmpty) {
  //    return _pref.setString(url, value);
  //  }
  //  return false;
  //}

  //Future<String> getEtag(String url) async {
  //  final _pref = await preference;
  //  return _pref.getString(url) ?? '';
  //}

  Future<Map<String, Map<String, String>>> get _allClassImgUrlCache =>
      _classImgUrlCache.fetch(() async => Map<String, Map<String, String>>());

  Future<void> addClassImgUrlCache(
      String classId, String fileName, String url) async {
    final dataMap = await _allClassImgUrlCache;
    if (dataMap.containsKey(classId)) {
      dataMap[classId].update(fileName, (v) => url, ifAbsent: () => url);
    } else {
      dataMap[classId] = {fileName: url};
    }
    _classImgUrlCache.invalidate();
    _classImgUrlCache.fetch(() async => dataMap);
  }

  Future<Map<String, String>> getClassImgUrlCache(String classId) async {
    final dataMap = await _allClassImgUrlCache;
    print('dataMap --> $dataMap');
    return dataMap.containsKey(classId) ? dataMap[classId] : null;
  }
}

final LocalCacheServ cacheServ = LocalCacheServ();

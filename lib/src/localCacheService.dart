import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert' as convert;

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
}

LocalCacheServ cacheServ = new LocalCacheServ();

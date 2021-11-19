import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'dart:async';
import 'package:async/async.dart' show AsyncCache;

final _getHttpUserAgentFromCache = AsyncCache<String>(const Duration(hours: 2));

class BUtil {
  Future<String> get getHttpUserAgentFromCache =>
      _getHttpUserAgentFromCache.fetch(() => _getHttpUserAgent());

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<String> _getHttpUserAgent() async {
    try {
      final String result = await _platform.invokeMethod("getUserAgent");
      //print('User Agent --> $result');
      return result;
    } on PlatformException catch (e) {
      print('error in getUserAgent channel = ${e.message}');
      return null;
    }
  }
}

final BUtil bUtil = BUtil();

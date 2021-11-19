import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert' as convert;

//const _fileName = 'kgmsImageNetworkData';

class LocalFileServ {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> writeKeyWithData(String key, String data) async {
    if (key != null && data != null && !key.isEmpty && !data.isEmpty) {
      try {
        //final file = await _localFile;
        final path = await _localPath;
        final file = File('$path/$key');
        var sink = file.openWrite();
        sink.writeln('${data.trim()}');
        sink.close();
        return true;
      } catch (e) {
        print('from LocalFileServ --> writeKeyWithData --> error --> $e');
      }
    }
    return false;
  }

  Future<String> readDataByKey(String key) async {
    String result = 'nil';
    try {
      final path = await _localPath;
      final file = File('$path/$key');
      if (file.existsSync()) {
        Stream<String> lines = file
            .openRead()
            .transform(convert.utf8.decoder)
            .transform(convert.LineSplitter());
        await for (var line in lines) {
          //print('file $key --> line --> $line');
          result = line;
        }
      } else {
        print(
            'from LocalFileServ --> readDataByKey --> $key file not exists !');
      }
    } catch (e) {
      print('from LocalFileServ --> readDataByKey --> error --> $e');
    }
    return result;
  }

  //Future<bool> writeINMapToFile(Map<String, Map<String, String>> mapData) async {
  //  try {
  //    final path = await _localPath;
  //    final file = File('$path/$_fileName');
  //    final String mapDataStr = convert.jsonEncode(mapData);
  //    await file.writeAsString(mapDataStr);
  //    return true;
  //  } catch (e) {
  //    print('from writeMapToFile --> error --> $e');
  //  }
  //  return false;
  //}

  //Future<Map> getINMapFromFile(String classId) async {
  //  try {
  //    final path = await _localPath;
  //    final file = File('$path/$_fileName');
  //    if (file.existsSync()) {
  //      final mapDataStr = await file.readAsString();
  //      final Map<String, dynamic> mapDataDynamic =
  //          convert.jsonDecode(mapDataStr);
  //      if (mapDataDynamic.containsKey(classId)) {
  //        return (mapDataDynamic[classId] as Map).cast<String, String>();
  //      }
  //    } else {
  //      print('from getMapFromFile file not exists !');
  //    }
  //  } catch (e) {
  //    print('from getMapFromFile --> error --> $e');
  //  }
  //  return null;
  //}

}

final LocalFileServ fileServ = LocalFileServ();

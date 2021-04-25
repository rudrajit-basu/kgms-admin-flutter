import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert' as convert;

const _fileName = 'kgmsData.txt';

class LocalFileServ {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Future<File> get _localFile async {
  //  final path = await _localPath;
  //  print('file path ---> $path');
  //  File file = File('$path/$_fileName');
  //  if (!file.existsSync()) {
  //    file.createSync();
  //    print('LocalFileServ --> file created !');
  //  }
  //  return file;
  //}

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
}

LocalFileServ fileServ = LocalFileServ();

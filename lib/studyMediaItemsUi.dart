import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'self.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
//import 'package:video_player/video_player.dart';
//import 'package:chewie/chewie.dart';

final StorageReference storageReference =
    FirebaseStorage().ref().child('kgms-images');

class StudyMediaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String className;
  final String classId;
  StudyMediaAppBar({Key key, @required this.className, @required this.classId})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Media : $className'),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'add new media',
            onPressed: () {
              // print('add new media');
              kDAlert(
                  context,
                  MediaFilePickerForm(
                      classId: classId,
                      onSuccessfulUpload: (String fileName) async {
                        Provider.of<MediaItemsModel>(context, listen: false)
                            .addItem(fileName);
                      }));
            },
          ),
        ),
      ],
    );
  }
}

class StudyMedia extends StatelessWidget {
  final String className;
  final String classId;
  StudyMedia({Key key, @required this.className, @required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaItemsModel(classId),
      child: Scaffold(
        appBar: StudyMediaAppBar(className: className, classId: classId),
        body: StudyMediaBody(classId: classId),
      ),
    );
  }
}

class MediaItemsModel with ChangeNotifier {
  final List<String> _mediaItems = [];

  List<String> get mediaItems => _mediaItems;

  MediaItemsModel(String subDir) {
    _getStorageData(subDir);
  }

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<void> _getStorageData(String subDir) async {
    try {
      // final String result = await platform.invokeMethod('getMediaStorage',"Hello from Flutter !");
      final String result =
          await _platform.invokeMethod('getMediaStorage', subDir);
      var jsonArr = jsonDecode(result);
      List<String> outputList = jsonArr != null ? List.from(jsonArr) : null;
      //print('result = $outputList');
      if (outputList != null) {
        outputList.forEach((item) => _mediaItems.add(item));
        notifyListeners();
      }
    } on PlatformException catch (e) {
      print('error in storage channel = ${e.message}');
    }
  }

  void addItem(String item) {
    if (!_mediaItems.contains(item)) {
      _mediaItems.add(item);
      notifyListeners();
    }
  }

  void removeItem(String item) {
    if (_mediaItems.contains(item)) {
      _mediaItems.remove(item);
      notifyListeners();
    }
  }
}

class StudyMediaBody extends StatelessWidget {
  final String classId;
  StudyMediaBody({Key key, @required this.classId}) : super(key: key);

  Card _loadingTile(String msg) => Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Text(
            msg,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
              '0',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  AlertDialog _deleteAlertW(
          BuildContext context, String subDir, String fileName) =>
      AlertDialog(
        title: Text('Are you sure to delete: $fileName ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
        elevation: 15,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            iconSize: 27,
            onPressed: () async {
              //print('del image');
              final KCircularProgress cp = KCircularProgress(ctx: context);
              cp.showCircularProgress();
              try {
                await storageReference.child(subDir).child(fileName).delete();
                Provider.of<MediaItemsModel>(context, listen: false)
                    .removeItem(fileName);
                cp.closeProgress();
                Navigator.pop(context);
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Media deleted successfully..!!'));
              } catch (e) {
                cp.closeProgress();
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Delete unsuccessful. Please check.'));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            iconSize: 27,
            onPressed: () {
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  T cast<T>(x) => x is T ? x : null;

  final List<String> imageExtList = [
    '.jpg',
    '.png',
    '.jpeg',
    '.gif',
    '.svg',
    '.jfif',
    '.pjpeg',
    '.pjp',
    '.ico',
    '.cur',
    '.apng'
  ];

  String getFileType(String ext) {
    if (imageExtList.contains(ext.toLowerCase()))
      return "image";
    else
      return "unknown";
  }

  Card _studyClassMediaTile(
          BuildContext context, String fileName, String fileType, int index) =>
      Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
            title: Text(
              fileName,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text('type: $fileType'),
            ),
            leading: CircleAvatar(
              child: Text(
                (index + 1).toString(),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_forever),
              tooltip: 'delete forever',
              onPressed: () async {
                //print('delete item');
                kDAlert(context, _deleteAlertW(context, classId, fileName));
              },
            ),
            onTap: () async {
              //print('media item on tap');
              bool _internet = await isInternetAvailable();
              if (_internet) {
                if (fileType == "image") {
                  dynamic downloadUrl = await storageReference
                      .child(classId)
                      .child(fileName)
                      .getDownloadURL();
                  String sUrl = cast<String>(downloadUrl);
                  kDDAlert(context, ImageDialog(imgUrl: sUrl));
                } else {
                  Scaffold.of(context)
                      .showSnackBar(kSnackbar('Media not listed..!!'));
                }
              } else {
                kAlert(context, noInternetWidget);
              }
            }),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaItemsModel>(builder: (context, snapshot, _) {
      if (snapshot == null) {
        return _loadingTile('Something went wrong. Try later..!! 1');
      } else {
        if (snapshot.mediaItems == null) {
          return _loadingTile('Something went wrong. Try later..!! 2');
        } else {
          if (snapshot.mediaItems.isEmpty) {
            return _loadingTile('No Media items !');
          } else {
            return ListView.builder(
              itemCount: snapshot.mediaItems.length,
              itemBuilder: (context, index) => _studyClassMediaTile(
                  context,
                  snapshot.mediaItems[index],
                  getFileType(extension(snapshot.mediaItems[index])),
                  index),
            );
          }
        }
      }
    });
  }
}

class MediaFilePickerForm extends StatefulWidget {
  final String classId;
  final Function(String) onSuccessfulUpload;
  MediaFilePickerForm(
      {Key key, @required this.classId, @required this.onSuccessfulUpload})
      : super(key: key);

  @override
  _MediaFilePickerFormState createState() => _MediaFilePickerFormState();
}

class _MediaFilePickerFormState extends State<MediaFilePickerForm> {
  String _fullFilePath;
  String _uploadIssue;
  String _filePathExt;
  TextEditingController _fileNameCtrl;
  @override
  void initState() {
    super.initState();
    _filePathExt = "";
    _fileNameCtrl = TextEditingController(text: "None");
    _fullFilePath = null;
    _uploadIssue = "";
  }

  //final List<String> alExt = [
  //  'jpg',
  //  'png',
  //  'jpeg',
  //  'gif',
  //  'svg',
  //  'jfif',
  //  'pjpeg',
  //  'pjp',
  //  'ico',
  //  'cur',
  //  'apng'
  //];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Media File !'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      elevation: 15,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'File :  ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.5,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _fileNameCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
              Text(' $_filePathExt'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '$_uploadIssue',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        RaisedButton(
          onPressed: () async {
            String filePath =
                await FilePicker.getFilePath(type: FileType.image);

            if (filePath != null && filePath.isNotEmpty) {
              setState(() {
                _fullFilePath = filePath;
                _fileNameCtrl.text = basenameWithoutExtension(filePath);
                _filePathExt = extension(filePath);
                _uploadIssue = "";
              });
            } else {
              setState(() {
                _fullFilePath = null;
                _fileNameCtrl.text = "None";
                _filePathExt = "";
              });
            }
          },
          child: const Text('Select File'),
          // splashColor: Colors.yellow,
          color: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: RaisedButton(
            onPressed: () async {
              if (_fileNameCtrl.text.isEmpty ||
                  _fileNameCtrl.text.toLowerCase() == "none") {
                setState(() {
                  _uploadIssue = "** file name cannot be empty";
                });
              } else {
                if ((_fileNameCtrl.text.split(' ').length > 1) ||
                    (_fileNameCtrl.text != _fileNameCtrl.text.trim())) {
                  setState(() {
                    _uploadIssue = "** file name cannot have spaces";
                  });
                } else {
                  // print('go for upload');
                  setState(() {
                    _uploadIssue = "";
                  });
                  if (_fullFilePath != null) {
                    bool _internet = await isInternetAvailable();
                    if (_internet) {
                      final KCircularProgress cp =
                          KCircularProgress(ctx: context);
                      cp.showCircularProgress();
                      final File mediaItem = File(_fullFilePath);
                      final String fullFileName =
                          _fileNameCtrl.text + _filePathExt;
                      StorageTaskSnapshot snapshot = await storageReference
                          .child(widget.classId)
                          .child(fullFileName)
                          .putFile(mediaItem)
                          .onComplete;
                      if (snapshot.error == null) {
                        widget.onSuccessfulUpload(fullFileName);
                        cp.closeProgress();
                        //print('upload successful !');
                        Navigator.of(context).pop();
                      } else {
                        cp.closeProgress();
                        setState(() {
                          _uploadIssue = "** upload error";
                        });
                      }
                    } else {
                      kAlert(context, noInternetWidget);
                    }
                  } else {
                    setState(() {
                      _uploadIssue = "** please select a file";
                    });
                  }
                }
              }
            },
            child: const Text('Upload'),
            // splashColor: Colors.yellow,
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
            // splashColor: Colors.yellow,
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

class ImageDialog extends StatelessWidget {
  final String imgUrl;
  ImageDialog({Key key, @required this.imgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: imgUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}

//class VideoDialog extends StatefulWidget {
//  final String videoUrl;
//  VideoDialog({Key key, @required this.videoUrl}) : super(key: key);

//  @override
//  _VideoDialogState createState() => _VideoDialogState();
//}

//class _VideoDialogState extends State<VideoDialog> {
//  VideoPlayerController _videoPlayerController;
//  ChewieController _chewieController;

//  @override
//  void initState() {
//    super.initState();
//    _videoPlayerController = VideoPlayerController.network(
//      widget.videoUrl,
//    );

//    _chewieController = ChewieController(
//      videoPlayerController: _videoPlayerController,
//      aspectRatio: 16 / 9,
//      autoPlay: false,
//      looping: false,

//      materialProgressColors: ChewieProgressColors(
//        playedColor: Colors.red,
//        handleColor: Colors.blue,
//        backgroundColor: Colors.grey,
//        bufferedColor: Colors.lightGreen,
//      ),
//      autoInitialize: true,
//    );
//  }

//  @override
//  void dispose() {
//    _videoPlayerController.dispose();
//    _chewieController.dispose();
//    super.dispose();
//  }

//  @override
//  Widget build(BuildContext context) {
//    return Dialog(
//      elevation: 0,
//      backgroundColor: Colors.transparent,
//      child: Flexible(
//        child: Chewie(
//          controller: _chewieController,
//        ),
//      ),
//    );
//  }
//}
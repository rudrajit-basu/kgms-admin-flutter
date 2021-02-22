import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'self.dart';
import 'dart:convert' as convert;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';

class StudyVideoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String className;
  final String classId;
  StudyVideoAppBar({Key key, @required this.className, @required this.classId})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  void _kStudyNavigation(BuildContext context, StatelessWidget ksc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ksc,
      ),
    );
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Text('Video : $className')
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('Video :'),
          Text('$className', style: TextStyle(fontSize: 17.5))
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'add new video',
            onPressed: () {
              //print('add new video @ $classId');
              var isLoaded = Provider.of<VideoItemModel>(context, listen: false)
                  .getIsWaiting();
              if (!isLoaded) {
                var pid = Provider.of<VideoItemModel>(context, listen: false)
                    .classPlayListID;
                if (pid != null) {
                  var itemLen =
                      Provider.of<VideoItemModel>(context, listen: false)
                          .getItemCount();
                  //print('item len --> $itemLen');
                  if (itemLen < 10) {
                    final String usrAgent =
                        Provider.of<VideoItemModel>(context, listen: false)
                            .getUserAgent();
                    //print('allowed');
                    kDAlert(
                        context,
                        VideoFilePickerForm(
                            className: className,
                            classId: classId,
                            userAgent: usrAgent,
                            playlistId: pid,
                            onSuccessfulUpload: (String jsonStr) async {
                              Provider.of<VideoItemModel>(context,
                                      listen: false)
                                  .addItemByString(jsonStr);
                            }));
                  } else {
                    Scaffold.of(context)
                        .showSnackBar(kSnackbar('Max 10 videos allowed !'));
                  }
                } else {
                  Scaffold.of(context)
                      .showSnackBar(kSnackbar('Playlist not created !'));
                }
              } else {
                //print('not loaded yet');
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Please wait till resource is loaded !'));
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.update_rounded, size: 30),
            tooltip: 'recycle uploads',
            onPressed: () async {
              //print('add new video @ $classId');
              var isLoaded = Provider.of<VideoItemModel>(context, listen: false)
                  .getIsWaiting();
              if (!isLoaded) {
                var pid = Provider.of<VideoItemModel>(context, listen: false)
                    .classPlayListID;
                if (pid != null) {
                  var itemLen =
                      Provider.of<VideoItemModel>(context, listen: false)
                          .getItemCount();
                  //print('item len --> $itemLen');
                  if (itemLen < 10) {
                    //print('go to incomplete videos !');
                    //await yServ.getYtUserPlaylist();
                    //print('getYtUserPlaylist completed !');
                    final String usrAgent =
                        Provider.of<VideoItemModel>(context, listen: false)
                            .userAgent;
                    _kStudyNavigation(
                        context,
                        StudyRecycleVideo(
                            className: className,
                            classId: classId,
                            playlistId: pid,
                            userAgent: usrAgent,
                            onSuccessfulRecycle: (String jsonStr) async {
                              Provider.of<VideoItemModel>(context,
                                      listen: false)
                                  .addItemByString(jsonStr);
                            }));
                  } else {
                    Scaffold.of(context)
                        .showSnackBar(kSnackbar('Max 10 videos allowed !'));
                  }
                } else {
                  Scaffold.of(context)
                      .showSnackBar(kSnackbar('Playlist not created !'));
                }
              } else {
                //print('not loaded yet');
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Please wait till resource is loaded !'));
              }
            },
          ),
        ),
      ],
    );
  }
}

class StudyVideo extends StatelessWidget {
  final String className;
  final String classId;
  StudyVideo({Key key, @required this.className, @required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoItemModel(classId),
      child: Scaffold(
        appBar: StudyVideoAppBar(className: className, classId: classId),
        body: StudyVideoBody(classId: classId),
      ),
    );
  }
}

class VideoItemModel with ChangeNotifier {
  final List<_VideoItem> _videoItems = [];

  List<_VideoItem> get videoItems => _videoItems;

  bool _isWaiting = true;

  bool get isWaiting => _isWaiting;

  bool _isError = false;

  bool get isError => _isError;

  String _errorMsg = '';

  String get errorMsg => _errorMsg;

  String _classPlayListID = null;

  String get classPlayListID => _classPlayListID;

  String _userAgent = '';

  String get userAgent => _userAgent;

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  //var exampleList = ['First', 'Second', 'Third'];

  VideoItemModel(String classId) {
    _setYtPlaylistItem(classId);
  }

  Future<String> _getHttpUserAgent() async {
    try {
      final String result = await _platform.invokeMethod("getUserAgent");
      //print('User Agent --> $result');
      return result;
    } on PlatformException catch (e) {
      print('error in getUserAgent channel = ${e.message}');
      return "err";
    }
  }

  Future<void> _setYtPlaylistItem(String classId) async {
    if (_classPlayListID == null) {
      var _playlistId = await yServ.getYtPlaylist(classId);
      print('playlistId from ui --> $_playlistId');
      _classPlayListID = _playlistId;
    }
    yServ.getYtPlaylistItem(_classPlayListID).then((jsonTags) async {
      print('jsonTags from ui -->');
      //print(jsonTags);
      var _jsonArr = null;
      try {
        _jsonArr = convert.jsonDecode(jsonTags) as List;
        _isError = false;
        _errorMsg = '';
      } on FormatException catch (e) {
        print('ui video json error --> $jsonTags');
        _isError = true;
        _errorMsg = '$jsonTags';
      }
      if (_jsonArr != null) {
        for (final tag in _jsonArr) {
          _VideoItem vi = _VideoItem.fromJson(tag);
          _videoItems.add(vi);
        }
      }
      if (_userAgent == '') {
        final usrAgent = await _getHttpUserAgent();
        if (usrAgent != "err") {
          _userAgent = usrAgent + ' /Dart package:com.kgmskid.kgms_admin';
        }
      }
      _isWaiting = false;
      notifyListeners();
    });
  }

  void removeAll() {
    _videoItems.clear();
    notifyListeners();
  }

  //void reloadPlaylist(String classId) {
  //  _videoItems.clear();
  //  _setYtPlaylistItem(classId);
  //}
  void removeItem(_VideoItem item) {
    if (_videoItems.remove(item)) {
      notifyListeners();
    }
  }

  void addItemAtStart(_VideoItem item) {
    _videoItems.insert(0, item);
    notifyListeners();
  }

  void addItemByString(String jsonStr) {
    var _jsonObj = null;
    try {
      _jsonObj = convert.jsonDecode(jsonStr);
    } on FormatException catch (e) {
      print('error addItemByString --> $e');
    }
    if (_jsonObj != null) {
      _VideoItem vi = _VideoItem.fromJson(_jsonObj);
      addItemAtStart(vi);
    }
  }

  int getItemCount() {
    return _videoItems.length;
  }

  bool getIsWaiting() {
    return _isWaiting;
  }

  String getUserAgent() {
    return _userAgent;
  }

  bool isPlayListValid() {
    return _classPlayListID == null ? false : true;
  }
}

class _VideoItem {
  String id;
  String title;
  String videoId;
  String status;

  _VideoItem(this.id, this.title, this.videoId, this.status);

  factory _VideoItem.fromJson(dynamic json) {
    return _VideoItem(json['id'] as String, json['title'] as String,
        json['videoId'] as String, json['status'] as String);
  }

  @override
  String toString() {
    return '{${this.id}, ${this.title}, ${this.videoId}}';
  }
}

class StudyVideoBody extends StatelessWidget {
  final String classId;
  StudyVideoBody({Key key, @required this.classId}) : super(key: key);

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<void> _playYtVideo(String vidId) async {
    try {
      final bool result =
          await _platform.invokeMethod('playYoutubeVideo', vidId);
      print('result --> $result');
    } on PlatformException catch (e) {
      print('error in playYoutubeVideo channel = ${e.message}');
    }
  }

  String _rPlaylistId = null;

  AlertDialog _removeVideoAlertW(BuildContext context, _VideoItem item) =>
      AlertDialog(
        title: Text('Are you sure to remove: ${item.title}'),
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
              final KCircularProgress cp = KCircularProgress(ctx: context);
              cp.showCircularProgress();
              if (_rPlaylistId == null) {
                var _rPid = await yServ.getYtRecyclePlaylist(classId);
                _rPlaylistId = _rPid;
                print('_rPid fetched **');
              }
              if (_rPlaylistId != null) {
                //print('rPlaylistId --> $_rPlaylistId');
                //print('remove video item --> ${item.videoId}, ${item.id}');
                final String usrAgent =
                    Provider.of<VideoItemModel>(context, listen: false)
                        .userAgent;
                //print('user agent --> $usrAgent');
                bool _isDel =
                    await yServ.removeYtVideoFromPlaylist(item.id, usrAgent);
                if (_isDel) {
                  String _isPSet = await yServ.setYtVideoToPlaylist(
                      _rPlaylistId, item.videoId, usrAgent);
                  if (_isPSet != null) {
                    Provider.of<VideoItemModel>(context, listen: false)
                        .removeItem(item);
                    cp.closeProgress();
                    //_reloadPlaylist(context);
                    Navigator.pop(context);
                    Scaffold.of(context).showSnackBar(
                        kSnackbar('Video removed successfully..!!'));
                  } else {
                    cp.closeProgress();
                    print('error in set playlist');
                    Scaffold.of(context).showSnackBar(
                        kSnackbar('Set to playlist unsuccessful'));
                  }
                } else {
                  cp.closeProgress();
                  print('error in delete from playlist');
                  Scaffold.of(context).showSnackBar(
                      kSnackbar('Delete from Playlist unsuccessful'));
                }
              } else {
                cp.closeProgress();
                print('remove playlist not created');
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Remove playlist not created'));
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

  Card _studyClassVideoTile(BuildContext context, int index, _VideoItem item) =>
      Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
            title: Text(
              item.title,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
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
              tooltip: 'remove video',
              onPressed: () {
                //String _playlistId =
                //    Provider.of<VideoItemModel>(context, listen: false)
                //        .classPlayListID;
                //print('remove video item --> ${item.videoId}, ${item.id}');
                //print('playlistId --> $_playlistId');
                kDAlert(context, _removeVideoAlertW(context, item));
              },
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                '<status - ${item.status}>',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            onTap: () async {
              //print(
              //    'play video item and status --> ${item.videoId} and ${item.status}');
              await _playYtVideo(item.videoId);
            }),
      );

  Widget unlistedVideosWidget(BuildContext context) =>
      Consumer<VideoItemModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.videoItems == null) {
            return _loadingTile('snapshot videoItems null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _loadingTile(snapshot.errorMsg);
                  } else {
                    if (snapshot.videoItems.isEmpty) {
                      return _loadingTile('No Video Items !');
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.videoItems.length,
                          itemBuilder: (context, index) => _studyClassVideoTile(
                              context, index, snapshot.videoItems[index]));
                    }
                  }
                }
            }
          }
        }
      });

  @override
  Widget build(BuildContext context) {
    return unlistedVideosWidget(context);
  }
}

class VideoFilePickerForm extends StatefulWidget {
  final String className;
  final String classId;
  final String userAgent;
  final String playlistId;
  final Function(String) onSuccessfulUpload;
  VideoFilePickerForm(
      {Key key,
      @required this.className,
      @required this.classId,
      @required this.userAgent,
      @required this.playlistId,
      @required this.onSuccessfulUpload})
      : super(key: key);

  @override
  _VideoFilePickerFormState createState() => _VideoFilePickerFormState();
}

class _VideoFilePickerFormState extends State<VideoFilePickerForm> {
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

  void setDialogMsg(String msg) => setState(() {
        _uploadIssue = msg;
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Media File !'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
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
        ElevatedButton(
          onPressed: () async {
            setDialogMsg('Please wait...');
            String filePath =
                await FilePicker.getFilePath(type: FileType.video);
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
                _uploadIssue = "";
              });
            }
          },
          child: const Text('Select File',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
          // splashColor: Colors.yellow,
          //color: Colors.green,
          //shape: RoundedRectangleBorder(
          //  borderRadius: BorderRadius.all(Radius.circular(8)),
          //),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_fileNameCtrl.text.isEmpty ||
                _fileNameCtrl.text.toLowerCase() == "none") {
              setDialogMsg('** file name cannot be empty');
            } else {
              if ((_fileNameCtrl.text.split(' ').length > 1) ||
                  (_fileNameCtrl.text != _fileNameCtrl.text.trim())) {
                setDialogMsg('** file name cannot have spaces');
              } else {
                setDialogMsg('');
                if (_fullFilePath != null) {
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    //print(
                    //    'upload file --> $_fullFilePath at ${widget.classId}') widget.classId;
                    setDialogMsg('uploading video...');
                    var _videoId = await yServ.uploadFileToYoutube(
                        _fullFilePath, widget.userAgent);
                    if (_videoId != null) {
                      setDialogMsg('updating video details...');
                      bool _isUpdated = await yServ.updateYtVideo(
                          _videoId,
                          _fileNameCtrl.text,
                          widget.className,
                          widget.userAgent);
                      if (_isUpdated) {
                        String _isPset = await yServ.setYtVideoToPlaylist(
                            widget.playlistId, _videoId, widget.userAgent);
                        if (_isPset != null) {
                          widget.onSuccessfulUpload(_isPset);
                          print('video setup completed...');
                          Navigator.of(context).pop();
                        } else {
                          setDialogMsg('** video playlist error');
                        }
                        //setDialogMsg('updating video done...');
                      } else {
                        setDialogMsg('** video update error');
                      }
                    } else {
                      setDialogMsg('** video upload error');
                    }
                  } else {
                    kAlert(context, noInternetWidget);
                  }
                  //print('upload playlistId --> ${widget.playlistId}');
                } else {
                  setState(() {
                    _uploadIssue = "** please select a file";
                  });
                }
              }
            }
          },
          child: const Text('Upload',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
          ),
        ),
      ],
      //actionsOverflowButtonSpacing: 2.0,
      buttonPadding: const EdgeInsets.all(7),
    );
  }
}

class StudyRecycleVideo extends StatelessWidget {
  final String className;
  final String classId;
  final String playlistId;
  final String userAgent;
  final Function(String) onSuccessfulRecycle;
  StudyRecycleVideo(
      {Key key,
      @required this.className,
      @required this.classId,
      @required this.playlistId,
      @required this.userAgent,
      @required this.onSuccessfulRecycle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoRecycleItemModel(classId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Old video: $className'),
        ),
        body: StudyRecycleVideoBody(
            playlistId: playlistId,
            userAgent: userAgent,
            classId: classId,
            onSuccessfulRecycle: onSuccessfulRecycle),
      ),
    );
  }
}

class VideoRecycleItemModel with ChangeNotifier {
  final List<_VideoItem> _rVideoItems = [];

  List<_VideoItem> get rVideoItems => _rVideoItems;

  bool _isWaiting = true;

  bool get isWaiting => _isWaiting;

  bool _isError = false;

  bool get isError => _isError;

  String _errorMsg = '';

  String get errorMsg => _errorMsg;

  String _classRplayListID = null;

  String get classRplayListID => _classRplayListID;

  VideoRecycleItemModel(String classId) {
    _setYtRecyclePlaylistItem(classId);
  }

  Future<void> _setYtRecyclePlaylistItem(String classId) async {
    if (_classRplayListID == null) {
      var _playlistId = await yServ.getYtRecyclePlaylist(classId);
      print('rPlaylistId from ui --> $_playlistId');
      _classRplayListID = _playlistId;
    }

    yServ.getYtPlaylistItem(_classRplayListID).then((jsonTags) async {
      print('rJsonTags from ui -->');
      //print(jsonTags);
      var _jsonArr = null;
      try {
        _jsonArr = convert.jsonDecode(jsonTags) as List;
        _isError = false;
        _errorMsg = '';
      } on FormatException catch (e) {
        print('ui video json error --> $jsonTags');
        _isError = true;
        _errorMsg = '$jsonTags';
      }
      if (_jsonArr != null) {
        for (final tag in _jsonArr) {
          _VideoItem vi = _VideoItem.fromJson(tag);
          _rVideoItems.add(vi);
        }
      }
      _isWaiting = false;
      notifyListeners();
    });
  }

  //void reloadPlaylist(String classId) {
  //  _rVideoItems.clear();
  //  _setYtRecyclePlaylistItem(classId);
  //}

  void removeItem(_VideoItem item) {
    if (_rVideoItems.remove(item)) {
      notifyListeners();
    }
  }
}

class StudyRecycleVideoBody extends StatelessWidget {
  final String playlistId;
  final String userAgent;
  final String classId;
  final Function(String) onSuccessfulRecycle;
  StudyRecycleVideoBody(
      {Key key,
      @required this.playlistId,
      @required this.userAgent,
      @required this.classId,
      @required this.onSuccessfulRecycle})
      : super(key: key);

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<void> _playYtVideo(String vidId) async {
    try {
      final bool result =
          await _platform.invokeMethod('playYoutubeVideo', vidId);
      print('result --> $result');
    } on PlatformException catch (e) {
      print('error in playYoutubeVideo channel = ${e.message}');
    }
  }

  //Future<void> _reloadPlaylist(BuildContext context) {
  //  Provider.of<VideoRecycleItemModel>(context, listen: false)
  //      .reloadPlaylist(classId);
  //}

  AlertDialog _recycleVideoAlertW(BuildContext context, _VideoItem item) =>
      AlertDialog(
        title: Text('Are you sure to put back: ${item.title}'),
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
              final KCircularProgress cp = KCircularProgress(ctx: context);
              cp.showCircularProgress();
              //print('playlistId --> $playlistId');
              //print('recycle video item --> ${item.videoId}, ${item.id}');
              bool _isDel =
                  await yServ.removeYtVideoFromPlaylist(item.id, userAgent);
              if (_isDel) {
                String _isPSet = await yServ.setYtVideoToPlaylist(
                    playlistId, item.videoId, userAgent);
                if (_isPSet != null) {
                  Provider.of<VideoRecycleItemModel>(context, listen: false)
                      .removeItem(item);
                  onSuccessfulRecycle(_isPSet);
                  cp.closeProgress();
                  Navigator.pop(context);
                  Scaffold.of(context).showSnackBar(
                      kSnackbar('Video recycled successfully..!!'));
                } else {
                  cp.closeProgress();
                  print('error in set playlist');
                  Scaffold.of(context)
                      .showSnackBar(kSnackbar('Set to playlist unsuccessful'));
                }
              } else {
                cp.closeProgress();
                print('error in delete from playlist');
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Delete from Playlist unsuccessful'));
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

  Card _studyClassVideoTile(BuildContext context, int index, _VideoItem item) =>
      Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
            title: Text(
              item.title,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
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
              icon: Icon(Icons.update_rounded),
              tooltip: 'recycle back',
              onPressed: () {
                //String _rPlaylistId =
                //    Provider.of<VideoRecycleItemModel>(context, listen: false)
                //        .classRplayListID;
                //print('recycle video item --> ${item.videoId}, ${item.id}');
                //print('rPlaylistId --> $_rPlaylistId');
                //print('playlistId --> $_playlistId');
                kDAlert(context, _recycleVideoAlertW(context, item));
              },
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                '<status - ${item.status}>',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            onTap: () async {
              //print(
              //    'play video item and status --> ${item.videoId} and ${item.status}');
              await _playYtVideo(item.videoId);
            }),
      );

  Widget _videoList(BuildContext context) =>
      Consumer<VideoRecycleItemModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.rVideoItems == null) {
            return _loadingTile('snapshot rVideoItems null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _loadingTile(snapshot.errorMsg);
                  } else {
                    if (snapshot.rVideoItems.isEmpty) {
                      return _loadingTile('No Video Items !');
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.rVideoItems.length,
                          itemBuilder: (context, index) => _studyClassVideoTile(
                              context, index, snapshot.rVideoItems[index]));
                    }
                  }
                }
            }
          }
        }
      });

  @override
  Widget build(BuildContext context) {
    return _videoList(context);
  }
}

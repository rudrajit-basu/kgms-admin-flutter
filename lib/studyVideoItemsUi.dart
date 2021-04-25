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
    bool _shouldRefresh =
        Provider.of<VideoItemModel>(context, listen: false).shouldRefresh;
    if (_shouldRefresh) {
      Provider.of<VideoItemModel>(context, listen: false)
          .reloadPlaylist(classId);
      Provider.of<VideoItemModel>(context, listen: false)
          .setShouldRefresh(false);
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
          Text(
              'Video :  ${context.watch<VideoItemModel>().totalResults > 0 ? '(${context.watch<VideoItemModel>().totalResults})' : ''}'),
          Text('$className', style: TextStyle(fontSize: 17.5))
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'add new video',
            onPressed: () async {
              //print('add new video @ $classId');
              bool _internet = await isInternetAvailable();
              if (_internet) {
                var isLoaded =
                    Provider.of<VideoItemModel>(context, listen: false)
                        .getIsWaiting();
                if (!isLoaded) {
                  var pid = Provider.of<VideoItemModel>(context, listen: false)
                      .classPlayListID;
                  if (pid != null) {
                    var itemLen =
                        Provider.of<VideoItemModel>(context, listen: false)
                            .getItemCount;
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
              } else {
                kAlert(context, noInternetWidget);
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
              bool _internet = await isInternetAvailable();
              if (_internet) {
                var isLoaded =
                    Provider.of<VideoItemModel>(context, listen: false)
                        .getIsWaiting();
                if (!isLoaded) {
                  var pid = Provider.of<VideoItemModel>(context, listen: false)
                      .classPlayListID;
                  if (pid != null) {
                    var itemLen =
                        Provider.of<VideoItemModel>(context, listen: false)
                            .getItemCount;
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
                              //classId: classId,
                              //playlistId: pid,
                              userAgent: usrAgent,
                              onSuccessfulRecycle: (String jsonStr) async {
                                //Provider.of<VideoItemModel>(context,
                                //        listen: false)
                                //    .addItemByString(jsonStr);
                                Provider.of<VideoItemModel>(context,
                                        listen: false)
                                    .setShouldRefresh(true);
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
              } else {
                kAlert(context, noInternetWidget);
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
        body: StudyVideoBody(classId: classId, className: className),
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

  int _totalResults = 0;

  int get totalResults => _totalResults;

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
      var _playlistId = await _getPlalistIdTitle(classId);
      if (_playlistId == null) {
        _playlistId = await yServ.getYtPlaylist(classId);
      }
      //print('playlistId from ui --> $_playlistId');
      _classPlayListID = _playlistId;
    }
    yServ.getYtPlaylistItem(_classPlayListID, null).then((jsonTags) async {
      //print('jsonTags from ui -->');
      //print(jsonTags);
      var _jsonResp = null;
      //var _jsonArr = null;
      try {
        _jsonResp = convert.jsonDecode(jsonTags);
        //_jsonArr = convert.jsonDecode(jsonTags) as List;
        _isError = false;
        _errorMsg = '';
      } on FormatException catch (e) {
        print('ui video json error --> $jsonTags');
        _isError = true;
        _errorMsg = '$jsonTags';
      }
      if (_jsonResp != null) {
        var _jsonArr = _jsonResp['items'] as List;
        if (_jsonArr != null) {
          for (final tag in _jsonArr) {
            _VideoItem vi = _VideoItem.fromJson(tag);
            _videoItems.add(vi);
          }
        }
        _totalResults = _jsonResp['totalResults'] as int;
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

  Future<String> _getPlalistIdTitle(String classId) async {
    String playlistId = null;
    String data = await fileServ.readDataByKey('classesAndPlaylistId');
    if (data != 'nil') {
      var _jsonArr = null;
      try {
        _jsonArr = convert.jsonDecode(data) as List;
      } on FormatException catch (e) {
        print('_validatePlaylistUpdate data = $data and error = $e');
      }
      if (_jsonArr != null) {
        for (final tag in _jsonArr) {
          var clId = tag['title'] as String;
          if (classId == clId) {
            playlistId = tag['id'] as String;
            break;
          }
        }
      }
    }
    return playlistId;
  }

  void removeAll() {
    _videoItems.clear();
    notifyListeners();
  }

  void reloadPlaylist(String classId) {
    _videoItems.clear();
    _isWaiting = true;
    _setYtPlaylistItem(classId);
  }

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

  void modifyItem(_VideoItem oldItem, _VideoItem newItem) {
    int index = _videoItems.indexOf(oldItem);
    if (index != null) {
      if (_videoItems.remove(oldItem)) {
        _videoItems.insert(index, newItem);
        notifyListeners();
      }
    }
  }

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  int get getItemCount => _videoItems.length;

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
  final String id;
  final String title;
  final String videoId;
  final String status;
  final int position;

  _VideoItem(this.id, this.title, this.videoId, this.status, this.position);

  factory _VideoItem.fromJson(dynamic json) {
    return _VideoItem(
        json['id'] as String,
        json['title'] as String,
        json['videoId'] as String,
        json['status'] as String,
        json['position'] as int);
  }

  @override
  String toString() {
    return '{${this.id}, ${this.title}, ${this.videoId}, ${this.status}, ${this.position}}';
  }
}

class StudyVideoBody extends StatelessWidget {
  final String classId;
  final String className;
  StudyVideoBody({Key key, @required this.classId, @required this.className})
      : super(key: key);

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<void> _playYtVideo(String vidId) async {
    try {
      final bool result =
          await _platform.invokeMethod('playYoutubeVideo', vidId);
      //print('result --> $result');
    } on PlatformException catch (e) {
      print('error in playYoutubeVideo channel = ${e.message}');
    }
  }

  String _rPlaylistId = null;

  Future<List<dynamic>> getPlalistIdTitle() async {
    String data = await fileServ.readDataByKey('classesAndPlaylistId');
    if (data != 'nil') {
      var _jsonArr = null;
      try {
        _jsonArr = convert.jsonDecode(data) as List;
      } on FormatException catch (e) {
        print('_validatePlaylistUpdate data = $data and error = $e');
      }
      return _jsonArr;
    }
    return null;
  }

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
              //_rPlaylistId = yServ.recycleBinPlaylistId;
              final String usrAgent =
                  Provider.of<VideoItemModel>(context, listen: false).userAgent;
              bool _isDel =
                  await yServ.removeYtVideoFromPlaylist(item.id, usrAgent);
              if (_isDel) {
                Provider.of<VideoItemModel>(context, listen: false)
                    .removeItem(item);
                cp.closeProgress();
                //_reloadPlaylist(context);
                Navigator.pop(context);
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Video removed successfully..!!'));
              } else {
                cp.closeProgress();
                //print('error in delete from playlist');
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Delete from Playlist unsuccessful'));
              }
            },
          ),
          Divider(),
          IconButton(
            icon: const Icon(Icons.clear),
            iconSize: 27,
            onPressed: () {
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
          Divider(),
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

  Card _studyClassVideoTile1(BuildContext context, _VideoItem item) => Card(
        color: Colors.orange[300],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                item.title,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: CircleAvatar(
                child: Text(
                  (item.position + 1).toString(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              trailing: IconButton(
                icon: const Icon(Icons.share_outlined, size: 27.5),
                tooltip: 'share video to classes',
                onPressed: () async {
                  //print('share video to classes !');
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    final KCircularProgress cp =
                        KCircularProgress(ctx: context);
                    cp.showCircularProgress();
                    var pList = await getPlalistIdTitle();
                    //pList.forEach((item) => print('${item['title'] as String} and ${item['id'] as String}'));
                    if (pList != null && pList.length > 0) {
                      var pmv = await yServ.getPlaylistMatchingVideo(
                          pList, item.videoId);
                      //print('pmv --> ${pmv.toString()}');
                      if (pmv != null) {
                        final String usrAgent =
                            Provider.of<VideoItemModel>(context, listen: false)
                                .userAgent;
                        cp.closeProgress();
                        kDAlert(
                            context,
                            _MultiSelectClassForm(
                                preClassId: pmv,
                                onSuccessfulUpdate: (String value) {
                                  //print("hey it's $value");
                                  Scaffold.of(context)
                                      .showSnackBar(kSnackbar("$value"));
                                },
                                videoId: item.videoId,
                                userAgent: usrAgent,
                                videoTitle: item.title));
                      } else {
                        cp.closeProgress();
                        print('pmv null or empty !');
                      }
                    } else {
                      cp.closeProgress();
                      print('pList null or empty !');
                    }
                  } else {
                    kAlert(context, noInternetWidget);
                  }
                },
              ),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('|> Play'),
                    onPressed: () async {
                      //print('Play Video --> ${item.title} & ${item.videoId}');
                      await _playYtVideo(item.videoId);
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.465)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    child: const Text('/ Edit'),
                    onPressed: () async {
                      //print('Edit Video --> ${item.title} & ${item.videoId}');
                      final String usrAgent =
                          Provider.of<VideoItemModel>(context, listen: false)
                              .userAgent;

                      kDAlert(
                          context,
                          VideoTitleEditForm(
                              vItem: item,
                              className: className,
                              userAgent: usrAgent,
                              onSuccessfulUpdate: (_VideoItem vi) async {
                                //print(
                                //    'onSuccessfulUpload --> ${vi.toString()}');
                                Provider.of<VideoItemModel>(context,
                                        listen: false)
                                    .modifyItem(item, vi);
                              }));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.46)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    child: const Text('X Remove'),
                    onPressed: () {
                      //print('Remove Video --> ${item.title} & ${item.videoId}');
                      kDAlert(context, _removeVideoAlertW(context, item));
                      //String jsonData =
                      //    await cacheServ.getJsonData('classesAndIds');
                      //print('from remove --> $jsonData');
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.46)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Card _studyClassVideoTile(BuildContext context, _VideoItem item) => Card(
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
                (item.position + 1).toString(),
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
                      return ListView.separated(
                          itemCount: snapshot.videoItems.length,
                          separatorBuilder: (context, index) => Divider(
                                height: 4.2,
                              ),
                          itemBuilder: (context, index) =>
                              _studyClassVideoTile1(
                                  context, snapshot.videoItems[index]));
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

class VideoTitleEditForm extends StatefulWidget {
  final _VideoItem vItem;
  final String className;
  final String userAgent;
  final Function(_VideoItem) onSuccessfulUpdate;
  VideoTitleEditForm(
      {Key key,
      @required this.vItem,
      @required this.className,
      @required this.userAgent,
      @required this.onSuccessfulUpdate})
      : super(key: key);

  @override
  _VideoTitleEditFormState createState() => _VideoTitleEditFormState();
}

class _VideoTitleEditFormState extends State<VideoTitleEditForm> {
  TextEditingController _vTitleCtrl;
  String _updateIssue;

  @override
  void initState() {
    super.initState();
    _vTitleCtrl = TextEditingController(text: widget.vItem.title);
    _updateIssue = "";
  }

  void setDialogMsg(String msg) => setState(() {
        _updateIssue = msg;
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Video Title !'),
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
                'Title :  ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.5,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _vTitleCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '$_updateIssue',
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
            if (_vTitleCtrl.text.isEmpty) {
              setDialogMsg('** title cannot be empty');
            } else {
              if ((_vTitleCtrl.text.split(' ').length > 1) ||
                  (_vTitleCtrl.text != _vTitleCtrl.text.trim())) {
                setDialogMsg('** title cannot have spaces');
              } else {
                if (_vTitleCtrl.text == widget.vItem.title) {
                  setDialogMsg('** nothing to update');
                } else {
                  setDialogMsg('');
                  //print('update video title');
                  //print(
                  //    'vid details --> ${widget.vItem.videoId}, ${_vTitleCtrl.text}, ${widget.className}, ${widget.userAgent}');
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    final KCircularProgress cp =
                        KCircularProgress(ctx: context);
                    cp.showCircularProgress();
                    bool _isUpdated = await yServ.updateYtVideo(
                        widget.vItem.videoId,
                        _vTitleCtrl.text,
                        widget.className,
                        widget.userAgent);
                    if (_isUpdated) {
                      var vi = _VideoItem(
                          widget.vItem.id,
                          _vTitleCtrl.text,
                          widget.vItem.videoId,
                          widget.vItem.status,
                          widget.vItem.position);
                      widget.onSuccessfulUpdate(vi);
                      cp.closeProgress();
                      Navigator.of(context).pop();
                    } else {
                      setDialogMsg('** video update error');
                      cp.closeProgress();
                    }
                  } else {
                    kAlert(context, noInternetWidget);
                  }
                }
              }
            }
          },
          child: const Text('Save',
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
        Divider(),
        ElevatedButton(
          onPressed: () async {
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
        Divider(),
      ],
      //buttonPadding: const EdgeInsets.all(5),
    );
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
      title: const Text('Select Video File !'),
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
                    final KCircularProgress cp =
                        KCircularProgress(ctx: context);
                    cp.showCircularProgress();
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
                          //print('video setup completed...');
                          cp.closeProgress();
                          Navigator.of(context).pop();
                        } else {
                          setDialogMsg('** video playlist error');
                          cp.closeProgress();
                        }
                        //setDialogMsg('updating video done...');
                      } else {
                        setDialogMsg('** video update error');
                        cp.closeProgress();
                      }
                    } else {
                      setDialogMsg('** video upload error');
                      cp.closeProgress();
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

class StudyRecycleVideoAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String className;

  StudyRecycleVideoAppBar({Key key, @required this.className})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
                'Old video:  ${context.watch<VideoRecycleItemModel>().totalResults > 0 ? '(${context.watch<VideoRecycleItemModel>().totalResults})' : ''}'),
            Text('$className', style: TextStyle(fontSize: 17.5))
          ]),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.navigate_before, size: 32),
            tooltip: 'show previous list',
            onPressed: () async {
              //print('<-- show previous list');
              var isLoaded =
                  Provider.of<VideoRecycleItemModel>(context, listen: false)
                      .isWaiting;
              if (!isLoaded) {
                var _prevPageToken =
                    Provider.of<VideoRecycleItemModel>(context, listen: false)
                        .previousPageToken;
                if (_prevPageToken != null) {
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    //print('<-- show previous list = $_prevPageToken');
                    Provider.of<VideoRecycleItemModel>(context, listen: false)
                        .setYtRecyclePlaylistItemByPageToken(_prevPageToken);
                  } else {
                    Scaffold.of(context)
                        .showSnackBar(kSnackbar('No internet !'));
                  }
                } else {
                  Scaffold.of(context)
                      .showSnackBar(kSnackbar('No previous page list !'));
                }
              } else {
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Please wait till resource is loaded !'));
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 7),
          child: IconButton(
            icon: const Icon(Icons.navigate_next, size: 32),
            tooltip: 'show next list',
            onPressed: () async {
              //print('show next list -->');
              var isLoaded =
                  Provider.of<VideoRecycleItemModel>(context, listen: false)
                      .isWaiting;
              if (!isLoaded) {
                var _nextPageToken =
                    Provider.of<VideoRecycleItemModel>(context, listen: false)
                        .nextPageToken;
                if (_nextPageToken != null) {
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    //print('show next list --> $_nextPageToken');
                    Provider.of<VideoRecycleItemModel>(context, listen: false)
                        .setYtRecyclePlaylistItemByPageToken(_nextPageToken);
                  } else {
                    Scaffold.of(context)
                        .showSnackBar(kSnackbar('No internet !'));
                  }
                } else {
                  Scaffold.of(context)
                      .showSnackBar(kSnackbar('No next page list !'));
                }
              } else {
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

class StudyRecycleVideo extends StatelessWidget {
  final String className;
  //final String classId;
  //final String playlistId;
  final String userAgent;
  final Function(String) onSuccessfulRecycle;
  StudyRecycleVideo(
      {Key key,
      @required this.className,
      //@required this.classId,
      //@required this.playlistId,
      @required this.userAgent,
      @required this.onSuccessfulRecycle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoRecycleItemModel(),
      child: Scaffold(
        appBar: StudyRecycleVideoAppBar(className: className),
        body: StudyRecycleVideoBody(
            className: className,
            //playlistId: playlistId,
            userAgent: userAgent,
            //classId: classId,
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

  String _previousPageToken;

  String get previousPageToken => _previousPageToken;

  String _nextPageToken;

  String get nextPageToken => _nextPageToken;

  int _totalResults = 0;

  int get totalResults => _totalResults;

  //String _classRplayListID = null;

  //String get classRplayListID => _classRplayListID;

  VideoRecycleItemModel() {
    _setYtRecyclePlaylistItem(null);
  }

  Future<void> _setYtRecyclePlaylistItem(String pageToken) async {
    //if (_classRplayListID == null) {
    //  var _playlistId = await yServ.getYtRecyclePlaylist(classId);
    //  print('rPlaylistId from ui --> $_playlistId');
    //  _classRplayListID = _playlistId;
    //}
    //var _classRplayListID = yServ.recycleBinPlaylistId;
    var _classRplayListID = await yServ.getUserChannelUploadPlaylistId();

    yServ
        .getYtPlaylistItem(_classRplayListID, pageToken)
        .then((jsonTags) async {
      //print('rJsonTags from ui -->');
      //print(jsonTags);
      var _jsonResp = null;
      //var _jsonArr = null;
      try {
        _jsonResp = convert.jsonDecode(jsonTags);
        //_jsonArr = convert.jsonDecode(jsonTags) as List;
        _isError = false;
        _errorMsg = '';
      } on FormatException catch (e) {
        print('ui video json error --> $jsonTags');
        _isError = true;
        _errorMsg = '$jsonTags';
      }
      if (_jsonResp != null) {
        var _jsonPreviousToken = _jsonResp['prevPageToken'] as String;
        var _jsonNextToken = _jsonResp['nextPageToken'] as String;
        _previousPageToken = _jsonPreviousToken;
        _nextPageToken = _jsonNextToken;
        var _jsonArr = _jsonResp['items'] as List;
        if (_jsonArr != null) {
          for (final tag in _jsonArr) {
            _VideoItem vi = _VideoItem.fromJson(tag);
            _rVideoItems.add(vi);
          }
        }
        _totalResults = _jsonResp['totalResults'] as int;
      }
      _isWaiting = false;
      notifyListeners();
    });
  }

  void setYtRecyclePlaylistItemByPageToken(String pageToken) {
    _isWaiting = true;
    _rVideoItems.clear();
    _setYtRecyclePlaylistItem(pageToken);
  }

  void removeItem(_VideoItem item) {
    if (_rVideoItems.remove(item)) {
      notifyListeners();
    }
  }

  int get getItemCount => _rVideoItems.length;

  void modifyItem(_VideoItem oldItem, _VideoItem newItem) {
    int index = _rVideoItems.indexOf(oldItem);
    if (index != null) {
      if (_rVideoItems.remove(oldItem)) {
        _rVideoItems.insert(index, newItem);
        notifyListeners();
      }
    }
  }
}

class StudyRecycleVideoBody extends StatelessWidget {
  final String className;
  //final String playlistId;
  final String userAgent;
  //final String classId;
  final Function(String) onSuccessfulRecycle;
  StudyRecycleVideoBody(
      {Key key,
      @required this.className,
      //@required this.playlistId,
      @required this.userAgent,
      //@required this.classId,
      @required this.onSuccessfulRecycle})
      : super(key: key);

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<void> _playYtVideo(String vidId) async {
    try {
      final bool result =
          await _platform.invokeMethod('playYoutubeVideo', vidId);
      //print('result --> $result');
    } on PlatformException catch (e) {
      print('error in playYoutubeVideo channel = ${e.message}');
    }
  }

  //Future<void> _reloadPlaylist(BuildContext context) {
  //  Provider.of<VideoRecycleItemModel>(context, listen: false)
  //      .reloadPlaylist(classId);
  //}

  Future<List<dynamic>> getPlalistIdTitle() async {
    String data = await fileServ.readDataByKey('classesAndPlaylistId');
    if (data != 'nil') {
      var _jsonArr = null;
      try {
        _jsonArr = convert.jsonDecode(data) as List;
      } on FormatException catch (e) {
        print('_validatePlaylistUpdate data = $data and error = $e');
      }
      return _jsonArr;
    }
    return null;
  }

  //AlertDialog _recycleVideoAlertW(BuildContext context, _VideoItem item) =>
  //    AlertDialog(
  //      title: Text('Are you sure to put back: ${item.title}'),
  //      shape: RoundedRectangleBorder(
  //        borderRadius: BorderRadius.all(Radius.circular(10)),
  //      ),
  //      titleTextStyle: TextStyle(
  //        color: Colors.black,
  //        fontWeight: FontWeight.w500,
  //        fontSize: 17,
  //      ),
  //      elevation: 15,
  //      actions: <Widget>[
  //        IconButton(
  //          icon: const Icon(Icons.done),
  //          iconSize: 27,
  //          onPressed: () async {
  //            final KCircularProgress cp = KCircularProgress(ctx: context);
  //            cp.showCircularProgress();
  //            //print('playlistId --> $playlistId');
  //            //print('recycle video item --> ${item.videoId}, ${item.id}');
  //            bool _isDel =
  //                await yServ.removeYtVideoFromPlaylist(item.id, userAgent);
  //            if (_isDel) {
  //              String _isPSet = await yServ.setYtVideoToPlaylist(
  //                  playlistId, item.videoId, userAgent);
  //              if (_isPSet != null) {
  //                Provider.of<VideoRecycleItemModel>(context, listen: false)
  //                    .removeItem(item);
  //                onSuccessfulRecycle(_isPSet);
  //                cp.closeProgress();
  //                Navigator.pop(context);
  //                Scaffold.of(context).showSnackBar(
  //                    kSnackbar('Video recycled successfully..!!'));
  //              } else {
  //                cp.closeProgress();
  //                //print('error in set playlist');
  //                Scaffold.of(context)
  //                    .showSnackBar(kSnackbar('Set to playlist unsuccessful'));
  //              }
  //            } else {
  //              cp.closeProgress();
  //              //print('error in delete from playlist');
  //              Scaffold.of(context).showSnackBar(
  //                  kSnackbar('Delete from Playlist unsuccessful'));
  //            }
  //          },
  //        ),
  //        IconButton(
  //          icon: const Icon(Icons.clear),
  //          iconSize: 27,
  //          onPressed: () {
  //            // print('Nav Pop');
  //            Navigator.pop(context);
  //          },
  //        ),
  //      ],
  //    );

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

  Card _studyClassVideoTile(BuildContext context, _VideoItem item) => Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                item.title,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: CircleAvatar(
                child: Text(
                  (item.position + 1).toString(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share_outlined, size: 27.5),
                tooltip: 'share video to classes',
                onPressed: () async {
                  //String _rPlaylistId =
                  //    Provider.of<VideoRecycleItemModel>(context, listen: false)
                  //        .classRplayListID;
                  //print('recycle video item --> ${item.videoId}, ${item.id}');
                  //print('rPlaylistId --> $_rPlaylistId');
                  //print('playlistId --> $_playlistId');

                  //kDAlert(context, _recycleVideoAlertW(context, item));
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    final KCircularProgress cp =
                        KCircularProgress(ctx: context);
                    cp.showCircularProgress();
                    var pList = await getPlalistIdTitle();
                    //pList.forEach((item) => print('${item['title'] as String} and ${item['id'] as String}'));
                    if (pList != null && pList.length > 0) {
                      var pmv = await yServ.getPlaylistMatchingVideo(
                          pList, item.videoId);
                      //print('pmv --> ${pmv.toString()}');
                      if (pmv != null) {
                        //final String usrAgent =
                        //    Provider.of<VideoItemModel>(context, listen: false)
                        //        .userAgent;
                        cp.closeProgress();
                        kDAlert(
                            context,
                            _MultiSelectClassForm(
                                preClassId: pmv,
                                onSuccessfulUpdate: (String value) {
                                  //print("hey it's $value");
                                  Scaffold.of(context)
                                      .showSnackBar(kSnackbar("$value"));
                                  onSuccessfulRecycle('ok');
                                },
                                videoId: item.videoId,
                                userAgent: userAgent,
                                videoTitle: item.title));
                      } else {
                        cp.closeProgress();
                        print('pmv null or empty !');
                      }
                    } else {
                      cp.closeProgress();
                      print('pList null or empty !');
                    }
                  } else {
                    kAlert(context, noInternetWidget);
                  }
                },
              ),
              isThreeLine: true,
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
              //onTap: () async {
              //  //print(
              //  //    'play video item and status --> ${item.videoId} and ${item.status}');
              //  //await _playYtVideo(item.videoId);
              //}
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: const Text('|> Play'),
                    onPressed: () async {
                      //print('Play Video --> ${item.title} & ${item.videoId}');
                      //await _playYtVideo(item.videoId);
                      await _playYtVideo(item.videoId);
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.465)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                  //Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                  TextButton(
                    child: const Text('/ Edit'),
                    onPressed: () async {
                      //print('Edit Video --> ${item.title} & ${item.videoId}');
                      //final String usrAgent =
                      //    Provider.of<VideoItemModel>(context, listen: false)
                      //        .userAgent;
                      //print('userAgent --> $userAgent');

                      kDAlert(
                          context,
                          VideoTitleEditForm(
                              vItem: item,
                              className: className,
                              userAgent: userAgent,
                              onSuccessfulUpdate: (_VideoItem vi) async {
                                //print(
                                //    'onSuccessfulUpload --> ${vi.toString()}');
                                Provider.of<VideoRecycleItemModel>(context,
                                        listen: false)
                                    .modifyItem(item, vi);
                              }));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.46)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      return ListView.separated(
                          itemCount: snapshot.rVideoItems.length,
                          separatorBuilder: (context, index) => Divider(
                                height: 4.2,
                              ),
                          itemBuilder: (context, index) => _studyClassVideoTile(
                              context, snapshot.rVideoItems[index]));
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

class _MultiSelectClassForm extends StatefulWidget {
  final List<String> preClassId;
  final Function(String) onSuccessfulUpdate;
  final String videoId;
  final String userAgent;
  final String videoTitle;
  _MultiSelectClassForm(
      {Key key,
      @required this.preClassId,
      @required this.onSuccessfulUpdate,
      @required this.videoId,
      @required this.userAgent,
      @required this.videoTitle})
      : super(key: key);

  @override
  _MultiSelectClassFormState createState() => _MultiSelectClassFormState();
}

class _MultiSelectClassFormState extends State<_MultiSelectClassForm> {
  final List<_ClassListModel> _classList = [];
  var _currentState = 'loading';
  var _showMessage = false;
  var _dialogMessage = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    String data = await fileServ.readDataByKey('classesAndIds');
    if (data != 'nil') {
      var _jsonArr = null;
      try {
        _jsonArr = convert.jsonDecode(data) as List;
        //List<_ClassListModel> _tags =
        //    _jsonArr.map((tagJson) => _ClassListModel.fromJson(tagJson)).toList();
      } on FormatException catch (e) {
        print('data = $data and error = $e');
        setState(() {
          _currentState = 'empty';
          _dialogMessage = 'Error !';
          _showMessage = true;
        });
      }
      if (_jsonArr != null && _jsonArr.length > 0) {
        setState(() {
          for (final tag in _jsonArr) {
            var clId = tag['classId'] as String;
            var isMatch = widget.preClassId.contains(clId);
            var clm = _ClassListModel.fromJson(tag, isEditable: !isMatch);
            _classList.add(clm);
          }
          _currentState = 'ok';
        });
      }
    } else {
      setState(() {
        _currentState = 'empty';
        _dialogMessage = 'Error !';
        _showMessage = true;
      });
    }
  }

  void setValueForClass(int index, bool value) {
    setState(() {
      //_classList[index].boolValue = value;
      _classList[index].setBoolvalue(value);
    });
  }

  Widget _getMessageWidget(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text('$message',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0)),
        ),
      );

  CheckboxListTile _checkBoxListTile(_ClassListModel clm, int index) =>
      CheckboxListTile(
        title: Text(
          '${clm.className}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.9,
          ),
        ),
        selected: !clm.isEditable,
        value: clm.boolValue,
        onChanged: (bool value) {
          setValueForClass(index, value);
          //setState(() {
          //  clm.boolValue(value);
          //});
        },
        //secondary: const Icon(Icons.fact_check),
        activeColor: Colors.lightBlue[600],
        dense: true,
      );

  Widget _getCurrentStateWidget(String stateValue) {
    switch (stateValue) {
      case 'ok':
        return ListView.separated(
          shrinkWrap: true,
          itemCount: _classList.length,
          itemBuilder: (context, index) =>
              _checkBoxListTile(_classList[index], index),
          separatorBuilder: (context, index) => Divider(
            height: 4.2,
          ),
        );
        break;
      case 'empty':
        return _getMessageWidget('No value...');
        break;
      default:
        return _getMessageWidget('Loading...');
    }
  }

  Future<String> _validatePlaylistUpdate() async {
    final List<_ClassListModel> classListUpdated = [];
    for (final clm in _classList) {
      if (clm.isEditable && clm.boolValue) {
        //print(clm.toString());
        classListUpdated.add(clm);
      }
    }
    if (classListUpdated.length > 0) {
      //print(classListUpdated.toString());
      String data = await fileServ.readDataByKey('classesAndPlaylistId');
      //print('data --> $data');
      if (data != 'nil') {
        var _jsonArr = null;
        try {
          _jsonArr = convert.jsonDecode(data) as List;
        } on FormatException catch (e) {
          print('_validatePlaylistUpdate data = $data and error = $e');
        }
        if (_jsonArr != null && _jsonArr.length > 0) {
          final List<_ClassPlaylistIdModel> cplm = [];
          for (final clm in classListUpdated) {
            for (final tag in _jsonArr) {
              if (clm.classId == tag['title'] as String) {
                //print('${clm.toString()} --> ${tag.toString()}');
                cplm.add(
                    _ClassPlaylistIdModel(clm.className, tag['id'] as String));
                break;
              }
            }
          }
          var resStr = convert.jsonEncode(cplm);
          return resStr;
        }
      } else {
        setState(() {
          _dialogMessage = 'Error !';
          _showMessage = true;
        });
      }
    } else {
      setState(() {
        _dialogMessage = 'No change !';
        _showMessage = true;
      });
    }
    return 'no';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Select Class :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text('Video : ${widget.videoTitle}',
                style: const TextStyle(color: Colors.black, fontSize: 16)),
          ),
          trailing: const Icon(
            Icons.arrow_downward,
            size: 27.0,
          ),
          //tileColor: Colors.yellow,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 2.0, color: Colors.grey),
          ),
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: _getCurrentStateWidget(_currentState),
      ),
      actions: <Widget>[
        Visibility(
          visible: _showMessage,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Text('$_dialogMessage',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
        Visibility(
          visible: _currentState == 'ok',
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: ElevatedButton(
              onPressed: () async {
                //print('save class list !');
                setState(() {
                  _dialogMessage = '';
                  _showMessage = false;
                });
                var msg = await _validatePlaylistUpdate();
                if (msg != 'no') {
                  final KCircularProgress cp = KCircularProgress(ctx: context);
                  cp.showCircularProgress();
                  var errorClassList = await yServ.setYtVideoToMultiplePlaylist(
                      msg, widget.videoId, widget.userAgent);
                  if (errorClassList.length == 0) {
                    widget.onSuccessfulUpdate('Update successfully !');
                  } else {
                    print('errorClassList --> ${errorClassList.toString()}');
                    widget.onSuccessfulUpdate('Error while update !');
                  }
                  cp.closeProgress();
                  Navigator.of(context).pop();
                  //print('msg --> $msg');
                }
              },
              child: const Text('Save',
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
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('Close',
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
      buttonPadding: const EdgeInsets.only(right: 7.0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      clipBehavior: Clip.none,
      insetPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      //actionsOverflowButtonSpacing: 20.0,
      backgroundColor: Colors.indigo.shade50,
    );
  }
}

class _ClassListModel {
  final String className;
  final String classId;
  final bool isEditable;
  bool _boolValue = false;

  _ClassListModel(this.className, this.classId, this.isEditable,
      {boolValue: false})
      : _boolValue = boolValue;

  //String get className => _className;

  factory _ClassListModel.fromJson(dynamic json, {isEditable: true}) {
    return _ClassListModel(
        json['className'] as String, json['classId'] as String, isEditable,
        boolValue: !isEditable);
  }

  bool get boolValue => _boolValue;

  void setBoolvalue(bool value) {
    if (this.isEditable) {
      this._boolValue = value;
    }
  }

  @override
  String toString() {
    return '{${this.classId}, ${this.className}, ${this.boolValue}, isEditable: ${this.isEditable}}';
  }
}

class _ClassPlaylistIdModel {
  final String _className;
  final String _playlistId;

  _ClassPlaylistIdModel(this._className, this._playlistId);

  Map toJson() => {
        'className': _className,
        'playlistId': _playlistId,
      };
}

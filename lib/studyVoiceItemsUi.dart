import 'package:flutter/material.dart';
import 'self.dart';
//import 'package:medcorder_audio/medcorder_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
//import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

final Reference storageReference =
    FirebaseStorage.instance.ref().child('kgms-voice-notes');

class StudyVoiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String className;
  final String classId;
  StudyVoiceAppBar({Key key, @required this.className, @required this.classId})
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
          const Text('Voice :'),
          Text('$className', style: TextStyle(fontSize: 17.5)),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.cached_rounded, size: 30),
            tooltip: 'list voice from cache',
            onPressed: () {
              //print('add new voice from files !');
              kDAlert(
                  context,
                  _VoiceFilesFromCacheWrapper(
                      classId: classId,
                      className: className,
                      onSuccessfulUpload: (String fileName) {
                        //print('from StudyVoiceAppBar fileName --> $fileName');
                        Provider.of<VoiceItemsModel>(context, listen: false)
                            .addItem(fileName);
                      },
                      getMaxVoiceCount: () {
                        if (Provider.of<VoiceItemsModel>(context, listen: false)
                            .isWaiting) {
                          return -1;
                        } else {
                          return Provider.of<VoiceItemsModel>(context,
                                  listen: false)
                              .getLen;
                        }
                      }));
              //Provider.of<CacheFileItemModel>(context, listen: false)
              //    .loadFilesFromCacheDirectory();
            },
          ),
        ),
      ],
    );
  }
}

class StudyVoiceWrapper extends StatelessWidget {
  final String className;
  final String classId;
  StudyVoiceWrapper({Key key, @required this.className, @required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceItemsModel(classId),
      child: StudyVoice(className: className, classId: classId),
    );
  }
}

class VoiceItemsModel with ChangeNotifier implements ReassembleHandler {
  final List<String> _voiceItems = [];

  List<String> get voiceItems => _voiceItems;

  bool _isWaiting = true;

  bool get isWaiting => _isWaiting;

  bool _isError = false;

  bool get isError => _isError;

  String _errorMsg = '';

  String get errorMsg => _errorMsg;

  VoiceItemsModel(String subDir) {
    //print('VoiceItemsModel subDir --> $subDir');
    _getStorageData(subDir);
    //_voiceItems.add('xyz.mp4');
    //_isWaiting = false;
    //notifyListeners();
  }

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<void> _getStorageData(String subDir) async {
    try {
      // final String result = await platform.invokeMethod('getMediaStorage',"Hello from Flutter !");
      final String result =
          await _platform.invokeMethod('getVoiceStorage', subDir);
      var jsonArr = jsonDecode(result);
      List<String> outputList = jsonArr != null ? List.from(jsonArr) : null;
      //print('result = $outputList');
      if (outputList != null) {
        outputList.forEach((item) => _voiceItems.add(item));
      }
      _isError = false;
      _errorMsg = '';
    } on PlatformException catch (e) {
      print('error in storage channel = ${e.message}');
      _isError = true;
      _errorMsg = 'platform exception';
    } on FormatException catch (e) {
      print('error in json parse = ${e.message}');
      _isError = true;
      _errorMsg = 'json exception';
    }
    _isWaiting = false;
    notifyListeners();
  }

  void addItem(String item) {
    if (!_voiceItems.contains(item)) {
      _voiceItems.add(item);
      notifyListeners();
    }
    //print('add item name --> $item');
  }

  void removeItem(String item) {
    if (_voiceItems.contains(item)) {
      _voiceItems.remove(item);
      notifyListeners();
    }
  }

  int get getLen => _voiceItems.length;

  @override
  void reassemble() {
    print('Did hot-reload from VoiceItemsModel !');
  }
}

class StudyVoice extends StatelessWidget {
  final String className;
  final String classId;
  StudyVoice({Key key, @required this.className, @required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudyVoiceAppBar(className: className, classId: classId),
      body: StudyVoiceBody(classId: classId),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 57.0,
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton.icon(
                  onPressed: () async {
                    kDAlert(
                        context,
                        _VoiceRecorderPlayer(
                            classId: classId,
                            onSuccessfulUpload: (String fileName) {
                              //print(
                              //    'from study voice upload file name --> $fileName');
                              Provider.of<VoiceItemsModel>(context,
                                      listen: false)
                                  .addItem(fileName);
                            },
                            getMaxVoiceCount: () {
                              if (Provider.of<VoiceItemsModel>(context,
                                      listen: false)
                                  .isWaiting) {
                                return -1;
                              } else {
                                return Provider.of<VoiceItemsModel>(context,
                                        listen: false)
                                    .getLen;
                              }
                            }));
                  },
                  label: const Text(
                    'Record',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child:
                        const Icon(Icons.keyboard_voice_outlined, size: 25.2),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  //splashColor: Colors.yellow,
                  color: Colors.lightBlue[600],
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      //floatingActionButton: FloatingActionButton(
      //  onPressed: () => print('start recording !'),
      //  tooltip: 'Increment Counter',
      //  child: const Icon(Icons.keyboard_voice, size: 27.5),
      //  backgroundColor: Colors.lightBlue[600],
      //  foregroundColor: Colors.white,
      //),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class StudyVoiceBody extends StatelessWidget {
  final String classId;
  StudyVoiceBody({Key key, @required this.classId}) : super(key: key);

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
              print('del voice $fileName from sub dir $subDir');
              final KCircularProgress cp = KCircularProgress(ctx: context);
              cp.showCircularProgress();
              try {
                await storageReference.child(subDir).child(fileName).delete();
                Provider.of<VoiceItemsModel>(context, listen: false)
                    .removeItem(fileName);
                cp.closeProgress();
                Navigator.pop(context);
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Voice deleted successfully..!!'));
              } catch (e) {
                cp.closeProgress();
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Delete unsuccessful. Please check.'));
              }
              //Navigator.pop(context);
              //Scaffold.of(context)
              //    .showSnackBar(kSnackbar('Voice deleted successfully..!!'));
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

  String getFileType(String ext) {
    if (ext == '.mp4')
      return 'voice';
    else
      return 'unknown';
  }

  Card _studyClassVoiceTile1(
          BuildContext context, String fileName, String fileType, int index) =>
      Card(
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
                fileName,
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
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  '<type - $fileType>',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
                      if (fileType == 'voice') {
                        print('play voice file --> $fileName');
                        bool _internet = await isInternetAvailable();
                        if (_internet) {
                          final KCircularProgress cp =
                              KCircularProgress(ctx: context);
                          cp.showCircularProgress();
                          dynamic downloadUrl = await storageReference
                              .child(classId)
                              .child(fileName)
                              .getDownloadURL();
                          String sUrl = cast<String>(downloadUrl);
                          cp.closeProgress();
                          //print('sUrl --> $sUrl');
                          kDAlert(context,
                              _VoicePlayer(trackUrl: sUrl, fileName: fileName));
                        } else {
                          kAlert(context, noInternetWidget);
                        }
                      } else {
                        Scaffold.of(context)
                            .showSnackBar(kSnackbar('Media not listed..!!'));
                      }
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
                  //TextButton(
                  //  child: const Text('/ Edit'),
                  //  onPressed: () async {
                  //    if (fileType == 'voice') {
                  //      print('edit voice file --> $fileName');
                  //    }
                  //  },
                  //  style: ButtonStyle(
                  //    foregroundColor: MaterialStateProperty.all<Color>(
                  //        Colors.black.withOpacity(0.46)),
                  //    textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                  //      fontSize: 16,
                  //      fontWeight: FontWeight.bold,
                  //    )),
                  //  ),
                  //),
                  //Spacer(),
                  TextButton(
                    child: const Text('X Remove'),
                    onPressed: () {
                      if (fileType == 'voice') {
                        print('remove voice file --> $fileName');
                        kDAlert(
                            context, _deleteAlertW(context, classId, fileName));
                      }
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

  Widget unlistedVoiceWidget(BuildContext context) =>
      Consumer<VoiceItemsModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.voiceItems == null) {
            return _loadingTile('snapshot voiceItems null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _loadingTile(snapshot.errorMsg);
                  } else {
                    if (snapshot.voiceItems.isEmpty) {
                      return _loadingTile('No Voice Items !');
                    } else {
                      return ListView.separated(
                          itemCount: snapshot.voiceItems.length,
                          separatorBuilder: (context, index) => Divider(
                                height: 4.2,
                              ),
                          itemBuilder: (context, index) =>
                              _studyClassVoiceTile1(
                                  context,
                                  snapshot.voiceItems[index],
                                  getFileType(
                                      extension(snapshot.voiceItems[index])),
                                  index));
                    }
                  }
                }
            }
          }
        }
      });

  @override
  Widget build(BuildContext context) {
    return unlistedVoiceWidget(context);
  }
}

class _VoicePlayer extends StatefulWidget {
  final String trackUrl;
  final String fileName;
  const _VoicePlayer(
      {Key key, @required this.trackUrl, @required this.fileName})
      : super(key: key);

  @override
  _VoicePlayerState createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  final FlutterSoundPlayer _myPlayer = FlutterSoundPlayer();

  bool _isPlay = false;
  String _errorMsg = '';
  bool _canPlay = false;
  Duration _recordDuration = Duration(milliseconds: 1);
  Duration _playPosition = Duration(milliseconds: 0);

  StreamSubscription<Duration> _playerSubscription = null;
  String _msg = '';
  //Track track;

  @override
  void initState() {
    super.initState();
    _myPlayer.openAudioSession().then((value) {
      print('_myPlayer value --> $value');
      setState(() {
        _canPlay = true;
      });
    });
  }

  @override
  void dispose() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
    _myPlayer.closeAudioSession();
    super.dispose();
  }

  Stream<Duration> _streamPlayerProgress(Duration recordDurationInSec) {
    StreamController<Duration> controller;
    Timer timer;
    int counter = 500;

    void runProgress(_) {
      var curDuration = Duration(milliseconds: counter);
      if (recordDurationInSec >= (curDuration)) {
        controller.add(curDuration);
        //counter += 111;
        counter += 500;
      } else {
        timer.cancel();
        timer = null;
        print('timer completed !');
      }
    }

    void startTimer() {
      timer = Timer.periodic(const Duration(milliseconds: 500), runProgress);
    }

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
      if (controller != null) {
        controller.close();
        controller = null;
      }
    }

    controller =
        StreamController<Duration>(onListen: startTimer, onCancel: stopTimer);

    return controller.stream;
  }

  Future<void> _startStopPlayNew(bool isPlay) async {
    if (_canPlay) {
      if (isPlay) {
        if (_myPlayer != null) {
          await _myPlayer.stopPlayer();
          if (_myPlayer.isStopped) {
            setState(() {
              _isPlay = false;
              _playPosition = Duration(milliseconds: 0);
              if (_playerSubscription != null) {
                _playerSubscription.cancel();
                _playerSubscription = null;
              }
            });
          }
        }
        print('stop track --> ${widget.trackUrl}');
      } else {
        print('play track --> ${widget.trackUrl}');
        Duration d = await _myPlayer.startPlayer(
          fromURI: widget.trackUrl,
          whenFinished: () {
            print('player finished playing !');
            setState(() {
              _isPlay = false;
              _playPosition = Duration(milliseconds: 0);
              if (_playerSubscription != null) {
                _playerSubscription.cancel();
                _playerSubscription = null;
              }
            });
          },
        );
        if (_myPlayer.isPlaying) {
          setState(() {
            _msg = '';
            _recordDuration = d;
            _playerSubscription =
                _streamPlayerProgress(_recordDuration).listen((e) {
              //print('current progress --> $e');
              setState(() {
                _playPosition = e;
              });
            });
            _isPlay = true;
          });
        }
      }
    } else {
      setState(() {
        _errorMsg = 'Cannot play audio';
      });
    }
  }

  ElevatedButton _togglePlayButton(bool isPlay) => ElevatedButton(
        onPressed: () async {
          if (!isPlay && _canPlay && _errorMsg.isEmpty) {
            print('Play track !');
            setState(() {
              _msg = 'Loading...';
            });
            _startStopPlayNew(isPlay);
            //_startStopPlay(isPlay);
            //setState(() {
            //  _isPlay = true;
            //});
          } else {
            if (_canPlay && _errorMsg.isEmpty) {
              print('Stop play track !');
              _startStopPlayNew(isPlay);
            }
            //_startStopPlay(isPlay);
            //setState(() {
            //  _isPlay = false;
            //});
          }
        },
        child: isPlay
            ? const Icon(Icons.stop_rounded, color: Colors.white)
            : const Icon(Icons.play_arrow_rounded, color: Colors.white),
        style: ButtonStyle(
          backgroundColor: isPlay
              ? MaterialStateProperty.all<Color>(Colors.cyan)
              : MaterialStateProperty.all<Color>(Colors.green[400]),
          shape:
              MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          )),
        ),
      );

  Widget _playTrackWidget() {
    var lpv = _playPosition.inMilliseconds / _recordDuration.inMilliseconds;
    return ListView(
      //mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 30.0,
        ),
        Container(
          //width: MediaQuery.of(context).size.width * 0.90,
          child: LinearProgressIndicator(
            value: lpv,
            minHeight: 5.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            //backgroundColor: Colors.white,
            semanticsLabel: 'Linear progress indicator for playing track',
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '>  ${_printDuration(_recordDuration)}',
            ),
          ],
        ),
        SizedBox(
          height: 25.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _togglePlayButton(_isPlay),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Play track :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text('file : ${widget.fileName}',
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
        //height: 175.0,
        height: double.minPositive + 170.0,
        child: _playTrackWidget(),
      ),
      actions: <Widget>[
        Visibility(
          visible: !_msg.isEmpty,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Text('$_msg',
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
          ),
        ),
        Visibility(
          visible: !_errorMsg.isEmpty,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Text('$_errorMsg',
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
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

class _VoiceRecorderPlayer extends StatefulWidget {
  final String classId;
  final Map<String, dynamic> loadedData;
  final Function(String) onSuccessfulUpload;
  final Function getMaxVoiceCount;
  const _VoiceRecorderPlayer(
      {Key key,
      @required this.classId,
      this.loadedData,
      @required this.onSuccessfulUpload,
      @required this.getMaxVoiceCount})
      : super(key: key);

  @override
  _VoiceRecorderPlayerState createState() => _VoiceRecorderPlayerState();
}

class _VoiceRecorderPlayerState extends State<_VoiceRecorderPlayer> {
  final FlutterSoundRecorder _myRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _myPlayer = FlutterSoundPlayer();
  bool _isRecord = false;
  bool _isPlay = false;
  bool _showRecording = true;
  String _errorMsg = '';
  bool _canRecord = false;
  bool _canPlay = false;
  String _file = "";
  Duration _playPosition = Duration(milliseconds: 0);
  double _recordPower = 0.0;
  Duration _recordDuration = Duration(milliseconds: 0);
  String _fileName = '';

  String _filePath = "";

  final TextEditingController _fileNameCtrl = TextEditingController();

  bool _hasRecodingDone = false;

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  StreamSubscription<RecordingDisposition> _recordSubscription = null;

  StreamSubscription<Duration> _playerSubscription = null;

  @override
  void initState() {
    super.initState();
    if (widget.loadedData != null) {
      setState(() {
        _fileName = widget.loadedData['fileName'] as String;
        _file = widget.loadedData['filePath'] as String;
        _recordDuration = widget.loadedData['fileDuration'] as Duration;
        _fileNameCtrl.text = _getClassFileName(
            widget.classId, basenameWithoutExtension(_fileName));
        _showRecording = false;
      });
    }
    _initRecordSetup();
  }

  Future<void> _localPath() async {
    try {
      final String result = await _platform.invokeMethod('getExtCacheDir');
      if (result != null && !result.isEmpty) {
        //print('_localPath path --> $result');
        setState(() {
          _filePath = result;
        });
      } else {
        setState(() {
          _errorMsg = 'Error in cache dir';
        });
      }
    } on PlatformException catch (e) {
      print('error in getExtCacheDir channel = ${e.message}');
    }
  }

  Future<void> _initRecordSetup() async {
    try {
      final bool result = await _platform.invokeMethod('isPermissionToRecord');
      print('_initRecordSetup result --> $result');
      if (result) {
        _myRecorder.openAudioSession().then((value) async {
          print('_myRecorder value --> $value');
          await _localPath();
          setState(() {
            //subscription = _recorderStatusStream(_myRecorder).listen((value) {
            //  print('_recorderStatusStream value --> $value');
            //  _onRecordEvent(value);
            //});
            _canRecord = true;
          });
        });
        _myPlayer.openAudioSession().then((value) {
          print('_myPlayer value --> $value');
          setState(() {
            _canPlay = true;
            //_myPlayer.setPlayerCallback();
          });
        });
      } else {
        setState(() {
          _errorMsg = 'No microphone permission';
        });
      }
    } on PlatformException catch (e) {
      print('error in isPermissionToRecord channel = ${e.message}');
    }
  }

  Future<void> _startRecordNew() async {
    DateTime time = DateTime.now();
    //var fName = _getVoiceFileNameFromDateTime(time);
    //print('fName --> $fName');
    setState(() {
      _fileName = '${time.millisecondsSinceEpoch.toString()}.mp4';
      //_fileName = fName;
      _file = _filePath + '/$_fileName';
    });
    print('file with path --> $_file');
    try {
      await _myRecorder.startRecorder(
        toFile: _file,
        codec: Codec.aacMP4,
      );
      if (_myRecorder.isRecording) {
        setState(() {
          _isRecord = true;
          _recordSubscription = _myRecorder.onProgress.listen((e) {
            setState(() {
              _recordDuration = e.duration;
              _recordPower = e.decibels;
            });
          });
        });
      }
    } catch (e) {
      print('error _startRecordNew --> $e');
      setState(() {
        _errorMsg = 'Error in start record';
      });
    }
  }

  Future<void> _stopRecordNew() async {
    try {
      await _myRecorder.stopRecorder();
      if (_myRecorder.isStopped) {
        var recDuration = await FlutterSoundHelper().duration(_file);
        var _fTitle = _getClassFileName(
            widget.classId, basenameWithoutExtension(_fileName));
        setState(() {
          _fileNameCtrl.text = _fTitle;
          _recordDuration = recDuration;
          _showRecording = false;
          if (_recordSubscription != null) {
            _recordSubscription.cancel();
            _recordSubscription = null;
          }
          _hasRecodingDone = true;
        });
      }
    } catch (e) {
      print('error _stopRecordNew --> $e');
      setState(() {
        _errorMsg = 'Error in stop record';
      });
    }
  }

  Stream<Duration> _streamPlayerProgress(Duration recordDurationInSec) {
    StreamController<Duration> controller;
    Timer timer;
    int counter = 500;

    void runProgress(_) {
      var curDuration = Duration(milliseconds: counter);
      if (recordDurationInSec >= (curDuration)) {
        controller.add(curDuration);
        //counter += 111;
        counter += 500;
      } else {
        timer.cancel();
        timer = null;
        print('timer completed !');
      }
    }

    void startTimer() {
      timer = Timer.periodic(const Duration(milliseconds: 500), runProgress);
    }

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
      if (controller != null) {
        controller.close();
        controller = null;
      }
    }

    controller =
        StreamController<Duration>(onListen: startTimer, onCancel: stopTimer);

    return controller.stream;
  }

  Future<void> _startStopPlayNew(bool isPlay) async {
    if (_canPlay) {
      if (isPlay) {
        if (_myPlayer != null) {
          await _myPlayer.stopPlayer();
          if (_myPlayer.isStopped) {
            setState(() {
              _isPlay = false;
              _playPosition = Duration(milliseconds: 0);
              if (_playerSubscription != null) {
                _playerSubscription.cancel();
                _playerSubscription = null;
              }
            });
          }
        }
      } else {
        await _myPlayer.startPlayer(
            fromURI: _file,
            codec: Codec.aacMP4,
            whenFinished: () {
              setState(() {
                print('player finished playing !');
                _isPlay = false;
                _playPosition = Duration(milliseconds: 0);
                if (_playerSubscription != null) {
                  _playerSubscription.cancel();
                  _playerSubscription = null;
                }
              });
            });
        if (_myPlayer.isPlaying) {
          print('tot dur --> $_recordDuration');
          //print('play dur --> $_playDuration');
          setState(() {
            _playerSubscription =
                _streamPlayerProgress(_recordDuration).listen((e) {
              //print('current progress --> $e');
              setState(() {
                _playPosition = e;
              });
            });
            _isPlay = true;
          });
        }
      }
    } else {
      setState(() {
        _errorMsg = 'Cannot play audio';
      });
    }
  }

  //Stream<int> _getPlayerCurrentPos() {
  //  StreamController<int> controller;

  //  void

  //  controller = StreamController<int>(
  //    listen:
  //    pause:
  //    resume:
  //    cancel:
  //  );
  //}

  Future<void> _resetRecord() async {
    if (_myPlayer.isPlaying) {
      await _myPlayer.stopPlayer();
      if (_myPlayer.isStopped) {
        setState(() {
          _isPlay = false;
          _playPosition = Duration(milliseconds: 0);
          if (_playerSubscription != null) {
            _playerSubscription.cancel();
            _playerSubscription = null;
          }
        });
      }
    }
    setState(() {
      _isRecord = false;
      _isPlay = false;
      _showRecording = true;
      _errorMsg = '';
      _file = "";
      _playPosition = Duration(milliseconds: 0);
      _recordPower = 0.0;
      _recordDuration = Duration(milliseconds: 0);
      _fileName = '';
    });
  }

  @override
  void dispose() {
    if (_recordSubscription != null) {
      _recordSubscription.cancel();
      _recordSubscription = null;
    }
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
    _myRecorder.closeAudioSession();
    _myPlayer.closeAudioSession();
    super.dispose();
  }

  ElevatedButton _togglePlayButton(bool isPlay) => ElevatedButton(
        onPressed: () {
          if (!isPlay && _canPlay && _errorMsg.isEmpty) {
            print('Play recording !');
            _startStopPlayNew(isPlay);
            //_startStopPlay(isPlay);
            //setState(() {
            //  _isPlay = true;
            //});
          } else {
            if (_canPlay && _errorMsg.isEmpty) {
              print('Stop play recording !');
              _startStopPlayNew(isPlay);
            }
            //_startStopPlay(isPlay);
            //setState(() {
            //  _isPlay = false;
            //});
          }
        },
        child: isPlay
            ? const Icon(Icons.stop_rounded, color: Colors.white)
            : const Icon(Icons.play_arrow_rounded, color: Colors.white),
        style: ButtonStyle(
          backgroundColor: isPlay
              ? MaterialStateProperty.all<Color>(Colors.cyan)
              : MaterialStateProperty.all<Color>(Colors.green[400]),
          shape:
              MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          )),
        ),
      );

  ElevatedButton _toggleRecordButton(bool isRecord) => ElevatedButton(
        onPressed: () {
          if (!isRecord) {
            //print('start recording !');
            if (_canRecord && _errorMsg.isEmpty) {
              print('can record !');
              print('starting recording !');
              _startRecordNew();
              //_startRecord();
              //setState(() {
              //  _isRecord = true;
              //});
            }
          } else {
            print('stop recording !');
            if (_canRecord && _isRecord && _errorMsg.isEmpty) {
              print('stoping recording !');
              _stopRecordNew();
              //_stopRecord();
            }
            //setState(() {
            //  //_isRecord = false;
            //  _showRecording = false;
            //});
          }
        },
        child: isRecord
            ? const Icon(Icons.stop_rounded, color: Colors.white)
            : const Icon(Icons.keyboard_voice_rounded, color: Colors.white),
        style: ButtonStyle(
          backgroundColor: isRecord
              ? MaterialStateProperty.all<Color>(Colors.red)
              : MaterialStateProperty.all<Color>(Colors.green),
          shape:
              MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          )),
        ),
      );

  Widget _startRecordWidget(BuildContext context) {
    var recordPosition = _printDuration(_recordDuration);
    var recordPower = _recordPower.toStringAsFixed(2);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.50,
          child: Center(
            child: ListTile(
              title: Text('${!_isRecord ? 'Start' : 'Stop'} recording !',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 17.0,
                      letterSpacing: 0.5)),
              subtitle: Visibility(
                visible: _isRecord,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                      '( Speak... )' +
                          '\n\n' +
                          ' decibel :( $recordPower )' +
                          '\n' +
                          ' > $recordPosition ',
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                          letterSpacing: 0.7)),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Center(
            child: _toggleRecordButton(_isRecord),
          ),
        ),
      ],
    );
  }

  Widget _playRecordWidget(BuildContext context) {
    var lpv = _playPosition.inMilliseconds / _recordDuration.inMilliseconds;
    return ListView(
      //mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
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
              child: Theme(
                data: ThemeData(
                  primaryColor: Colors.blueAccent,
                  //primaryColorDark: Colors.red,
                ),
                child: TextField(
                  controller: _fileNameCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  cursorColor: Colors.blue,
                ),
              ),
            ),
            Text(' ${extension(_fileName)}'),
          ],
        ),
        SizedBox(
          height: 50.0,
        ),
        Container(
          //width: MediaQuery.of(context).size.width * 0.90,
          child: LinearProgressIndicator(
            value: lpv,
            minHeight: 5.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            //backgroundColor: Colors.white,
            semanticsLabel: 'Linear progress indicator for playing record',
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '>  ${_printDuration(_recordDuration)}',
            ),
          ],
        ),
        SizedBox(
          height: 25.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _togglePlayButton(_isPlay),
          ],
        ),
        SizedBox(
          height: 50.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                print('again recording !');
                _resetRecord();
              },
              child: const Text('< Retake',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.5,
                    letterSpacing: 0.5,
                  )),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                )),
              ),
            ),
            SizedBox(
              width: 98.0,
            ),
            ElevatedButton(
              onPressed: () async {
                //print('upload recording !');
                var maxCount = widget.getMaxVoiceCount();
                //print('max count --> $maxCount');
                if (maxCount == -1) {
                  setState(() {
                    _errorMsg = 'wait resource loading';
                  });
                } else if (maxCount == 10) {
                  setState(() {
                    _errorMsg = 'max 10 voice allowed !';
                  });
                } else {
                  if (_fileNameCtrl.text.isEmpty) {
                    setState(() {
                      _errorMsg = 'File name required !';
                    });
                  } else if ((_fileNameCtrl.text.split(' ').length > 1) ||
                      (_fileNameCtrl.text != _fileNameCtrl.text.trim())) {
                    setState(() {
                      _errorMsg = 'File name has spaces !';
                    });
                  } else {
                    setState(() {
                      _errorMsg = '';
                    });
                    if (!_file.isEmpty) {
                      //print('file name --> ${_fileNameCtrl.text}');
                      //print('upload file --> $_file');
                      //final String fullFileName =
                      //    _fileNameCtrl.text + extension(_fileName);
                      //print('upload file name --> $fullFileName');

                      bool _internet = await isInternetAvailable();
                      if (_internet) {
                        final KCircularProgress cp =
                            KCircularProgress(ctx: context);
                        cp.showCircularProgress();
                        final File mediaItem = File(_file);
                        final String fullFileName =
                            _fileNameCtrl.text + extension(_fileName);
                        final uploadStream = storageReference
                            .child(widget.classId)
                            .child(fullFileName)
                            .putFile(mediaItem)
                            .asStream();
                        setState(() {
                          _errorMsg = "uploading...";
                        });
                        final subscription = uploadStream.listen(
                          (data) {
                            if (data.state == TaskState.running) {
                            } else if (data.state == TaskState.error) {
                              cp.closeProgress();
                              setState(() {
                                _errorMsg = "** upload error";
                              });
                            } else if (data.state == TaskState.success) {
                              widget.onSuccessfulUpload(fullFileName);
                              cp.closeProgress();
                              Navigator.of(context).pop();
                            } else if (data.state == TaskState.canceled) {
                              cp.closeProgress();
                              setState(() {
                                _errorMsg = "** upload canceled";
                              });
                            } else if (data.state == TaskState.paused) {
                              cp.closeProgress();
                              setState(() {
                                _errorMsg = "** upload paused";
                              });
                            }
                          },
                          onError: (err) {
                            print('Error during upload --> $err');
                          },
                          cancelOnError: false,
                          onDone: () {
                            print('upload stream done !');
                          },
                        );
                      } else {
                        kAlert(context, noInternetWidget);
                      }
                    } else {
                      setState(() {
                        _errorMsg = 'File empty !';
                      });
                    }
                  }
                }
              },
              child: const Text('Upload >',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.5,
                    letterSpacing: 0.5,
                  )),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Voice recorder :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text('record, play & upload',
                style: TextStyle(color: Colors.black, fontSize: 16)),
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
        height: _showRecording ? double.minPositive + 200.00 : double.maxFinite,
        child: _showRecording
            ? _startRecordWidget(context)
            : _playRecordWidget(context),
      ),
      actions: <Widget>[
        Visibility(
          visible: !_errorMsg.isEmpty,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Text('$_errorMsg',
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_hasRecodingDone);
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

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

class _VoiceFilesFromCache extends StatelessWidget {
  final String classId;
  final String className;
  final Function(String) onSuccessfulUpload;
  final Function getMaxVoiceCount;
  const _VoiceFilesFromCache(
      {Key key,
      @required this.classId,
      @required this.className,
      @required this.onSuccessfulUpload,
      @required this.getMaxVoiceCount})
      : super(key: key);

  Card _loadingTile(String msg) => Card(
        //color: Colors.orange[300],
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

  Function _deleteFileFromCache(String filePath) {
    String deleteFileFromCache() {
      //print('delete file from cache --> $filePath');
      var _file = File(filePath);
      if (_file.existsSync()) {
        try {
          _file.deleteSync();
          return 'ok';
        } catch (e) {
          print('Remove Audio err --> $e');
          return "Couldn't delete file !";
        }
      } else {
        print('Remove Audio err --> file not exists !');
        return "File doesn't exists";
      }
    }

    return deleteFileFromCache;
  }

  Function _deleteAllFilesFromCache(List<String> fileList) {
    String deleteAllFilesFromCache() {
      //print('delete file from cache --> $filePath');
      bool _isOk = true;
      for (var filePath in fileList) {
        //print('delete file from cache --> $file');
        var _file = File(filePath);
        if (_file.existsSync()) {
          try {
            _file.deleteSync();
          } catch (e) {
            print('Remove all Audio err --> $e');
            _isOk = false;
          }
        } else {
          _isOk = false;
        }
      }
      if (_isOk) {
        return 'ok';
      } else {
        return 'Error during deletion !';
      }
    }

    return deleteAllFilesFromCache;
  }

  AlertDialog _getAlertDialog(BuildContext context, String msg, Function fn) {
    return AlertDialog(
      title: Text('$msg'),
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
          onPressed: () {
            //print('exec function');
            final KCircularProgress cp = KCircularProgress(ctx: context);
            cp.showCircularProgress();
            var res = fn();
            print('res --> $res');
            if (res == 'ok') {
              cp.closeProgress();
              Navigator.pop(context);
              Provider.of<CacheFileItemModel>(context, listen: false)
                  .reloadData();
            } else {
              cp.closeProgress();
              Navigator.pop(context);
              Provider.of<CacheFileItemModel>(context, listen: false)
                  .reloadData();
              kAlert(context, showErrorWidget(res));
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
  }

  Card _fileDetailsWidget(BuildContext context, String filePath, int index) =>
      Card(
        //color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                _getFileNameFromPath(filePath),
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
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Date: ' +
                      _getStringDateFromMse(basenameWithoutExtension(
                          _getFileNameFromPath(filePath))),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('X Remove'),
                    onPressed: () {
                      //kDAlert(context, _removeVoiceAlertW(context, filePath));
                      var _fn = _deleteFileFromCache(filePath);
                      var _msg =
                          'Are you sure to remove: ${_getFileNameFromPath(filePath)}';
                      kDAlert(context, _getAlertDialog(context, _msg, _fn));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.465)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        //fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    child: const Text('|> Play'),
                    onPressed: () async {
                      //print('Play Audio --> $filePath');
                      var dur = await FlutterSoundHelper().duration(filePath);
                      Map<String, dynamic> data = {
                        'fileName': _getFileNameFromPath(filePath),
                        'filePath': filePath,
                        'fileDuration': dur,
                      };
                      var result = await _showDialog(
                          context,
                          _VoiceRecorderPlayer(
                              classId: classId,
                              loadedData: data,
                              onSuccessfulUpload: onSuccessfulUpload,
                              getMaxVoiceCount: getMaxVoiceCount));

                      //print('kDAlert _VoiceRecorderPlayer --> $result');

                      if (result != null && !result) {
                        print('no refreshing data required..!');
                      } else {
                        print('refreshing data..!');
                        Provider.of<CacheFileItemModel>(context, listen: false)
                            .reloadData();
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.465)),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        //fontSize: 16,
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

  Future<bool> _showDialog(BuildContext ctx, Widget widg) async {
    return showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: widg,
        );
      },
    );
  }

  Widget _loadCacheVoiceFileList(BuildContext context) =>
      Consumer<CacheFileItemModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.voiceItems == null) {
            return _loadingTile('snapshot voiceItems null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _loadingTile(snapshot.errorMsg);
                  } else {
                    if (snapshot.voiceItems.isEmpty) {
                      return _loadingTile('No Voice Items !');
                    } else {
                      return ListView.separated(
                        itemCount: snapshot.voiceItems.length,
                        itemBuilder: (context, index) => _fileDetailsWidget(
                            context, snapshot.voiceItems[index], index),
                        separatorBuilder: (context, index) => Divider(
                          height: 4.2,
                        ),
                      );
                    }
                  }
                }
            }
          }
        }
      });

  //Widget _loadCacheVoiceFileList(BuildContext context) {
  //  var fileList = context.watch<CacheFileItemModel>().voiceItems;
  //  print('fileList --> $fileList');
  //  return _loadingTile('Loading....');
  //}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: Text(
              'Class $className :  ${context.watch<CacheFileItemModel>().totalVoiceFile > 0 ? '(${context.watch<CacheFileItemModel>().totalVoiceFile})' : ''}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text('Voice files from cache',
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
        child: _loadCacheVoiceFileList(context),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            print('Delete All files !');
            var fList = context.read<CacheFileItemModel>().voiceItems;
            //print(fList.toString());
            var _fn = _deleteAllFilesFromCache(fList);
            var _msg = 'Are you sure to remove: \n ** All files';
            kDAlert(context, _getAlertDialog(context, _msg, _fn));
          },
          child: const Text('Delete All',
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
        SizedBox(
          width: 35.0,
        ),
        ElevatedButton(
          onPressed: () {
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
      backgroundColor: Colors.indigo.shade50,
    );
  }
}

class _VoiceFilesFromCacheWrapper extends StatelessWidget {
  final String classId;
  final String className;
  final Function(String) onSuccessfulUpload;
  final Function getMaxVoiceCount;
  _VoiceFilesFromCacheWrapper(
      {Key key,
      @required this.classId,
      @required this.className,
      @required this.onSuccessfulUpload,
      @required this.getMaxVoiceCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CacheFileItemModel(),
      child: _VoiceFilesFromCache(
          classId: classId,
          className: className,
          onSuccessfulUpload: onSuccessfulUpload,
          getMaxVoiceCount: getMaxVoiceCount),
    );
  }
}

String _getFileNameFromPath(String fullPath) {
  var opera1 = fullPath.split('/').last;
  return opera1;
}

String _getClassFileName(String classId, String mse) {
  var title = '${classId}_subject';
  int _mse = int.tryParse(mse);
  if (_mse != null) {
    var dt = DateTime.fromMillisecondsSinceEpoch(_mse);
    var dtStr = '_${dt.day}_${dt.month}_${dt.year}';
    title = title + dtStr;
  }
  return title;
}

String _getStringDateFromMse(String mse) {
  var title = '';
  int _mse = int.tryParse(mse);
  if (_mse != null) {
    var dt = DateTime.fromMillisecondsSinceEpoch(_mse);
    var dtStr = '${dt.day}/${dt.month}/${dt.year}';
    title = dtStr;
  }
  return title;
}

//String _getVoiceFileNameFromDateTime(DateTime dt) {
//  var result = 'Kv_${dt.hour}_${dt.minute}_${dt.second}_${dt.millisecond}.mp4';
//  return result;
//}

class CacheFileItemModel with ChangeNotifier implements ReassembleHandler {
  final List<String> _voiceItems = [];

  List<String> get voiceItems => _voiceItems;

  bool _isWaiting = true;

  bool get isWaiting => _isWaiting;

  bool _isError = false;

  bool get isError => _isError;

  String _errorMsg = '';

  String get errorMsg => _errorMsg;

  CacheFileItemModel() {
    loadFilesFromCacheDirectory();
  }

  static const _platform =
      const MethodChannel('flutter.kgmskid.kgms_admin/firestorage');

  Future<String> _localPath() async {
    try {
      final String result = await _platform.invokeMethod('getExtCacheDir');
      if (result != null && !result.isEmpty) {
        //print('_localPath path --> $result');
        return result;
      }
    } on PlatformException catch (e) {
      print('error in getExtCacheDir channel = ${e.message}');
    }
    return null;
  }

  Future<void> loadFilesFromCacheDirectory() async {
    var path = await _localPath();
    if (path != null) {
      var cacheDir = Directory(path);
      if (cacheDir.existsSync()) {
        await for (var entity
            in cacheDir.list(recursive: false, followLinks: false)) {
          //print(entity.path);
          var fileName = _getFileNameFromPath(entity.path);
          if (extension(fileName) == '.mp4') {
            _voiceItems.add(entity.path);
          }
        }
        _isError = false;
        _isWaiting = false;
        notifyListeners();
      } else {
        print('no exists local path --> $path');
        _isError = true;
        _errorMsg = 'local cache path does not exists !';
        notifyListeners();
      }
    } else {
      print('null local path');
      _isError = true;
      _errorMsg = 'local cache path is null !';
      notifyListeners();
    }
  }

  Future<void> reloadData() {
    _voiceItems.clear();
    _isWaiting = true;
    notifyListeners();
    loadFilesFromCacheDirectory();
  }

  int get totalVoiceFile => _voiceItems.length;

  @override
  void reassemble() {
    print('Did hot-reload from CacheFileItemModel !');
  }
}

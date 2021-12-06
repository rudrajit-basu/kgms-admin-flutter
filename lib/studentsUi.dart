import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'src/kUtil.dart';
import 'src/firestoreService.dart';
import 'src/localDataStoreService.dart';
import 'dart:async';
import 'package:provider/provider.dart'
    show
        ReassembleHandler,
        Provider,
        ChangeNotifierProvider,
        Consumer,
        ChangeNotifierProvider,
        ReadContext,
        WatchContext;
import 'admissionUi.dart' show KgmsAdmission;
import 'accountsUi.dart' show KgmsAccountsWrapper;

bool _isNotDisposed = true;

class KgmsStudentsWarpper extends StatelessWidget {
  final bool isRestoreStudent;
  const KgmsStudentsWarpper({Key key, this.isRestoreStudent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KStudentsModel(isRestoreStudent),
      child: KgmsStudents(isRestoreStudent: isRestoreStudent),
    );
  }
}

class KgmsStudentsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isRestoreStudent;
  KgmsStudentsAppBar({Key key, @required this.isRestoreStudent})
      : preferredSize = Size.fromHeight(kToolbarHeight + 25.0),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    var _currentTotCount = context.watch<KStudentsModel>().totalCount == null
        ? '—'
        : context.watch<KStudentsModel>().totalCount.toString();
    var nextToken = context.watch<KStudentsModel>().nextPageToken;
    var prevToken = context.watch<KStudentsModel>().previousPageToken;
    var isWaiting = context.watch<KStudentsModel>().isWaiting;
    return AppBar(
      title: Text('${isRestoreStudent ? 'Restore' : 'Students'}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 24,
        tooltip: 'back',
        onPressed: () {
          ////print('back');
          Navigator.pop(context);
        },
      ),
      bottom: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            'Class Name - ${context.watch<KStudentsModel>().currentClassName} ,\t Sec - ${context.watch<KStudentsModel>().currentSection}  \t [ $_currentTotCount ]',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
        ),
        preferredSize: preferredSize,
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 11),
          child: IconButton(
            icon: const Icon(Icons.navigate_before),
            iconSize: 32,
            tooltip: 'list previous',
            onPressed: isWaiting || prevToken == null
                ? null
                : () => Provider.of<KStudentsModel>(context, listen: false)
                    .fetchPreviousStudents(),
            //() {
            //  //print('Go Previous !');
            //},
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.navigate_next),
            iconSize: 32,
            tooltip: 'list next',
            onPressed: isWaiting || nextToken == null
                ? null
                : () => Provider.of<KStudentsModel>(context, listen: false)
                    .fetchNextStudents(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 30,
            tooltip: 'more options',
            onPressed: () {
              ////print('show drawer');
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }
}

const List<String> _sectionList = ['All', 'A', 'B', 'C', 'D', 'E', 'F'];

//final TextEditingController _studentNameSearchCtrl = TextEditingController();

class KgmsStudents extends StatelessWidget {
  final bool isRestoreStudent;
  const KgmsStudents({Key key, @required this.isRestoreStudent})
      : super(key: key);

  Widget _kStudentSearchDrawer(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[50],
        ),
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.86,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Search Options',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2.0,
                    //decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
                SizedBox(
                  height: 37.0,
                ),
                Padding(
                  /*Student name start*/
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Student name *',
                      labelStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                    ),
                    onChanged: (String value) async {
                      Provider.of<KStudentsModel>(context, listen: false)
                          .setStdNameValue(value);
                    },
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      letterSpacing: 0.9,
                    ),
                    //initialValue: context.read<KStudentsModel>().stdNameValue,
                    //keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller:
                        context.watch<KStudentsModel>().studentNameSearchCtrl,
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Student name end*/,
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  /*Student class start*/
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Select class *',
                      labelStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    value: context.watch<KStudentsModel>().classIndexValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 10,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                    onChanged: ((newValueIndex) async {
                      Provider.of<KStudentsModel>(context, listen: false)
                          .setClassIndexValue(newValueIndex);
                    }),
                    items: context
                        .watch<KStudentsModel>()
                        .classNameList
                        .map<DropdownMenuItem<int>>(
                            (Map<String, String> value) {
                      return DropdownMenuItem<int>(
                        value: context
                            .watch<KStudentsModel>()
                            .classNameList
                            .indexOf(value),
                        child: Text(
                          value['className'],
                          style: const TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      );
                    }).toList(),
                    onTap: () async {
                      clearKeyBoard(context);
                    },
                  ),
                ) /*Student class end*/,
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  /*Student section start*/
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Section',
                      labelStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    value: context.watch<KStudentsModel>().secIndexValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 10,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                    onChanged: ((newValueIndex) async {
                      Provider.of<KStudentsModel>(context, listen: false)
                          .setSecIndexValue(newValueIndex);
                    }),
                    items:
                        _sectionList.map<DropdownMenuItem<int>>((String value) {
                      return DropdownMenuItem<int>(
                        value: _sectionList.indexOf(value),
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      );
                    }).toList(),
                    onTap: () async {
                      clearKeyBoard(context);
                    },
                  ),
                ) /*Student section end*/,
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        ////print('Go and execute !');
                        Navigator.of(context).pop();
                        Provider.of<KStudentsModel>(context, listen: false)
                            .executeQuery();
                      },
                      child: const Text('Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          )),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        )),
                      ),
                    ),
                    SizedBox(
                      width: 45.0,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        ////print('Reset search !');
                        //Navigator.of(context).pop();
                        //if (_studentNameSearchCtrl.text != null &&
                        //    _studentNameSearchCtrl.text != '')
                        //  _studentNameSearchCtrl.text = '';
                        Provider.of<KStudentsModel>(context, listen: false)
                            .resetSearch();
                      },
                      child: const Text('Reset',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          )),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        )),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        //Provider.of<KStudentsModel>(context, listen: false).resetValue();
                      },
                      child: const Text('Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          )),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KgmsStudentsAppBar(isRestoreStudent: isRestoreStudent),
      body: KgmsStudentsBody(isRestoreStudent: isRestoreStudent),
      endDrawerEnableOpenDragGesture: false,
      //drawerDragStartBehavior: null,
      //drawerEdgeDragWidth: 0.0,
      endDrawer: Theme(
        data: ThemeData(
          primaryColor: Colors.blueAccent,
        ),
        child: _kStudentSearchDrawer(context),
      ),
    );
  }
}

class KStudentsModel with ChangeNotifier implements ReassembleHandler {
  final List<Map<String, String>> _classNameList = [
    {'classId': 'all', 'className': 'All'}
  ];

  List<Map<String, String>> get classNameList => _classNameList;

  int _classIndexValue = 0;
  int get classIndexValue => _classIndexValue;

  int _secIndexValue = 0;
  int get secIndexValue => _secIndexValue;

  String _stdNameValue = '';
  String get stdNameValue => _stdNameValue;

  String get currentSection => _sectionList[_secIndexValue];
  String get currentClassName => _classNameList[_classIndexValue]['className'];

  final List<_KgmsStudentBasicInfoModel> _studentListItem = [];
  List<_KgmsStudentBasicInfoModel> get studentListItem => _studentListItem;

  bool _isWaiting = true;
  bool get isWaiting => _isWaiting;

  bool _isError = false;
  bool get isError => _isError;

  String _errorMsg = '';
  String get errorMsg => _errorMsg;

  int _totalCount = null;
  int get totalCount => _totalCount;

  String _nextPageToken = null;
  String get nextPageToken => _nextPageToken;

  String _previousPageToken = null;
  String get previousPageToken => _previousPageToken;

  final List<String> _tokenList = [];
  int _currentTokenPos = 0;

  int _widgetIndex = 1;
  int get widgetIndex => _widgetIndex;

  String _lastTokenUsed = null;

  bool _isRestoreStudent = false;

  KStudentsModel(bool isRestoreStudent) {
    _isRestoreStudent = isRestoreStudent;
    _isNotDisposed = true;
    _fetchStudents();
    Future.delayed(const Duration(milliseconds: 400), () {
      firestoreServ.getClassesAndIds().then((result) {
        _classNameList.addAll(result);
        notifyListeners();
      });
    });
  }

  void executeQuery() {
    ////print('exec query !');
    ////print('std name --> $_stdNameValue');
    ////print('class id --> ${_classNameList[_classIndexValue]['classId']}');
    ////print('sec --> ${_sectionList[_secIndexValue]}');
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentListItem.clear();
    _totalCount = null;
    _nextPageToken = null;
    _previousPageToken = null;
    _currentTokenPos = 0;
    _tokenList.clear();
    _widgetIndex = 1;
    notifyListeners();
    _fetchStudents();
  }

  void fetchNextStudents() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _widgetIndex += _studentListItem.length;
    _studentListItem.clear();
    notifyListeners();
    _fetchStudents(isNext: true, token: _nextPageToken);
  }

  void fetchPreviousStudents() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    //_widgetIndex -= _studentListItem.length - 1;
    _studentListItem.clear();
    notifyListeners();
    _fetchStudents(isPrev: true, token: _previousPageToken);
  }

  void reloadCurrentStudents() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentListItem.clear();
    notifyListeners();
    _fetchStudents(token: _lastTokenUsed, isReload: true);
  }

  void _fetchStudents(
      {String token = null,
      bool isNext = false,
      bool isPrev = false,
      bool isReload = false}) {
    _lastTokenUsed = token;
    Map queryMap = {
      'classId': _classNameList[_classIndexValue]['classId'] == 'all'
          ? ''
          : _classNameList[_classIndexValue]['classId'],
      'section': _sectionList[_secIndexValue] == 'All'
          ? ''
          : _sectionList[_secIndexValue],
      'limit': 10,
      'last': token == null ? '' : token,
      'name': _stdNameValue,
      'isActive': !_isRestoreStudent,
    };
    var queryStr = convert.jsonEncode(queryMap);
    //print('query str --> $queryStr');
    dataStoreServ.getStudentList(queryStr).then((result) {
      ////print('getKgmsStudents data = $result');
      if (_isNotDisposed) {
        try {
          var _jsonObj = convert.jsonDecode(result);
          if (_jsonObj != null) {
            var _jsonArr = _jsonObj['items'] as List;
            final List<_KgmsStudentBasicInfoModel> _dataList = _jsonArr
                .map((jsonTag) => _KgmsStudentBasicInfoModel.fromJson(jsonTag))
                .toList();
            _studentListItem.addAll(_dataList);
            if (!isReload) {
              var lastKey = _jsonObj['last'] as String;
              if (lastKey != null && !_tokenList.contains(lastKey))
                _tokenList.add(lastKey);
              if (!isNext && !isPrev) {
                if (_tokenList.length > _currentTokenPos) {
                  _nextPageToken = _tokenList[_currentTokenPos];
                  _previousPageToken = null;
                  //print('(default) current pos --> $_currentTokenPos');
                }
                _totalCount = _jsonObj['totalCount'] as int;
              }
              if (isNext) {
                _currentTokenPos++;
                var tokenLen = _tokenList.length;
                if (tokenLen == _currentTokenPos)
                  _nextPageToken = null;
                else if (tokenLen > _currentTokenPos)
                  _nextPageToken = _tokenList[_currentTokenPos];
                if (_currentTokenPos == 1)
                  _previousPageToken = '';
                else if (_currentTokenPos > 1)
                  _previousPageToken = _tokenList[_currentTokenPos - 2];
                //print('(next) current pos --> $_currentTokenPos');
                //print('student list --> $_tokenList');
              }
              if (isPrev) {
                _currentTokenPos--;
                if (_currentTokenPos < 1)
                  _previousPageToken = null;
                else if (_currentTokenPos == 1)
                  _previousPageToken = '';
                else if (_currentTokenPos > 1)
                  _previousPageToken = _tokenList[_currentTokenPos - 2];
                _nextPageToken = _tokenList[_currentTokenPos];
                //print('(prev) current pos --> $_currentTokenPos');
                //print('student list --> $_tokenList');
                _widgetIndex -= _studentListItem.length;
              }
            }
          }
        } on FormatException catch (e) {
          //print('getKgmsStudents data = $result and error = $e');
          _errorMsg = '$result';
          _isError = true;
        }
        _isWaiting = false;
        notifyListeners();
      }
    });
  }

  final TextEditingController studentNameSearchCtrl = TextEditingController();

  void setStdNameValue(String name) {
    _stdNameValue = name;
  }

  void setClassIndexValue(int val) {
    if (_classIndexValue != val) {
      _classIndexValue = val;
      //notifyListeners();
    }
  }

  void setSecIndexValue(int val) {
    if (_secIndexValue != val) {
      _secIndexValue = val;
      //notifyListeners();
    }
  }

  void resetSearch() {
    var isChannge = false;
    if (_classIndexValue != 0) {
      _classIndexValue = 0;
      isChannge = true;
    }
    if (_secIndexValue != 0) {
      _secIndexValue = 0;
      isChannge = true;
    }
    if (_stdNameValue != '') {
      _stdNameValue = '';
      studentNameSearchCtrl.text = '';
      isChannge = true;
    }
    if (isChannge) notifyListeners();
  }

  @override
  void reassemble() {
    ////print('Did hot-reload from KStudentsModel !');
  }

  @override
  void dispose() {
    _isNotDisposed = false;
    studentNameSearchCtrl.dispose();
    ////print('disposing KStudentsModel !');
  }
}

class _KgmsStudentBasicInfoModel {
  final String studentId;
  final String studentName;
  final String className;
  final String classId;
  final String section;
  final String rollNo;
  final String doa;
  //final String paid;
  final String stdLoginId;
  final String password;

  _KgmsStudentBasicInfoModel(
      this.studentId,
      this.studentName,
      this.className,
      this.classId,
      this.section,
      this.rollNo,
      this.doa,
      //this.paid,
      this.stdLoginId,
      this.password);

  factory _KgmsStudentBasicInfoModel.fromJson(dynamic json) {
    return _KgmsStudentBasicInfoModel(
        json['key'] as String,
        json['name'] as String,
        json['className'] as String,
        json['classId'] as String,
        json['section'] as String,
        (json['rollNo'] as int).toString(),
        json['doa'] as String,
        //json['paid'] as String,
        json['stdLoginId'] as String,
        json['password'] as String);
  }

  //String get studentId => _studentId;
  //String get studentName => _studentName;
  //String get className => _className;
  //String get section => _section;
  //String get rollNo => _rollNo;
  //String get doa => _doa;
  //String get paid => _paid;
  //String get stdLoginId => _stdLoginId;
  //String get password => _password;

  Map get studentInfo => {
        "stdName": studentName,
        "class": className,
        "classId": classId,
        "section": section,
        "rollNo": rollNo,
        "doa": doa,
        "studentInfoKey": studentId,
      };
}

class KgmsStudentsBody extends StatelessWidget {
  final bool isRestoreStudent;
  const KgmsStudentsBody({Key key, @required this.isRestoreStudent})
      : super(key: key);

  Card _loadingTile(String msg) => Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Text(
            msg,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: const CircleAvatar(
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

  Widget _unlistedStudentListWidget(BuildContext context) =>
      Consumer<KStudentsModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.studentListItem == null) {
            return _loadingTile('snapshot studentListItem null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _loadingTile(snapshot.errorMsg);
                  } else {
                    if (snapshot.studentListItem.isEmpty) {
                      return _loadingTile('No Students Found !');
                    } else {
                      var itemLen = snapshot.studentListItem.length;
                      var widLen = snapshot.widgetIndex;
                      return ListView.separated(
                          shrinkWrap: true,
                          itemCount: itemLen,
                          separatorBuilder: (context, index) => const Divider(
                                height: 4.2,
                              ),
                          cacheExtent: itemLen * 500.0,
                          itemBuilder: (context, index) => _studentTile(context,
                              snapshot.studentListItem[index], index, widLen));
                    }
                  }
                }
            }
          }
        }
      });

  void _kClassNavigation(BuildContext context, Widget newStateWidget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => newStateWidget,
      ),
    );
    if (result != null) {
      if (result == 'Update successfully..!!')
        Provider.of<KStudentsModel>(context, listen: false)
            .reloadCurrentStudents();
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  AlertDialog _modifyStudentStatusAlertW(BuildContext context, String keyId,
          String stdName, String className, String sec) =>
      AlertDialog(
        title: Text(
            'Are you sure to ${isRestoreStudent ? 'restore' : 'delete'} ?\nname - $stdName\nclass name - $className\nsec - $sec'),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        titleTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 17,
            letterSpacing: 0.5,
            height: 1.8),
        elevation: 15,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            iconSize: 27,
            onPressed: () async {
              //////print('delete acc key id ---> $keyId');
              //Navigator.pop(context);
              bool _internet = await isInternetAvailable();
              if (_internet) {
                final KCircularProgress cp = KCircularProgress(ctx: context);
                cp.showCircularProgress();
                var body = {'keyId': keyId, 'isActive': isRestoreStudent};
                var bodyStr = convert.jsonEncode(body);
                ////print('delete bodyStr --> $bodyStr');
                var res =
                    await dataStoreServ.updateStudentBasicStatusInfo(bodyStr);
                if (res) {
                  Provider.of<KStudentsModel>(context, listen: false)
                      .executeQuery();
                  ScaffoldMessenger.of(context).showSnackBar(kSnackbar(
                      '${isRestoreStudent ? 'Restore' : 'Delete'} successfully !'));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(kSnackbar(
                      '${isRestoreStudent ? 'Restore' : 'Delete'} unsuccessful !'));
                }
                cp.closeProgress();
              } else {
                kAlert(context, noInternetWidget);
              }
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            iconSize: 27,
            onPressed: () {
              // ////print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  Card _studentTile(BuildContext context, _KgmsStudentBasicInfoModel info,
          int index, int indexC) =>
      Card(
        color: Colors.orange[300],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: Text(
                  info.studentName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: CircleAvatar(
                  child: Text(
                    (index + indexC).toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 7.0),
                  child: Text(
                    'Class - ${info.className}, Sec - ${info.section}, Roll no. - ${info.rollNo}\nd.o.a - ${info.doa}',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        height: 1.5),
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
                      child: const Text('Details'),
                      onPressed: () async {
                        //////print('student details for id --> ${info.studentId}');
                        animatedCustomNonDismissibleAlert(
                            context,
                            _KgmsStudentDetails(
                                studentId: info.studentId,
                                stdName: info.studentName,
                                stdLoginId: info.stdLoginId,
                                stdLoginPassword: info.password,
                                getStudentInfo: () => info.studentInfo,
                                onEdit: (Map data) async {
                                  //print('onEdit data --> $data');
                                  _kClassNavigation(context,
                                      KgmsAdmission(studentEditData: data));
                                },
                                isRestoreStudent: isRestoreStudent));
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.465)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                    Spacer(),
                    Visibility(
                      visible: !isRestoreStudent,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: TextButton(
                        child: const Text('Accounts'),
                        onPressed: () {
                          //print('student accounts -->');
                          _kClassNavigation(
                              context,
                              KgmsAccountsWrapper(
                                  studentId: info.studentId,
                                  stdName: info.studentName,
                                  className: info.className,
                                  classId: info.classId,
                                  sec: info.section));
                          //cacheServ.getClassImgUrlCache('nursery').then((res)=>//print('nursery res --> $res'));
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.black.withOpacity(0.46)),
                          textStyle:
                              MaterialStateProperty.all<TextStyle>(TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                        ),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      child: Text('${isRestoreStudent ? 'Restore' : 'Delete'}'),
                      onPressed: () async {
                        animatedCustomNonDismissibleAlert(
                            context,
                            _modifyStudentStatusAlertW(
                                context,
                                info.studentId,
                                info.studentName,
                                info.className,
                                info.section));
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.46)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
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
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _unlistedStudentListWidget(context);
  }
}

class _KgmsStudentDetails extends StatefulWidget {
  final String studentId;
  final String stdName;
  final String stdLoginId;
  final String stdLoginPassword;
  final Function getStudentInfo;
  final Function(Map) onEdit;
  final bool isRestoreStudent;
  const _KgmsStudentDetails(
      {Key key,
      @required this.studentId,
      @required this.stdName,
      @required this.stdLoginId,
      @required this.stdLoginPassword,
      @required this.getStudentInfo,
      @required this.onEdit,
      @required this.isRestoreStudent})
      : super(key: key);

  @override
  _KgmsStudentDetailsState createState() => _KgmsStudentDetailsState();
}

class _KgmsStudentDetailsState extends State<_KgmsStudentDetails> {
  //final List<_DemoStudentDetails> demoData;
  final StreamController<List<Map<String, String>>> _controller =
      StreamController<List<Map<String, String>>>();

  var _studentMoreInfo = null;

  @override
  void initState() {
    super.initState();
    _controller.onListen = _startFetchStdMoreInfo;
  }

  @override
  void dispose() {
    if (_controller != null) _controller.close();
    super.dispose();
  }

  Widget _lableDataWidget(String label, String data) => ListTile(
        title: Text('$label',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 15,
              letterSpacing: 0.7,
            )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(data.isEmpty ? 'nil' : '$data',
              style: const TextStyle(
                //fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 15,
                letterSpacing: 0.25,
              )),
        ),
      );

  void _startFetchStdMoreInfo() {
    var reqData = {
      'stdId': widget.studentId,
    };
    var reqDataStr = convert.jsonEncode(reqData);
    dataStoreServ.getStudentMoreInfo(reqDataStr).then((resp) {
      if (mounted) {
        try {
          var jsonObj = convert.jsonDecode(resp);
          var jsonArr = jsonObj['items'] as List;
          if (jsonArr.length > 0) {
            var dataObj = _KgmsStudentMoreInfoModel.fromJson(
                jsonArr[0], widget.stdLoginId, widget.stdLoginPassword);
            _controller.add(dataObj.studentMoreInfoList);
            setState(() {
              _studentMoreInfo = dataObj.studentMoreInfo;
            });
          } else
            _controller.add([
              {'No info exists': ''}
            ]);
        } on FormatException catch (e) {
          _controller.add([
            {'Error': resp}
          ]);
        }
      }
    });
  }

  StreamBuilder _studentMoreInfoWidget(BuildContext context) => StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return _lableDataWidget('Please wait !', 'Loading....');
          default:
            {
              return ListView.separated(
                  itemCount: snapshot.data.length,
                  separatorBuilder: (context, index) => const Divider(
                        height: 4.2,
                      ),
                  itemBuilder: (context, index) => _lableDataWidget(
                      snapshot.data[index].keys.first,
                      snapshot.data[index].values.first));
            }
        }
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Details about :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(widget.stdName,
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
        child: _studentMoreInfoWidget(context),
      ),
      actions: <Widget>[
        Visibility(
          visible: _studentMoreInfo != null && !widget.isRestoreStudent,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: ElevatedButton(
              onPressed: () {
                ////print('edit student !');
                ////print('edit std info ---> ${widget.getStudentInfo()}');
                ////print('edit std more info ---> $_studentMoreInfo');
                Map data = {...widget.getStudentInfo(), ..._studentMoreInfo};
                ////print('data ---> $data');
                Navigator.of(context).pop();
                widget.onEdit(data);
              },
              child: const Text('Edit',
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

//class _DemoStudentDetails {
//  final String _lable;
//  final String _data;

//  _DemoStudentDetails(this._lable, this._data);

//  String get label => _lable;
//  String get data => _data;
//}

class _KgmsStudentMoreInfoModel {
  final String studentMoreId;
  final String dob;
  final String medium;
  final String secondLang;
  final String fatherName;
  final String motherName;
  final String lgName;
  final String contact1;
  final String contact2;
  final String emailId;
  final String address1;
  final String address2;
  final String stdLoginId;
  final String password;

  _KgmsStudentMoreInfoModel(
      this.studentMoreId,
      this.dob,
      this.medium,
      this.secondLang,
      this.fatherName,
      this.motherName,
      this.lgName,
      this.contact1,
      this.contact2,
      this.emailId,
      this.address1,
      this.address2,
      this.stdLoginId,
      this.password);

  factory _KgmsStudentMoreInfoModel.fromJson(
      dynamic json, String loginId, String passwd) {
    return _KgmsStudentMoreInfoModel(
        json['key'] as String,
        json['dob'] as String,
        json['medium'] as String,
        json['secondLang'] as String,
        json['fatherName'] as String,
        json['motherName'] as String,
        json['lgName'] as String,
        json['contact1'] as String,
        json['contact2'] as String,
        json['emailId'] as String,
        json['address1'] as String,
        json['address2'] as String,
        loginId,
        passwd);
  }

  List<Map<String, String>> get studentMoreInfoList => [
        {'d.o.b': dob},
        {'Medium': medium},
        {'2nd language': secondLang},
        {'Father name': fatherName},
        {'Mother name': motherName},
        {'Local guardian': lgName},
        {'Contact 1': contact1},
        {'Contact 2': contact2},
        {'Email id': emailId},
        {'Address 1': address1},
        {'Address 2': address2},
        {'Login id': stdLoginId},
        {'Login password': password}
      ];

  Map get studentMoreInfo => {
        "medium": medium,
        "2ndLang": secondLang,
        "dob": dob,
        "fatherName": fatherName,
        "motherName": motherName,
        "lgName": lgName,
        "contact1": contact1,
        "contact2": contact2,
        "emailId": emailId,
        "address1": address1,
        "address2": address2,
        'stdLoginId': stdLoginId,
        'stdLoginpassword': password,
        'studentMoreInfoKey': studentMoreId,
      };
}

//Route _createRoute(Widget wig) {
//  return PageRouteBuilder(
//    pageBuilder: (context, animation, secondaryAnimation) => wig,
//    transitionsBuilder: (context, animation, secondaryAnimation, child) {
//      var begin = Offset(0.0, 1.0);
//      var end = Offset.zero;
//      var curve = Curves.ease;
//      // var curve = Curves.easeInOutSine;

//      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

//      return SlideTransition(
//        position: animation.drive(tween),
//        child: child,
//      );
//    },
//  );
//}

//class ClassPlaylistModel {
//  final String id;
//  final String title;

//  ClassPlaylistModel(this.id, this.title);

//  factory ClassPlaylistModel.fromJson(dynamic json) {
//    return ClassPlaylistModel(json['id'] as String, json['title'] as String);
//  }

//  //Map<String, dynamic> toMap() {
//  //  return {'id': id, 'title': title};
//  //}

//  @override
//  String toString() {
//    return '{${this.id}, ${this.title}}';
//  }
//}

//final Map<String, bool> _classListData = {
//  'Dolna Ghar': false,
//  'O Group': false,
//  'Nursery': false,
//  'Kg': false,
//  'One': false,
//  'Two': false,
//  'Three': false,
//  'Four': false,
//};

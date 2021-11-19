import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'src/kUtil.dart';
//import 'src/firestoreService.dart';
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
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show DatePickerTheme, DatePicker, LocaleType;

bool _isNotDisposed = true;
bool _isNotDisposed1 = true;

class KgmsAccountsWrapper extends StatelessWidget {
  final String studentId;
  final String stdName;
  final String className;
  final String classId;
  final String sec;
  const KgmsAccountsWrapper(
      {Key key,
      @required this.studentId,
      @required this.stdName,
      @required this.className,
      @required this.classId,
      @required this.sec})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _KAccountsModel(studentId),
      child: KgmsAccounts(
          studentId: studentId,
          stdName: stdName,
          className: className,
          classId: classId,
          sec: sec),
    );
  }
}

class _KgmsAccountsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String stdName;
  final String className;
  _KgmsAccountsAppBar(
      {Key key, @required this.stdName, @required this.className})
      : preferredSize = Size.fromHeight(kToolbarHeight + 25.0),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    var _currentTotCount = context.watch<_KAccountsModel>().totalCount == null
        ? '—'
        : context.watch<_KAccountsModel>().totalCount.toString();
    var nextToken = context.watch<_KAccountsModel>().nextPageToken;
    var prevToken = context.watch<_KAccountsModel>().previousPageToken;
    var isWaiting = context.watch<_KAccountsModel>().isWaiting;
    var searchDate = context.watch<_KAccountsModel>().currentDateStr == ''
        ? ''
        : 'on ${context.watch<_KAccountsModel>().currentDateStr}';
    return AppBar(
      title: const Text('Accounts'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 24,
        tooltip: 'back',
        onPressed: () {
          //print('back');
          Navigator.pop(context);
        },
      ),
      bottom: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            '$stdName  ($className)  [$_currentTotCount]  $searchDate',
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
                : () => Provider.of<_KAccountsModel>(context, listen: false)
                    .fetchPreviousStudentAccount(),
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
                : () => Provider.of<_KAccountsModel>(context, listen: false)
                    .fetchNextStudentAccount(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 30,
            tooltip: 'more options',
            onPressed: () {
              //print('show drawer');
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }
}

class KgmsAccounts extends StatelessWidget {
  final String studentId;
  final String stdName;
  final String className;
  final String classId;
  final String sec;
  const KgmsAccounts(
      {Key key,
      @required this.studentId,
      @required this.stdName,
      @required this.className,
      @required this.classId,
      @required this.sec})
      : super(key: key);

  Widget _collectionWidg(BuildContext context) => Center(
        child: SingleChildScrollView(
            child: _AccountCollection(
                studentId: studentId,
                stdName: stdName,
                className: className,
                classId: classId,
                sec: sec,
                onSuccessfulUpload: () async {
                  Provider.of<_KAccountsModel>(context, listen: false)
                      .reloadCurrentStudentAccount();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(kSnackbar('Upload successfully !'));
                })),
      );

  Widget _kStudentAccountSearchDrawer(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[50],
        ),
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.50,
        //height: 300.0,
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.28,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          print('get date !');
                          DatePicker.showPicker(
                            context,
                            showTitleActions: true,
                            pickerModel: CustomYearAndMonthPicker(),
                            theme: const DatePickerTheme(
                                headerColor: Colors.yellow,
                                backgroundColor: Colors.lightBlue,
                                itemStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                doneStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17),
                                cancelStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17)),
                            onConfirm: (date) async {
                              //print('confirm $date');
                              //var dayStr = date.day < 10
                              //? '0${date.day.toString()}'
                              //: date.day.toString();
                              var monthStr = date.month < 10
                                  ? '0${date.month.toString()}'
                                  : date.month.toString();
                              var dateStr =
                                  '${monthStr}/${date.year.toString()}';
                              //print('date selected --> $dateStr');
                              Provider.of<_KAccountsModel>(context,
                                      listen: false)
                                  .setDateStr(dateStr);
                            },
                          );
                          //DatePicker.showDatePicker(context,
                          //    showTitleActions: true,
                          //    minTime: DateTime(2005, 1, 1),
                          //    maxTime: DateTime(2035, 12, 31),
                          //    theme: const DatePickerTheme(
                          //        headerColor: Colors.yellow,
                          //        backgroundColor: Colors.lightBlue,
                          //        itemStyle: TextStyle(
                          //            color: Colors.white,
                          //            fontWeight: FontWeight.bold,
                          //            fontSize: 18),
                          //        doneStyle: TextStyle(
                          //            color: Colors.black87,
                          //            fontWeight: FontWeight.w500,
                          //            fontSize: 17),
                          //        cancelStyle: TextStyle(
                          //            color: Colors.black87,
                          //            fontWeight: FontWeight.w500,
                          //            fontSize: 17)), onConfirm: (date) async {
                          //  //print('confirm $date');
                          //  var dayStr = date.day < 10
                          //      ? '0${date.day.toString()}'
                          //      : date.day.toString();
                          //  var monthStr = date.month < 10
                          //      ? '0${date.month.toString()}'
                          //      : date.month.toString();
                          //  var dateStr =
                          //      '${dayStr}/${monthStr}/${date.year.toString()}';
                          //  //print('date selected --> $dateStr');
                          //  Provider.of<_KAccountsModel>(context, listen: false)
                          //      .setDateStr(dateStr);
                          //},
                          //    currentTime: DateTime.now(),
                          //    locale: LocaleType.en);
                        },
                        label: const Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            letterSpacing: 0.9,
                          ),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 7.3),
                          child: Icon(Icons.date_range_outlined, size: 22),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.lightBlue),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black87),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            //side: BorderSide(
                            //    color: _isDateValid
                            //        ? Colors.red
                            //        : Colors.transparent),
                          )),
                        ),
                      ),
                    ),
                    //Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: Text(
                        '\t\t=    ${context.watch<_KAccountsModel>().dateStr.isEmpty ? 'mm / yyyy' : context.watch<_KAccountsModel>().dateStr}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          letterSpacing: 1.2,
                        ),
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
                      onPressed: () async {
                        //print('Go and execute !');
                        Navigator.of(context).pop();
                        Provider.of<_KAccountsModel>(context, listen: false)
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
                      onPressed: () {
                        Provider.of<_KAccountsModel>(context, listen: false)
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
                  height: 30.0,
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
      appBar: _KgmsAccountsAppBar(stdName: stdName, className: className),
      body: _KgmsAccountsBody(stdName: stdName),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Theme(
        data: ThemeData(
          primaryColor: Colors.blueAccent,
        ),
        child: _kStudentAccountSearchDrawer(context),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 55.0,
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline_outlined),
                    iconSize: 30,
                    tooltip: 'add collection',
                    onPressed: () async {
                      //var widg = SingleChildScrollView(child: _AccountCollection());
                      animatedCustomNonDismissibleAlert(
                          context, _collectionWidg(context));
                    },
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: IconButton(
                    icon: const Icon(Icons.restore_outlined),
                    iconSize: 30,
                    tooltip: 'restore transaction',
                    onPressed: () {
                      print('restore transaction');
                      animatedCustomNonDismissibleAlert(
                          context,
                          _AccountRestoreTransactionWrapper(
                              studentId: studentId,
                              stdName: stdName,
                              onSuccessfulRestore: () async {
                                Provider.of<_KAccountsModel>(context,
                                        listen: false)
                                    .reloadCurrentStudentAccount();
                                //ScaffoldMessenger.of(context)
                                //    .showSnackBar(kSnackbar('Upload successfully !'));
                              }));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KAccountsModel with ChangeNotifier implements ReassembleHandler {
  String _dateStr = '';

  String get dateStr => _dateStr;

  int _dtDay = 0;
  int _dtMonth = 0;
  int _dtYear = 0;

  String _studentId = '';

  final List<_KgmsStudentAccountInfoModel> _studentAccListItem = [];
  List<_KgmsStudentAccountInfoModel> get studentAccListItem =>
      _studentAccListItem;

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

  //String _lastTokenUsed = null;
  String currentDateStr = '';

  _KAccountsModel(String studentId) {
    _isNotDisposed = true;
    _studentId = studentId;
    _fetchStudentAccount();
  }

  void executeQuery() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentAccListItem.clear();
    _totalCount = null;
    _nextPageToken = null;
    _previousPageToken = null;
    _currentTokenPos = 0;
    _tokenList.clear();
    _widgetIndex = 1;
    notifyListeners();
    _fetchStudentAccount();
  }

  void fetchNextStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _widgetIndex += _studentAccListItem.length;
    _studentAccListItem.clear();
    notifyListeners();
    _fetchStudentAccount(isNext: true, token: _nextPageToken);
  }

  void fetchPreviousStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentAccListItem.clear();
    notifyListeners();
    _fetchStudentAccount(isPrev: true, token: _previousPageToken);
  }

  void reloadCurrentStudentAccount() {
    //_isWaiting = true;
    //_errorMsg = '';
    //_isError = false;
    //_studentAccListItem.clear();
    //notifyListeners();
    //_fetchStudentAccount(token: _lastTokenUsed, isReload: true);
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentAccListItem.clear();
    _totalCount = null;
    _nextPageToken = null;
    _previousPageToken = null;
    _currentTokenPos = 0;
    _tokenList.clear();
    _widgetIndex = 1;
    _dtDay = 0;
    _dtMonth = 0;
    _dtYear = 0;
    notifyListeners();
    _fetchStudentAccount();
  }

  void _fetchStudentAccount(
      {String token = null,
      bool isNext = false,
      bool isPrev = false,
      bool isReload = false}) {
    //_lastTokenUsed = token;
    Map queryMap = {
      'studentId': _studentId,
      'installmentId': '',
      'isActive': true,
      'limit': 3,
      'last': token == null ? '' : token,
      'dtDay': _dtDay,
      'dtMonth': _dtMonth,
      'dtYear': _dtYear,
    };
    var queryStr = convert.jsonEncode(queryMap);
    print('query str --> $queryStr');
    dataStoreServ.getStudentAccountInfo(queryStr).then((result) {
      if (_isNotDisposed) {
        try {
          var _jsonObj = convert.jsonDecode(result);
          var _jsonArr = _jsonObj['items'] as List;
          final List<_KgmsStudentAccountInfoModel> _dataList = _jsonArr
              .map((jsonTag) => _KgmsStudentAccountInfoModel.fromJson(jsonTag))
              .toList();
          _studentAccListItem.addAll(_dataList);
          if (!isReload) {
            var lastKey = _jsonObj['last'] as String;
            if (lastKey != null && !_tokenList.contains(lastKey))
              _tokenList.add(lastKey);
            if (!isNext && !isPrev) {
              if (_tokenList.length > _currentTokenPos) {
                _nextPageToken = _tokenList[_currentTokenPos];
                _previousPageToken = null;
                print('(default) current pos --> $_currentTokenPos');
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
              print('(next) current pos --> $_currentTokenPos');
              print('student list --> $_tokenList');
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
              print('(prev) current pos --> $_currentTokenPos');
              print('student list --> $_tokenList');
              _widgetIndex -= _studentAccListItem.length;
            }
          }
        } on FormatException catch (e) {
          print('getKgmsStudents data = $result and error = $e');
          _errorMsg = '$result';
          _isError = true;
        }
        _isWaiting = false;
        notifyListeners();
      }
    });

    currentDateStr = dateStr;
  }

  void setDateStr(String date) {
    _dateStr = date;
    var opera1 = date.split('/');
    _dtMonth = int.tryParse(opera1[0]);
    _dtYear = int.tryParse(opera1[1]);
    notifyListeners();
  }

  void resetSearch() {
    _dateStr = '';
    _dtDay = 0;
    _dtMonth = 0;
    _dtYear = 0;
    notifyListeners();
  }

  @override
  void reassemble() {
    print('Did hot-reload from _KAccountsModel !');
  }

  @override
  void dispose() {
    _isNotDisposed = false;
    print('disposing _KAccountsModel !');
  }
}

class _KgmsAccountsBody extends StatelessWidget {
  final String stdName;
  const _KgmsAccountsBody({Key key, @required this.stdName}) : super(key: key);

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

  AlertDialog _deleteStdAccountAlertW(
          BuildContext context,
          String keyId,
          String dateStr,
          String feeType,
          int amount,
          bool isInstallment,
          bool isMainInstallment,
          bool hasInstallmentId,
          String sessionInfo) =>
      AlertDialog(
        title: Text(
            'Are you sure to delete transaction ?\namount - $amount on $dateStr\nfee type - $feeType\n$sessionInfo\n${isInstallment ? '[installment]' : ''}'),
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
              bool _internet = await isInternetAvailable();
              if (_internet) {
                final KCircularProgress cp = KCircularProgress(ctx: context);
                cp.showCircularProgress();
                var body = {
                  'keyId': keyId,
                  'isActive': false,
                  'isMainInstallment': isMainInstallment,
                  'hasInstallmentId': hasInstallmentId,
                };
                var bodyStr = convert.jsonEncode(body);
                print('delete bodyStr --> $bodyStr');
                var res =
                    await dataStoreServ.updateStudentAccountStatusInfo(bodyStr);
                if (res) {
                  Provider.of<_KAccountsModel>(context, listen: false)
                      .reloadCurrentStudentAccount();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(kSnackbar('Delete successfully !'));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(kSnackbar('Delete unsuccessful !'));
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
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  Card _studentAccTile(BuildContext context,
          _KgmsStudentAccountInfoModel accInfo, int index, int indexC) =>
      Card(
        color: Colors.orange[300],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Rs. ${accInfo.amount} \t\ton\t\t ${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}',
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
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(
                    '${accInfo.feeType} \t ${accInfo.sessionInfo} \t ${accInfo.isInstallment ? accInfo.isMainInstallment ? '\n[main installment]' : '\n[installment]' : ''}\nclass - ${accInfo.className} \t sec - ${accInfo.sec}',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        height: 1.8),
                  ),
                ),
                //isThreeLine: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Visibility(
                      visible: accInfo.isContainsInstallment,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: TextButton(
                        child: const Text('Installment'),
                        onPressed: () async {
                          //print(
                          //    'acc take installment id --> ${accInfo.installmentId}');
                          //print(
                          //    'isContainsInstallment --> ${accInfo.isContainsInstallment}');
                          var dateStr =
                              '${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}';
                          animatedCustomNonDismissibleAlert(
                              context,
                              _InstallemtCollection(
                                  keyId: accInfo.keyId,
                                  installmentId: accInfo.installmentId,
                                  feeType: accInfo.feeType,
                                  date: dateStr,
                                  studentId: accInfo.studentId,
                                  stdName: stdName,
                                  className: accInfo.className,
                                  classId: accInfo.classId,
                                  sec: accInfo.sec,
                                  session: accInfo.session,
                                  sessionYear: accInfo.sessionYear,
                                  onSuccessfulUpload: () async {
                                    Provider.of<_KAccountsModel>(context,
                                            listen: false)
                                        .reloadCurrentStudentAccount();
                                    //ScaffoldMessenger.of(context)
                                    //    .showSnackBar(kSnackbar('Upload successfully !'));
                                  }));
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
                    ),
                    //Spacer(),
                    //TextButton(
                    //  child: const Text('Edit'),
                    //  onPressed: () {
                    //    print('acc transaction modify -->');
                    //    //cacheServ.getClassImgUrlCache('nursery').then((res)=>print('nursery res --> $res'));
                    //  },
                    //  style: ButtonStyle(
                    //    foregroundColor: MaterialStateProperty.all<Color>(
                    //        Colors.black.withOpacity(0.46)),
                    //    textStyle:
                    //        MaterialStateProperty.all<TextStyle>(TextStyle(
                    //      fontSize: 16,
                    //      fontWeight: FontWeight.bold,
                    //    )),
                    //  ),
                    //),
                    Spacer(),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        //print('acc transaction delete -->');
                        var dateStr =
                            '${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}';
                        var isMainInstallment = accInfo.isInstallment &&
                            accInfo.installmentId.isEmpty;
                        var hasInstallmentId = !accInfo.installmentId.isEmpty;
                        animatedCustomNonDismissibleAlert(
                            context,
                            _deleteStdAccountAlertW(
                                context,
                                accInfo.keyId,
                                dateStr,
                                accInfo.feeType,
                                accInfo.amount,
                                accInfo.isInstallment,
                                isMainInstallment,
                                hasInstallmentId,
                                accInfo.sessionInfo));
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

  Widget _unlistedStudentAccListWidget(BuildContext context) =>
      Consumer<_KAccountsModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.studentAccListItem == null) {
            return _loadingTile('snapshot studentAccListItem null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _loadingTile(snapshot.errorMsg);
                  } else {
                    if (snapshot.studentAccListItem.isEmpty) {
                      return _loadingTile('No Accounts Found !');
                    } else {
                      var itemLen = snapshot.studentAccListItem.length;
                      var widLen = snapshot.widgetIndex;
                      return ListView.separated(
                          shrinkWrap: true,
                          itemCount: itemLen,
                          separatorBuilder: (context, index) => const Divider(
                                height: 4.2,
                              ),
                          cacheExtent: itemLen * 100.0,
                          itemBuilder: (context, index) => _studentAccTile(
                              context,
                              snapshot.studentAccListItem[index],
                              index,
                              widLen));
                    }
                  }
                }
            }
          }
        }
      });

  @override
  Widget build(BuildContext context) {
    return _unlistedStudentAccListWidget(context);
  }
}

class _AccountCollection extends StatefulWidget {
  final String studentId;
  final String stdName;
  final String className;
  final String classId;
  final String sec;
  final Function onSuccessfulUpload;
  final String installmentId;
  final String feeTypeForInstallment;
  final List<int> session;
  final int sessionYear;
  const _AccountCollection(
      {Key key,
      @required this.studentId,
      @required this.stdName,
      @required this.className,
      @required this.classId,
      @required this.sec,
      @required this.onSuccessfulUpload,
      this.installmentId = null,
      this.feeTypeForInstallment = null,
      this.session = null,
      this.sessionYear = null})
      : super(key: key);

  @override
  _AccountCollectionState createState() => _AccountCollectionState();
}

class _AccountCollectionState extends State<_AccountCollection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _feeCtrl = TextEditingController();

  String collection_date = '';
  bool _isDateValid = false;
  int _feeTypeCtrl = null;
  bool _isInstallment = false;
  bool _showMonthYear = false;
  String collection_session = '';

  final Map<String, int> _feeStruct = {};
  bool _isKgmsSettings = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      dataStoreServ.getFeeStructureFromCache.then((feeStruct) {
        if (mounted) {
          if (feeStruct != null) {
            setState(() {
              _feeStruct.addAll(feeStruct);
              _isKgmsSettings = true;
              if (widget.feeTypeForInstallment != null) {
                for (var feeTypeItem in feeTypeList) {
                  if (feeTypeItem['feeId'] == widget.feeTypeForInstallment) {
                    _feeTypeCtrl = feeTypeList.indexOf(feeTypeItem);
                    break;
                  }
                }
                if (widget.session != null && widget.sessionYear != null) {
                  if (feeTypeList[_feeTypeCtrl]['feeId'] == 'admissionFee') {
                    collection_session = ' of ${widget.session[0]}';
                  } else {
                    collection_session =
                        dataStoreServ.getStringMonthsFromList(widget.session) +
                            ' of ${widget.sessionYear}';
                  }
                }
              }
            });
          } else {
            dataStoreServ.resetFeeStructureFromCache();
            setState(() {
              _isKgmsSettings = false;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _getDate(BuildContext context, DateTime currentDate) =>
      DatePicker.showDatePicker(context,
          showTitleActions: true,
          //minTime: DateTime(2005, 1, 1),
          //maxTime: DateTime(2035, 12, 31),
          theme: const DatePickerTheme(
              headerColor: Colors.yellow,
              backgroundColor: Colors.lightBlue,
              itemStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              doneStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 17),
              cancelStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 17)), onConfirm: (date) async {
        //print('confirm $date');
        var dayStr =
            date.day < 10 ? '0${date.day.toString()}' : date.day.toString();
        var monthStr = date.month < 10
            ? '0${date.month.toString()}'
            : date.month.toString();
        var dateStr = '${dayStr}/${monthStr}/${date.year.toString()}';
        //print('date selected --> $dateStr');
        setState(() {
          collection_date = dateStr;
        });
      }, currentTime: currentDate, locale: LocaleType.en);

  Future<bool> _submitCollection() async {
    var opera1 = collection_date.split('/');
    var amnt = int.tryParse(_feeCtrl.text) ?? 0;
    var isInst = _isInstallment;
    var session = null;
    var sessionYear = null;
    if (widget.installmentId == null) {
      if (feeTypeList[_feeTypeCtrl]['feeId'] == 'tuitionFee') if (amnt <
          _feeStruct['tuitionFee']) isInst = true;
    }
    if (feeTypeList[_feeTypeCtrl]['feeId'] == 'admissionFee') {
      var opera1 = collection_session.split(' of ');
      sessionYear = int.tryParse(opera1[1]) ?? 0;
      var opera2 = [];
      opera2.add(sessionYear);
      session = opera2;
    } else {
      var opera1 = collection_session.split(' of ');
      sessionYear = int.tryParse(opera1[1]) ?? 0;
      var opera2 = opera1[0].split(' , ');
      session = dataStoreServ.getMonthsInList(opera2);
    }
    var collectionBody = {
      'feeType': feeTypeList[_feeTypeCtrl]['feeId'],
      'amount': amnt,
      'isInstallment': isInst,
      'dtDay': int.tryParse(opera1[0]),
      'dtMonth': int.tryParse(opera1[1]),
      'dtYear': int.tryParse(opera1[2]),
      'classId': widget.classId,
      'className': widget.className,
      'sec': widget.sec,
      'installmentId': widget.installmentId == null ? '' : widget.installmentId,
      'isSync': false,
      'isActive': true,
      'studentId': widget.studentId,
      'stdName': widget.stdName,
      'session': session,
      'sessionYear': sessionYear,
    };
    var bodyStr = convert.jsonEncode(collectionBody);
    print('_submitCollection --> $bodyStr');
    var result = await dataStoreServ.uploadStudentAccountInfo(bodyStr);
    return result;
  }

  bool _isValidated() {
    if (!_isKgmsSettings) {
      setState(() {
        _errorMsg = '** Account settings invalid';
      });
      return false;
    } else {
      setState(() {
        _errorMsg = '';
      });
      var isVal = true;
      if (!_formKey.currentState.validate()) isVal = false;
      if (collection_date.isEmpty) {
        setState(() {
          _isDateValid = true;
        });
        isVal = false;
      } else
        setState(() {
          _isDateValid = false;
        });
      if (collection_session.isEmpty) {
        setState(() {
          _showMonthYear = true;
        });
        isVal = false;
      } else
        setState(() {
          _showMonthYear = false;
        });

      return isVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: Text(
              widget.installmentId == null
                  ? 'Add collection'
                  : 'Add installment',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(widget.stdName,
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          trailing: const Icon(
            Icons.account_balance,
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.blueAccent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    /*Collection fee type start*/
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Fee type *',
                        labelStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        errorStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Fee type cannot be empty !';
                        }
                        return null;
                      },
                      value: _feeTypeCtrl,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 10,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                      onChanged: widget.installmentId == null
                          ? ((newValueIndex) async {
                              setState(() {
                                _feeTypeCtrl = newValueIndex;
                                if (feeTypeList[_feeTypeCtrl]['feeId'] ==
                                    'tuitionFee')
                                  _feeCtrl.text =
                                      _feeStruct['tuitionFee'].toString();
                                else
                                  _feeCtrl.text = '';
                                if (!collection_session.isEmpty)
                                  collection_session = '';
                              });
                            })
                          : null,
                      onTap: () async {
                        clearKeyBoard(context);
                      },
                      items: feeTypeList.map<DropdownMenuItem<int>>(
                          (Map<String, String> value) {
                        return DropdownMenuItem<int>(
                          value: feeTypeList.indexOf(value),
                          child: Text(
                            value['feeName'],
                            style: TextStyle(
                              color: Colors.purple,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ) /*Collection fee type end*/,
                  Padding(
                    /*Collection fee date start*/
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  //print('get date !');
                                  clearKeyBoard(context);
                                  var dt = _getDateFromString(collection_date);
                                  _getDate(context, dt);
                                },
                                label: const Text(
                                  'Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                icon: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7.3),
                                  child:
                                      Icon(Icons.date_range_outlined, size: 22),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.lightBlue),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black87),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    side: BorderSide(
                                        color: _isDateValid
                                            ? Colors.red
                                            : Colors.transparent),
                                  )),
                                ),
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.47,
                              child: Text(
                                '=    ${collection_date.isEmpty ? 'none' : collection_date}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _isDateValid,
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.0, top: 6.0),
                              child: Text('Date cannot be empty !',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) /*Collection fee date end*/,
                  Padding(
                    /*Fee month year start*/
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[
                        iconTag('@ For session * (mm & yyyy)  ',
                            Icons.view_module_outlined, 19.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              /*Student roll no. start*/
                              width: MediaQuery.of(context).size.width * 0.36,
                              child: ElevatedButton.icon(
                                onPressed: widget.installmentId == null
                                    ? () async {
                                        //print('get date !');
                                        clearKeyBoard(context);
                                        if (_feeTypeCtrl == null) {
                                          kAlert(
                                              context,
                                              showErrorWidget(
                                                  'Select feeType first !'));
                                        } else {
                                          animatedCustomNonDismissibleAlert(
                                              context,
                                              MultiselectForMonthYear(
                                                  showMonths:
                                                      feeTypeList[_feeTypeCtrl]
                                                              ['feeId'] !=
                                                          'admissionFee',
                                                  //showMonths: true,
                                                  onSelect: (String value) {
                                                    //print('result from ui --> $value');
                                                    setState(() {
                                                      collection_session =
                                                          value;
                                                    });
                                                  }));
                                        }
                                      }
                                    : null,
                                label: const Text(
                                  'Session',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                icon: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7.3),
                                  child: Icon(Icons.view_module_outlined,
                                      size: 22),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.lightBlue),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black87),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    side: BorderSide(
                                        color: _showMonthYear
                                            ? Colors.red
                                            : Colors.transparent),
                                  )),
                                ),
                              ),
                            ),
                            Spacer(),
                            Text('= \t',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 1.2,
                                )),
                            Container(
                              /*Student roll no. start*/
                              width: MediaQuery.of(context).size.width * 0.38,
                              child: Text(
                                '${collection_session.toString().isEmpty ? 'none' : collection_session.toString()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _showMonthYear,
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.0, top: 6.0),
                              child: Text('Session cannot be empty !',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) /*Fee month year end*/,
                  Padding(
                    /*Collection fee start*/
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: TextFormField(
                      controller: _feeCtrl,
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Fee cannot be empty !';
                        else if (!value.isEmpty && !isNumFromString(value))
                          return 'not number !';
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Fee (Rs.) *',
                        labelStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        errorStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        letterSpacing: 0.9,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ], // Only numbers can be entered
                    ),
                  ) /*Collection fee end*/,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    child: CheckboxListTile(
                      title: const Text(
                        'If installment',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.9,
                        ),
                      ),
                      value: _isInstallment,
                      onChanged: (bool value) {
                        setState(() {
                          _isInstallment = value;
                        });
                      },
                      secondary: const Icon(Icons.fact_check),
                      activeColor: Colors.lightBlue[600],
                      dense: true,
                    ),
                  ),
                  Visibility(
                    visible: _errorMsg != '',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      child: Text(
                        _errorMsg,
                        style: const TextStyle(
                          fontSize: 16.4,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          width: double.maxFinite,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  //print('save collection');
                  if (_isValidated()) {
                    bool _internet = await isInternetAvailable();
                    if (_internet) {
                      final KCircularProgress cp =
                          KCircularProgress(ctx: context);
                      cp.showCircularProgress();
                      var res = await _submitCollection();
                      if (res) {
                        cp.closeProgress();
                        Navigator.of(context).pop();
                        widget.onSuccessfulUpload();
                      } else {
                        setState(() {
                          _errorMsg = '** Error while upload';
                        });
                        cp.closeProgress();
                      }
                    } else {
                      kAlert(context, noInternetWidget);
                    }
                  }
                },
                child: const Text('Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
                width: 30.0,
              ),
              ElevatedButton(
                onPressed: () {
                  //clearKeyBoard(context);
                  Navigator.of(context).pop();
                },
                child: const Text('Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
        ),
      ],
      buttonPadding: const EdgeInsets.only(right: 7.0),
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
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

class _InstallemtCollection extends StatefulWidget {
  final String keyId;
  final String installmentId;
  final String feeType;
  final String date;
  final String studentId;
  final String stdName;
  final String className;
  final String classId;
  final String sec;
  final List<int> session;
  final int sessionYear;
  final Function onSuccessfulUpload;
  const _InstallemtCollection(
      {Key key,
      @required this.keyId,
      @required this.installmentId,
      @required this.feeType,
      @required this.date,
      @required this.studentId,
      @required this.stdName,
      @required this.className,
      @required this.classId,
      @required this.sec,
      @required this.session,
      @required this.sessionYear,
      @required this.onSuccessfulUpload})
      : super(key: key);

  @override
  _InstallemtCollectionState createState() => _InstallemtCollectionState();
}

class _InstallemtCollectionState extends State<_InstallemtCollection> {
  final StreamController<List<_KgmsStudentAccountInfoModel>> _controller =
      StreamController<List<_KgmsStudentAccountInfoModel>>();

  bool _isFurtherInstallment = false;
  bool _isError = false;
  bool _isNewCollectionAdded = false;

  @override
  void initState() {
    super.initState();
    _controller.onListen = _fetchStudentAccountInstallmentDetailList;
  }

  Widget _collectionWidg(BuildContext context) => Center(
        child: SingleChildScrollView(
            child: _AccountCollection(
                studentId: widget.studentId,
                stdName: widget.stdName,
                className: widget.className,
                classId: widget.classId,
                sec: widget.sec,
                installmentId: widget.installmentId.isEmpty
                    ? widget.keyId
                    : widget.installmentId,
                feeTypeForInstallment: widget.feeType,
                onSuccessfulUpload: () async {
                  //Provider.of<_KAccountsModel>(context, listen: false)
                  //    .reloadCurrentStudentAccount();
                  //ScaffoldMessenger.of(context)
                  //    .showSnackBar(kSnackbar('Upload successfully !'));
                  if (mounted) {
                    setState(() {
                      _controller.add(null);
                      _isNewCollectionAdded = true;
                    });
                    _fetchStudentAccountInstallmentDetailList();
                  }
                },
                session: widget.session,
                sessionYear: widget.sessionYear)),
      );

  void _fetchStudentAccountInstallmentDetailList() {
    var reqData = {
      'installmentId':
          widget.installmentId.isEmpty ? widget.keyId : widget.installmentId,
      'isActive': true
    };
    var reqDataStr = convert.jsonEncode(reqData);
    Future.delayed(
        const Duration(milliseconds: 1300),
        () => dataStoreServ
                .getStudentAccountInstallmentInfo(reqDataStr)
                .then((resp) {
              if (mounted) {
                try {
                  var _jsonObj = convert.jsonDecode(resp);
                  var _jsonArr = _jsonObj['items'] as List;
                  final List<_KgmsStudentAccountInfoModel> _dataList = _jsonArr
                      .map((jsonTag) =>
                          _KgmsStudentAccountInfoModel.fromJson(jsonTag))
                      .toList();
                  _controller.add(_dataList);
                  setState(() {
                    if (_dataList.first.isInstallment)
                      _isFurtherInstallment = true;
                    else
                      _isFurtherInstallment = false;
                    _isError = false;
                  });
                } on FormatException catch (e) {
                  setState(() {
                    _isError = true;
                    _isFurtherInstallment = false;
                  });
                  print('getStudentAccountInstallmentInfo err --> $e');
                }
              }
            }));
  }

  @override
  void dispose() {
    if (_controller != null) _controller.close();
    super.dispose();
  }

  Card _lableWidget(String msg) => Card(
        //color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              msg,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          leading: CircleAvatar(
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          //subtitle: Padding(
          //  padding: const EdgeInsets.only(top: 5.0),
          //  child: Text(
          //    'admissionFee \t [installment]',
          //    style: const TextStyle(
          //      color: Colors.black87,
          //      fontWeight: FontWeight.w400,
          //    ),
          //  ),
          //),
        ),
      );

  Card _studentAccountDetailsWidget(
          _KgmsStudentAccountInfoModel accInfo, int index) =>
      Card(
        //color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Rs. ${accInfo.amount} \t\ton\t\t ${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
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
            padding: const EdgeInsets.only(top: 5.0, bottom: 4.0),
            child: Text(
              '${accInfo.feeType} \t ${accInfo.isInstallment ? '[installment]' : ''}\nclass - ${accInfo.className} \t sec - ${accInfo.sec}',
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  height: 1.8),
            ),
          ),
        ),
      );

  StreamBuilder _studentAccountsWidget(BuildContext context) => StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return _lableWidget('Loading....');
          default:
            {
              if (snapshot.data == null)
                return _lableWidget('Loading....');
              else if (snapshot.data != null && snapshot.data.length > 0)
                return ListView.separated(
                    itemCount: snapshot.data.length,
                    separatorBuilder: (context, index) => const Divider(
                          height: 4.2,
                        ),
                    itemBuilder: (context, index) =>
                        _studentAccountDetailsWidget(
                            snapshot.data[index], index));
              else
                return _lableWidget('No installment found !');
            }
        }
      });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        if (_isNewCollectionAdded) widget.onSuccessfulUpload();
      },
      child: AlertDialog(
        title: Container(
          child: ListTile(
            title: const Text('Installment details :',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 17,
                )),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                  '${widget.stdName}\n${widget.feeType} on ${widget.date}',
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
          child: _studentAccountsWidget(context),
        ),
        actions: <Widget>[
          Visibility(
            visible: _isError,
            child: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: const Text(
                '** Error found',
                style: TextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _isFurtherInstallment && !_isError,
            child: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: ElevatedButton(
                onPressed: () async {
                  //print('take installment @keyId --> ${widget.keyId}');
                  //print('take installment @instId --> ${widget.installmentId}');
                  animatedCustomNonDismissibleAlert(
                      context, _collectionWidg(context));
                },
                child: const Text('Take installment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_isNewCollectionAdded) widget.onSuccessfulUpload();
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
      ),
    );
  }
}

//const List<Map<String, String>> feeTypeList = [
//  {'feeId': 'tuitionFee', 'feeName': 'Tuition Fee'},
//  {'feeId': 'functionFee', 'feeName': 'Function Fee'},
//  {'feeId': 'medicalFee', 'feeName': 'Medical Fee'},
//  {'feeId': 'stationaryFee', 'feeName': 'Stationary Fee'},
//  {'feeId': 'admissionFee', 'feeName': 'Admission Fee'}
//];

DateTime _getDateFromString(String dt) {
  if (!dt.isEmpty) {
    try {
      var opera = dt.split('/');
      var day = int.tryParse(opera[0]);
      var month = int.tryParse(opera[1]);
      var year = int.tryParse(opera[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    } catch (e) {
      print(e);
    }
  }
  return DateTime.now();
}

class _KgmsStudentAccountInfoModel {
  final String keyId;
  final String feeType;
  final int amount;
  final bool isInstallment;
  final int dtDay;
  final int dtMonth;
  final int dtYear;
  final String classId;
  final String className;
  final String sec;
  final String installmentId;
  final bool isActive;
  final String studentId;
  final bool isContainsInstallment;
  final List<int> session;
  final int sessionYear;
  final String sessionInfo;
  final bool isMainInstallment;

  _KgmsStudentAccountInfoModel(
      this.keyId,
      this.feeType,
      this.amount,
      this.isInstallment,
      this.dtDay,
      this.dtMonth,
      this.dtYear,
      this.classId,
      this.className,
      this.sec,
      this.installmentId,
      this.isActive,
      this.studentId,
      this.session,
      this.sessionYear)
      : isContainsInstallment = isInstallment || installmentId != '',
        sessionInfo =
            dataStoreServ.getSessionString(feeType, sessionYear, session),
        isMainInstallment = isInstallment && installmentId.isEmpty;

  factory _KgmsStudentAccountInfoModel.fromJson(dynamic json) {
    return _KgmsStudentAccountInfoModel(
        json['key'] as String,
        json['feeType'] as String,
        json['amount'] as int,
        json['isInstallment'] as bool,
        json['dtDay'] as int,
        json['dtMonth'] as int,
        json['dtYear'] as int,
        json['classId'] as String,
        json['className'] as String,
        json['sec'] as String,
        json['installmentId'] as String,
        json['isActive'] as bool,
        json['studentId'] as String,
        json['session'].cast<int>(),
        json['sessionYear'] as int);
  }
}

class _AccountRestoreTransactionWrapper extends StatelessWidget {
  final String studentId;
  final String stdName;
  final Function onSuccessfulRestore;
  const _AccountRestoreTransactionWrapper(
      {Key key,
      @required this.studentId,
      @required this.stdName,
      @required this.onSuccessfulRestore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _KAccountsRestoreModel(studentId),
      child: _AccountRestoreTransaction(
          studentId: studentId,
          stdName: stdName,
          onSuccessfulRestore: onSuccessfulRestore),
    );
  }
}

class _KAccountsRestoreModel with ChangeNotifier implements ReassembleHandler {
  String _studentId = '';

  final List<_KgmsStudentAccountInfoModel> _studentAccListItem = [];
  List<_KgmsStudentAccountInfoModel> get studentAccListItem =>
      _studentAccListItem;

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

  _KAccountsRestoreModel(String studentId) {
    _isNotDisposed1 = true;
    _studentId = studentId;
    _fetchStudentAccount();
  }

  void executeQuery() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentAccListItem.clear();
    _totalCount = null;
    _nextPageToken = null;
    _previousPageToken = null;
    _currentTokenPos = 0;
    _tokenList.clear();
    _widgetIndex = 1;
    notifyListeners();
    _fetchStudentAccount();
  }

  void fetchNextStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _widgetIndex += _studentAccListItem.length;
    _studentAccListItem.clear();
    notifyListeners();
    _fetchStudentAccount(isNext: true, token: _nextPageToken);
  }

  void fetchPreviousStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentAccListItem.clear();
    notifyListeners();
    _fetchStudentAccount(isPrev: true, token: _previousPageToken);
  }

  void reloadCurrentStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentAccListItem.clear();
    _totalCount = null;
    _nextPageToken = null;
    _previousPageToken = null;
    _currentTokenPos = 0;
    _tokenList.clear();
    _widgetIndex = 1;
    notifyListeners();
    _fetchStudentAccount();
  }

  void _fetchStudentAccount(
      {String token = null,
      bool isNext = false,
      bool isPrev = false,
      bool isReload = false}) {
    //_lastTokenUsed = token;
    Map queryMap = {
      'studentId': _studentId,
      'installmentId': '',
      'isActive': false,
      'limit': 3,
      'last': token == null ? '' : token,
      'dtDay': 0,
      'dtMonth': 0,
      'dtYear': 0,
    };
    var queryStr = convert.jsonEncode(queryMap);
    print('query str --> $queryStr');
    dataStoreServ.getStudentAccountInfo(queryStr).then((result) {
      if (_isNotDisposed1) {
        try {
          var _jsonObj = convert.jsonDecode(result);
          var _jsonArr = _jsonObj['items'] as List;
          final List<_KgmsStudentAccountInfoModel> _dataList = _jsonArr
              .map((jsonTag) => _KgmsStudentAccountInfoModel.fromJson(jsonTag))
              .toList();
          _studentAccListItem.addAll(_dataList);
          if (!isReload) {
            var lastKey = _jsonObj['last'] as String;
            if (lastKey != null && !_tokenList.contains(lastKey))
              _tokenList.add(lastKey);
            if (!isNext && !isPrev) {
              if (_tokenList.length > _currentTokenPos) {
                _nextPageToken = _tokenList[_currentTokenPos];
                _previousPageToken = null;
                print('(default) current pos --> $_currentTokenPos');
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
              print('(next) current pos --> $_currentTokenPos');
              print('student acc list --> $_tokenList');
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
              print('(prev) current pos --> $_currentTokenPos');
              print('student acc list --> $_tokenList');
              _widgetIndex -= _studentAccListItem.length;
            }
          }
        } on FormatException catch (e) {
          print('getStudentAccountInfo data = $result and error = $e');
          _errorMsg = '$result';
          _isError = true;
        }
        _isWaiting = false;
        notifyListeners();
      }
    });
  }

  bool _isRestore = false;

  bool get isRestore => _isRestore;

  void setIsRestore(bool isRestore) {
    _isRestore = isRestore;
    notifyListeners();
  }

  @override
  void reassemble() {
    print('Did hot-reload from _KAccountsRestoreModel !');
  }

  @override
  void dispose() {
    _isNotDisposed1 = false;
    print('disposing _KAccountsRestoreModel !');
  }
}

class _AccountRestoreTransaction extends StatelessWidget {
  final String studentId;
  final String stdName;
  final Function onSuccessfulRestore;
  const _AccountRestoreTransaction(
      {Key key,
      @required this.studentId,
      @required this.stdName,
      @required this.onSuccessfulRestore})
      : super(key: key);

  AlertDialog _restoreStdAccountAlertW(
          BuildContext context,
          String keyId,
          String dateStr,
          String feeType,
          int amount,
          bool isInstallment,
          bool isMainInstallment,
          bool hasInstallmentId,
          String sessionInfo) =>
      AlertDialog(
        title: Text(
            'Are you sure to restore transaction ?\namount - $amount on $dateStr\nfee type - $feeType\n$sessionInfo\n${isInstallment ? '[installment]' : ''}'),
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
              bool _internet = await isInternetAvailable();
              if (_internet) {
                final KCircularProgress cp = KCircularProgress(ctx: context);
                cp.showCircularProgress();
                var body = {
                  'keyId': keyId,
                  'isActive': true,
                  'isMainInstallment': isMainInstallment,
                  'hasInstallmentId': hasInstallmentId,
                };
                var bodyStr = convert.jsonEncode(body);
                print('restore bodyStr --> $bodyStr');
                var res =
                    await dataStoreServ.updateStudentAccountStatusInfo(bodyStr);
                if (res) {
                  Provider.of<_KAccountsRestoreModel>(context, listen: false)
                      .setIsRestore(true);
                  Provider.of<_KAccountsRestoreModel>(context, listen: false)
                      .reloadCurrentStudentAccount();
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
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  AlertDialog _deleteStdAccountAlertW(
          BuildContext context,
          String keyId,
          String dateStr,
          String feeType,
          int amount,
          bool isInstallment,
          bool isMainInstallment,
          //bool hasInstallmentId,
          String sessionInfo) =>
      AlertDialog(
        title: Text(
            'Are you sure to delete permanently** ?${isMainInstallment ? '\n[may have installments under it]' : ''}\namount - $amount on $dateStr\nfee type - $feeType\nSession - $sessionInfo\n${isInstallment ? '[installment]' : ''}'),
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
              bool _internet = await isInternetAvailable();
              if (_internet) {
                final KCircularProgress cp = KCircularProgress(ctx: context);
                cp.showCircularProgress();
                var body = {
                  'keyId': keyId,
                  //'isActive': true,
                  'isMainInstallment': isMainInstallment,
                  //'hasInstallmentId': hasInstallmentId,
                };
                var bodyStr = convert.jsonEncode(body);
                print('restore bodyStr --> $bodyStr');
                var res = await dataStoreServ.deleteStudentAccountInfo(bodyStr);
                if (res) {
                  //Provider.of<_KAccountsRestoreModel>(context, listen: false)
                  //    .setIsRestore(true);
                  Provider.of<_KAccountsRestoreModel>(context, listen: false)
                      .reloadCurrentStudentAccount();
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
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  Card _lableWidget(String msg) => Card(
        //color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              msg,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          leading: CircleAvatar(
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  Card _studentAccountDetailsWidget(BuildContext context,
          _KgmsStudentAccountInfoModel accInfo, int index, int indexC) =>
      Card(
          //color: Colors.orange[300],
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Rs. ${accInfo.amount} \t\ton\t\t ${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  child: Text(
                    (index + indexC).toString(),
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    '${accInfo.feeType} \t ${accInfo.sessionInfo} \t ${accInfo.isContainsInstallment ? '[installment]' : ''}\nclass - ${accInfo.className} \t sec - ${accInfo.sec}',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        height: 1.8),
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
                      child: const Text('X Delete'),
                      onPressed: () async {
                        //print('Delete student id --> ${accInfo.keyId}');
                        var dateStr =
                            '${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}';
                        var isMainInstallment = accInfo.isInstallment &&
                            accInfo.installmentId.isEmpty;
                        //var hasInstallmentId = !accInfo.installmentId.isEmpty;
                        animatedCustomNonDismissibleAlert(
                            context,
                            _deleteStdAccountAlertW(
                                context,
                                accInfo.keyId,
                                dateStr,
                                accInfo.feeType,
                                accInfo.amount,
                                accInfo.isInstallment,
                                isMainInstallment,
                                //hasInstallmentId,
                                accInfo.sessionInfo));
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.465)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
                          //fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      child: const Text('^ Restore'),
                      onPressed: () async {
                        //print('Restore student id --> ${accInfo.keyId}');
                        var dateStr =
                            '${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}';
                        var isMainInstallment = accInfo.isInstallment &&
                            accInfo.installmentId.isEmpty;
                        var hasInstallmentId = !accInfo.installmentId.isEmpty;
                        animatedCustomNonDismissibleAlert(
                            context,
                            _restoreStdAccountAlertW(
                                context,
                                accInfo.keyId,
                                dateStr,
                                accInfo.feeType,
                                accInfo.amount,
                                accInfo.isInstallment,
                                isMainInstallment,
                                hasInstallmentId,
                                accInfo.sessionInfo));
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.465)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
                          //fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));

  Widget _unlistedRestoreStudentAccListWidget(BuildContext context) =>
      Consumer<_KAccountsRestoreModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _lableWidget('snapshot null !');
        } else {
          if (snapshot.studentAccListItem == null) {
            return _lableWidget('snapshot studentAccListItem null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _lableWidget('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _lableWidget(snapshot.errorMsg);
                  } else {
                    if (snapshot.studentAccListItem.isEmpty) {
                      return _lableWidget('No Accounts Found !');
                    } else {
                      var itemLen = snapshot.studentAccListItem.length;
                      var widLen = snapshot.widgetIndex;
                      return ListView.separated(
                          shrinkWrap: true,
                          itemCount: itemLen,
                          separatorBuilder: (context, index) => const Divider(
                                height: 4.2,
                              ),
                          cacheExtent: itemLen * 100.0,
                          itemBuilder: (context, index) =>
                              _studentAccountDetailsWidget(
                                  context,
                                  snapshot.studentAccListItem[index],
                                  index,
                                  widLen));
                    }
                  }
                }
            }
          }
        }
      });

  @override
  Widget build(BuildContext context) {
    var _currentTotCount =
        context.watch<_KAccountsRestoreModel>().totalCount == null
            ? '—'
            : context.watch<_KAccountsRestoreModel>().totalCount.toString();
    var nextToken = context.watch<_KAccountsRestoreModel>().nextPageToken;
    var prevToken = context.watch<_KAccountsRestoreModel>().previousPageToken;
    var isWaiting = context.watch<_KAccountsRestoreModel>().isWaiting;
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          if (Provider.of<_KAccountsRestoreModel>(context, listen: false)
              .isRestore) onSuccessfulRestore();
        },
        child: AlertDialog(
          title: Container(
            //width: double.maxFinite,
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: const Text('Restore accounts',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text('$stdName \t [$_currentTotCount]',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.navigate_next),
                iconSize: 32,
                color: Colors.black87,
                tooltip: 'list next',
                onPressed: isWaiting || nextToken == null
                    ? null
                    : () => Provider.of<_KAccountsRestoreModel>(context,
                            listen: false)
                        .fetchNextStudentAccount(),
              ),
              leading: IconButton(
                icon: const Icon(Icons.navigate_before),
                iconSize: 32,
                color: Colors.black87,
                tooltip: 'list previous',
                onPressed: isWaiting || prevToken == null
                    ? null
                    : () => Provider.of<_KAccountsRestoreModel>(context,
                            listen: false)
                        .fetchPreviousStudentAccount(),
              ),
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2.0, color: Colors.grey),
              ),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: _unlistedRestoreStudentAccListWidget(context),
          ),
          actions: <Widget>[
            Container(
              width: double.maxFinite,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      //clearKeyBoard(context);
                      Navigator.of(context).pop();
                      if (Provider.of<_KAccountsRestoreModel>(context,
                              listen: false)
                          .isRestore) onSuccessfulRestore();
                    },
                    child: const Text('Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
            ),
          ],
          buttonPadding: const EdgeInsets.only(right: 7.0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
          clipBehavior: Clip.none,
          insetPadding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          //actionsOverflowButtonSpacing: 20.0,
          backgroundColor: Colors.indigo.shade50,
        ));
  }
}

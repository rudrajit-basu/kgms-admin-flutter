import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';
import 'src/kUtil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show DatePickerTheme, DatePicker;
import 'src/localDataStoreService.dart';
import 'dart:convert' as convert;
import 'package:provider/provider.dart'
    show
        ReassembleHandler,
        Provider,
        ChangeNotifierProvider,
        Consumer,
        ChangeNotifierProvider,
        ReadContext,
        WatchContext;

class KgmsCollectionReport extends StatefulWidget {
  const KgmsCollectionReport({Key key}) : super(key: key);

  @override
  KgmsCollectionReportState createState() => KgmsCollectionReportState();
}

class KgmsCollectionReportState extends State<KgmsCollectionReport> {
  //int _sessionMonth = 0;
  //int _sessionYear = 0;
  bool isReportLoaded = true;
  Map showOptions = null;
  List<LinearMonthlyAccounts> sampleData = null;
  bool testBool = false;
  Map _lastReqValue = null;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(milliseconds: 500),
        () => animatedCustomNonDismissibleAlert(
            context, _CollectionReportOptions(onSelect: _onSelect)));
  }

  Future<void> _onSelect(Map value, Map mapValue) async {
    var valueStr = convert.jsonEncode(value);
    //print('selected options --> $valueStr');
    //print('show options --> $mapValue');
    setState(() {
      isReportLoaded = false;
      showOptions = mapValue;
    });
    var resp = await dataStoreServ.getStudentCollectionReport(valueStr);
    final List<LinearMonthlyAccounts> respData = [];
    int indexPl = 0;
    int indexCl = 0;
    try {
      var jsonObj = convert.jsonDecode(resp);
      if (jsonObj != null) {
        var paidL = jsonObj['paid'] as Map<String, dynamic>;
        if (paidL != null) {
          for (var pl in paidL.entries) {
            respData.add(LinearMonthlyAccounts(pl.key, indexPl, pl.value as int,
                _collectionColorList[indexCl]));
            indexPl++;
            if (indexCl == 7)
              indexCl = 0;
            else
              indexCl++;
          }
        }
        var unPaidL = jsonObj['unPaid'] as Map<String, dynamic>;
        if (unPaidL != null) {
          indexCl = 0;
          for (var upl in unPaidL.entries) {
            respData.add(LinearMonthlyAccounts(upl.key, indexPl,
                upl.value as int, _collectionRedColorList[indexCl]));
            indexPl++;
            if (indexCl == 7)
              indexCl = 0;
            else
              indexCl++;
          }
        }
      }
    } on FormatException catch (e) {
      //print('getStudentCollectionReport err --> $e');
      //print('getStudentCollectionReport --> $resp');
    }
    ////print('respData --> $respData');
    if (mounted)
      setState(() {
        isReportLoaded = true;
        sampleData = respData;
        _lastReqValue = value;
      });
  }

  AlertDialog _showCollectionInfoAlertW(
          BuildContext context,
          Map query,
          bool isPaid,
          String className,
          String feeType,
          String sessionYear,
          String session,
          int studentCount) =>
      AlertDialog(
        title: Text(
            'Are you sure to view the ${isPaid ? 'paid' : 'un-paid'} students ?\nfor class - $className\nfeeType - $feeType\nsession year - $sessionYear\nsession - $session'),
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
              ////print('show student list !');
              //bool _internet = await isInternetAvailable();
              //if (_internet) {
              //  final KCircularProgress cp = KCircularProgress(ctx: context);
              //  cp.showCircularProgress();
              //  cp.closeProgress();
              //} else {
              //  kAlert(context, noInternetWidget);
              //}
              Navigator.pop(context);
              animatedCustomNonDismissibleAlert(
                  context,
                  _StudentCollectionListWrapper(
                      query: query,
                      isPaid: isPaid,
                      className: className,
                      feeType: feeType,
                      sessionYear: sessionYear,
                      session: session,
                      studentCount: studentCount));
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            iconSize: 27,
            onPressed: () {
              // //print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  //Future<void> _onClickReportTile(String classTitle, int studentCount) async {
  //  var className = '';
  //  var isPaid = true;
  //  if (classTitle.contains('-unpaid')) {
  //    var opera = classTitle.split('-');
  //    className = opera[0];
  //    isPaid = false;
  //  } else {
  //    className = classTitle;
  //    isPaid = true;
  //  }
  //  Map reportQueryData = {
  //    'feeType': _lastReqValue['feeType'],
  //    'className': className,
  //    'isPaid': isPaid,
  //    'sessionYear': _lastReqValue['sessionYear'],
  //    'session': _lastReqValue['session'],
  //  };
  //  //print('reportQueryData --> $reportQueryData');
  //  if (studentCount > 0) {
  //    animatedCustomNonDismissibleAlert(
  //        this,
  //        _showCollectionInfoAlertW(
  //            this,
  //            isPaid,
  //            className,
  //            showOptions['feeType'],
  //            showOptions['sessionYear'],
  //            showOptions['session']));
  //  } else {
  //    kAlert(this, showErrorWidget('No Students to show !'));
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KgmsCollectionReportAppBar(
          onSelect: _onSelect, showOptions: showOptions),
      body: KgmsCollectionReportBody(
          sampleData: sampleData,
          isReportLoaded: isReportLoaded,
          onClickReportTile: (String classTitle, int studentCount) async {
            if (studentCount > 0) {
              var className = '';
              var isPaid = true;
              if (classTitle.contains('-unpaid')) {
                var opera = classTitle.split('-');
                className = opera[0];
                isPaid = false;
              } else {
                className = classTitle;
                isPaid = true;
              }
              Map reportQueryData = {
                'feeType': _lastReqValue['feeType'],
                'className': className,
                'isPaid': isPaid,
                'sessionYear': _lastReqValue['sessionYear'],
                'session': _lastReqValue['session'],
              };
              //var reportQueryDataStr = convert.jsonEncode(reportQueryData);
              ////print('reportQueryData --> $reportQueryData');
              animatedCustomNonDismissibleAlert(
                  context,
                  _showCollectionInfoAlertW(
                      context,
                      reportQueryData,
                      isPaid,
                      className,
                      showOptions['feeType'],
                      showOptions['sessionYear'],
                      showOptions['session'],
                      studentCount));
            } else {
              kAlert(context, showErrorWidget('No Students to show !'));
            }
          }),
    );
  }
}

class LinearMonthlyAccounts {
  final String className;
  final int classId;
  final int studentCount;
  final Color colorVal;

  LinearMonthlyAccounts(
      this.className, this.classId, this.studentCount, this.colorVal);

  @override
  String toString() {
    return '${this.className} (${this.studentCount}) (id : ${this.classId})';
  }
}

final List<Color> _collectionColorList = [
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.amber,
  Colors.orange,
  Colors.lime[700],
  Colors.teal,
  Colors.cyan
];

final List<Color> _collectionRedColorList = [
  Colors.redAccent[400],
  Colors.red[400],
  Colors.red,
  Colors.red[600],
  Colors.red[700],
  Colors.red[800],
  Colors.red[900],
  Colors.redAccent,
];

class KgmsCollectionReportAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Function(Map, Map) onSelect;
  final Map showOptions;
  KgmsCollectionReportAppBar(
      {Key key, @required this.onSelect, @required this.showOptions})
      : preferredSize = Size.fromHeight(kToolbarHeight + 25.0),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    var showOptionsStr = showOptions != null
        ? 'Fee Type: ${showOptions['feeType']}, Year ${showOptions['sessionYear']}, Session: ${showOptions['session']}'
        : '';
    return AppBar(
      title: const Text('Collection Report'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
          scrollDirection: Axis.horizontal,
          child: Text(
            showOptionsStr,
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
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 30,
            tooltip: 'more options',
            onPressed: () async {
              ////print('show drawer');
              //Scaffold.of(context).openEndDrawer();
              animatedCustomNonDismissibleAlert(
                  context, _CollectionReportOptions(onSelect: onSelect));
            },
          ),
        ),
      ],
    );
  }
}

class _CollectionReportOptions extends StatefulWidget {
  final Function(Map, Map) onSelect;
  const _CollectionReportOptions({Key key, @required this.onSelect})
      : super(key: key);

  @override
  _CollectionReportOptionsState createState() =>
      _CollectionReportOptionsState();
}

class _CollectionReportOptionsState extends State<_CollectionReportOptions> {
  int _feeTypeCtrl = 0;
  bool _showMonthYear = false;
  String collection_session = '';

  bool _isValidated() {
    var isVal = true;
    //if (!_formKey.currentState.validate()) isVal = false;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Select options',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: const Text('Collection Report',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          trailing: const Icon(
            Icons.menu,
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
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                child: DropdownButtonFormField(
                  // collection feeType start
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
                  //validator: (value) {
                  //  if (value == null) {
                  //    return 'Fee type cannot be empty !';
                  //  }
                  //  return null;
                  //},
                  value: _feeTypeCtrl,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 10,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 17,
                  ),
                  onChanged: ((newValueIndex) async {
                    setState(() {
                      _feeTypeCtrl = newValueIndex;
                      if (!collection_session.isEmpty) collection_session = '';
                      //if (feeTypeList[_feeTypeCtrl]['feeId'] ==
                      //    'tuitionFee')
                      //  _feeCtrl.text =
                      //      _feeStruct['tuitionFee'].toString();
                      //else
                      //  _feeCtrl.text = '';
                      //if (!collection_session.isEmpty)
                      //  collection_session = '';
                    });
                  }),
                  onTap: () async {
                    clearKeyBoard(context);
                  },
                  items: feeTypeList
                      .map<DropdownMenuItem<int>>((Map<String, String> value) {
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
                ), // collection feeType end
              ),
              Padding(
                /*Fee month year start*/
                padding: const EdgeInsets.symmetric(vertical: 20),
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
                            onPressed: () async {
                              ////print('get date !');
                              clearKeyBoard(context);
                              if (_feeTypeCtrl == null) {
                                kAlert(context,
                                    showErrorWidget('Select feeType first !'));
                              } else {
                                animatedCustomNonDismissibleAlert(
                                    context,
                                    MultiselectForMonthYear(
                                        showMonths: feeTypeList[_feeTypeCtrl]
                                                ['feeId'] !=
                                            'admissionFee',
                                        //showMonths: true,
                                        onSelect: (String value) {
                                          ////print('result from ui --> $value');
                                          setState(() {
                                            collection_session = value;
                                          });
                                        }));
                              }
                            },
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
                              child: Icon(Icons.view_module_outlined, size: 22),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.lightBlue),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black87),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
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
            ],
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
                onPressed: () {
                  ////print('save collection');
                  if (_isValidated()) {
                    var session = null;
                    var sessionYear = null;
                    var sessionStr = null;
                    if (feeTypeList[_feeTypeCtrl]['feeId'] == 'admissionFee') {
                      var opera1 = collection_session.split(' of ');
                      sessionYear = int.tryParse(opera1[1]) ?? 0;
                      var opera2 = [];
                      opera2.add(sessionYear);
                      session = opera2;
                      sessionStr = sessionYear.toString();
                    } else {
                      var opera1 = collection_session.split(' of ');
                      sessionYear = int.tryParse(opera1[1]) ?? 0;
                      var opera2 = opera1[0].split(' , ');
                      session = dataStoreServ.getMonthsInList(opera2);
                      sessionStr = opera1[0];
                    }
                    var selectedOpt = {
                      'feeType': feeTypeList[_feeTypeCtrl]['feeId'],
                      'sessionYear': sessionYear,
                      'session': session,
                    };
                    var showSelectOption = {
                      'feeType': feeTypeList[_feeTypeCtrl]['feeId'],
                      'sessionYear': sessionYear.toString(),
                      'session': sessionStr,
                    };
                    //var selectedOptStr = convert.jsonEncode(selectedOpt);
                    widget.onSelect(selectedOpt, showSelectOption);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Go',
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

class KgmsCollectionReportBody extends StatelessWidget {
  final List<LinearMonthlyAccounts> sampleData;
  final bool isReportLoaded;
  final Function(String, int) onClickReportTile;
  KgmsCollectionReportBody(
      {Key key,
      @required this.sampleData,
      @required this.isReportLoaded,
      @required this.onClickReportTile})
      : super(key: key);

  Widget _statsReportTileWidget(
          String className, int studentCount, Color color) =>
      InkWell(
        splashColor: color,
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          ////print('open dialog for title --> $title');
          onClickReportTile(className, studentCount);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color),
                ),
              ),
              Text(
                '$className ($studentCount)',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _getCollectionReportWidget(BuildContext context) {
    final List<Widget> repotTileList = sampleData
        .map((sd) =>
            _statsReportTileWidget(sd.className, sd.studentCount, sd.colorVal))
        .toList();

    final seriesList = [
      charts.Series<LinearMonthlyAccounts, String>(
        id: 'MonthlyAcc',
        domainFn: (LinearMonthlyAccounts mAcc, _) =>
            '${mAcc.className} (${mAcc.studentCount})',
        measureFn: (LinearMonthlyAccounts mAcc, _) => mAcc.studentCount,
        colorFn: (LinearMonthlyAccounts mAcc, _) =>
            charts.ColorUtil.fromDartColor(mAcc.colorVal),
        data: sampleData,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearMonthlyAccounts row, _) =>
            '(${row.studentCount})\n${row.className}',
      )
    ];

    var reportTile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Wrap(
        spacing: 30.0,
        runSpacing: 24.0,
        children: repotTileList,
      ),
    );

    return SingleChildScrollView(
      primary: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.7,
            child: charts.PieChart(seriesList,
                animate: true,
                animationDuration: Duration(seconds: 1),
                //defaultInteractions: false,
                defaultRenderer: charts.ArcRendererConfig(
                    arcWidth: 90,
                    arcRendererDecorators: [
                      charts.ArcLabelDecorator(
                        showLeaderLines: true,
                      )
                    ])),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: reportTile,
          ),
        ],
      ),
    );
  }

  Widget _collectionWidg(context) {
    if (isReportLoaded) {
      if (sampleData == null)
        return Center(child: Text('Please select options !'));
      else if (sampleData.length == 0)
        return Center(child: Text('No Collection Report found !'));
      else if (sampleData.length > 0)
        return _getCollectionReportWidget(context);
    } else {
      return Center(child: Text('Please wait loading ...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _collectionWidg(context),
    );
  }
}

class _StudentCollectionListWrapper extends StatelessWidget {
  final Map query;
  final bool isPaid;
  final String className;
  final String feeType;
  final String sessionYear;
  final String session;
  final int studentCount;
  const _StudentCollectionListWrapper(
      {Key key,
      @required this.query,
      this.isPaid,
      this.className,
      this.feeType,
      this.sessionYear,
      this.session,
      this.studentCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _KStudentCollectionModel(query, studentCount),
      child: _StudentCollectionList(
          isPaid: isPaid,
          className: className,
          feeType: feeType,
          sessionYear: sessionYear,
          session: session,
          studentCount: studentCount),
    );
  }
}

class _KgmsStudentCollectionInfoModel {
  final String className;
  final String stdName;
  final String sec;
  //final int sessionYear;
  //final List<int> session;
  //final String sessionInfo;

  _KgmsStudentCollectionInfoModel(this.className, this.stdName, this.sec);

  factory _KgmsStudentCollectionInfoModel.fromJson(dynamic json) {
    return _KgmsStudentCollectionInfoModel(
      json['className'] as String,
      json['stdName'] as String,
      json['sec'] as String,
    );
  }
}

bool _isNotDisposed1 = true;

class _KStudentCollectionModel
    with ChangeNotifier
    implements ReassembleHandler {
  Map _query = {};

  final List<_KgmsStudentCollectionInfoModel> _studentListColleItem = [];
  List<_KgmsStudentCollectionInfoModel> get studentListColleItem =>
      _studentListColleItem;

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

  int _studentCount = 0;
  bool get isStudentCountReached =>
      _studentCount == (_widgetIndex + (_studentListColleItem.length - 1));

  _KStudentCollectionModel(Map query, int studentCount) {
    _isNotDisposed1 = true;
    _query = query;
    _studentCount = studentCount;
    ////print('_query --> $_query');
    _fetchStudentCollectionInfo();
  }

  //void executeQuery() {
  //  _isWaiting = true;
  //  _errorMsg = '';
  //  _isError = false;
  //  _studentListColleItem.clear();
  //  _totalCount = null;
  //  _nextPageToken = null;
  //  _previousPageToken = null;
  //  _currentTokenPos = 0;
  //  _tokenList.clear();
  //  _widgetIndex = 1;
  //  notifyListeners();
  //  _fetchStudentCollectionInfo();
  //}

  void fetchNextStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _widgetIndex += _studentListColleItem.length;
    _studentListColleItem.clear();
    notifyListeners();
    _fetchStudentCollectionInfo(isNext: true, token: _nextPageToken);
  }

  void fetchPreviousStudentAccount() {
    _isWaiting = true;
    _errorMsg = '';
    _isError = false;
    _studentListColleItem.clear();
    notifyListeners();
    _fetchStudentCollectionInfo(isPrev: true, token: _previousPageToken);
  }

  //void reloadCurrentStudentAccount() {
  //  _isWaiting = true;
  //  _errorMsg = '';
  //  _isError = false;
  //  _studentListColleItem.clear();
  //  _totalCount = null;
  //  _nextPageToken = null;
  //  _previousPageToken = null;
  //  _currentTokenPos = 0;
  //  _tokenList.clear();
  //  _widgetIndex = 1;
  //  notifyListeners();
  //  _fetchStudentCollectionInfo();
  //}

  void _fetchStudentCollectionInfo(
      {String token = null,
      bool isNext = false,
      bool isPrev = false,
      bool isReload = false}) {
    //_lastTokenUsed = token;
    Map queryMap = {
      'feeType': _query['feeType'],
      'className': _query['className'],
      'isPaid': _query['isPaid'],
      'sessionYear': _query['sessionYear'],
      'session': _query['session'],
      'last': token == null ? '' : token,
      'limit': 10
    };
    var queryStr = convert.jsonEncode(queryMap);
    ////print('query str --> $queryStr');
    dataStoreServ.getStudentCollectionInfo(queryStr).then((result) {
      //print('result --> $result');
      if (_isNotDisposed1) {
        try {
          var _jsonObj = convert.jsonDecode(result);
          var _jsonArr = _jsonObj['items'] as List;
          final List<_KgmsStudentCollectionInfoModel> _dataList = _jsonArr
              .map((jsonTag) =>
                  _KgmsStudentCollectionInfoModel.fromJson(jsonTag))
              .toList();
          _studentListColleItem.addAll(_dataList);
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
              //print('student acc list --> $_tokenList');
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
              //print('student acc list --> $_tokenList');
              _widgetIndex -= _studentListColleItem.length;
            }
          }
        } on FormatException catch (e) {
          //print('getStudentAccountInfo data = $result and error = $e');
          _errorMsg = '$result';
          _isError = true;
        }
        _isWaiting = false;
        notifyListeners();
      }
    });
  }

  //bool _isRestore = false;

  //bool get isRestore => _isRestore;

  //void setIsRestore(bool isRestore) {
  //  _isRestore = isRestore;
  //  notifyListeners();
  //}

  @override
  void reassemble() {
    //print('Did hot-reload from _KStudentCollectionModel !');
  }

  @override
  void dispose() {
    _isNotDisposed1 = false;
    //print('disposing _KStudentCollectionModel !');
  }
}

class _StudentCollectionList extends StatelessWidget {
  final bool isPaid;
  final String className;
  final String feeType;
  final String sessionYear;
  final String session;
  final int studentCount;
  const _StudentCollectionList(
      {Key key,
      this.isPaid,
      this.className,
      this.feeType,
      this.sessionYear,
      this.session,
      this.studentCount})
      : super(key: key);

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

  Card _studentListCollectionWidget(
          _KgmsStudentCollectionInfoModel accInfo, int index, int indexC) =>
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
                    '${accInfo.stdName}',
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
                    'class - ${accInfo.className} , sec - ${accInfo.sec}',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        height: 1.8),
                  ),
                ),
              ),
            ],
          ));

  Widget _unlistedRestoreStudentAccListWidget(BuildContext context) =>
      Consumer<_KStudentCollectionModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _lableWidget('snapshot null !');
        } else {
          if (snapshot.studentListColleItem == null) {
            return _lableWidget('snapshot studentListColleItem null !');
          } else {
            switch (snapshot.isWaiting) {
              case true:
                return _lableWidget('Loading....');
              default:
                {
                  if (snapshot.isError) {
                    return _lableWidget(snapshot.errorMsg);
                  } else {
                    if (snapshot.studentListColleItem.isEmpty) {
                      return _lableWidget('No students Found !');
                    } else {
                      var itemLen = snapshot.studentListColleItem.length;
                      var widLen = snapshot.widgetIndex;
                      return ListView.separated(
                          shrinkWrap: true,
                          itemCount: itemLen,
                          separatorBuilder: (context, index) => const Divider(
                                height: 4.2,
                              ),
                          cacheExtent: itemLen * 500.0,
                          itemBuilder: (context, index) =>
                              _studentListCollectionWidget(
                                  snapshot.studentListColleItem[index],
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
    //var _currentTotCount =
    //    context.watch<_KStudentCollectionModel>().totalCount == null
    //        ? '—'
    //        : context.watch<_KStudentCollectionModel>().totalCount.toString();
    var nextToken = context.watch<_KStudentCollectionModel>().nextPageToken;
    var prevToken = context.watch<_KStudentCollectionModel>().previousPageToken;
    var isWaiting = context.watch<_KStudentCollectionModel>().isWaiting;
    var isListComplete =
        context.watch<_KStudentCollectionModel>().isStudentCountReached;
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          //if (Provider.of<_KStudentCollectionModel>(context, listen: false)
          //    .isRestore) onSuccessfulRestore();
        },
        child: AlertDialog(
          title: Container(
            //width: double.maxFinite,
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Text('${isPaid ? 'Paid' : 'Un-paid'} student list',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                    '$className \t [$studentCount]\n$feeType \t- $sessionYear\n@ $session',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.navigate_next),
                iconSize: 32,
                color: Colors.black87,
                tooltip: 'list next',
                onPressed: isWaiting || nextToken == null || isListComplete
                    ? null
                    : () => Provider.of<_KStudentCollectionModel>(context,
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
                    : () => Provider.of<_KStudentCollectionModel>(context,
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
                      //if (Provider.of<_KStudentCollectionModel>(context,
                      //        listen: false)
                      //    .isRestore) onSuccessfulRestore();
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

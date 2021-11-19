import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'src/kUtil.dart';
import 'src/localDataStoreService.dart';
import 'src/firestoreService.dart';
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
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show DatePickerTheme, DatePicker, LocaleType;

bool _isNotDisposed = true;

class KgmsCollectionTransactionWrapper extends StatelessWidget {
  const KgmsCollectionTransactionWrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _KTransactionModel(),
      child: _KgmsCollectionTransaction(),
    );
  }
}

class _KgmsCollectionTransactionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  _KgmsCollectionTransactionAppBar({Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight + 25.0),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    var _currentTotCount =
        context.watch<_KTransactionModel>().totalCount == null
            ? '—'
            : context.watch<_KTransactionModel>().totalCount.toString();
    var nextToken = context.watch<_KTransactionModel>().nextPageToken;
    var prevToken = context.watch<_KTransactionModel>().previousPageToken;
    var isWaiting = context.watch<_KTransactionModel>().isWaiting;
    var optionsDisp = context.watch<_KTransactionModel>().currentOptionStr == ''
        ? ''
        : '${context.watch<_KTransactionModel>().currentOptionStr}';
    return AppBar(
      title: const Text(
        'Daily Transaction',
        overflow: TextOverflow.fade,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
          scrollDirection: Axis.horizontal,
          child: Text(
            '[$_currentTotCount] \t' + optionsDisp,
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
                : () => Provider.of<_KTransactionModel>(context, listen: false)
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
                : () => Provider.of<_KTransactionModel>(context, listen: false)
                    .fetchNextStudentAccount(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 30,
            tooltip: 'more options',
            onPressed: () async {
              //print('show drawer');
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }
}

const List<String> _sectionList = ['All', 'A', 'B', 'C', 'D', 'E', 'F'];

class _KgmsCollectionTransaction extends StatelessWidget {
  const _KgmsCollectionTransaction({Key key}) : super(key: key);
  //Widget _collectionWidg(BuildContext context) => Center(
  //      child: SingleChildScrollView(
  //          child: _AccountCollection(
  //              studentId: studentId,
  //              stdName: stdName,
  //              className: className,
  //              classId: classId,
  //              sec: sec,
  //              onSuccessfulUpload: () async {
  //                Provider.of<_KTransactionModel>(context, listen: false)
  //                    .reloadCurrentStudentAccount();
  //                ScaffoldMessenger.of(context)
  //                    .showSnackBar(kSnackbar('Upload successfully !'));
  //              })),
  //    );

  Widget _kStudentAccountSearchDrawer(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[50],
        ),
        //width: MediaQuery.of(context).size.width * 0.88,
        //height: MediaQuery.of(context).size.height * 0.85,
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
                Padding(
                  /*Collection fee type start*/
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    //validator: (value) {
                    //  if (value == null) {
                    //    return 'Fee type cannot be empty !';
                    //  }
                    //  return null;
                    //},
                    value: context.watch<_KTransactionModel>().feeTypeCtrl,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 10,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                    onChanged: ((newValueIndex) async {
                      //setState(() {
                      //  _feeTypeCtrl = newValueIndex;
                      //  if (feeTypeList[_feeTypeCtrl]['feeId'] ==
                      //      'tuitionFee')
                      //    _feeCtrl.text =
                      //        _feeStruct['tuitionFee'].toString();
                      //  else
                      //    _feeCtrl.text = '';
                      //  if (!collection_session.isEmpty)
                      //    collection_session = '';
                      //});
                      Provider.of<_KTransactionModel>(context, listen: false)
                          .setFeeType(newValueIndex);
                      Provider.of<_KTransactionModel>(context, listen: false)
                          .setCollectionSession('');
                      Provider.of<_KTransactionModel>(context, listen: false)
                          .setNotifyListeners();
                    }),
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
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '< Search by ${context.watch<_KTransactionModel>().isSwitchOn ? 'session' : 'date'} >',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.9,
                        ),
                      ),
                      Spacer(),
                      Switch(
                        value: context.watch<_KTransactionModel>().isSwitchOn,
                        onChanged: (value) async {
                          //print('switch value --> $value');
                          Provider.of<_KTransactionModel>(context,
                                  listen: false)
                              .setSwitchValue(value);
                          clearKeyBoard(context);
                        },
                        activeTrackColor: Colors.lightBlue,
                        activeColor: Colors.blueAccent[300],
                        inactiveTrackColor: Colors.lightBlue,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 34.0,
                ),
                Visibility(
                  visible: !context.watch<_KTransactionModel>().isSwitchOn,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: CheckboxListTile(
                          title: const Text(
                            'Search month-wise',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.9,
                            ),
                          ),
                          value:
                              context.watch<_KTransactionModel>().isDateMonthly,
                          onChanged: (bool value) async {
                            Provider.of<_KTransactionModel>(context,
                                    listen: false)
                                .setDateMonthly(value);
                            Provider.of<_KTransactionModel>(context,
                                    listen: false)
                                .setDateStr('');
                            Provider.of<_KTransactionModel>(context,
                                    listen: false)
                                .setNotifyListeners();
                          },
                          secondary: const Icon(Icons.date_range_outlined),
                          activeColor: Colors.lightBlue[600],
                          dense: true,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.32,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                //print('get date !');
                                clearKeyBoard(context);
                                var isSearchMonthly = context
                                    .read<_KTransactionModel>()
                                    .isDateMonthly;
                                DatePicker.showPicker(
                                  context,
                                  showTitleActions: true,
                                  pickerModel: CustomYearAndMonthPicker(
                                      showAllDate: !isSearchMonthly),
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
                                    var dateStr = '';
                                    if (!isSearchMonthly) {
                                      var dayStr = date.day < 10
                                          ? '0${date.day.toString()}'
                                          : date.day.toString();
                                      var monthStr = date.month < 10
                                          ? '0${date.month.toString()}'
                                          : date.month.toString();
                                      dateStr =
                                          '$dayStr/$monthStr/${date.year.toString()}';
                                    } else {
                                      var monthStr = date.month < 10
                                          ? '0${date.month.toString()}'
                                          : date.month.toString();
                                      dateStr =
                                          '$monthStr/${date.year.toString()}';
                                    }
                                    //print('date selected --> $dateStr');
                                    Provider.of<_KTransactionModel>(context,
                                            listen: false)
                                        .setDateStr(dateStr);
                                  },
                                );
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
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Text(
                              '\t\t=    ${context.watch<_KTransactionModel>().dateStr.isEmpty ? 'none' : context.watch<_KTransactionModel>().dateStr}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: context.watch<_KTransactionModel>().isSwitchOn,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          /*Student roll no. start*/
                          width: MediaQuery.of(context).size.width * 0.36,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              //print('get date !');
                              clearKeyBoard(context);
                              var feeTypeIndex = context
                                  .read<_KTransactionModel>()
                                  .feeTypeCtrl;
                              animatedCustomNonDismissibleAlert(
                                  context,
                                  MultiselectForMonthYear(
                                      showMonths: feeTypeList[feeTypeIndex]
                                              ['feeId'] !=
                                          'admissionFee',
                                      //showMonths: true,
                                      onSelect: (String value) {
                                        //print('result from ui --> $value');
                                        Provider.of<_KTransactionModel>(context,
                                                listen: false)
                                            .setCollectionSession(value);
                                        Provider.of<_KTransactionModel>(context,
                                                listen: false)
                                            .setNotifyListeners();
                                      }));
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
                                //side: BorderSide(
                                //    color: _showMonthYear
                                //        ? Colors.red
                                //        : Colors.transparent),
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
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: Text(
                            '${context.watch<_KTransactionModel>().collection_session.toString().isEmpty ? 'none' : context.watch<_KTransactionModel>().collection_session.toString()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CheckboxListTile(
                    title: const Text(
                      'Advance search',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.9,
                      ),
                    ),
                    value: context.watch<_KTransactionModel>().isAdvanceSearch,
                    onChanged: (bool value) async {
                      Provider.of<_KTransactionModel>(context, listen: false)
                          .setAdvanceSearch(value);
                    },
                    secondary: const Icon(Icons.fact_check),
                    activeColor: Colors.lightBlue[600],
                    dense: true,
                  ),
                ),
                Visibility(
                  visible: context.watch<_KTransactionModel>().isAdvanceSearch,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30.0,
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
                          //onChanged: (String value) async {
                          //  Provider.of<_KTransactionModel>(context, listen: false)
                          //      .setStdNameValue(value);
                          //},
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            letterSpacing: 0.9,
                          ),
                          //initialValue: context.read<_KTransactionModel>().stdNameValue,
                          //keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller: context
                              .watch<_KTransactionModel>()
                              .studentNameSearchCtrl,
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
                          value: context
                              .watch<_KTransactionModel>()
                              .classIndexValue,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 10,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 17,
                          ),
                          onChanged: ((newValueIndex) async {
                            Provider.of<_KTransactionModel>(context,
                                    listen: false)
                                .setClassIndexValue(newValueIndex);
                          }),
                          items: context
                              .watch<_KTransactionModel>()
                              .classNameList
                              .map<DropdownMenuItem<int>>(
                                  (Map<String, String> value) {
                            return DropdownMenuItem<int>(
                              value: context
                                  .watch<_KTransactionModel>()
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
                          value:
                              context.watch<_KTransactionModel>().secIndexValue,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 10,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 17,
                          ),
                          onChanged: ((newValueIndex) async {
                            Provider.of<_KTransactionModel>(context,
                                    listen: false)
                                .setSecIndexValue(newValueIndex);
                          }),
                          items: _sectionList
                              .map<DropdownMenuItem<int>>((String value) {
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
                    ],
                  ),
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
                        Provider.of<_KTransactionModel>(context, listen: false)
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
                        //print('Reset options !');
                        Provider.of<_KTransactionModel>(context, listen: false)
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
                        //Provider.of<_KTransactionModel>(context, listen: false).resetValue();
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
      appBar: _KgmsCollectionTransactionAppBar(),
      body: _KgmsCollectionTransactionBody(),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Theme(
        data: ThemeData(
          primaryColor: Colors.blueAccent,
        ),
        child: _kStudentAccountSearchDrawer(context),
      ),
      //bottomNavigationBar: BottomAppBar(
      //  shape: const CircularNotchedRectangle(),
      //  child: Container(
      //    height: 55.0,
      //    color: Colors.yellow,
      //    child: Padding(
      //      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      //      child: Row(
      //        mainAxisSize: MainAxisSize.max,
      //        mainAxisAlignment: MainAxisAlignment.center,
      //        crossAxisAlignment: CrossAxisAlignment.center,
      //        children: <Widget>[
      //          Container(
      //            width: MediaQuery.of(context).size.width * 0.40,
      //            child: IconButton(
      //              icon: const Icon(Icons.add_circle_outline_outlined),
      //              iconSize: 30,
      //              tooltip: 'add collection',
      //              onPressed: () async {
      //                //var widg = SingleChildScrollView(child: _AccountCollection());
      //                //animatedCustomNonDismissibleAlert(
      //                //    context, _collectionWidg(context));
      //              },
      //            ),
      //          ),
      //          Spacer(),
      //          Container(
      //            width: MediaQuery.of(context).size.width * 0.40,
      //            child: IconButton(
      //              icon: const Icon(Icons.restore_outlined),
      //              iconSize: 30,
      //              tooltip: 'restore transaction',
      //              onPressed: () {
      //                //print('restore transaction');
      //                //animatedCustomNonDismissibleAlert(
      //                //    context,
      //                //    _AccountRestoreTransactionWrapper(
      //                //        studentId: studentId,
      //                //        stdName: stdName,
      //                //        onSuccessfulRestore: () async {
      //                //          Provider.of<_KTransactionModel>(context,
      //                //                  listen: false)
      //                //              .reloadCurrentStudentAccount();
      //                //          //ScaffoldMessenger.of(context)
      //                //          //    .showSnackBar(kSnackbar('Upload successfully !'));
      //                //        }));
      //              },
      //            ),
      //          ),
      //        ],
      //      ),
      //    ),
      //  ),
      //),
    );
  }
}

class _KTransactionModel with ChangeNotifier implements ReassembleHandler {
  String _dateStr = '';

  String get dateStr => _dateStr;

  int _dtDay = 0;
  int _dtMonth = 0;
  int _dtYear = 0;

  //String _studentId = '';

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
  String currentOptionStr = '';

  bool _isQueryExecuted = false;
  bool get isQueryExecuted => _isQueryExecuted;

  _KTransactionModel() {
    _isNotDisposed = true;
    _setCurrentDate();
    //_fetchStudentAccount();
    Future.delayed(const Duration(milliseconds: 600), () {
      firestoreServ.getClassesAndIds().then((result) {
        _classNameList.addAll(result);
        notifyListeners();
      });
    });
  }

  //bool _isQueryExec = false;
  //bool get isQueryExec => _isQueryExec;

  void executeQuery() {
    //if (!_isQueryExec) _isQueryExec = true;
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
    if (!_isQueryExecuted) _isQueryExecuted = true;
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
    //Map queryMap = {
    //  'studentId': _studentId,
    //  'installmentId': '',
    //  'isActive': true,
    //  'limit': 3,
    //  'last': token == null ? '' : token,
    //  'dtDay': _dtDay,
    //  'dtMonth': _dtMonth,
    //  'dtYear': _dtYear,
    //};
    Map queryMap = {
      "feeType": feeTypeList[_feeTypeCtrl]['feeId'],
      "dtDay": _isSwitchOn ? 0 : _dtDay,
      "dtMonth": _isSwitchOn ? 0 : _dtMonth,
      "dtYear": _isSwitchOn ? 0 : _dtYear,
      "classId": !_isAdvanceSearch ||
              _classNameList[_classIndexValue]['classId'] == 'all'
          ? ''
          : _classNameList[_classIndexValue]['classId'],
      "className": "",
      "sec": !_isAdvanceSearch || _sectionList[_secIndexValue] == 'All'
          ? ''
          : _sectionList[_secIndexValue],
      "stdName": _isAdvanceSearch ? studentNameSearchCtrl.text : '',
      "session": _isSwitchOn ? _sessionList : [],
      "sessionYear": _isSwitchOn ? _sessionYear : 0,
      "last": token == null ? '' : token,
      "limit": 20
    };
    var queryStr = convert.jsonEncode(queryMap);
    print('query str --> $queryStr');
    dataStoreServ.getAccountTransactionDetails(queryStr).then((result) {
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

    //currentDateStr = dateStr;
    _setSearchOptions(queryMap);
  }

  void _setSearchOptions(Map query) {
    List<String> optionList = [];
    optionList.add('feeType: ${query['feeType']}');
    if (!_isSwitchOn) {
      if (!_dateStr.isEmpty) optionList.add('date: $_dateStr');
    }
    if (_isSwitchOn) {
      if (!_collection_session.isEmpty)
        optionList.add('session: $_collection_session');
    }
    if (_isAdvanceSearch) {
      if (!query['stdName'].toString().isEmpty)
        optionList.add('stdName: ${query['stdName'].toString()}');
      if (!query['classId'].toString().isEmpty)
        optionList
            .add('class: ${_classNameList[_classIndexValue]['className']}');
      if (!query['sec'].toString().isEmpty)
        optionList.add('sec: ${query['sec'].toString()}');
    }
    currentOptionStr = optionList.join(' , ');
  }

  void setDateStr(String date) {
    _dateStr = date;
    if (!date.isEmpty) {
      var opera1 = date.split('/');
      if (opera1.length == 3) {
        _dtDay = int.tryParse(opera1[0]);
        _dtMonth = int.tryParse(opera1[1]);
        _dtYear = int.tryParse(opera1[2]);
      }
      if (opera1.length == 2) {
        _dtDay = 0;
        _dtMonth = int.tryParse(opera1[0]);
        _dtYear = int.tryParse(opera1[1]);
      }
    } else {
      _dtDay = 0;
      _dtMonth = 0;
      _dtYear = 0;
    }
    notifyListeners();
  }

  void resetSearch() {
    _dateStr = '';
    _dtDay = 0;
    _dtMonth = 0;
    _dtYear = 0;
    _collection_session = '';
    _classIndexValue = 0;
    _secIndexValue = 0;
    studentNameSearchCtrl.text = '';
    _feeTypeCtrl = 0;
    _setSessionListFromStr(_collection_session);
    notifyListeners();
  }

  bool _isSwitchOn = false;
  bool get isSwitchOn => _isSwitchOn;

  int _feeTypeCtrl = 0;
  int get feeTypeCtrl => _feeTypeCtrl;

  String _collection_session = '';
  String get collection_session => _collection_session;

  bool _isAdvanceSearch = false;
  bool get isAdvanceSearch => _isAdvanceSearch;

  final TextEditingController studentNameSearchCtrl = TextEditingController();

  final List<Map<String, String>> _classNameList = [
    {'classId': 'all', 'className': 'All'}
  ];

  List<Map<String, String>> get classNameList => _classNameList;

  int _classIndexValue = 0;
  int get classIndexValue => _classIndexValue;

  int _secIndexValue = 0;
  int get secIndexValue => _secIndexValue;

  List<int> _sessionList = [];
  int _sessionYear = 0;

  bool _isDateMonthly = false;
  bool get isDateMonthly => _isDateMonthly;

  void setSwitchValue(bool value) {
    _isSwitchOn = value;
    notifyListeners();
  }

  void setFeeType(int value) {
    _feeTypeCtrl = value;
    //notifyListeners();
  }

  void setCollectionSession(String value) {
    _collection_session = value;
    _setSessionListFromStr(value);
    //notifyListeners();
  }

  void setDateMonthly(bool value) {
    _isDateMonthly = value;
  }

  void setNotifyListeners() {
    notifyListeners();
  }

  void setAdvanceSearch(bool value) {
    _isAdvanceSearch = value;
    notifyListeners();
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

  void _setSessionListFromStr(String value) {
    if (!value.isEmpty) {
      if (feeTypeList[_feeTypeCtrl]['feeId'] == 'admissionFee') {
        var opera1 = value.split(' of ');
        _sessionYear = int.tryParse(opera1[1]) ?? 0;
        List<int> opera2 = [];
        opera2.add(_sessionYear);
        _sessionList = opera2;
      } else {
        var opera1 = value.split(' of ');
        _sessionYear = int.tryParse(opera1[1]) ?? 0;
        var opera2 = opera1[0].split(' , ');
        _sessionList = dataStoreServ.getMonthsInList(opera2);
      }
    } else {
      _sessionList = [];
      _sessionYear = 0;
    }
  }

  void _setCurrentDate() {
    var date = DateTime.now();
    var dayStr =
        date.day < 10 ? '0${date.day.toString()}' : date.day.toString();
    var monthStr =
        date.month < 10 ? '0${date.month.toString()}' : date.month.toString();
    var dateStr = '$dayStr/$monthStr/${date.year.toString()}';
    setDateStr(dateStr);
  }

  @override
  void reassemble() {
    print('Did hot-reload from _KTransactionModel !');
  }

  @override
  void dispose() {
    _isNotDisposed = false;
    print('disposing _KTransactionModel !');
  }
}

class _KgmsCollectionTransactionBody extends StatefulWidget {
  const _KgmsCollectionTransactionBody({Key key}) : super(key: key);

  @override
  _KgmsCollectionTransactionBodyState createState() =>
      _KgmsCollectionTransactionBodyState();
}

class _KgmsCollectionTransactionBodyState
    extends State<_KgmsCollectionTransactionBody> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700),
        () => Scaffold.of(context).openEndDrawer());
    //Scaffold.of(context).openEndDrawer();
  }

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

  //AlertDialog _deleteStdAccountAlertW(
  //        BuildContext context,
  //        String keyId,
  //        String dateStr,
  //        String feeType,
  //        int amount,
  //        bool isInstallment,
  //        bool isMainInstallment,
  //        bool hasInstallmentId,
  //        String sessionInfo) =>
  //    AlertDialog(
  //      title: Text(
  //          'Are you sure to delete transaction ?\namount - $amount on $dateStr\nfee type - $feeType\n$sessionInfo\n${isInstallment ? '[installment]' : ''}'),
  //      shape: RoundedRectangleBorder(
  //        borderRadius: const BorderRadius.all(Radius.circular(10)),
  //      ),
  //      titleTextStyle: const TextStyle(
  //          color: Colors.black,
  //          fontWeight: FontWeight.w500,
  //          fontSize: 17,
  //          letterSpacing: 0.5,
  //          height: 1.8),
  //      elevation: 15,
  //      actions: <Widget>[
  //        IconButton(
  //          icon: const Icon(Icons.done),
  //          iconSize: 27,
  //          onPressed: () async {
  //            bool _internet = await isInternetAvailable();
  //            if (_internet) {
  //              final KCircularProgress cp = KCircularProgress(ctx: context);
  //              cp.showCircularProgress();
  //              var body = {
  //                'keyId': keyId,
  //                'isActive': false,
  //                'isMainInstallment': isMainInstallment,
  //                'hasInstallmentId': hasInstallmentId,
  //              };
  //              var bodyStr = convert.jsonEncode(body);
  //              print('delete bodyStr --> $bodyStr');
  //              var res =
  //                  await dataStoreServ.updateStudentAccountStatusInfo(bodyStr);
  //              if (res) {
  //                Provider.of<_KTransactionModel>(context, listen: false)
  //                    .reloadCurrentStudentAccount();
  //                ScaffoldMessenger.of(context)
  //                    .showSnackBar(kSnackbar('Delete successfully !'));
  //              } else {
  //                ScaffoldMessenger.of(context)
  //                    .showSnackBar(kSnackbar('Delete unsuccessful !'));
  //              }
  //              cp.closeProgress();
  //            } else {
  //              kAlert(context, noInternetWidget);
  //            }
  //            Navigator.pop(context);
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
                    '${accInfo.feeType} \t ${accInfo.sessionInfo} \t ${accInfo.isInstallment ? accInfo.isMainInstallment ? '\n[main installment]' : '\n[installment]' : ''}\nclass - ${accInfo.className} \t sec - ${accInfo.sec}\nname - ${accInfo.stdName}',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        height: 1.8),
                  ),
                ),
                //isThreeLine: true,
              ),
              //Padding(
              //  padding: const EdgeInsets.symmetric(horizontal: 12.0),
              //  child: Row(
              //    mainAxisSize: MainAxisSize.max,
              //    mainAxisAlignment: MainAxisAlignment.end,
              //    children: <Widget>[
              //      Visibility(
              //        visible: accInfo.isContainsInstallment,
              //        maintainSize: true,
              //        maintainAnimation: true,
              //        maintainState: true,
              //        child: TextButton(
              //          child: const Text('Installment'),
              //          onPressed: () async {
              //            //print(
              //            //    'acc take installment id --> ${accInfo.installmentId}');
              //            //print(
              //            //    'isContainsInstallment --> ${accInfo.isContainsInstallment}');
              //            var dateStr =
              //                '${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}';
              //            animatedCustomNonDismissibleAlert(
              //                context,
              //                _InstallemtCollection(
              //                    keyId: accInfo.keyId,
              //                    installmentId: accInfo.installmentId,
              //                    feeType: accInfo.feeType,
              //                    date: dateStr,
              //                    studentId: accInfo.studentId,
              //                    stdName: stdName,
              //                    className: accInfo.className,
              //                    classId: accInfo.classId,
              //                    sec: accInfo.sec,
              //                    session: accInfo.session,
              //                    sessionYear: accInfo.sessionYear,
              //                    onSuccessfulUpload: () async {
              //                      Provider.of<_KTransactionModel>(context,
              //                              listen: false)
              //                          .reloadCurrentStudentAccount();
              //                      //ScaffoldMessenger.of(context)
              //                      //    .showSnackBar(kSnackbar('Upload successfully !'));
              //                    }));
              //          },
              //          style: ButtonStyle(
              //            foregroundColor: MaterialStateProperty.all<Color>(
              //                Colors.black.withOpacity(0.465)),
              //            textStyle:
              //                MaterialStateProperty.all<TextStyle>(TextStyle(
              //              fontSize: 16,
              //              fontWeight: FontWeight.bold,
              //            )),
              //          ),
              //        ),
              //      ),
              //      Spacer(),
              //      TextButton(
              //        child: const Text('Delete'),
              //        onPressed: () {
              //          //print('acc transaction delete -->');
              //          var dateStr =
              //              '${accInfo.dtDay}-${accInfo.dtMonth}-${accInfo.dtYear}';
              //          var isMainInstallment = accInfo.isInstallment &&
              //              accInfo.installmentId.isEmpty;
              //          var hasInstallmentId = !accInfo.installmentId.isEmpty;
              //          animatedCustomNonDismissibleAlert(
              //              context,
              //              _deleteStdAccountAlertW(
              //                  context,
              //                  accInfo.keyId,
              //                  dateStr,
              //                  accInfo.feeType,
              //                  accInfo.amount,
              //                  accInfo.isInstallment,
              //                  isMainInstallment,
              //                  hasInstallmentId,
              //                  accInfo.sessionInfo));
              //        },
              //        style: ButtonStyle(
              //          foregroundColor: MaterialStateProperty.all<Color>(
              //              Colors.black.withOpacity(0.46)),
              //          textStyle:
              //              MaterialStateProperty.all<TextStyle>(TextStyle(
              //            fontSize: 16,
              //            fontWeight: FontWeight.bold,
              //          )),
              //        ),
              //      ),
              //    ],
              //),
              //),
            ],
          ),
        ),
      );

  Widget _unlistedStudentAccListWidget(BuildContext context) =>
      Consumer<_KTransactionModel>(builder: (context, snapshot, _) {
        if (snapshot == null) {
          return _loadingTile('snapshot null !');
        } else {
          if (snapshot.studentAccListItem == null) {
            return _loadingTile('studentAccListItem is null !');
          } else {
            if (!snapshot.isQueryExecuted)
              return _loadingTile('No query executed !');
            else  
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
                          //cacheExtent: itemLen * 100.0,
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
  final String stdName;
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
      this.sessionYear,
      this.stdName)
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
        json['sessionYear'] as int,
        json['stdName'] as String);
  }
}

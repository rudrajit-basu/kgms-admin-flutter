import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show DatePickerModel, LocaleType;

Future<bool> isInternetAvailable() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      // print('connected');
      return true;
    } else {
      return false;
    }
  } on SocketException catch (_) {
    // print('not connected');
    return false;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<void> kAlert(BuildContext ctx, Widget widg) async {
  return showDialog<void>(
    context: ctx,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return widg;
    },
  );
}

Future<void> kDAlert(BuildContext ctx, Widget widg) async {
  return showDialog<void>(
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

Future<void> kDDAlert(BuildContext ctx, Widget widg) async {
  return showDialog<void>(
    context: ctx,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return widg;
    },
  );
}

class KCircularProgress {
  final BuildContext ctx;
  KCircularProgress({@required this.ctx});

  final _loadingWidget = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      const CircularProgressIndicator(),
    ],
  );

  Future<void> showCircularProgress() async {
    return showDialog<void>(
      context: this.ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _loadingWidget;
      },
    );
  }

  void closeProgress() {
    Navigator.of(this.ctx, rootNavigator: true).pop();
  }
}

final noInternetWidget = AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  title: const Center(
    child: ListTile(
      leading: Icon(
        Icons.block,
        color: Colors.black,
      ),
      title: const Text(
        'No internet...!!',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
    ),
  ),
  titleTextStyle: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  elevation: 15,
);

final wrongLogin = AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  title: const Center(
    child: ListTile(
      leading: Icon(Icons.report_problem, color: Colors.black, size: 24),
      title: Text(
        'Login unsuccessful...!!',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Text('please check user id or password.'),
      ),
    ),
  ),
  titleTextStyle: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  elevation: 15,
  // contentPadding: const EdgeInsets.all(5),
);

final wrongSignOut = AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  title: const Center(
    child: ListTile(
      leading: Icon(Icons.report_problem, //report_problem priority_high
          color: Colors.black,
          size: 24),
      title: Text(
        'Sign out unsuccessful...!!',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Text('Something went wrong. Try later...!!'),
      ),
    ),
  ),
  titleTextStyle: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  elevation: 15,
  // contentPadding: const EdgeInsets.all(5),
);

SnackBar kSnackbar(String msg) => SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          // fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.lightBlue,
      duration: Duration(seconds: 2),
    );

AlertDialog showErrorWidget(String msg) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      title: Center(
        child: ListTile(
          leading: const Icon(
              Icons.error_outline_rounded, //report_problem priority_high
              color: Colors.black,
              size: 32),
          title: Text(
            '$msg',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          subtitle: const Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text('Something went wrong. Try later...!!'),
          ),
        ),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      elevation: 15,
      // contentPadding: const EdgeInsets.all(5),
    );

Function animatedCustomNonDismissibleAlertT<T>() {
  Future<T> genericNonDismissibleAlert(BuildContext ctx, Widget widg) async {
    return showDialog<T>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return _SlideBottomToUp(kWidget: widg);
      },
    );
  }

  return genericNonDismissibleAlert;
}

Future<bool> animatedCustomNonDismissibleAlertBool(
    BuildContext ctx, Widget widg) async {
  return showDialog<bool>(
    context: ctx,
    barrierDismissible: false,
    builder: (_) {
      return _SlideBottomToUp(kWidget: widg);
    },
  );
}

Future<void> animatedCustomNonDismissibleAlert(
    BuildContext ctx, Widget widg) async {
  return showDialog<void>(
    context: ctx,
    barrierDismissible: false,
    builder: (_) {
      return _SlideBottomToUp(kWidget: widg);
    },
  );
}

class _SlideBottomToUp extends StatefulWidget {
  final Widget kWidget;
  const _SlideBottomToUp({Key key, @required this.kWidget}) : super(key: key);

  @override
  _SlideBottomToUpState createState() => _SlideBottomToUpState();
}

class _SlideBottomToUpState extends State<_SlideBottomToUp>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInSine,
      //curve: Curves.fastOutSlowIn,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onTap: () async {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: widget.kWidget,
      ),
    );
  }
}

class _FunckyOverlay extends StatefulWidget {
  final Widget kWidget;
  const _FunckyOverlay({Key key, @required this.kWidget}) : super(key: key);

  @override
  _FunckyOverlayState createState() => _FunckyOverlayState();
}

class _FunckyOverlayState extends State<_FunckyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: GestureDetector(
        onTap: () async {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: widget.kWidget,
      ),
    );
  }
}

bool isNumFromString(String s) => int.tryParse(s) != null;

void clearKeyBoard(BuildContext context) async {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
    //currentFocus.requestFocus(FocusNode());
  }
}

iconTag(String label, IconData icon, double bottomValue) => Padding(
      padding: EdgeInsets.only(bottom: bottomValue),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              letterSpacing: 0.9,
            ),
          ),
          Icon(
            icon,
            color: Colors.black54,
          ),
        ],
      ),
    );

class CustomYearAndMonthPicker extends DatePickerModel {
  final DateTime customDateTime;
  final bool showYearOnly;
  final bool showMonthOnly;
  final bool showAllDate;
  CustomYearAndMonthPicker(
      {this.customDateTime = null,
      this.showYearOnly = false,
      this.showMonthOnly = false,
      this.showAllDate = false}) {
    this.currentTime = customDateTime == null ? DateTime.now() : customDateTime;
    //this.minTime = DateTime(2005, 1, 1);
    //this.maxTime = DateTime(2035, 12, 31);
    this.locale = LocaleType.en;
    //this.setLeftIndex(this.currentTime.year);
    //this.setMiddleIndex(this.currentTime.month);
    //this.setRightIndex(this.currentTime.second);
  }

  @override
  List<int> layoutProportions() {
    if (showAllDate) {
      return [1, 2, 1];
    } else {
      if (showYearOnly && !showMonthOnly)
        return [2, 0, 0];
      else if (!showYearOnly && showMonthOnly)
        return [0, 3, 0];
      else
        return [2, 3, 0];
    }
  }
}

class MultiselectForMonthYear extends StatefulWidget {
  final bool showMonths;
  final Function(String) onSelect;
  const MultiselectForMonthYear(
      {Key key, this.showMonths = false, @required this.onSelect})
      : super(key: key);

  @override
  _MultiselectForMonthYearState createState() =>
      _MultiselectForMonthYearState();
}

const List<String> _monthsName = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class _MultiselectForMonthYearState extends State<MultiselectForMonthYear> {
  final List<_MonthListModel> _monthList = [];
  final List<int> _yearsList = [];
  int _yearValueCtrl = null;

  var _currentState = 'loading';
  var _showMessage = false;
  var _dialogMessage = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          if (widget.showMonths)
            for (var mnth in _monthsName) _monthList.add(_MonthListModel(mnth));
          var currentYear = DateTime.now().year;
          for (var i = currentYear - 5; i < currentYear; i++) _yearsList.add(i);
          for (var i = currentYear; i <= currentYear + 5; i++)
            _yearsList.add(i);
          _yearValueCtrl = currentYear;
          _currentState = 'ok';
        });
      }
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

  void setValueForClass(int index, bool value) {
    setState(() {
      //_classList[index].boolValue = value;
      _monthList[index].setBoolvalue(value);
    });
  }

  CheckboxListTile _checkBoxListTile(_MonthListModel clm, int index) =>
      CheckboxListTile(
        title: Text(
          clm.monthName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.9,
          ),
        ),
        //selected: !clm.isEditable,
        value: clm.boolValue,
        onChanged: (bool value) {
          setValueForClass(index, value);
        },
        //secondary: const Icon(Icons.fact_check),
        activeColor: Colors.lightBlue[600],
        dense: true,
      );

  Widget _getCurrentStateWidget(String stateValue) {
    switch (stateValue) {
      case 'ok':
        if (widget.showMonths)
          return ListView.separated(
            shrinkWrap: true,
            itemCount: _monthList.length,
            itemBuilder: (context, index) =>
                _checkBoxListTile(_monthList[index], index),
            separatorBuilder: (context, index) => Divider(
              height: 4.2,
            ),
          );
        else
          return null;
        break;
      case 'empty':
        return _getMessageWidget('No value...');
        break;
      default:
        return _getMessageWidget('Loading...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        width: double.maxFinite,
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Select Month and Year :',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 17,
                  )),
              //subtitle:
              trailing: const Icon(
                Icons.view_module_outlined,
                size: 30.0,
              ),
              //tileColor: Colors.yellow,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 80, bottom: 4.0),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Year *',
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
                value: _yearValueCtrl,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                //elevation: 10,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 17,
                ),
                onChanged: (value) {
                  setState(() {
                    _yearValueCtrl = value;
                  });
                },
                items: _yearsList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        color: Colors.purple,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          //decoration: BoxDecoration(
          //  border: Border(
          //    bottom: BorderSide(width: 2.0, color: Colors.grey),
          //  ),
          //),
        ),
      ),
      content: widget.showMonths
          ? Container(
              width: double.maxFinite,
              child: _getCurrentStateWidget(_currentState),
            )
          : null,
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
                //print('save month list !');
                if (widget.showMonths) {
                  var monthsStr = [];
                  for (var mnth in _monthList) {
                    if (mnth.boolValue) {
                      monthsStr.add(mnth.monthName);
                    }
                  }
                  if (monthsStr.length > 0 && _yearValueCtrl != null) {
                    var result = monthsStr.join(' , ') + ' of $_yearValueCtrl';
                    widget.onSelect(result);
                    Navigator.of(context).pop();
                  } else {
                    if (_yearValueCtrl == null) {
                      setState(() {
                        _dialogMessage = 'No year';
                        _showMessage = true;
                      });
                    } else {
                      if (monthsStr.length == 0) {
                        setState(() {
                          _dialogMessage = 'No month';
                          _showMessage = true;
                        });
                      }
                    }
                  }
                } else {
                  if (_yearValueCtrl == null)
                    setState(() {
                      _dialogMessage = 'No year';
                      _showMessage = true;
                    });
                  else {
                    var result = ' of $_yearValueCtrl';
                    widget.onSelect(result);
                    Navigator.of(context).pop();
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

class _MonthListModel {
  final String monthName;
  bool boolValue = false;

  _MonthListModel(this.monthName);

  void setBoolvalue(bool value) {
    this.boolValue = value;
  }
}

DateTime getDateFromString(String dt) {
  if (!dt.isEmpty) {
    try {
      var opera = dt.split('/');
      if (opera.length == 3) {
        var day = int.tryParse(opera[0]);
        var month = int.tryParse(opera[1]);
        var year = int.tryParse(opera[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
      if (opera.length == 2) {
        var day = 1;
        var month = int.tryParse(opera[0]);
        var year = int.tryParse(opera[1]);
        if (month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
      if (opera.length == 1) {
        var day = 1;
        var month = 1;
        var year = int.tryParse(opera[0]);
        if (year != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      print(e);
    }
  }
  return DateTime.now();
}

const List<Map<String, String>> feeTypeList = [
  {'feeId': 'tuitionFee', 'feeName': 'Tuition Fee'},
  {'feeId': 'functionFee', 'feeName': 'Function Fee'},
  {'feeId': 'medicalFee', 'feeName': 'Medical Fee'},
  {'feeId': 'stationaryFee', 'feeName': 'Stationary Fee'},
  {'feeId': 'admissionFee', 'feeName': 'Admission Fee'}
];
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

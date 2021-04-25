import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:email_validator/email_validator.dart';
//import 'package:flutter/scheduler.dart' show timeDilation;
//import 'package:cloud_firestore/cloud_firestore.dart';

const List<Tab> tabs = <Tab>[
  Tab(icon: Icon(Icons.face_unlock_outlined), text: 'Student'),
  Tab(icon: Icon(Icons.person_outline), text: 'Parent'),
  Tab(icon: Icon(Icons.house_outlined), text: 'Address'),
];

class KgmsAdmission extends StatelessWidget {
  KgmsAdmission({Key key}) : super(key: key);

  final Map<String, dynamic> _studentData = {
    "stdName": '',
    "class": '',
    "section": '',
    "rollNo": '',
    "medium": 'English',
    "2ndLang": 'Bengali',
    "doa": '',
    "dob": '',
  };

  final Map<String, dynamic> _parentData = {
    "fatherName": '',
    "motherName": '',
    "lgName": '',
    "contact1": '',
    "contact2": '',
    "emailId": '',
  };

  final Map<String, dynamic> _accountData = {
    "address1": '',
    "address2": '',
    "amount": '',
    "admissionFee": '',
    "tuitionFee": '',
    "isInstallment": false,
  };

  void _clearKeyBoard(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _clearKeyBoard(context);
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Kgms Admission'),
              bottom: TabBar(
                tabs: tabs,
                indicatorColor: Colors.green,
                indicatorWeight: 2.5,
                onTap: (value) async {
                  //print('tabBar --> $value');
                  _clearKeyBoard(context);
                },
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.pending_actions, size: 30),
                    tooltip: 'pending admissions',
                    onPressed: () async {
                      _clearKeyBoard(context);
                      print('admission pending !');
                    },
                  ),
                ),
              ],
            ),
            body: Container(
              color: Colors.orange[300],
              alignment: Alignment.center,
              child: TabBarView(
                children: [
                  //Icon(Icons.directions_car),
                  _KgmsAdmissionStudentForm(
                      studentData: _studentData,
                      toggleToTab1: () async {
                        _clearKeyBoard(context);
                        tabController.animateTo(1);
                      }),
                  _KgmsAdmissionParentForm(
                      parentData: _parentData,
                      toggleToTab2: () async {
                        _clearKeyBoard(context);
                        tabController.animateTo(2);
                      }),
                  _KgmsAdmissionAddressForm(accountData: _accountData),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _KgmsAdmissionStudentForm extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final Function toggleToTab1;
  const _KgmsAdmissionStudentForm(
      {Key key, @required this.studentData, @required this.toggleToTab1})
      : super(key: key);

  @override
  _KgmsAdmissionStudentFormState createState() =>
      _KgmsAdmissionStudentFormState();
}

const List<String> _classNameList = [
  'Dolna Ghar',
  'O Group',
  'Nursery',
  'KG',
  'I (one)',
  'II (two)',
  'III (three)',
  'IV (four)'
];

const List<String> _sectionList = ['A', 'B', 'C', 'D', 'E', 'F'];

class _KgmsAdmissionStudentFormState extends State<_KgmsAdmissionStudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _stdNameCtrl = TextEditingController();

  String _classNameCtrl = null;
  String _sectionCtrl = null;
  final TextEditingController _stdRollNoCtrl = TextEditingController();
  bool _showDoa = false;
  bool _showDob = false;
  bool _showErrMsg = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() {
    _stdNameCtrl.text = widget.studentData['stdName'] as String;
    _stdNameCtrl.addListener(_updateLatestValue(_stdNameCtrl, 'stdName'));
    if (!widget.studentData['class'].toString().isEmpty) {
      _classNameCtrl = widget.studentData['class'] as String;
    }
    if (!widget.studentData['section'].toString().isEmpty) {
      _sectionCtrl = widget.studentData['section'] as String;
    }
    _stdRollNoCtrl.text = widget.studentData['rollNo'] as String;
    _stdRollNoCtrl.addListener(_updateLatestValue(_stdRollNoCtrl, 'rollNo'));
  }

  Function _updateLatestValue(TextEditingController tec, String dataKey) {
    Future<VoidCallback> addListenerToUpdate() async {
      if (tec.text != widget.studentData[dataKey].toString()) {
        //print('Std latest changed value --> ${tec.text}');
        widget.studentData[dataKey] = tec.text;
      }
    }

    return addListenerToUpdate;
  }

  @override
  void dispose() {
    _stdNameCtrl.dispose();
    _stdRollNoCtrl.dispose();
    super.dispose();
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

  Future<void> _getDate(
          BuildContext context, String dataKey, DateTime currentDate) =>
      DatePicker.showDatePicker(context,
          showTitleActions: true,
          minTime: DateTime(2005, 1, 1),
          maxTime: DateTime(2035, 12, 31),
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
          widget.studentData[dataKey] = dateStr;
        });
      }, currentTime: currentDate, locale: LocaleType.en);

  bool _isValidated() {
    bool isVal = true;
    if (!_formKey.currentState.validate()) {
      isVal = false;
    }
    if (widget.studentData['doa'].toString().isEmpty) {
      setState(() {
        _showDoa = true;
      });
      isVal = false;
    } else {
      setState(() {
        _showDoa = false;
      });
    }
    if (widget.studentData['dob'].toString().isEmpty) {
      setState(() {
        _showDob = true;
      });
      isVal = false;
    } else {
      setState(() {
        _showDob = false;
      });
    }
    if (isVal) {
      setState(() {
        _showErrMsg = false;
      });
    } else {
      setState(() {
        _showErrMsg = true;
      });
    }
    return isVal;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  /*Student name start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _stdNameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Student name cannot be empty !';
                      } else {
                        setState(() {
                          _stdNameCtrl.text = _formatName(_stdNameCtrl.text);
                        });
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Student name *',
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
                    // initialValue: widget.em.title,
                    // initialValue:
                    //     widget.document != null ? widget.document['header'] : '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      letterSpacing: 0.9,
                    ),
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Student name end*/,
                Padding(
                  /*Student class start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Select class *',
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
                        return 'Class cannot be empty !';
                      }
                      return null;
                    },
                    value: _classNameCtrl,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 10,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                    onChanged: ((String newValue) {
                      setState(() {
                        _classNameCtrl = newValue;
                        widget.studentData['class'] = newValue;
                      });
                    }),
                    items: _classNameList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ) /*Student class end*/,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        /*Student section start*/
                        //height: 65.0,
                        //width: 170.0,
                        width: MediaQuery.of(context).size.width * 0.48,
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            labelText: 'Select section *',
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
                              return 'Section empty !';
                            }
                            return null;
                          },
                          value: _sectionCtrl,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 10,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 17,
                          ),
                          onChanged: ((String newValue) {
                            setState(() {
                              _sectionCtrl = newValue;
                              widget.studentData['section'] = newValue;
                            });
                          }),
                          items: _sectionList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ) /*Student section end*/,
                      Spacer(),
                      Container(
                        /*Student roll no. start*/
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: TextFormField(
                          controller: _stdRollNoCtrl,
                          validator: (value) {
                            //if (value.isEmpty) {
                            //  return 'Roll no. empty !';
                            //}
                            if (!value.isEmpty && !_isNumFromString(value)) {
                              return 'not number !';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Roll no.',
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
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            letterSpacing: 0.9,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ], // Only numbers can be entered
                          //textInputAction: TextInputAction.next,
                          //onFieldSubmitted: (value) {
                          //  FocusScope.of(context).requestFocus(_subtitleFocus);
                          //},
                        ),
                      ) /*Student roll no. end*/,
                    ],
                  ),
                ),
                Padding(
                  /*Student medium start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      iconTag('@ Medium * ', Icons.palette_outlined, 7.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          LabelRadio<String>(
                            label: 'English',
                            widthPercent: 0.47,
                            groupValue: widget.studentData['medium'].toString(),
                            value: 'English',
                            onChanged: (String newValue) {
                              setState(() {
                                widget.studentData['medium'] = newValue;
                              });
                            },
                          ),
                          LabelRadio<String>(
                            label: 'Bengali',
                            widthPercent: 0.47,
                            groupValue: widget.studentData['medium'].toString(),
                            value: 'Bengali',
                            onChanged: (String newValue) {
                              setState(() {
                                widget.studentData['medium'] = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ) /*Student medium end*/,
                Padding(
                  /*Student 2nd language start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      iconTag('@ 2nd Language * ', Icons.language, 7.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          LabelRadio<String>(
                            label: 'Bengali',
                            widthPercent: 0.47,
                            groupValue:
                                widget.studentData['2ndLang'].toString(),
                            value: 'Bengali',
                            onChanged: (String newValue) {
                              setState(() {
                                widget.studentData['2ndLang'] = newValue;
                              });
                            },
                          ),
                          LabelRadio<String>(
                            label: 'Hindi',
                            widthPercent: 0.47,
                            groupValue:
                                widget.studentData['2ndLang'].toString(),
                            value: 'Hindi',
                            onChanged: (String newValue) {
                              setState(() {
                                widget.studentData['2ndLang'] = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ) /*Student 2nd language end*/,
                Padding(
                  /*Student DOA start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      iconTag('@ D.O.A * (dd/mm/yyyy)  ',
                          Icons.calendar_today_outlined, 19.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            /*Student roll no. start*/
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: RaisedButton.icon(
                              onPressed: () {
                                //print('get date !');
                                var dt = _getDateFromString(
                                    widget.studentData['doa']);
                                _getDate(context, 'doa', dt);
                              },
                              label: const Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 0.9,
                                ),
                              ),
                              icon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7.3),
                                child: const Icon(Icons.date_range_outlined,
                                    size: 22),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                side: BorderSide(
                                    color: _showDoa
                                        ? Colors.red
                                        : Colors.transparent),
                              ),
                              color: Colors.lightBlue,
                              //highlightColor: Colors.lightBlue,
                            ),
                          ),
                          Spacer(),
                          Container(
                            /*Student roll no. start*/
                            width: MediaQuery.of(context).size.width * 0.54,
                            child: Text(
                              '=    ${widget.studentData['doa'].toString().isEmpty ? 'none' : widget.studentData['doa'].toString()}',
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
                        visible: _showDoa,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12.0, top: 6.0),
                            child: Text('D.o.a cannot be empty !',
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
                ) /*Student DOA end*/,
                Padding(
                  /*Student DOB start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      iconTag('@ D.O.B * (dd/mm/yyyy)  ',
                          Icons.calendar_today_outlined, 19.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            /*Student roll no. start*/
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: RaisedButton.icon(
                              onPressed: () async {
                                //print('get date !');
                                var dt = _getDateFromString(
                                    widget.studentData['dob']);
                                _getDate(context, 'dob', dt);
                              },
                              label: const Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              icon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7.3),
                                child: const Icon(Icons.date_range_outlined,
                                    size: 22),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                side: BorderSide(
                                    color: _showDob
                                        ? Colors.red
                                        : Colors.transparent),
                              ),
                              color: Colors.lightBlue,
                            ),
                          ),
                          Spacer(),
                          Container(
                            /*Student roll no. start*/
                            width: MediaQuery.of(context).size.width * 0.54,
                            child: Text(
                              '=    ${widget.studentData['dob'].toString().isEmpty ? 'none' : widget.studentData['dob'].toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: _showDob,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12.0, top: 6.0),
                            child: Text('D.o.b cannot be empty !',
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
                ) /*Student DOB end*/,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Visibility(
                          visible: _showErrMsg,
                          child: const Text(
                            '** Error found above',
                            style: TextStyle(
                              fontSize: 16.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: RaisedButton.icon(
                          /*Next button start*/
                          onPressed: () async {
                            //if (_formKey.currentState.validate()) {
                            //  //print('next to parent section !');
                            //  //print('student name --> ${_stdNameCtrl.text}');
                            //  //print('std class --> $_classNameCtrl');
                            //  //print('std section --> $_sectionCtrl');
                            //  //print('std roll no. --> ${_stdRollNoCtrl.text}');
                            //  //widget.toggleToTab1();

                            //  if(!widget.studentData['doa'].toString().isEmpty && !widget.studentData['dob'].toString().isEmpty) {
                            //    print(widget.studentData.toString());
                            //  }
                            //}
                            if (_isValidated()) {
                              print(widget.studentData.toString());
                              widget.toggleToTab1();
                            }
                          },
                          label: const Text(
                            'Next',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Icon(Icons.navigate_next_outlined,
                                size: 25),
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          splashColor: Colors.yellow,
                          color: Colors.green,
                        ) /*Next button end*/,
                      ),
                    ],
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

class _KgmsAdmissionParentForm extends StatefulWidget {
  final Map<String, dynamic> parentData;
  final Function toggleToTab2;
  const _KgmsAdmissionParentForm(
      {Key key, @required this.parentData, @required this.toggleToTab2})
      : super(key: key);

  @override
  _KgmsAdmissionParentFormState createState() =>
      _KgmsAdmissionParentFormState();
}

class _KgmsAdmissionParentFormState extends State<_KgmsAdmissionParentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fatherNameCtrl = TextEditingController();
  final TextEditingController _motherNameCtrl = TextEditingController();
  final TextEditingController _lgNameCtrl = TextEditingController();
  final TextEditingController _contact1Ctrl = TextEditingController();
  final TextEditingController _contact2Ctrl = TextEditingController();
  final TextEditingController _emailIdCtrl = TextEditingController();

  bool _showErrMsg = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() {
    _fatherNameCtrl.text = widget.parentData['fatherName'] as String;
    _fatherNameCtrl
        .addListener(_updateLatestValue(_fatherNameCtrl, 'fatherName'));
    _motherNameCtrl.text = widget.parentData['motherName'] as String;
    _motherNameCtrl
        .addListener(_updateLatestValue(_motherNameCtrl, 'motherName'));
    _lgNameCtrl.text = widget.parentData['lgName'] as String;
    _lgNameCtrl.addListener(_updateLatestValue(_lgNameCtrl, 'lgName'));
    _contact1Ctrl.text = widget.parentData['contact1'] as String;
    _contact1Ctrl.addListener(_updateLatestValue(_contact1Ctrl, 'contact1'));
    _contact2Ctrl.text = widget.parentData['contact2'] as String;
    _contact2Ctrl.addListener(_updateLatestValue(_contact2Ctrl, 'contact2'));
    _emailIdCtrl.text = widget.parentData['emailId'] as String;
    _emailIdCtrl.addListener(_updateLatestValue(_emailIdCtrl, 'emailId'));
  }

  Function _updateLatestValue(TextEditingController tec, String dataKey) {
    Future<VoidCallback> addListenerToUpdate() async {
      if (tec.text != widget.parentData[dataKey].toString()) {
        //print('Std latest changed value --> ${tec.text}');
        widget.parentData[dataKey] = tec.text;
      }
    }

    return addListenerToUpdate;
  }

  _formatText(TextEditingController tec) {
    setState(() {
      tec.text = _formatName(tec.text);
    });
  }

  @override
  void dispose() {
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _lgNameCtrl.dispose();
    _contact1Ctrl.dispose();
    _contact2Ctrl.dispose();
    _emailIdCtrl.dispose();
    super.dispose();
  }

  bool _isValidated() {
    if (_formKey.currentState.validate()) {
      setState(() {
        _showErrMsg = false;
      });
      return true;
    } else {
      setState(() {
        _showErrMsg = true;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  /*Father name start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _fatherNameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Father name cannot be empty !';
                      } else {
                        _formatText(_fatherNameCtrl);
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Father name *',
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
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Father name end*/,
                Padding(
                  /*Mother name start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _motherNameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Mother name cannot be empty !';
                      } else {
                        _formatText(_motherNameCtrl);
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Mother name *',
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
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Mother name end*/,
                Padding(
                  /*Local guardian name start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _lgNameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Local guardian name cannot be empty !';
                      } else {
                        _formatText(_lgNameCtrl);
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Local guardian name *',
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
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Local guardian name end*/,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        /*Contact 1 start*/
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: TextFormField(
                          controller: _contact1Ctrl,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Contact 1 empty !';
                            } else if (!_isNumFromString(value)) {
                              return 'not number !';
                            } else if (value.length != 10) {
                              return 'not 10 digits !';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Contact 1 *',
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
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            letterSpacing: 0.9,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ], // Only numbers can be entered
                          //textInputAction: TextInputAction.next,
                          //onFieldSubmitted: (value) {
                          //  FocusScope.of(context).requestFocus(_subtitleFocus);
                          //},
                        ),
                      ) /*Contact 1 end*/,
                      Spacer(),
                      Container(
                        /*Contact 2 start*/
                        width: MediaQuery.of(context).size.width * 0.428,
                        child: TextFormField(
                          controller: _contact2Ctrl,
                          validator: (value) {
                            if (!value.isEmpty) {
                              if (!_isNumFromString(value)) {
                                return 'not number !';
                              } else if (value.length < 6) {
                                return 'too less !';
                              }
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Contact 2',
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
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            letterSpacing: 0.9,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ], // Only numbers can be entered
                          //textInputAction: TextInputAction.next,
                          //onFieldSubmitted: (value) {
                          //  FocusScope.of(context).requestFocus(_subtitleFocus);
                          //},
                        ),
                      ) /*Contact 2 end*/,
                    ],
                  ),
                ),
                Padding(
                  /*email id start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _emailIdCtrl,
                    validator: (value) {
                      if (!value.isEmpty && !EmailValidator.validate(value)) {
                        return 'not a valid email id or can be empty !';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email id',
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
                    keyboardType: TextInputType.emailAddress,
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*email id end*/,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Visibility(
                          visible: _showErrMsg,
                          child: const Text(
                            '** Error found above',
                            style: TextStyle(
                              fontSize: 16.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: RaisedButton.icon(
                          onPressed: () async {
                            if (_isValidated()) {
                              //print('next to parent section !');
                              //print('parent name --> ${_fatherNameCtrl.text}');
                              print(widget.parentData.toString());
                              widget.toggleToTab2();
                            }
                          },
                          label: const Text(
                            'Next',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Icon(Icons.navigate_next_outlined,
                                size: 25),
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          splashColor: Colors.yellow,
                          color: Colors.green,
                        ),
                      ),
                    ],
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

class _KgmsAdmissionAddressForm extends StatefulWidget {
  final Map<String, dynamic> accountData;
  const _KgmsAdmissionAddressForm({Key key, @required this.accountData})
      : super(key: key);

  @override
  _KgmsAdmissionAddressFormState createState() =>
      _KgmsAdmissionAddressFormState();
}

class _KgmsAdmissionAddressFormState extends State<_KgmsAdmissionAddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _address1Ctrl = TextEditingController();
  final TextEditingController _address2Ctrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _admissionFeeCtrl = TextEditingController();
  final TextEditingController _tuitionFeeCtrl = TextEditingController();

  bool _showErrMsg = false;
  bool _isInstallment = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() {
    _address1Ctrl.text = widget.accountData['address1'] as String;
    _address1Ctrl.addListener(_updateLatestValue(_address1Ctrl, 'address1'));
    _address2Ctrl.text = widget.accountData['address2'] as String;
    _address2Ctrl.addListener(_updateLatestValue(_address2Ctrl, 'address2'));
    _amountCtrl.text = widget.accountData['amount'] as String;
    _amountCtrl.addListener(_updateLatestValue(_amountCtrl, 'amount'));
    _admissionFeeCtrl.text = widget.accountData['admissionFee'] as String;
    _admissionFeeCtrl
        .addListener(_updateLatestValue(_admissionFeeCtrl, 'admissionFee'));
    _tuitionFeeCtrl.text = widget.accountData['tuitionFee'] as String;
    _tuitionFeeCtrl
        .addListener(_updateLatestValue(_tuitionFeeCtrl, 'tuitionFee'));
    _isInstallment = widget.accountData['isInstallment'] as bool;
  }

  Function _updateLatestValue(TextEditingController tec, String dataKey) {
    Future<VoidCallback> addListenerToUpdate() async {
      if (tec.text != widget.accountData[dataKey].toString()) {
        //print('Std latest changed value --> ${tec.text}');
        widget.accountData[dataKey] = tec.text;
      }
    }

    return addListenerToUpdate;
  }

  _formatText(TextEditingController tec) {
    setState(() {
      tec.text = _formatName(tec.text);
    });
  }

  @override
  void dispose() {
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _amountCtrl.dispose();
    _admissionFeeCtrl.dispose();
    _tuitionFeeCtrl.dispose();
    super.dispose();
  }

  bool _isValidated() {
    if (_formKey.currentState.validate()) {
      setState(() {
        _showErrMsg = false;
      });
      return true;
    } else {
      setState(() {
        _showErrMsg = true;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  /*Address 1 start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _address1Ctrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Address 1 cannot be empty !';
                      } else {
                        _formatText(_address1Ctrl);
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Address 1 *',
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
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Address 1 end*/,
                Padding(
                  /*Address 2 start*/
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextFormField(
                    controller: _address2Ctrl,
                    validator: (value) {
                      if (!value.isEmpty) {
                        _formatText(_address2Ctrl);
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Address 2',
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
                    //textInputAction: TextInputAction.next,
                    //onFieldSubmitted: (value) {
                    //  FocusScope.of(context).requestFocus(_subtitleFocus);
                    //},
                  ),
                ) /*Address 2 end*/,
                Visibility(
                  /*Fee Amount start*/
                  visible: !_isInstallment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: TextFormField(
                      controller: _amountCtrl,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Amount cannot be empty !';
                        } else if (!_isNumFromString(value)) {
                          return 'not number !';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
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
                      //textInputAction: TextInputAction.next,
                      //onFieldSubmitted: (value) {
                      //  FocusScope.of(context).requestFocus(_subtitleFocus);
                      //},
                    ),
                  ),
                ) /*Fee Amount end*/,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        //timeDilation = value ? 3 : 1.0;
                        //timeDilation != 1.0,
                        _isInstallment = value;
                        widget.accountData['isInstallment'] = value;
                      });
                    },
                    secondary: const Icon(Icons.fact_check),
                    activeColor: Colors.lightBlue[600],
                    dense: true,
                  ),
                ),
                Visibility(
                  visible: _isInstallment,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        /*Admission fee start*/
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: TextFormField(
                          controller: _admissionFeeCtrl,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Admission fee cannot be empty !';
                            } else if (!_isNumFromString(value)) {
                              return 'not number !';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Admission fee *',
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
                          //textInputAction: TextInputAction.next,
                          //onFieldSubmitted: (value) {
                          //  FocusScope.of(context).requestFocus(_subtitleFocus);
                          //},
                        ),
                      ) /*Admission fee end*/,
                      Padding(
                        /*Tuition fee start*/
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: TextFormField(
                          controller: _tuitionFeeCtrl,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Tuition fee cannot be empty !';
                            } else if (!_isNumFromString(value)) {
                              return 'not number !';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Tuition fee *',
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
                          //textInputAction: TextInputAction.next,
                          //onFieldSubmitted: (value) {
                          //  FocusScope.of(context).requestFocus(_subtitleFocus);
                          //},
                        ),
                      ) /*Tuition fee end*/,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Visibility(
                          visible: _showErrMsg,
                          child: const Text(
                            '** Error found above',
                            style: TextStyle(
                              fontSize: 16.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: RaisedButton.icon(
                          onPressed: () async {
                            if (_isValidated()) {
                              //print('next to parent section !');
                              //print('parent name --> ${_fatherNameCtrl.text}');
                              //widget.toggleToTab2();
                              print(widget.accountData.toString());
                            }
                          },
                          label: const Text(
                            'Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Icon(Icons.save, size: 25),
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          splashColor: Colors.yellow,
                          color: Colors.green,
                        ),
                      ),
                    ],
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

class LabelRadio<T> extends StatelessWidget {
  final String label;
  final double widthPercent;
  final T groupValue;
  final T value;
  final Function onChanged;
  const LabelRadio(
      {Key key,
      @required this.label,
      @required this.widthPercent,
      @required this.groupValue,
      @required this.value,
      @required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * widthPercent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio<T>(
              groupValue: groupValue,
              value: value,
              onChanged: (T newValue) {
                onChanged(newValue);
              },
              activeColor: Colors.lightBlue[600],
            ),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                letterSpacing: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatName(String name) {
  var opera = name.trim().split(' ');
  if (opera.length > 1) {
    final List<String> _li = [];
    opera.forEach((item) {
      if (item.replaceAll(RegExp(r'/\s/g'), '').length > 0) {
        _li.add(_upperCaseFirstLetter(item.toLowerCase()));
      }
    });
    return _li.join(' ');
  } else {
    return _upperCaseFirstLetter(name.toString().toLowerCase());
  }
}

String _upperCaseFirstLetter(String str) {
  return str[0].toUpperCase() + str.substring(1);
}

bool _isNumFromString(String s) => int.tryParse(s) != null;

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

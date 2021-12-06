import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'dart:async';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show DatePickerTheme, DatePicker, LocaleType;
import 'package:email_validator/email_validator.dart';
//import 'self.dart';
import 'src/kUtil.dart';
import 'src/firestoreService.dart';
import 'src/localFileStorageService.dart';
import 'src/localDataStoreService.dart';
import 'dart:convert' as convert;
//import 'package:flutter/scheduler.dart' show timeDilation;
//import 'package:cloud_firestore/cloud_firestore.dart';

const List<Tab> tabs = <Tab>[
  Tab(icon: Icon(Icons.face_unlock_outlined), text: 'Student'),
  Tab(icon: Icon(Icons.person_outline), text: 'Parent'),
  Tab(icon: Icon(Icons.house_outlined), text: 'Address'),
];

class _AdmissionStudentData {
  static _AdmissionStudentData _instance;

  _AdmissionStudentData._internal() {
    _instance = this;
  }

  factory _AdmissionStudentData() =>
      _instance ?? _AdmissionStudentData._internal();

  final Map<String, dynamic> _studentData = {
    "stdName": '',
    "class": '',
    "classId": '',
    "classIndex": '',
    "section": '',
    "rollNo": '',
    "medium": 'English',
    "2ndLang": 'Bengali',
    "doa": '',
    "dob": '',
    "password": '',
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
    'forMonthYear': '',
  };

  Map<String, dynamic> get studentData => _studentData;
  Map<String, dynamic> get parentData => _parentData;
  Map<String, dynamic> get accountData => _accountData;

  Future<void> resetData() async {
    ////print('reset admission student data !');
    _studentData.updateAll((k, v) {
      if (k == 'medium') {
        return 'English';
      } else if (k == '2ndLang') {
        return 'Bengali';
      } else {
        return '';
      }
    });
    _parentData.updateAll((k, v) {
      return '';
    });
    _accountData.updateAll((k, v) {
      if (k == 'isInstallment') {
        return false;
      } else {
        return '';
      }
    });
    if (resetCurrentForm != null) resetCurrentForm();
    _admissionConfig['isEdit'] = false;
    _admissionConfig['studentId'] = '';
  }

  Function resetCurrentForm;
  Function reloadCurrentForm;

  Future<void> setData(Map stdData, Map prtData, Map accData, String id) async {
    //print('std data --> ${stdData.toString()}');
    _studentData.updateAll((k, v) {
      if (stdData.containsKey(k))
        return stdData[k];
      else {
        if (k == 'medium') {
          return 'English';
        } else if (k == '2ndLang') {
          return 'Bengali';
        } else {
          return '';
        }
      }
    });
    _parentData.updateAll((k, v) {
      if (prtData.containsKey(k))
        return prtData[k];
      else
        return '';
    });
    _accountData.updateAll((k, v) {
      if (accData.containsKey(k))
        return accData[k];
      else {
        if (k == 'isInstallment') {
          return false;
        } else {
          return '';
        }
      }
    });
    if (reloadCurrentForm != null) reloadCurrentForm();
    _admissionConfig['isEdit'] = true;
    _admissionConfig['studentId'] = id;
  }

  final Map<String, dynamic> _admissionConfig = {
    'isEdit': false,
    'studentId': '',
  };

  Map<String, dynamic> get admissionConfig => _admissionConfig;

  Future<void> setDataForEdit(Map stdData) async {
    ////print('edit data --> $stdData');
    _studentData.updateAll((k, v) {
      if (stdData.containsKey(k))
        return stdData[k];
      else
        return '';
    });

    _parentData.updateAll((k, v) {
      if (stdData.containsKey(k))
        return stdData[k];
      else
        return '';
    });

    _accountData.updateAll((k, v) {
      if (stdData.containsKey(k))
        return stdData[k];
      else {
        if (k == 'isInstallment') {
          return false;
        } else {
          return '';
        }
      }
    });

    if (reloadCurrentForm != null) reloadCurrentForm();
  }
}

class KgmsAdmission extends StatefulWidget {
  final Map studentEditData;
  const KgmsAdmission({Key key, this.studentEditData = null}) : super(key: key);

  @override
  KgmsAdmissionState createState() => KgmsAdmissionState();
}

class KgmsAdmissionState extends State<KgmsAdmission> {
  bool isStudentEdit;

  @override
  void initState() {
    super.initState();
    if (widget.studentEditData != null)
      _admissionData.setDataForEdit(widget.studentEditData);
    isStudentEdit = widget.studentEditData == null ? false : true;
  }

  _AdmissionStudentData get _admissionData => _AdmissionStudentData();

  AlertDialog _resetFormAlertW(
          BuildContext context, TabController tabController) =>
      AlertDialog(
        title: const Text(
            'Are you sure to reset the admission form (clear all data) ?'),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        titleTextStyle: const TextStyle(
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
              ////print('reset admission form');
              _admissionData
                  .resetData()
                  .then((_) => tabController.animateTo(0));
              Navigator.pop(context);
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

  //void _clearKeyBoardFromParent(BuildContext context) async {
  //  FocusScopeNode currentFocus = FocusScope.of(context);
  //  if (!currentFocus.hasPrimaryFocus) {
  //    currentFocus.unfocus();
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        clearKeyBoard(context);
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(isStudentEdit ? 'Edit student' : 'Admission'),
              bottom: TabBar(
                tabs: tabs,
                indicatorColor: Colors.green,
                indicatorWeight: 2.5,
                onTap: (value) async {
                  ////print('tabBar --> $value');
                  clearKeyBoard(context);
                },
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 24,
                tooltip: 'back',
                onPressed: () {
                  ////print('back');
                  Navigator.pop(context);
                  if (isStudentEdit) _admissionData.resetData();
                },
              ),
              actions: isStudentEdit
                  ? null
                  : <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon:
                              const Icon(Icons.restore_page_outlined, size: 30),
                          tooltip: 'reset admissions',
                          onPressed: () async {
                            ////print('reset admissions !');
                            animatedCustomNonDismissibleAlert(context,
                                _resetFormAlertW(context, tabController));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.pending_actions, size: 30),
                          tooltip: 'pending admissions',
                          onPressed: () async {
                            clearKeyBoard(context);
                            ////print('admission pending !');
                            animatedCustomNonDismissibleAlert(context,
                                _PendingStudentListFromStorage(onEditStudent:
                                    (Map<String, dynamic> editData,
                                        String stdId) {
                              //print('pass params edit student --> ${editData.toString()}');
                              _admissionData.setData(
                                  editData['studentData'],
                                  editData['parentData'],
                                  editData['accountData'],
                                  stdId);
                            }));
                            //dataStoreServ.getPendingAdmissions().then((res) => //print('pending list --> ${res.toString()}'));
                          },
                        ),
                      ),
                    ],
            ),
            body: Container(
              color: Colors.orange[300],
              alignment: Alignment.center,
              child: Theme(
                data: ThemeData(
                  primaryColor: Colors.blueAccent,
                ),
                child: TabBarView(
                  children: [
                    //Icon(Icons.directions_car),
                    _KgmsAdmissionStudentForm(
                        studentData: _admissionData.studentData,
                        toggleToTab1: () async {
                          clearKeyBoard(context);
                          tabController.animateTo(1);
                        },
                        clearUiForm: (Function x) {
                          _admissionData.resetCurrentForm = x;
                        },
                        reloadUiForm: (Function x) {
                          _admissionData.reloadCurrentForm = x;
                        }),
                    _KgmsAdmissionParentForm(
                        parentData: _admissionData.parentData,
                        toggleToTab2: () async {
                          clearKeyBoard(context);
                          tabController.animateTo(2);
                        },
                        clearUiForm: (Function x) {
                          _admissionData.resetCurrentForm = x;
                        },
                        reloadUiForm: (Function x) {
                          _admissionData.reloadCurrentForm = x;
                        }),
                    _KgmsAdmissionAddressForm(
                        accountData: _admissionData.accountData,
                        clearUiForm: (Function x) {
                          _admissionData.resetCurrentForm = x;
                        },
                        reloadUiForm: (Function x) {
                          _admissionData.reloadCurrentForm = x;
                        },
                        isAllFormDataValid: () {
                          //var res = await _isAllFormsValid(_admissionData.studentData, _admissionData.parentData);
                          return _isAllFormsValid(_admissionData.studentData,
                              _admissionData.parentData);
                        },
                        getPartId: () {
                          var numPart = _admissionData.parentData['contact1']
                              .toString()
                              .substring(4, 10);
                          var strPart = _getNamePart(
                              _admissionData.studentData['stdName'].toString());
                          return <String, String>{
                            "numPart": numPart,
                            "strPart": strPart
                          };
                        },
                        saveAdmission: (String pId) {
                          //return dataStoreServ.insertNewAdmission(
                          //    studentData: _admissionData.studentData,
                          //    parentData: _admissionData.parentData,
                          //    accountData: _admissionData.accountData,
                          //    feeStruct: feeStruct,
                          //    studentId: pId);
                          return dataStoreServ.insertNewAdmissionLocal(
                              studentData: _admissionData.studentData,
                              parentData: _admissionData.parentData,
                              accountData: _admissionData.accountData,
                              studentId: pId);
                        },
                        onSuccessfulSave: () {
                          _admissionData.resetData().then((_) {
                            tabController.animateTo(0);
                            Future.delayed(
                                const Duration(milliseconds: 950),
                                () => ScaffoldMessenger.of(context)
                                    .showSnackBar(kSnackbar(
                                        'Admission saved successfully !')));
                          });
                          //ScaffoldMessenger.of(context).showSnackBar(kSnackbar('Admission saved successfully !'));
                        },
                        isAdmissionConfig: _admissionData.admissionConfig,
                        isOnStudentEdit: isStudentEdit,
                        isDataChangedToEdit: () {
                          return _isDataChangedToEdit(
                              widget.studentEditData,
                              _admissionData.studentData,
                              _admissionData.parentData,
                              _admissionData.accountData);
                        },
                        saveUpdate: (Map studentUpdates) {
                          return _updateStudentDetailsToCloud(
                              studentUpdates,
                              widget.studentEditData['studentInfoKey'],
                              widget.studentEditData['studentMoreInfoKey']);
                        },
                        resetForm: () {
                          _admissionData.resetData();
                        }),
                  ],
                ),
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
  final Function(Function) clearUiForm;
  final Function(Function) reloadUiForm;
  const _KgmsAdmissionStudentForm(
      {Key key,
      @required this.studentData,
      @required this.toggleToTab1,
      @required this.clearUiForm,
      @required this.reloadUiForm})
      : super(key: key);

  @override
  _KgmsAdmissionStudentFormState createState() =>
      _KgmsAdmissionStudentFormState();
}

//const List<String> _classNameList = [
//  'Dolna Ghar',
//  'O Group',
//  'Nursery',
//  'KG',
//  'I (one)',
//  'II (two)',
//  'III (three)',
//  'IV (four)'
//];
Function _updateLatestValue(
    TextEditingController tec, String dataKey, Map<String, dynamic> dataMap) {
  Future<VoidCallback> addListenerToUpdate() async {
    if (tec.text != dataMap[dataKey].toString()) {
      ////print('Std latest changed value --> ${tec.text}');
      dataMap[dataKey] = tec.text;
    }
  }

  return addListenerToUpdate;
}

const List<String> _sectionList = ['A', 'B', 'C', 'D', 'E', 'F'];

class _KgmsAdmissionStudentFormState extends State<_KgmsAdmissionStudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _stdNameCtrl = TextEditingController();

  //String _classNameCtrl = null;
  int _classNameCtrl = null;
  String _sectionCtrl = null;
  final TextEditingController _stdRollNoCtrl = TextEditingController();
  bool _showDoa = false;
  bool _showDob = false;
  bool _showErrMsg = false;

  final List<Map<String, String>> _classNameList = [];

  @override
  void initState() {
    super.initState();
    _init();
    Future.delayed(const Duration(milliseconds: 1800), () {
      firestoreServ.getClassesAndIds().then((result) {
        if (mounted) {
          setState(() {
            //result.forEach((resMap) {
            //  _classNameList.add(resMap);
            //});
            _classNameList.addAll(result);
            if (_classNameCtrl == null &&
                !widget.studentData['classId'].toString().isEmpty) {
              for (var classItem in _classNameList) {
                if (classItem['classId'] ==
                    widget.studentData['classId'].toString()) {
                  _classNameCtrl = _classNameList.indexOf(classItem);
                  widget.studentData['classIndex'] = _classNameCtrl;
                  break;
                }
              }
            }
          });
        }
      });
    });
  }

  Future<void> _init() async {
    _stdNameCtrl.text = widget.studentData['stdName'] as String;
    _stdNameCtrl.addListener(
        _updateLatestValue(_stdNameCtrl, 'stdName', widget.studentData));
    if (!widget.studentData['classIndex'].toString().isEmpty) {
      _classNameCtrl = widget.studentData['classIndex'] as int;
    }
    if (!widget.studentData['section'].toString().isEmpty) {
      _sectionCtrl = widget.studentData['section'] as String;
    }
    _stdRollNoCtrl.text = widget.studentData['rollNo'] as String;
    _stdRollNoCtrl.addListener(
        _updateLatestValue(_stdRollNoCtrl, 'rollNo', widget.studentData));
    widget.clearUiForm(clearStudentForm);
    widget.reloadUiForm(reloadStudentForm);
  }

  //Function _updateLatestValue(TextEditingController tec, String dataKey) {
  //  Future<VoidCallback> addListenerToUpdate() async {
  //    if (tec.text != widget.studentData[dataKey].toString()) {
  //      ////print('Std latest changed value --> ${tec.text}');
  //      widget.studentData[dataKey] = tec.text;
  //    }
  //  }

  //  return addListenerToUpdate;
  //}

  @override
  void dispose() {
    _stdNameCtrl.dispose();
    _stdRollNoCtrl.dispose();
    super.dispose();
  }

  void reloadStudentForm() {
    if (mounted) {
      setState(() {
        _stdNameCtrl.text = widget.studentData['stdName'] as String;
        _stdRollNoCtrl.text = widget.studentData['rollNo'] as String;
        if (!widget.studentData['classIndex'].toString().isEmpty) {
          _classNameCtrl = widget.studentData['classIndex'] as int;
        }
        if (!widget.studentData['section'].toString().isEmpty) {
          _sectionCtrl = widget.studentData['section'] as String;
        }
        _showErrMsg = false;
      });
    }
  }

  void clearStudentForm() {
    //print('clear form _KgmsAdmissionStudentFormState !');
    if (mounted) {
      setState(() {
        _stdNameCtrl.text = widget.studentData['stdName'] as String;
        _classNameCtrl = null;
        _sectionCtrl = null;
        _stdRollNoCtrl.text = widget.studentData['rollNo'] as String;
        _showErrMsg = false;
      });
    }
  }

  //iconTag(String label, IconData icon, double bottomValue) => Padding(
  //      padding: EdgeInsets.only(bottom: bottomValue),
  //      child: Row(
  //        children: <Widget>[
  //          Text(
  //            label,
  //            style: TextStyle(
  //              fontSize: 17,
  //              letterSpacing: 0.9,
  //            ),
  //          ),
  //          Icon(
  //            icon,
  //            color: Colors.black54,
  //          ),
  //        ],
  //      ),
  //    );

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
        ////print('confirm $date');
        var dayStr =
            date.day < 10 ? '0${date.day.toString()}' : date.day.toString();
        var monthStr = date.month < 10
            ? '0${date.month.toString()}'
            : date.month.toString();
        var dateStr = '${dayStr}/${monthStr}/${date.year.toString()}';
        ////print('date selected --> $dateStr');
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
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 10,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                    onChanged: ((newValueIndex) {
                      setState(() {
                        //_classNameCtrl = newValue;
                        //widget.studentData['class'] = newValue;
                        //_classNameCtrl =
                        //    _classNameList[newValueIndex]['className'];
                        _classNameCtrl = newValueIndex;
                        widget.studentData['class'] =
                            _classNameList[newValueIndex]['className'];
                        widget.studentData['classId'] =
                            _classNameList[newValueIndex]['classId'];
                        widget.studentData['classIndex'] = newValueIndex;
                      });
                    }),
                    onTap: () async {
                      clearKeyBoard(context);
                    },
                    //items: _classNameList
                    //    .map<DropdownMenuItem<String>>((String value) {
                    //  return DropdownMenuItem<String>(
                    //    value: value,
                    //    child: Text(
                    //      value,
                    //      style: const TextStyle(
                    //        color: Colors.purple,
                    //      ),
                    //    ),
                    //  );
                    //}).toList(),
                    items: _classNameList.map<DropdownMenuItem<int>>(
                        (Map<String, String> value) {
                      return DropdownMenuItem<int>(
                        value: _classNameList.indexOf(value),
                        child: Text(
                          value['className'],
                          style: const TextStyle(
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
                          icon: const Icon(Icons.arrow_downward),
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
                          onTap: () async {
                            clearKeyBoard(context);
                          },
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
                            if (!value.isEmpty && !isNumFromString(value)) {
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
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                ////print('get date !');
                                clearKeyBoard(context);
                                var dt = getDateFromString(
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
                                      color: _showDoa
                                          ? Colors.red
                                          : Colors.transparent),
                                )),
                              ),
                              //shape: RoundedRectangleBorder(
                              //  borderRadius:
                              //      const BorderRadius.all(Radius.circular(8)),
                              //  side: BorderSide(
                              //      color: _showDoa
                              //          ? Colors.red
                              //          : Colors.transparent),
                              //),
                              //color: Colors.lightBlue,
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
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                ////print('get date !');
                                clearKeyBoard(context);
                                var dt = getDateFromString(
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
                                      color: _showDob
                                          ? Colors.red
                                          : Colors.transparent),
                                )),
                              ),
                              //shape: RoundedRectangleBorder(
                              //  borderRadius:
                              //      const BorderRadius.all(Radius.circular(8)),
                              //  side: BorderSide(
                              //      color: _showDob
                              //          ? Colors.red
                              //          : Colors.transparent),
                              //),
                              //color: Colors.lightBlue,
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
                        child: ElevatedButton.icon(
                          /*Next button start*/
                          onPressed: () async {
                            //if (_formKey.currentState.validate()) {
                            //  ////print('next to parent section !');
                            //  ////print('student name --> ${_stdNameCtrl.text}');
                            //  ////print('std class --> $_classNameCtrl');
                            //  ////print('std section --> $_sectionCtrl');
                            //  ////print('std roll no. --> ${_stdRollNoCtrl.text}');
                            //  //widget.toggleToTab1();

                            //  if(!widget.studentData['doa'].toString().isEmpty && !widget.studentData['dob'].toString().isEmpty) {
                            //    //print(widget.studentData.toString());
                            //  }
                            //}
                            clearKeyBoard(context);
                            if (_isValidated()) {
                              widget.studentData['password'] = _getStdPassword(
                                  widget.studentData['stdName'].toString(),
                                  widget.studentData['dob'].toString());
                              ////print(widget.studentData.toString());
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
                          icon: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Icon(Icons.navigate_next_outlined, size: 25),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black87),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            )),
                          ),
                          //shape: const RoundedRectangleBorder(
                          //  borderRadius: BorderRadius.all(Radius.circular(8)),
                          //),
                          //splashColor: Colors.yellow,
                          //color: Colors.green,
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
  final Function(Function) clearUiForm;
  final Function(Function) reloadUiForm;
  const _KgmsAdmissionParentForm(
      {Key key,
      @required this.parentData,
      @required this.toggleToTab2,
      @required this.clearUiForm,
      @required this.reloadUiForm})
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

  final _motherNameNode = FocusNode();
  final _lgNameNode = FocusNode();
  final _contact1Node = FocusNode();
  final _contact2Node = FocusNode();
  final _emailIdNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _fatherNameCtrl.text = widget.parentData['fatherName'] as String;
    _fatherNameCtrl.addListener(
        _updateLatestValue(_fatherNameCtrl, 'fatherName', widget.parentData));
    _motherNameCtrl.text = widget.parentData['motherName'] as String;
    _motherNameCtrl.addListener(
        _updateLatestValue(_motherNameCtrl, 'motherName', widget.parentData));
    _lgNameCtrl.text = widget.parentData['lgName'] as String;
    _lgNameCtrl.addListener(
        _updateLatestValue(_lgNameCtrl, 'lgName', widget.parentData));
    _contact1Ctrl.text = widget.parentData['contact1'] as String;
    _contact1Ctrl.addListener(
        _updateLatestValue(_contact1Ctrl, 'contact1', widget.parentData));
    _contact2Ctrl.text = widget.parentData['contact2'] as String;
    _contact2Ctrl.addListener(
        _updateLatestValue(_contact2Ctrl, 'contact2', widget.parentData));
    _emailIdCtrl.text = widget.parentData['emailId'] as String;
    _emailIdCtrl.addListener(
        _updateLatestValue(_emailIdCtrl, 'emailId', widget.parentData));
    widget.clearUiForm(clearParentForm);
    widget.reloadUiForm(clearParentForm);
  }

  //Function _updateLatestValue(TextEditingController tec, String dataKey) {
  //  Future<VoidCallback> addListenerToUpdate() async {
  //    if (tec.text != widget.parentData[dataKey].toString()) {
  //      ////print('Std latest changed value --> ${tec.text}');
  //      widget.parentData[dataKey] = tec.text;
  //    }
  //  }

  //  return addListenerToUpdate;
  //}

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

  void clearParentForm() {
    //print('clear form _KgmsAdmissionParentFormState !');
    if (mounted) {
      setState(() {
        _fatherNameCtrl.text = widget.parentData['fatherName'] as String;
        _motherNameCtrl.text = widget.parentData['motherName'] as String;
        _lgNameCtrl.text = widget.parentData['lgName'] as String;
        _contact1Ctrl.text = widget.parentData['contact1'] as String;
        _contact2Ctrl.text = widget.parentData['contact2'] as String;
        _emailIdCtrl.text = widget.parentData['emailId'] as String;
      });
    }
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
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_motherNameNode);
                    },
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
                    focusNode: _motherNameNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_lgNameNode);
                    },
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
                    focusNode: _lgNameNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_contact1Node);
                    },
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
                            } else if (!isNumFromString(value)) {
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
                          focusNode: _contact1Node,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_contact2Node);
                          },
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
                              if (!isNumFromString(value)) {
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
                          focusNode: _contact2Node,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_emailIdNode);
                          },
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
                    focusNode: _emailIdNode,
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
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            clearKeyBoard(context);
                            if (_isValidated()) {
                              ////print('next to parent section !');
                              ////print('parent name --> ${_fatherNameCtrl.text}');
                              ////print(widget.parentData.toString());
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
                          icon: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Icon(Icons.navigate_next_outlined, size: 25),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black87),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            )),
                          ),
                          //shape: const RoundedRectangleBorder(
                          //  borderRadius: BorderRadius.all(Radius.circular(8)),
                          //),
                          //splashColor: Colors.yellow,
                          //color: Colors.green,
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
  final Function(Function) clearUiForm;
  final Function isAllFormDataValid;
  final Function getPartId;
  final Function(String) saveAdmission;
  final Function onSuccessfulSave;
  final Function(Function) reloadUiForm;
  final Map<String, dynamic> isAdmissionConfig;
  final bool isOnStudentEdit;
  final Function isDataChangedToEdit;
  final Function(Map) saveUpdate;
  final Function resetForm;
  const _KgmsAdmissionAddressForm(
      {Key key,
      @required this.accountData,
      @required this.clearUiForm,
      @required this.isAllFormDataValid,
      @required this.getPartId,
      @required this.saveAdmission,
      @required this.onSuccessfulSave,
      @required this.reloadUiForm,
      @required this.isAdmissionConfig,
      @required this.isOnStudentEdit,
      @required this.isDataChangedToEdit,
      @required this.saveUpdate,
      @required this.resetForm})
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
  bool _isKgmsSettings = false;
  String _errorMsg = '';
  bool _showMonthYear = false;
  //final Map<String, int> _feeStruct = {
  //  'totalAmount': null,
  //  'admissionFee': null,
  //  'tuitionFee': null,
  //};
  final Map<String, int> _feeStruct = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _address1Ctrl.text = widget.accountData['address1'] as String;
    _address1Ctrl.addListener(
        _updateLatestValue(_address1Ctrl, 'address1', widget.accountData));
    _address2Ctrl.text = widget.accountData['address2'] as String;
    _address2Ctrl.addListener(
        _updateLatestValue(_address2Ctrl, 'address2', widget.accountData));
    _amountCtrl.text = widget.accountData['amount'] as String;
    _amountCtrl.addListener(
        _updateLatestValue(_amountCtrl, 'amount', widget.accountData));
    _admissionFeeCtrl.text = widget.accountData['admissionFee'] as String;
    _admissionFeeCtrl.addListener(_updateLatestValue(
        _admissionFeeCtrl, 'admissionFee', widget.accountData));
    _tuitionFeeCtrl.text = widget.accountData['tuitionFee'] as String;
    _tuitionFeeCtrl.addListener(
        _updateLatestValue(_tuitionFeeCtrl, 'tuitionFee', widget.accountData));
    _isInstallment = widget.accountData['isInstallment'] as bool;
    widget.clearUiForm(clearAddressForm);
    widget.reloadUiForm(clearAddressForm);
    Future.delayed(const Duration(milliseconds: 600), () {
      dataStoreServ.getFeeStructureFromCache.then((feeStruct) {
        if (mounted) {
          if (feeStruct != null) {
            setState(() {
              if (_amountCtrl.text.isEmpty)
                _amountCtrl.text =
                    (feeStruct['admissionFee'] + feeStruct['tuitionFee'])
                        .toString();
              if (_admissionFeeCtrl.text.isEmpty)
                _admissionFeeCtrl.text = feeStruct['admissionFee'].toString();
              if (_tuitionFeeCtrl.text.isEmpty)
                _tuitionFeeCtrl.text = feeStruct['tuitionFee'].toString();
              _feeStruct.addAll(feeStruct);
              _isKgmsSettings = true;
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

  //Function _updateLatestValue(TextEditingController tec, String dataKey) {
  //  Future<VoidCallback> addListenerToUpdate() async {
  //    if (tec.text != widget.accountData[dataKey].toString()) {
  //      ////print('Std latest changed value --> ${tec.text}');
  //      widget.accountData[dataKey] = tec.text;
  //    }
  //  }

  //  return addListenerToUpdate;
  //}
  Future<void> _getMonthYearDate(
          BuildContext context, String dataKey, DateTime currentDate) =>
      DatePicker.showPicker(context,
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
                  fontSize: 17)), onConfirm: (date) async {
        ////print('confirm $date');
        //var dayStr =
        //    date.day < 10 ? '0${date.day.toString()}' : date.day.toString();
        var monthStr = date.month < 10
            ? '0${date.month.toString()}'
            : date.month.toString();
        var dateStr = '${monthStr}/${date.year.toString()}';
        ////print('date selected --> $dateStr');
        setState(() {
          widget.accountData[dataKey] = dateStr;
        });
      });

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

  void clearAddressForm() {
    //print('clear form _KgmsAdmissionAddressFormState !');
    if (mounted) {
      setState(() {
        _address1Ctrl.text = widget.accountData['address1'] as String;
        _address2Ctrl.text = widget.accountData['address2'] as String;
        _amountCtrl.text = widget.accountData['amount'] as String;
        _admissionFeeCtrl.text = widget.accountData['admissionFee'] as String;
        _tuitionFeeCtrl.text = widget.accountData['tuitionFee'] as String;
        _isInstallment = widget.accountData['isInstallment'] as bool;
        _showErrMsg = false;
      });
    }
  }

  bool _isValidated() {
    if (!_isKgmsSettings) {
      setState(() {
        _errorMsg = '** Account settings invalid';
        _showErrMsg = true;
      });
      return false;
    } else {
      bool isVal = true;
      if (!_formKey.currentState.validate()) isVal = false;
      if (!widget.isOnStudentEdit) {
        if (widget.accountData['forMonthYear'].toString().isEmpty) {
          setState(() {
            _showMonthYear = true;
          });
          isVal = false;
        } else {
          setState(() {
            _showMonthYear = false;
          });
        }
      }
      if (isVal) {
        setState(() {
          _showErrMsg = false;
        });
        return true;
      } else {
        setState(() {
          _errorMsg = '** Error found above';
          _showErrMsg = true;
        });
        return false;
      }
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
                  visible: !widget.isOnStudentEdit,
                  child: Column(
                    children: <Widget>[
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.36,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      ////print('get date !');
                                      clearKeyBoard(context);
                                      //var dt = getDateFromString(
                                      //    widget.accountData['forMonthYear']);
                                      //_getMonthYearDate(
                                      //    context, 'forMonthYear', dt);
                                      animatedCustomNonDismissibleAlert(
                                          context,
                                          MultiselectForMonthYear(
                                              showMonths: true,
                                              onSelect: (String value) {
                                                ////print(
                                                //    'result from ui --> $value');
                                                setState(() {
                                                  widget.accountData[
                                                      'forMonthYear'] = value;
                                                });
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 7.3),
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
                                      shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.50,
                                  child: Text(
                                    '${widget.accountData['forMonthYear'].toString().isEmpty ? 'none' : widget.accountData['forMonthYear'].toString()}',
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
                                  padding:
                                      EdgeInsets.only(left: 12.0, top: 6.0),
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
                              } else if (!isNumFromString(value)) {
                                return 'not number !';
                              } else if (!_isKgmsSettings) {
                                return 'Set account settings under user profile !';
                              } else {
                                var val = int.tryParse(value);
                                //if (val == null || val <= 0)
                                //  return 'Amount cannot be zero or negative !';
                                if (val != null &&
                                    _feeStruct['totalAmount'] != null &&
                                    val != _feeStruct['totalAmount'])
                                  return 'Amount not matching !';
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
                                  } else if (!isNumFromString(value)) {
                                    return 'not number !';
                                  } else {
                                    var val = int.tryParse(value);
                                    if (val != null &&
                                        _feeStruct['admissionFee'] != null &&
                                        val > _feeStruct['admissionFee']) {
                                      return 'Cannot be more than Admission Fee !';
                                    }
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
                                  } else if (!isNumFromString(value)) {
                                    return 'not number !';
                                  } else {
                                    var val = int.tryParse(value);
                                    if (val != null &&
                                        _feeStruct['tuitionFee'] != null &&
                                        val > _feeStruct['tuitionFee']) {
                                      return 'Cannot be more than Tuition Fee !';
                                    }
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
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            clearKeyBoard(context);
                            if (_isValidated()) {
                              final KCircularProgress cp =
                                  KCircularProgress(ctx: context);
                              cp.showCircularProgress();

                              ////print('next to parent section !');
                              ////print('parent name --> ${_fatherNameCtrl.text}');
                              //widget.toggleToTab2();
                              ////print(widget.accountData.toString());
                              if (!widget.isOnStudentEdit) {
                                ////print('fresh admission !');
                                var res = await widget.isAllFormDataValid();
                                //print(res);
                                if (res == 'ok') {
                                  ////print('std part id ---> ${widget.getPartId()}');
                                  if (widget.isAdmissionConfig['isEdit']
                                      as bool) {
                                    //print('std id = ${widget.isAdmissionConfig['studentId'] as String}');
                                    var result = await widget.saveAdmission(
                                        widget.isAdmissionConfig['studentId']
                                            as String);
                                    //print('edit insertNewAdmissionLocal res ---> $result');
                                    if (result == 'ok') {
                                      cp.closeProgress();
                                      widget.onSuccessfulSave();
                                    } else {
                                      cp.closeProgress();
                                      setState(() {
                                        _errorMsg = result;
                                        _showErrMsg = true;
                                      });
                                    }
                                  } else {
                                    //print('new admission by config !');
                                    var ptID = widget.getPartId();
                                    ////print('ptID --> $ptID');
                                    var availId = await dataStoreServ
                                        .getAvailableStdId(ptID);
                                    //print('available id ---> $availId');
                                    var result =
                                        await widget.saveAdmission(availId);
                                    //print('insertNewAdmissionLocal res ---> $result');
                                    if (result == 'ok') {
                                      cp.closeProgress();
                                      widget.onSuccessfulSave();
                                    } else {
                                      cp.closeProgress();
                                      setState(() {
                                        _errorMsg = result;
                                        _showErrMsg = true;
                                      });
                                    }
                                  }
                                } else {
                                  cp.closeProgress();
                                  setState(() {
                                    _errorMsg = res;
                                    _showErrMsg = true;
                                  });
                                }
                              } else {
                                ////print('edit admission !');
                                ////print(widget.accountData.toString());
                                var res = await widget.isAllFormDataValid();
                                if (res == 'ok') {
                                  var res1 = await widget.isDataChangedToEdit();
                                  if (res1.isEmpty) {
                                    cp.closeProgress();
                                    setState(() {
                                      _errorMsg = 'Nothing changed !';
                                      _showErrMsg = true;
                                    });
                                  } else {
                                    ////print('isDataChangedToEdit --> $res1');
                                    var res2 = await widget.saveUpdate(res1);
                                    if (res2 == 'ok') {
                                      cp.closeProgress();
                                      Navigator.pop(
                                          context, 'Update successfully..!!');
                                      widget.resetForm();
                                    } else {
                                      cp.closeProgress();
                                      setState(() {
                                        _errorMsg = res2;
                                        _showErrMsg = true;
                                      });
                                    }
                                  }
                                } else {
                                  cp.closeProgress();
                                  setState(() {
                                    _errorMsg = res;
                                    _showErrMsg = true;
                                  });
                                }
                              }
                            }
                          },
                          label: const Text(
                            'Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          icon: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Icon(Icons.save, size: 25),
                          ),
                          //shape: const RoundedRectangleBorder(
                          //  borderRadius: BorderRadius.all(Radius.circular(8)),
                          //),
                          //splashColor: Colors.yellow,
                          //color: Colors.green,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black87),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            )),
                          ),
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
        clearKeyBoard(context);
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

//bool _isNumFromString(String s) => int.tryParse(s) != null;

//DateTime getDateFromString(String dt) {
//  if (!dt.isEmpty) {
//    try {
//      var opera = dt.split('/');
//      if (opera.length == 3) {
//        var day = int.tryParse(opera[0]);
//        var month = int.tryParse(opera[1]);
//        var year = int.tryParse(opera[2]);
//        if (day != null && month != null && year != null) {
//          return DateTime(year, month, day);
//        }
//      }
//      if (opera.length == 2) {
//        var day = 1;
//        var month = int.tryParse(opera[0]);
//        var year = int.tryParse(opera[1]);
//        if (month != null && year != null) {
//          return DateTime(year, month, day);
//        }
//      }
//    } catch (e) {
//      //print(e);
//    }
//  }
//  return DateTime.now();
//}

class _PendingStudentListFromStorage extends StatefulWidget {
  final Function(Map<String, dynamic>, String) onEditStudent;
  const _PendingStudentListFromStorage({Key key, @required this.onEditStudent})
      : super(key: key);

  @override
  _PendingStudentListFromStorageState createState() =>
      _PendingStudentListFromStorageState();
}

class _PendingStudentListFromStorageState
    extends State<_PendingStudentListFromStorage> {
  final StreamController<List<Map<String, String>>> _controller =
      StreamController<List<Map<String, String>>>();

  bool _isPendingStudents = false;

  @override
  void initState() {
    super.initState();
    _controller.onListen = _startFetchPendingList;
  }

  @override
  void dispose() {
    if (_controller != null) _controller.close();
    super.dispose();
  }

  void _startFetchPendingList() {
    Future.delayed(
        const Duration(milliseconds: 1300),
        () => dataStoreServ.getPendingAdmissions().then((res) {
              if (mounted) {
                _controller.add(res);
                setState(() => res.length > 0
                    ? _isPendingStudents = true
                    : _isPendingStudents = false);
              }
              //print('_startFetchPendingList f() called !');
            }));
  }

  AlertDialog _deletePendingStdAlertW(BuildContext context, String stdId,
          String stdName, String stdClass) =>
      AlertDialog(
        title: Text(
            'Are you sure to delete pending\nstudent - $stdName of class - $stdClass ?'),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        titleTextStyle: const TextStyle(
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
              //print('delete std id ---> $stdId');
              //Navigator.pop(context);
              await dataStoreServ.deletePendingAdmission(stdId);
              _startFetchPendingList();
              Navigator.pop(context);
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

  Card _loadingTile(String msg) => Card(
        //color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Text(
            msg,
            style: TextStyle(
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

  Card _studentDetailsWidget(int index, String stdName, String className,
          String sec, String doa, String id) =>
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
                  stdName,
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
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Class: $className,  Sec - $sec,\nD.O.A - $doa',
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
                      ////print('Remove student --> $id !');
                      animatedCustomNonDismissibleAlert(
                          context,
                          _deletePendingStdAlertW(
                              context, id, stdName, className));
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
                    child: const Text('/ Edit'),
                    onPressed: () async {
                      ////print('Edit student --> $id !');
                      var editData =
                          await dataStoreServ.getPendingStudentById(id);
                      widget.onEditStudent(editData, id);
                      Navigator.of(context).pop();
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
                    child: const Text('^ Upload'),
                    onPressed: () async {
                      ////print('Upload student !');
                      bool _internet = await isInternetAvailable();
                      if (_internet) {
                        final KCircularProgress cp =
                            KCircularProgress(ctx: context);
                        cp.showCircularProgress();
                        var isDone =
                            await dataStoreServ.uploadAdmissionToCloud(id);
                        if (isDone) {
                          await dataStoreServ.deletePendingAdmission(id);
                          _startFetchPendingList();
                          cp.closeProgress();
                        } else {
                          cp.closeProgress();
                          kAlert(context, showErrorWidget('Upload error !'));
                        }
                      } else {
                        kAlert(context, noInternetWidget);
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

  StreamBuilder _pendingAdmissionWidget(BuildContext context) => StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return _loadingTile('snapshot has error');
          else
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _loadingTile('Loading....');
              default:
                {
                  if (snapshot.data != null && snapshot.data.length > 0)
                    return ListView.separated(
                        itemCount: snapshot.data.length,
                        separatorBuilder: (context, index) => Divider(
                              height: 4.2,
                            ),
                        itemBuilder: (context, index) => _studentDetailsWidget(
                            index,
                            snapshot.data[index]['name'],
                            snapshot.data[index]['class'],
                            snapshot.data[index]['sec'],
                            snapshot.data[index]['doa'],
                            snapshot.data[index]['id']));
                  else
                    return _loadingTile('No pending admission !');
                }
            }
        },
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Pending Admission',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text('Confirm student admission',
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
        child: _pendingAdmissionWidget(context),
      ),
      actions: <Widget>[
        Visibility(
          visible: _isPendingStudents,
          child: ElevatedButton(
            onPressed: () async {
              ////print('Upload All students !');
              bool _internet = await isInternetAvailable();
              if (_internet) {
                final KCircularProgress cp = KCircularProgress(ctx: context);
                cp.showCircularProgress();
                var isDone = await dataStoreServ.uploadBulkAdmissionToCloud();
                _startFetchPendingList();
                cp.closeProgress();
                if (!isDone) kAlert(context, showErrorWidget('Upload error !'));
              } else {
                kAlert(context, noInternetWidget);
              }
            },
            child: const Text('Upload All',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              )),
            ),
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
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            )),
          ),
        ),
      ],
      buttonPadding: const EdgeInsets.only(right: 7.0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      clipBehavior: Clip.none,
      insetPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Colors.indigo.shade50,
    );
  }
}

String _getStdPassword(String name, String dt) {
  try {
    //var opera = dt.split('/');
    //var dtYear = opera[2];
    var dtYear = dt.split('/')[2];
    var nR = name.replaceAll(RegExp(r"\s+"), "");
    if (nR.length > 3) {
      var n4 = nR.substring(0, 4).toLowerCase();
      return n4 + dtYear;
    } else {
      var n4 = nR.substring(0, nR.length).toLowerCase();
      return n4 + dtYear;
    }
  } catch (e) {
    //print(e);
  }
  return null;
}

String _getNamePart(String name) {
  var nR = name.replaceAll(RegExp(r"\s+"), "");
  if (nR.length > 3) {
    var n4 = nR.substring(0, 4).toLowerCase();
    return n4;
  } else {
    var n4 = nR.substring(0, nR.length).toLowerCase();
    return n4;
  }
}

Future<String> _isAllFormsValid(Map studentData, Map parentData) async {
  String result = 'ok';

  //studentData.forEach((k, v) {
  //  if(k != 'rollNo' && v.toString().isEmpty) {
  //    result = 'invalid student section !';
  //  }
  //});

  for (var std in studentData.entries) {
    if (std.key != 'rollNo' &&
        std.key != 'password' &&
        std.value.toString().isEmpty) {
      result = 'invalid student section !';
      break;
    }
    if (std.key == 'password' &&
        !studentData['stdName'].toString().isEmpty &&
        !studentData['dob'].toString().isEmpty)
      studentData['password'] = _getStdPassword(
          studentData['stdName'].toString(), studentData['dob'].toString());
    if (std.key == 'stdName')
      studentData['stdName'] = _formatName(std.value.toString());
  }

  if (result == 'ok') {
    //parentData.forEach((k,v) {
    // if(k != 'contact2' && k != 'emailId' && v.toString().isEmpty) {
    //  result = 'invalid parent section !';
    // }
    //});
    for (var prt in parentData.entries) {
      if (prt.key != 'contact2' &&
          prt.key != 'emailId' &&
          prt.value.toString().isEmpty) {
        result = 'invalid parent section !';
        break;
      } else if (prt.key == 'contact1' && prt.value.toString().length != 10) {
        result = 'invalid parent section !';
        break;
      } else if (prt.key == 'emailId' &&
          !prt.value.toString().isEmpty &&
          !EmailValidator.validate(prt.value.toString())) {
        result = 'invalid parent section !';
        break;
      }
      if (prt.key == 'fatherName')
        parentData['fatherName'] = _formatName(prt.value.toString());
      if (prt.key == 'motherName')
        parentData['motherName'] = _formatName(prt.value.toString());
      if (prt.key == 'lgName')
        parentData['lgName'] = _formatName(prt.value.toString());
    }
  }

  return result;
}

Future<Map> _isDataChangedToEdit(
    Map originaMap, Map studentData, Map parentData, Map accountData) async {
  Map result = {};
  for (var ord in originaMap.entries) {
    if (studentData.containsKey(ord.key)) {
      if (ord.value != studentData[ord.key])
        result[ord.key] = studentData[ord.key];
    } else if (parentData.containsKey(ord.key)) {
      if (ord.value != parentData[ord.key])
        result[ord.key] = parentData[ord.key];
    } else if (accountData.containsKey(ord.key)) {
      if (ord.value != accountData[ord.key])
        result[ord.key] = accountData[ord.key];
    }
  }
  if (result.containsKey('stdName') || result.containsKey('contact1')) {
    var stName = result['stdName'] != null
        ? result['stdName'].toString()
        : studentData['stdName'].toString();
    var conct1 = result['contact1'] != null
        ? result['contact1'].toString()
        : parentData['contact1'].toString();
    var testID = _getNamePart(stName) + conct1.substring(4, 10);
    if (testID != originaMap['stdLoginId']) result['stdLoginId'] = testID;
  }

  if (result.containsKey('stdName') || result.containsKey('dob')) {
    var stName = result['stdName'] != null
        ? result['stdName'].toString()
        : studentData['stdName'].toString();
    var dob = result['dob'] != null
        ? result['dob'].toString()
        : studentData['dob'].toString();
    var testID = _getStdPassword(stName, dob);
    if (testID != originaMap['stdLoginpassword'])
      result['stdLoginpassword'] = testID;
  }

  return result;
}

Future<String> _updateStudentDetailsToCloud(
    Map studentUpdates, String studentInfoKey, String studentMoreKey) async {
  Map studentInfo = {};
  Map studentMoreInfo = {};
  for (var stdUpd in studentUpdates.entries) {
    switch (stdUpd.key) {
      case 'stdLoginId':
        studentInfo['stdLoginId'] = stdUpd.value;
        break;
      case 'stdName':
        studentInfo['name'] = stdUpd.value;
        break;
      case 'class':
        studentInfo['className'] = stdUpd.value;
        break;
      case 'classId':
        studentInfo['classId'] = stdUpd.value;
        break;
      case 'section':
        studentInfo['section'] = stdUpd.value;
        break;
      case 'rollNo':
        studentInfo['rollNo'] = int.tryParse(stdUpd.value) ?? 0;
        break;
      case 'doa':
        studentInfo['doa'] = stdUpd.value;
        break;
      case 'stdLoginpassword':
        studentInfo['password'] = stdUpd.value;
        break;
      case 'medium':
        studentMoreInfo['medium'] = stdUpd.value;
        break;
      case '2ndLang':
        studentMoreInfo['secondLang'] = stdUpd.value;
        break;
      case 'dob':
        studentMoreInfo['dob'] = stdUpd.value;
        break;
      case 'fatherName':
        studentMoreInfo['fatherName'] = stdUpd.value;
        break;
      case 'motherName':
        studentMoreInfo['motherName'] = stdUpd.value;
        break;
      case 'motherName':
        studentMoreInfo['motherName'] = stdUpd.value;
        break;
      case 'lgName':
        studentMoreInfo['lgName'] = stdUpd.value;
        break;
      case 'contact1':
        studentMoreInfo['contact1'] = stdUpd.value;
        break;
      case 'contact2':
        studentMoreInfo['contact2'] = stdUpd.value;
        break;
      case 'emailId':
        studentMoreInfo['emailId'] = stdUpd.value;
        break;
      case 'address1':
        studentMoreInfo['address1'] = stdUpd.value;
        break;
      case 'address2':
        studentMoreInfo['address2'] = stdUpd.value;
        break;
    }
  }
  Map reqBody = {
    "studentInfoKey": studentInfoKey,
    "studentInfo": studentInfo,
    "studentMoreInfoKey": studentMoreKey,
    "studentMoreInfo": studentMoreInfo,
  };
  ////print('reqBody --> $reqBody');
  var bodyStr = convert.jsonEncode(reqBody);
  var resp = await dataStoreServ.updateStudentBasicInfo(bodyStr);
  try {
    var jsonObj = convert.jsonDecode(resp);
    var statusCode = jsonObj['statusCode'] as int;
    if (statusCode == 200)
      return 'ok';
    else
      return jsonObj['message'] as String;
  } on FormatException catch (e) {
    return '$e';
  }
}

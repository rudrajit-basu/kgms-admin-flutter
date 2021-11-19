//import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'localFileStorageService.dart';
import 'bUtil.dart';
import 'package:async/async.dart' show AsyncCache;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const kgmsMainApiUrl = 'https://kgmskid-main-micro.deta.dev';

final _getFeeStructureFromCache =
    AsyncCache<Map<String, int>>(const Duration(hours: 2));

class LocalDataStoreServ {
  Future<Map<String, int>> get getFeeStructureFromCache =>
      _getFeeStructureFromCache.fetch(() => _getFeeStructureFromFile());

  void resetFeeStructureFromCache() {
    _getFeeStructureFromCache.invalidate();
  }

  Future<Map<String, int>> _getFeeStructureFromFile() async {
    var dataStr = await fileServ.readDataByKey('kgmsSettings');
    if (dataStr != 'nil') {
      try {
        final _jsonObj = convert.jsonDecode(dataStr);
        final admFee = int.tryParse(_jsonObj['admissionFee']);
        final tuiFee = int.tryParse(_jsonObj['tuitionFee']);
        if (admFee != null && tuiFee != null && admFee > 0 && tuiFee > 0) {
          final Map<String, int> _feeStruct = {
            'totalAmount': admFee + tuiFee,
            'admissionFee': admFee,
            'tuitionFee': tuiFee,
          };
          print('kgms feeStruct data from file io ');
          return _feeStruct;
        }
      } on FormatException catch (e) {
        print('_getFeeStructureFromFile data = $dataStr and error = $e');
      }
    }
    return null;
  }

  Future<String> insertNewAdmissionLocal(
      {Map studentData,
      Map parentData,
      Map accountData,
      String studentId}) async {
    var result = 'ok';
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    if (dataStr == 'nil') {
      final Map<String, Map> admissionDataMap = {
        'studentData': studentData,
        'parentData': parentData,
        'accountData': accountData,
      };
      final Map<String, Map<String, Map>> admissionMap = {
        studentId: admissionDataMap,
      };
      final String _newAdmissionStr = convert.jsonEncode(admissionMap);
      fileServ.writeKeyWithData('kgmsAdmissions', _newAdmissionStr).then(
          (result) =>
              print('writeKeyWithData = key kgmsNewAdmission --> $result'));
    } else {
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        final Map<String, Map> admissionDataMap = {
          'studentData': studentData,
          'parentData': parentData,
          'accountData': accountData,
        };
        _jsonMapObj[studentId] = admissionDataMap;
        final String _newAdmissionStr = convert.jsonEncode(_jsonMapObj);
        fileServ.writeKeyWithData('kgmsAdmissions', _newAdmissionStr).then(
            (result) => print(
                'writeKeyWithData = key kgmsNewAdmission append --> $result'));
      } on FormatException catch (e) {
        print('insertNewAdmissionLocal data = $dataStr and error = $e');
        result = 'json decode error';
      } catch (e) {
        print('insertNewAdmissionLocal error = $e');
        result = 'other error';
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> getPendingStudentById(String id) async {
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    if (dataStr != 'nil') {
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        if (_jsonMapObj.containsKey(id)) return _jsonMapObj[id];
      } on FormatException catch (e) {
        print('getPendingStudentById data = $dataStr and error = $e');
      }
    }
    return null;
  }

  Future<String> getAvailableStdId(Map idPart) async {
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    if (dataStr != 'nil') {
      var idInt = int.tryParse(idPart['numPart']) ?? 0;
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        while (_jsonMapObj.containsKey(idPart['strPart'] + idInt.toString()))
          idInt += 3;
        return idPart['strPart'] + idInt.toString();
      } on FormatException catch (e) {
        print('getAvailableStdId data = $dataStr and error = $e');
        return 'error';
      }
    } else {
      return idPart['strPart'] + idPart['numPart'];
    }
  }

  Future<bool> deletePendingAdmission(String id) async {
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    if (dataStr != 'nil') {
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        _jsonMapObj.remove(id);
        final String _delAdmissionStr = convert.jsonEncode(_jsonMapObj);
        fileServ.writeKeyWithData('kgmsAdmissions', _delAdmissionStr).then(
            (result) => print(
                'writeKeyWithData = key deleteAllPendingAdmissions --> $result'));
        return true;
      } on FormatException catch (e) {
        print('deleteAllPendingAdmissions data = $dataStr and error = $e');
      }
    }
    return false;
  }

  Future<void> _deleteBulkPendingAdmission(List<String> ids) async {
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    if (dataStr != 'nil') {
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        for (var i = 0; i < ids.length; i++) _jsonMapObj.remove(ids[i]);
        final String _delAdmissionStr = convert.jsonEncode(_jsonMapObj);
        fileServ.writeKeyWithData('kgmsAdmissions', _delAdmissionStr).then(
            (result) => print(
                'writeKeyWithData = key deleteBulkPendingAdmission --> $result'));
      } on FormatException catch (e) {
        print('deleteBulkPendingAdmission data = $dataStr and error = $e');
      }
    }
  }

  Future<List<Map<String, String>>> getPendingAdmissions() async {
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    //print('getPendingAdmissions --> $dataStr');
    if (dataStr != 'nil') {
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        final List<Map<String, String>> pendingList = [];
        for (var adme in _jsonMapObj.entries) {
          Map<String, String> stdMap = {
            'name': adme.value['studentData']['stdName'],
            'class': adme.value['studentData']['class'],
            'sec': adme.value['studentData']['section'],
            'doa': adme.value['studentData']['doa'],
            'id': adme.key,
          };
          //Map<String, Map<String, String>> pendingMap = {
          //  adme.key: stdMap,
          //};
          pendingList.add(stdMap);
        }
        return pendingList;
      } on FormatException catch (e) {
        print('getPendingAdmissions data = $dataStr and error = $e');
      }
    }
    return null;
  }

  Future<List<Map>> _getPendingAdmissionsAllData() async {
    var dataStr = await fileServ.readDataByKey('kgmsAdmissions');
    //print('getPendingAdmissions --> $dataStr');
    if (dataStr != 'nil') {
      try {
        final _jsonMapObj = convert.jsonDecode(dataStr);
        final List<Map> pendingList = [];
        for (var adme in _jsonMapObj.entries) {
          Map stdMap = {'id': adme.key, 'data': adme.value};
          //Map<String, Map<String, String>> pendingMap = {
          //  adme.key: stdMap,
          //};
          pendingList.add(stdMap);
        }
        return pendingList;
      } on FormatException catch (e) {
        print('getPendingAdmissions data = $dataStr and error = $e');
      }
    }
    return null;
  }

  Future<String> getAdmissionToJsonStr(
      {Map studentData,
      Map parentData,
      Map accountData,
      String studentId}) async {
    var feeStruct = await getFeeStructureFromCache;
    var doaDtList = studentData['doa'].split('/');
    Map stdVal = {
      'stdLoginId': studentId,
      'name': studentData['stdName'],
      'className': studentData['class'],
      'classId': studentData['classId'],
      'section': studentData['section'],
      'rollNo': int.tryParse(studentData['rollNo']) ?? 0,
      'doa': studentData['doa'],
      //'paid': doaDtList[1] + '/' + doaDtList[2],
      'password': studentData['password'],
      'isSync': false,
      'isActive': true,
    };
    Map prtVal = {
      'medium': studentData['medium'],
      'secondLang': studentData['2ndLang'],
      'dob': studentData['dob'],
      'fatherName': parentData['fatherName'],
      'motherName': parentData['motherName'],
      'lgName': parentData['lgName'],
      'contact1': parentData['contact1'],
      'contact2': parentData['contact2'],
      'emailId': parentData['emailId'],
      'address1': accountData['address1'],
      'address2': accountData['address2'],
      'isSync': false,
      'isActive': true,
    };
    Map accAdmVal = null;
    Map accTuiVal = null;
    if (accountData['isInstallment'] as bool) {
      bool isInstal =
          int.tryParse(accountData['admissionFee']) < feeStruct['admissionFee'];
      accAdmVal = {
        'feeType': 'admissionFee',
        'amount': int.tryParse(accountData['admissionFee']) ?? 0,
        'isInstallment': isInstal,
        'dtDay': int.tryParse(doaDtList[0]) ?? 0,
        'dtMonth': int.tryParse(doaDtList[1]) ?? 0,
        'dtYear': int.tryParse(doaDtList[2]) ?? 0,
        'classId': studentData['classId'],
        'className': studentData['class'],
        'sec': studentData['section'],
        'installmentId': '',
        'isSync': false,
        'isActive': true,
      };
      isInstal =
          int.tryParse(accountData['tuitionFee']) < feeStruct['tuitionFee'];
      accTuiVal = {
        'feeType': 'tuitionFee',
        'amount': int.tryParse(accountData['tuitionFee']) ?? 0,
        'isInstallment': isInstal,
        'dtDay': int.tryParse(doaDtList[0]) ?? 0,
        'dtMonth': int.tryParse(doaDtList[1]) ?? 0,
        'dtYear': int.tryParse(doaDtList[2]) ?? 0,
        'classId': studentData['classId'],
        'className': studentData['class'],
        'sec': studentData['section'],
        'installmentId': '',
        'isSync': false,
        'isActive': true,
      };
    } else {
      accAdmVal = {
        'feeType': 'admissionFee',
        'amount': feeStruct['admissionFee'],
        'isInstallment': accountData['isInstallment'],
        'dtDay': int.tryParse(doaDtList[0]) ?? 0,
        'dtMonth': int.tryParse(doaDtList[1]) ?? 0,
        'dtYear': int.tryParse(doaDtList[2]) ?? 0,
        'classId': studentData['classId'],
        'className': studentData['class'],
        'sec': studentData['section'],
        'installmentId': '',
        'isSync': false,
        'isActive': true,
      };

      accTuiVal = {
        'feeType': 'tuitionFee',
        'amount': feeStruct['tuitionFee'],
        'isInstallment': accountData['isInstallment'],
        'dtDay': int.tryParse(doaDtList[0]) ?? 0,
        'dtMonth': int.tryParse(doaDtList[1]) ?? 0,
        'dtYear': int.tryParse(doaDtList[2]) ?? 0,
        'classId': studentData['classId'],
        'className': studentData['class'],
        'sec': studentData['section'],
        'installmentId': '',
        'isSync': false,
        'isActive': true,
      };
    }
    var opera1 = accountData['forMonthYear'].split(' of ');
    var sessionYear = int.tryParse(opera1[1]) ?? 0;
    var opera2 = opera1[0].split(' , ');
    var accAdmSession = [];
    accAdmSession.add(sessionYear);
    var accTuiSession = getMonthsInList(opera2);
    //for (var op in opera2) accTuiSession.add(_monthsName.indexOf(op) + 1);
    accAdmVal['session'] = accAdmSession;
    accAdmVal['sessionYear'] = sessionYear;
    accTuiVal['session'] = accTuiSession;
    accTuiVal['sessionYear'] = sessionYear;
    //print('stdVal --> ${stdVal.toString()}');
    //print('prtVal --> ${prtVal.toString()}');
    //print('accAdmVal --> ${accAdmVal.toString()}');
    //print('accTuiVal --> ${accTuiVal.toString()}');
    Map<String, Map> jsonObj = {
      'studentInfo': stdVal,
      'studentMoreInfo': prtVal,
      'studentAdmissionFeeInfo': accAdmVal,
      'studentTuitionFeeInfo': accTuiVal
    };
    var result = convert.jsonEncode(jsonObj);
    return result;
  }

  Future<Map<String, String>> _getHeader() async {
    final String userAgent = await bUtil.getHttpUserAgentFromCache;
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'X-API-Key': '${env['deta_api_key']}',
      'User-Agent': userAgent
    };
    return headers;
  }

  Future<bool> uploadAdmissionToCloud(String studentId) async {
    //print('deta api key ---> ${env['deta_api_key']}');
    print('stdId --> $studentId');
    String userAgent = await bUtil.getHttpUserAgentFromCache;
    //print('user agent --> $userAgent');
    var pendingStudent = await getPendingStudentById(studentId);
    //print('pendingStudent --> ${pendingStudent}');
    var bodyStr = await getAdmissionToJsonStr(
        studentData: pendingStudent['studentData'],
        parentData: pendingStudent['parentData'],
        accountData: pendingStudent['accountData'],
        studentId: studentId);
    print('bodyStr --> $bodyStr');
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/insertStudent';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    if (response.statusCode == 201)
      return true;
    else {
      print('response code ---> ${response.statusCode}');
      print('response headers ---> ${response.headers}');
      print('response body ---> ${response.body}');
      return false;
    }
  }

  Future<bool> uploadBulkAdmissionToCloud() async {
    var allDataMapList = await _getPendingAdmissionsAllData();
    //print('allDataMapList --> $allDataMapList');
    final List<String> _uploadCompletedStd = [];
    bool _isErrFound = false;
    final String userAgent = await bUtil.getHttpUserAgentFromCache;
    //final Map<String, String> headers = <String, String>{
    //  'Content-Type': 'application/json',
    //  'X-API-Key': '${env['deta_api_key']}',
    //  'User-Agent': userAgent
    //};
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/insertStudent';
    await Future.wait(allDataMapList.map((item) async {
      //print('item --> $item');
      var stdId = item['id'];
      var bodyStr = await getAdmissionToJsonStr(
          studentData: item['data']['studentData'],
          parentData: item['data']['parentData'],
          accountData: item['data']['accountData'],
          studentId: stdId);
      print('bodyStr --> $bodyStr');
      var response =
          await http.post(postReqStrUrl, headers: headers, body: bodyStr);
      if (response.statusCode == 201)
        _uploadCompletedStd.add(stdId);
      else {
        _isErrFound = true;
        print('response code ---> ${response.statusCode}');
        print('response headers ---> ${response.headers}');
        print('response body ---> ${response.body}');
      }
    }).toList());
    print('_uploadCompletedStd --> $_uploadCompletedStd');
    await _deleteBulkPendingAdmission(_uploadCompletedStd);
    return !_isErrFound;
  }

  Future<String> getStudentList(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getStudents';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
    //print('response code ---> ${response.statusCode}');
    //print('response headers ---> ${response.headers}');
    //print('response body ---> ${response.body}');
  }

  Future<String> getStudentMoreInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getStudentMoreInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
  }

  Future<String> updateStudentBasicInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/updateStudentBasicInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
    //print('updateStudentBasicInfo body ---> $bodyStr');
    //return 'ok';
  }

  Future<String> getStudentAccountInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getStudentAccountInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
  }

  Future<bool> uploadStudentAccountInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/insertStudentAccountInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    if (response.statusCode == 201)
      return true;
    else {
      print('response code ---> ${response.statusCode}');
      print('response headers ---> ${response.headers}');
      print('response body ---> ${response.body}');
      return false;
    }
    //return response.body;
  }

  Future<String> getStudentAccountInstallmentInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getStudentAccountInstallmentInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
  }

  Future<bool> updateStudentAccountStatusInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/updateStudentAccountStatusInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    if (response.statusCode == 200)
      return true;
    else {
      print('response code ---> ${response.statusCode}');
      print('response headers ---> ${response.headers}');
      print('response body ---> ${response.body}');
      return false;
    }
  }

  Future<bool> updateStudentBasicStatusInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/updateStudentBasicStatusInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    if (response.statusCode == 200)
      return true;
    else {
      print('response code ---> ${response.statusCode}');
      print('response headers ---> ${response.headers}');
      print('response body ---> ${response.body}');
      return false;
    }
  }

  List<int> getMonthsInList(List<String> monthStrList) {
    final List<int> result = [];
    for (var monthStr in monthStrList) {
      var monthIndex = _monthsName.indexOf(monthStr);
      if (monthIndex != -1) result.add(monthIndex + 1);
    }
    return result;
  }

  String getStringMonthsFromList(List<int> monthList) {
    final List<String> result = [];
    for (var monthInt in monthList) {
      result.add(_monthsName[monthInt - 1]);
    }
    return result.join(' , ');
  }

  String getSessionString(
      String feeType, int sessionYear, List<int> monthList) {
    if (feeType == 'admissionFee') {
      return ' of $sessionYear';
    } else {
      if (monthList == null)
        return '';
      else {
        return getStringMonthsFromList(monthList) + ' of $sessionYear';
      }
    }
  }

  final List<String> _monthsName = [
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

  Future<String> getStudentCollectionReport(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getStudentCollectionReport';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
  }

  Future<String> getStudentCollectionInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getStudentCollectionInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
  }

  Future<String> getAccountTransactionDetails(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/getAccountTransactionDetails';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    return response.body;
  }

  Future<bool> deleteStudentAccountInfo(String bodyStr) async {
    var headers = await _getHeader();
    final postReqStrUrl = kgmsMainApiUrl + '/deleteStudentAccountInfo';
    var response =
        await http.post(postReqStrUrl, headers: headers, body: bodyStr);
    if (response.statusCode == 200)
      return true;
    else {
      print('response code ---> ${response.statusCode}');
      print('response headers ---> ${response.headers}');
      print('response body ---> ${response.body}');
      return false;
    }
  }
}

final LocalDataStoreServ dataStoreServ = LocalDataStoreServ();

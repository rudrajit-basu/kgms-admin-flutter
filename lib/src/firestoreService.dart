import 'package:cloud_firestore/cloud_firestore.dart'
    show
        CollectionReference,
        QuerySnapshot,
        DocumentSnapshot,
        DocumentReference,
        FirebaseFirestore,
        WriteBatch;
import 'package:async/async.dart' show AsyncCache;
import 'dart:async';
import 'localFileStorageService.dart';
import 'dart:convert' as convert;

FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

final _getClassesFromLocalFileCache =
    AsyncCache<List<KgmsClassModel>>(const Duration(minutes: 45));

class FirestoreServ {
  //final _kClassesCollectionRef =
  //    FirebaseFirestore.instance.collection('kgms-classes');
  final _kClassesCollectionRef = firebaseFirestore.collection('kgms-classes');

  CollectionReference get kClassesCollectionRef => _kClassesCollectionRef;

  StreamSubscription<QuerySnapshot> _kgmsClassesSubscription = null;

  final StreamController<List<KgmsClassModel>> _updateController =
      StreamController<List<KgmsClassModel>>.broadcast();

  Stream<List<KgmsClassModel>> get _updateClassController =>
      _updateController.stream;

  Stream<List<KgmsClassModel>> getKgmsClasses() {
    StreamController<List<KgmsClassModel>> _controller;
    StreamSubscription<List<KgmsClassModel>> _updateSubscription = null;

    void startFetchClasses() {
      Future.delayed(const Duration(milliseconds: 1300), () async {
        //final result = await _getClassesFromLocalFile();
        final result = await getClassesFromLocalFileCache;
        if (result != null) _controller.add(result);
        _updateSubscription = _updateClassController.listen((value) {
          _controller.add(value);
        });
        //startKgmsClassesSubscription();
      });
    }

    void stopFetchClasses() {
      if (_updateSubscription != null) {
        _updateSubscription.cancel();
        _updateSubscription = null;
        print('stopFetchClasses() called');
      }
    }

    _controller = StreamController<List<KgmsClassModel>>(
        onListen: startFetchClasses,
        onPause: stopFetchClasses,
        onResume: startFetchClasses,
        onCancel: stopFetchClasses);

    return _controller.stream;
  }

  void startKgmsClassesSubscription() {
    if (_kgmsClassesSubscription == null) {
      _kgmsClassesSubscription = _kClassesCollectionRef
          .orderBy('classId')
          .snapshots()
          .listen((QuerySnapshot) {
        print('kgms classes data from firstore listen() ****');
        final List<KgmsClassModel> dataList = QuerySnapshot.docs
            .map((DocumentSnapshot document) =>
                KgmsClassModel.fromDocument(document))
            .toList();
        final String _kgmsClasses = convert.jsonEncode(dataList);
        fileServ.writeKeyWithData('kgmsClasses', _kgmsClasses).then((result) {
          print('writeKeyWithData = key kgmsClasses --> $result');
          _getClassesFromLocalFileCache.invalidate();
        });
        _updateController.add(dataList);
      });
    }
    print('firestoreServ startKgmsClassesSubscription() called !');
  }

  Future<List<KgmsClassModel>> get getClassesFromLocalFileCache =>
      _getClassesFromLocalFileCache.fetch(() => _getClassesFromLocalFile());

  Future<List<KgmsClassModel>> _getClassesFromLocalFile() async {
    String data = await fileServ.readDataByKey('kgmsClasses');
    if (data != 'nil') {
      print('kgms classes data from file io ');
      //print('str data --> $data');
      try {
        final _jsonArr = convert.jsonDecode(data) as List;
        final List<KgmsClassModel> _dataList = _jsonArr
            .map((jsonTag) => KgmsClassModel.fromJson(jsonTag))
            .toList();
        return _dataList;
      } on FormatException catch (e) {
        print('getKgmsClasses data = $data and error = $e');
      }
    }
    return null;
  }

  Future<List<Map<String, String>>> getClassesAndIds() async {
    final List<Map<String, String>> _classesAndIds = [];
    var kcm = await getClassesFromLocalFileCache;
    for (var tag in kcm) {
      _classesAndIds.add(tag.classesAndIds);
    }
    return _classesAndIds;
  }

  void stopKgmsClassesSubscription() {
    if (_kgmsClassesSubscription != null) {
      _kgmsClassesSubscription.cancel();
      _kgmsClassesSubscription = null;
      print('firestoreServ stopKgmsClassesSubscription() called !');
    }
  }

  Future<bool> addKgmsClass(Map<String, dynamic> data) async {
    try {
      final DocumentReference _dR = await _kClassesCollectionRef.add(data);
      return _dR != null ? true : false;
    } catch (e) {
      print('error at addKgmsClass --> $e');
      return false;
    }
  }

  Future<bool> updateKgmsClass(String docID, Map<String, dynamic> data) async {
    try {
      await _kClassesCollectionRef.doc(docID).update(data);
      return true;
    } catch (e) {
      print('error at updateKgmsClass --> $e');
      return false;
    }
  }

  Future<bool> deleteKgmsClass(String docID) async {
    final QuerySnapshot querySnapshot =
        await _kClassesCollectionRef.doc(docID).collection('kgms-study').get();

    try {
      if (querySnapshot != null &&
          querySnapshot.docs != null &&
          querySnapshot.docs.length > 0) {
        final WriteBatch batch = FirebaseFirestore.instance.batch();

        querySnapshot.docs.forEach((document) {
          batch.delete(document.reference);
        });

        await batch.commit();
        print('sub collection deleted');
      }

      await _kClassesCollectionRef.doc(docID).delete();
      print('collection deleted');
      return true;
    } catch (e) {
      print('error at deleteKgmsClass --> $e');
      return false;
    }
  }

  void disposeService() {
    _updateController.close();
    stopKgmsClassesSubscription();
    print('firestoreServ disposeService() called !');
  }
}

class KgmsClassModel {
  final String _docId;
  final String _className;
  final String _classId;
  final String _classPassword;

  KgmsClassModel(
      this._docId, this._className, this._classId, this._classPassword);

  Map toJson() => {
        'docId': _docId,
        'className': _className,
        'classId': _classId,
        'classPassword': _classPassword,
      };

  factory KgmsClassModel.fromJson(dynamic json) {
    return KgmsClassModel(json['docId'] as String, json['className'] as String,
        json['classId'] as String, json['classPassword'] as String);
  }

  factory KgmsClassModel.fromDocument(DocumentSnapshot document) {
    return KgmsClassModel(
        document.id as String,
        document['className'] as String,
        document['classId'] as String,
        document['classPassword'] as String);
  }

  String get docId => _docId;
  String get className => _className;
  String get classId => _classId;
  String get classPassword => _classPassword;

  Map<String, String> get classesAndIds => {
        'className': _className,
        'classId': _classId,
      };

  @override
  String toString() {
    return '{${this._className}, ${this._classId}, ${this._classPassword}, ${this._docId}}';
  }
}

final FirestoreServ firestoreServ = FirestoreServ();

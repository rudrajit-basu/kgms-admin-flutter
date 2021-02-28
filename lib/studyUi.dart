import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'self.dart';
import 'studyMediaItemsUi.dart';
import 'studyVideoItemsUi.dart';

//final kClassesCollectionRef = Firestore.instance.collection('kgms-classes');
final kClassesCollectionRef =
    FirebaseFirestore.instance.collection('kgms-classes');

// class StudyClassesModel {
//   final String tagNo;
//   final String classId;
//   final String className;
//   final String classPassword;

//   StudyClassesModel(
//       this.tagNo, this.classId, this.className, this.classPassword);
// }

class _TotalKlist {
  int _totalKList = 0;

  int getTotalKlist() {
    return _totalKList;
  }

  void setTotalKList(int tList) {
    this._totalKList = tList;
  }
}

class KgmsStudyClassAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final _TotalKlist totalClasses;

  KgmsStudyClassAppBar({Key key, @required this.totalClasses})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  void _kClassNavigation(BuildContext context, KgmsClassCredential kcc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => kcc,
      ),
    );
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Kgms Classes'),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'add new class',
            onPressed: () {
              // print('add new class');
              if (totalClasses.getTotalKlist() < 12) {
                _kClassNavigation(context,
                    KgmsClassCredential(kClassDocument: null, isDelete: false));
              } else {
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Max 12 Classes Allowed.'));
              }
            },
          ),
        ),
      ],
    );
  }
}

class KgmsStudyClassBody extends StatelessWidget {
  final _TotalKlist totalClasses;

  KgmsStudyClassBody({Key key, @required this.totalClasses}) : super(key: key);

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

  Card _studyClassesTile(
          BuildContext context, DocumentSnapshot document, int index) =>
      Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
            title: Text(
              document['className'],
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text('class id: ${document['classId']}'),
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
            trailing: IconButton(
              //icon: Icon(Icons.lock_open),
              icon: Icon(Icons.settings_sharp),
              tooltip: 'change credentials',
              onPressed: () {
                // print('change credentials pressed !');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => KgmsClassCredential(kClassDocument: document, isDelete: true),
                //   ),
                // );
                _kClassNavigation(
                    context,
                    KgmsClassCredential(
                        kClassDocument: document, isDelete: true));
              },
            ),
            onTap: () {
              // print('kgms class pressed !');
              //_KgmsClassCurrentDoc.docId = document.documentID;
              _KgmsClassCurrentDoc.docId = document.id;
              _KgmsClassCurrentDoc.className = document['className'];
              _KgmsClassCurrentDoc.classId = document['classId'];

              //Navigator.push(
              //  context,
              //  MaterialPageRoute(
              //    builder: (context) => KgmsStudy(),
              //  ),
              //);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KgmsClassStudyMain(),
                ),
              );
            }),
      );

  void _kClassNavigation(BuildContext context, KgmsClassCredential kcc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => kcc,
      ),
    );
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  // List<Card> listStudyClasses(BuildContext ctx, int count) => List.generate(
  //     count,
  //     (i) => _studyClassesTile(
  //         ctx,
  //         StudyClassesModel(
  //             (i + 1).toString(), 'ogroup', 'O Group', 'cat123')));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: kClassesCollectionRef.orderBy('classId').snapshots(),
      builder: (context, snapshot) {
        if (snapshot == null) {
          return _loadingTile('Please check the internet connection !');
        } else {
          if (snapshot.hasError)
            return _loadingTile('Something went wrong. Try later..!!');
          else
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _loadingTile('Loading....');
              default:
                {
                  //totalClasses.setTotalKList(snapshot.data.documents.length);
                  totalClasses.setTotalKList(snapshot.data.size);
                  return ListView.builder(
                    itemCount: snapshot.data.size,
                    itemBuilder: (context, index) => _studyClassesTile(
                        context, snapshot.data.docs[index], index),
                  );
                }
            }
        }
      },
    );
  }
}

class KgmsClassStudy extends StatelessWidget {
  KgmsClassStudy({Key key}) : super(key: key);

  final _totalClasses = _TotalKlist();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KgmsStudyClassAppBar(totalClasses: _totalClasses),
      body: KgmsStudyClassBody(totalClasses: _totalClasses),
    );
  }
}

class KgmsClassStudyMain extends StatelessWidget {
  KgmsClassStudyMain({Key key}) : super(key: key);

  Widget _buildMainButtons(BuildContext context, String s, StatelessWidget slw,
          IconData ic, bool checkInternet) =>
      FloatingActionButton.extended(
        label: Text(
          '$s',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        icon: Icon(
          ic,
          color: Colors.blue,
          size: 25,
        ),
        splashColor: Colors.green,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        onPressed: () async {
          if (slw != null) {
            if (checkInternet) {
              bool _internet = await isInternetAvailable();
              if (_internet) {
                Navigator.of(context).push(_createRoute(slw));
              } else {
                kAlert(context, noInternetWidget);
              }
            } else {
              Navigator.of(context).push(_createRoute(slw));
            }
          }
        },
        heroTag: '$s',
      );

  List<FloatingActionButton> _buildButtonList(BuildContext ctx) {
    List<FloatingActionButton> fabList = new List();
    fabList.add(_buildMainButtons(
        ctx, 'Study', KgmsStudy(), Icons.menu_book_rounded, true));
    fabList.add(_buildMainButtons(
        ctx,
        'Image',
        StudyMedia(
            className: _KgmsClassCurrentDoc.className,
            classId: _KgmsClassCurrentDoc.classId),
        Icons.add_photo_alternate,
        true));
    fabList.add(_buildMainButtons(
        ctx,
        'Video',
        StudyVideo(
            className: _KgmsClassCurrentDoc.className,
            classId: _KgmsClassCurrentDoc.classId),
        Icons.ondemand_video_rounded,
        true));
    //fabList
    //    .add(_buildMainButtons(ctx, 'Diary', null, Icons.book_rounded, true));
    //fabList.add(
    //    _buildMainButtons(ctx, 'Study', KgmsClassStudy(), Icons.face, true));
    // fabList.add(_buildMainButtons(ctx, 'Accounts', null, Icons.business));
    return fabList;
  }

  Route _createRoute(StatelessWidget slw) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => slw,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        // var curve = Curves.easeInOutSine;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class : ${_KgmsClassCurrentDoc.className}'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            primary: true,
            padding: const EdgeInsets.all(15),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            children: _buildButtonList(context),
          );
        },
      ),
    );
  }
}

class KgmsClassCredentialAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final DocumentSnapshot kClassDocument;
  final bool isDelete;

  KgmsClassCredentialAppBar(
      {Key key, this.kClassDocument, @required this.isDelete})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  AlertDialog _deleteAlertW(BuildContext context, String docID) => AlertDialog(
        title: const Text('Are you sure to delete ?'),
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
              // print('Delete doc: $docID');
              final KCircularProgress cp = KCircularProgress(ctx: context);
              cp.showCircularProgress();
              try {
                //QuerySnapshot snapshot = await kClassesCollectionRef
                //    .document(docID)
                //    .collection('kgms-study')
                //    .getDocuments();
                QuerySnapshot snapshot = await kClassesCollectionRef
                    .doc(docID)
                    .collection('kgms-study')
                    .get();
                //.getDocuments();

                for (QueryDocumentSnapshot ds in snapshot.docs) {
                  // print('DocID => ${ds.documentID}');
                  //await kClassesCollectionRef
                  //    .document(docID)
                  //    .collection('kgms-study')
                  //    .document(ds.documentID)
                  //    .delete();
                  //await kClassesCollectionRef
                  //    .document(docID)
                  //    .collection('kgms-study')
                  //    .document(ds.id)
                  //    .delete();
                  await kClassesCollectionRef
                      .doc(docID)
                      .collection('kgms-study')
                      .doc(ds.id)
                      .delete();
                }

                //await kClassesCollectionRef.document(docID).delete();
                await kClassesCollectionRef.doc(docID).delete();
                cp.closeProgress();
                Navigator.pop(context);
                Navigator.pop(context, 'Class deleted successfully..!!');
              } catch (e) {
                // _scaffoldKey2.currentState.showSnackBar(
                //     kSnackbar('Delete unsuccessful. Please check.'));
                cp.closeProgress();
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Delete unsuccessful. Please check.'));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            iconSize: 27,
            onPressed: () async {
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(isDelete ? 'Edit Class' : 'Add Class'),
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.delete_forever),
            iconSize: 30,
            tooltip: 'delete class',
            onPressed: () {
              // print('delete class');
              if (!isDelete) {
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Cannot delete new class.'));
              } else {
                //print('Delete Class Doc id: ${kClassDocument.documentID}');
                //kDAlert(
                //    context, _deleteAlertW(context, kClassDocument.documentID));
                kDAlert(context, _deleteAlertW(context, kClassDocument.id));
              }
            },
          ),
        ),
      ],
    );
  }
}

class KgmsClassCredentialForm extends StatefulWidget {
  final DocumentSnapshot kClassDocument;
  final bool isDelete;

  KgmsClassCredentialForm(
      {Key key, this.kClassDocument, @required this.isDelete})
      : super(key: key);

  @override
  _KgmsClassCredentialFormState createState() =>
      _KgmsClassCredentialFormState();
}

class _KgmsClassCredentialFormState extends State<KgmsClassCredentialForm> {
  GlobalKey<FormState> _formKey;
  TextEditingController _classNameCtrl;
  TextEditingController _classIDCtrl;
  TextEditingController _classPasswordCtrl;

  final _classIDFocus = FocusNode();
  final _classPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _classNameCtrl = TextEditingController(
        text: widget.kClassDocument != null
            ? widget.kClassDocument['className']
            : '');
    _classIDCtrl = TextEditingController(
        text: widget.kClassDocument != null
            ? widget.kClassDocument['classId']
            : '');
    _classPasswordCtrl = TextEditingController(
        text: widget.kClassDocument != null
            ? widget.kClassDocument['classPassword']
            : '');
  }

  @override
  void dispose() {
    _classNameCtrl.dispose();
    _classIDCtrl.dispose();
    _classPasswordCtrl.dispose();
    _formKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                controller: _classNameCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Class Name cannot be empty !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Class Name*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_classIDFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextFormField(
                controller: _classIDCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Class ID cannot be empty !';
                  } else if (value.split(' ').length > 1) {
                    return 'Class ID cannot have spaces !';
                  } else if (value != value.trim()) {
                    return 'Class ID cannot have spaces !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Class ID*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                focusNode: _classIDFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_classPasswordFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextFormField(
                controller: _classPasswordCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Class Password cannot be empty !';
                  } else if (value.split(' ').length > 1) {
                    return 'Class Password cannot have spaces !';
                  } else if (value != value.trim()) {
                    return 'Class Password cannot have spaces !';
                  } else if (value != value.toLowerCase()) {
                    return 'Class Password have to be lower case !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Class Password*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                focusNode: _classPasswordFocus,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: RaisedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      // print('Save Class Credentials');
                      bool _internet = await isInternetAvailable();
                      if (_internet) {
                        final KCircularProgress cp =
                            KCircularProgress(ctx: context);
                        cp.showCircularProgress();
                        if (widget.isDelete) {
                          // print('Update Class');
                          bool _isUpdate = false;
                          var kDataMap = Map<String, dynamic>();
                          if (_classNameCtrl.text !=
                              widget.kClassDocument['className']) {
                            _isUpdate = true;
                            kDataMap['className'] = _classNameCtrl.text;
                          }

                          if (_classIDCtrl.text !=
                              widget.kClassDocument['classId']) {
                            _isUpdate = true;
                            kDataMap['classId'] = _classIDCtrl.text;
                          }

                          if (_classPasswordCtrl.text !=
                              widget.kClassDocument['classPassword']) {
                            _isUpdate = true;
                            kDataMap['classPassword'] = _classPasswordCtrl.text;
                          }

                          if (_isUpdate) {
                            try {
                              //await kClassesCollectionRef
                              //    .document(widget.kClassDocument.documentID)
                              //    .updateData(kDataMap);
                              await kClassesCollectionRef
                                  .doc(widget.kClassDocument.id)
                                  .update(kDataMap);
                              cp.closeProgress();
                              Navigator.pop(context, 'Update success..!!');
                            } catch (e) {
                              cp.closeProgress();
                              Scaffold.of(context).showSnackBar(kSnackbar(
                                  'Update unsuccessful. Please check !'));
                            }
                          } else {
                            cp.closeProgress();
                            Scaffold.of(context).showSnackBar(
                                kSnackbar('Nothing to update..!!'));
                          }
                        } else {
                          // print('New Class');
                          var kDataMap = Map<String, dynamic>();
                          kDataMap['className'] = _classNameCtrl.text;
                          kDataMap['classId'] = _classIDCtrl.text;
                          kDataMap['classPassword'] = _classPasswordCtrl.text;

                          try {
                            final DocumentReference _dR =
                                await kClassesCollectionRef.add(kDataMap);
                            cp.closeProgress();
                            if (_dR != null)
                              Navigator.pop(context, 'New class added...!!');
                            else
                              Scaffold.of(context).showSnackBar(kSnackbar(
                                  'New class unsuccessful. Please check !'));
                          } catch (e) {
                            cp.closeProgress();
                            Scaffold.of(context).showSnackBar(kSnackbar(
                                'New class unsuccessful. Please check !'));
                          }
                        }
                      } else {
                        kAlert(context, noInternetWidget);
                      }
                    }
                  },
                  label: Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Icon(Icons.save, size: 28),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  splashColor: Colors.yellow,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KgmsClassCredential extends StatelessWidget {
  final DocumentSnapshot kClassDocument;
  final bool isDelete;

  KgmsClassCredential({Key key, this.kClassDocument, @required this.isDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: KgmsClassCredentialAppBar(
            kClassDocument: kClassDocument, isDelete: isDelete),
        body: Container(
          color: Colors.orange[300],
          alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              child: KgmsClassCredentialForm(
                  kClassDocument: kClassDocument, isDelete: isDelete),
            ),
          ),
        ),
      ),
    );
  }
}

// class KgmsStudyModel {
//   final String studyId;
//   final String studyHeader;
//   final String studySubHeader;
//   final String studyDesc;

//   KgmsStudyModel(
//       this.studyId, this.studyHeader, this.studySubHeader, this.studyDesc);
// }

class _KgmsClassCurrentDoc {
  static String docId;
  static String className;
  static String classId;
}

class KgmsStudyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CollectionReference kStudyCollectionRef;
  final _TotalKlist totalStudies;

  KgmsStudyAppBar(
      {Key key,
      @required this.kStudyCollectionRef,
      @required this.totalStudies})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  void _kStudyNavigation(BuildContext context, StatelessWidget ksc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ksc,
      ),
    );
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text('Study :'),
            Text('${_KgmsClassCurrentDoc.className}',
                style: TextStyle(fontSize: 17.5))
          ]),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 7),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'add new study',
            onPressed: () {
              //print('add new study');
              if (totalStudies.getTotalKlist() < 16) {
                _kStudyNavigation(
                    context,
                    KgmsStudyContent(
                        kStudyDocument: null,
                        isDelete: false,
                        kStudyCollectionRef: kStudyCollectionRef));
              } else {
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Max 16 Studies Allowed.'));
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 7),
          child: IconButton(
            icon: const Icon(Icons.add_photo_alternate, size: 30),
            tooltip: 'add new media',
            onPressed: () async {
              // print('add new media');
              bool _internet = await isInternetAvailable();
              if (_internet) {
                _kStudyNavigation(
                    context,
                    StudyMedia(
                        className: _KgmsClassCurrentDoc.className,
                        classId: _KgmsClassCurrentDoc.classId));
              } else {
                kAlert(context, noInternetWidget);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.ondemand_video_rounded, size: 28),
            tooltip: 'add new video',
            onPressed: () async {
              //print('add new video');
              bool _internet = await isInternetAvailable();
              if (_internet) {
                _kStudyNavigation(
                    context,
                    StudyVideo(
                        className: _KgmsClassCurrentDoc.className,
                        classId: _KgmsClassCurrentDoc.classId));
              } else {
                kAlert(context, noInternetWidget);
              }
            },
          ),
        ),
      ],
    );
  }
}

class KgmsStudyBody extends StatelessWidget {
  final CollectionReference kStudyCollectionRef;
  final _TotalKlist totalStudies;

  KgmsStudyBody(
      {Key key,
      @required this.kStudyCollectionRef,
      @required this.totalStudies})
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

  void _kStudyNavigation(BuildContext context, KgmsStudyContent ksc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ksc,
      ),
    );
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  Card _studyTile(BuildContext context, DocumentSnapshot document) => Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Text(
            document['header'],
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(document['subHeader']),
          ),
          leading: CircleAvatar(
            child: Text(
              document['studyNumber'].toString(),
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.mode_edit),
            tooltip: 'edit study',
            onPressed: () {
              // print('Edit study');
              _kStudyNavigation(
                  context,
                  KgmsStudyContent(
                      kStudyDocument: document,
                      isDelete: true,
                      kStudyCollectionRef: kStudyCollectionRef));
            },
          ),
        ),
      );

  // List<Card> listStudy(BuildContext ctx, int count) => List.generate(
  //     count,
  //     (i) => _studyTile(
  //         ctx,
  //         KgmsStudyModel((i + 1).toString(), 'This is Header ${i + 1}',
  //             '23rd June 1945', 'This is Description for ${i + 1}')));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: kStudyCollectionRef.orderBy('studyNumber').snapshots(),
      builder: (context, snapshot) {
        if (snapshot == null) {
          return _loadingTile('Please check the internet connection !');
        } else {
          if (snapshot.hasError)
            return _loadingTile('Something went wrong. Try later..!!');
          else
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _loadingTile('Loading....');
              default:
                {
                  //totalStudies.setTotalKList(snapshot.data.documents.length);
                  totalStudies.setTotalKList(snapshot.data.size);
                  if (snapshot.data.size > 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.size,
                      itemBuilder: (context, index) =>
                          _studyTile(context, snapshot.data.docs[index]),
                    );
                  } else {
                    return _loadingTile('No Study !');
                  }
                }
            }
        }
      },
    );
  }
}

class KgmsStudy extends StatelessWidget {
  KgmsStudy({Key key}) : super(key: key);

  //final kStudyCollectionRef = kClassesCollectionRef
  //    .document(_KgmsClassCurrentDoc.docId)
  //    .collection('kgms-study');
  final kStudyCollectionRef = kClassesCollectionRef
      .doc(_KgmsClassCurrentDoc.docId)
      .collection('kgms-study');

  final _totalStudies = _TotalKlist();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KgmsStudyAppBar(
          kStudyCollectionRef: kStudyCollectionRef,
          totalStudies: _totalStudies),
      body: KgmsStudyBody(
          kStudyCollectionRef: kStudyCollectionRef,
          totalStudies: _totalStudies),
    );
  }
}

class KgmsStudyContent extends StatelessWidget {
  final DocumentSnapshot kStudyDocument;
  final bool isDelete;
  final CollectionReference kStudyCollectionRef;

  KgmsStudyContent(
      {Key key,
      this.kStudyDocument,
      @required this.isDelete,
      @required this.kStudyCollectionRef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: KgmsStudyContentAppBar(
            kStudyDocument: kStudyDocument,
            isDelete: isDelete,
            kStudyCollectionRef: kStudyCollectionRef),
        body: Container(
          color: Colors.orange[300],
          alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              child: KgmsStudyContentForm(
                  kStudyDocument: kStudyDocument,
                  isDelete: isDelete,
                  kStudyCollectionRef: kStudyCollectionRef),
            ),
          ),
        ),
      ),
    );
  }
}

class KgmsStudyContentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final DocumentSnapshot kStudyDocument;
  final bool isDelete;
  final CollectionReference kStudyCollectionRef;

  KgmsStudyContentAppBar(
      {Key key,
      this.kStudyDocument,
      @required this.isDelete,
      @required this.kStudyCollectionRef})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  AlertDialog _deleteAlertW(BuildContext context, String docID) => AlertDialog(
        title: const Text('Are you sure to delete ?'),
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
              // print('Delete doc: $docID');
              final KCircularProgress cp = KCircularProgress(ctx: context);
              cp.showCircularProgress();
              try {
                //await kStudyCollectionRef.document(docID).delete();
                await kStudyCollectionRef.doc(docID).delete();
                cp.closeProgress();
                Navigator.pop(context);
                Navigator.pop(context, 'Study deleted successfully..!!');
              } catch (e) {
                // _scaffoldKey2.currentState.showSnackBar(
                //     kSnackbar('Delete unsuccessful. Please check.'));
                cp.closeProgress();
                Scaffold.of(context).showSnackBar(
                    kSnackbar('Delete unsuccessful. Please check.'));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            iconSize: 27,
            onPressed: () async {
              // print('Nav Pop');
              Navigator.pop(context);
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(isDelete
          ? 'Edit Study: ${_KgmsClassCurrentDoc.className}'
          : 'Add Study: ${_KgmsClassCurrentDoc.className}'),
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.delete_forever),
            iconSize: 30,
            tooltip: 'delete study',
            onPressed: () {
              //print('delete study');
              if (!isDelete) {
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Cannot delete new study.'));
              } else {
                //print('Delete Class Doc id: ${kStudyDocument.documentID}');
                //kDAlert(
                //    context, _deleteAlertW(context, kStudyDocument.documentID));
                kDAlert(context, _deleteAlertW(context, kStudyDocument.id));
              }
            },
          ),
        ),
      ],
    );
  }
}

class KgmsStudyContentForm extends StatefulWidget {
  final DocumentSnapshot kStudyDocument;
  final bool isDelete;
  final CollectionReference kStudyCollectionRef;

  KgmsStudyContentForm(
      {Key key,
      this.kStudyDocument,
      @required this.isDelete,
      @required this.kStudyCollectionRef})
      : super(key: key);

  @override
  _KgmsStudyContentFormState createState() => _KgmsStudyContentFormState();
}

class _KgmsStudyContentFormState extends State<KgmsStudyContentForm> {
  GlobalKey<FormState> _formKey;

  String _idCtrl;
  TextEditingController _headerCtrl;
  TextEditingController _subHeaderCtrl;
  TextEditingController _contentCtrl;

  final _subHeaderFocus = FocusNode();
  final _contentFocus = FocusNode();

  final List<String> _studyNumList = ['1', '2'];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    for (var i = 3; i < 16; i++) {
      _studyNumList.add(i.toString());
    }

    _idCtrl = widget.kStudyDocument != null
        ? widget.kStudyDocument['studyNumber'].toString()
        : '1';
    _headerCtrl = TextEditingController(
        text: widget.kStudyDocument != null
            ? widget.kStudyDocument['header']
            : '');
    _subHeaderCtrl = TextEditingController(
        text: widget.kStudyDocument != null
            ? widget.kStudyDocument['subHeader']
            : '');
    _contentCtrl = TextEditingController(
        text:
            widget.kStudyDocument != null ? widget.kStudyDocument['desc'] : '');
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _subHeaderCtrl.dispose();
    _contentCtrl.dispose();
    _formKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Study No.*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                ),
                value: _idCtrl,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 10,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 17,
                ),
                onChanged: ((String newValue) {
                  setState(() {
                    _idCtrl = newValue;
                  });
                }),
                items:
                    _studyNumList.map<DropdownMenuItem<String>>((String value) {
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
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                controller: _headerCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Header cannot be empty !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Header*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_subHeaderFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextFormField(
                controller: _subHeaderCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Sub Header cannot be empty !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Sub Header*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                focusNode: _subHeaderFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_contentFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                controller: _contentCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Content cannot be empty !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Content*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                textInputAction: TextInputAction.newline,
                maxLines: 10,
                minLines: 4,
                focusNode: _contentFocus,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: RaisedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      // print('Save Study');
                      bool _internet = await isInternetAvailable();
                      if (_internet) {
                        final KCircularProgress cp =
                            KCircularProgress(ctx: context);
                        cp.showCircularProgress();
                        if (widget.isDelete) {
                          //print('Update Study');
                          bool _isUpdate = false;
                          var kDataMap = Map<String, dynamic>();
                          if (_idCtrl !=
                              widget.kStudyDocument['studyNumber'].toString()) {
                            _isUpdate = true;
                            kDataMap['studyNumber'] = int.parse(_idCtrl);
                          }
                          if (_headerCtrl.text !=
                              widget.kStudyDocument['header']) {
                            _isUpdate = true;
                            kDataMap['header'] = _headerCtrl.text;
                          }

                          if (_subHeaderCtrl.text !=
                              widget.kStudyDocument['subHeader']) {
                            _isUpdate = true;
                            kDataMap['subHeader'] = _subHeaderCtrl.text;
                          }

                          if (_contentCtrl.text !=
                              widget.kStudyDocument['desc']) {
                            _isUpdate = true;
                            kDataMap['desc'] = _contentCtrl.text;
                          }

                          if (_isUpdate) {
                            try {
                              //await widget.kStudyCollectionRef
                              //    .document(widget.kStudyDocument.documentID)
                              //    .updateData(kDataMap);
                              await widget.kStudyCollectionRef
                                  .doc(widget.kStudyDocument.id)
                                  .update(kDataMap);
                              cp.closeProgress();
                              Navigator.pop(context, 'Update success..!!');
                            } catch (e) {
                              cp.closeProgress();
                              Scaffold.of(context).showSnackBar(kSnackbar(
                                  'Update unsuccessful. Please check !'));
                            }
                          } else {
                            cp.closeProgress();
                            Scaffold.of(context).showSnackBar(
                                kSnackbar('Nothing to update..!!'));
                          }
                        } else {
                          // print('New Study');
                          var kDataMap = Map<String, dynamic>();
                          kDataMap['studyNumber'] = int.parse(_idCtrl);
                          kDataMap['header'] = _headerCtrl.text;
                          kDataMap['subHeader'] = _subHeaderCtrl.text;
                          kDataMap['desc'] = _contentCtrl.text;

                          try {
                            final DocumentReference _dR =
                                await widget.kStudyCollectionRef.add(kDataMap);
                            cp.closeProgress();
                            if (_dR != null)
                              Navigator.pop(context, 'New study added...!!');
                            else
                              Scaffold.of(context).showSnackBar(kSnackbar(
                                  'New study unsuccessful. Please check !'));
                          } catch (e) {
                            cp.closeProgress();
                            Scaffold.of(context).showSnackBar(kSnackbar(
                                'New study unsuccessful. Please check !'));
                          }
                        }
                      } else {
                        kAlert(context, noInternetWidget);
                      }
                    }
                  },
                  label: Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Icon(Icons.save, size: 28),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  splashColor: Colors.yellow,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'eventsUi.dart' show KgmsEvents;
import 'studyUi.dart' show KgmsClassStudy;
//import 'self.dart';
import 'src/kUtil.dart';
import 'src/localCacheService.dart';
import 'src/localFileStorageService.dart';
import 'src/firebaseService.dart';
import 'src/firestoreService.dart';
import 'src/localDataStoreService.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'admissionUi.dart' show KgmsAdmission;
import 'studentsUi.dart' show KgmsStudentsWarpper;
import 'collectionReportUi.dart' show KgmsCollectionReport;
import 'collectionTransactionUi.dart' show KgmsCollectionTransactionWrapper;
import 'package:provider/provider.dart'
    show
        ReassembleHandler,
        Provider,
        ChangeNotifierProvider,
        Consumer,
        ChangeNotifierProvider;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(KgmsApp());
}

class KgmsApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  FutureBuilder _loadMainPage() => FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot == null) {
            return const Center(
              child: Text(
                'No internet connection !',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Init Error !',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider(
              create: (_) => LoginModel(),
              child: KgmsInitPage(),
            );
            //return KgmsLoginPage(userName: '');
          }

          return const Center(
            child: Text(
              'Loading.... ',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: MaterialApp(
        title: 'Kgms Admin',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
        ),
        home: _loadMainPage(),
      ),
    );
  }
}

class KgmsInitPage extends StatelessWidget {
  const KgmsInitPage({Key key}) : super(key: key);

  Widget _autoSignInWidget(BuildContext context) =>
      Consumer<LoginModel>(builder: (context, snapshot, _) {
        switch (snapshot.isWaiting) {
          case true:
            return const Scaffold(
              body: Center(
                child: Text(
                  'Checking.... !',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            );
          default:
            {
              if (snapshot.isSignedIn) {
                return KgmsMain(userN: snapshot.userId);
              } else {
                return KgmsLoginPage(userName: snapshot.userName);
              }
            }
        }
      });

  @override
  Widget build(BuildContext context) {
    return _autoSignInWidget(context);
  }
}

class LoginModel with ChangeNotifier implements ReassembleHandler {
  String _userId = '';

  String get userId => _userId;

  String _userName = '';

  String get userName => _userName;

  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  bool _isWaiting = true;

  bool get isWaiting => _isWaiting;

  LoginModel() {
    fServ.getCurrentUser().then((uid) {
      //print('uid from getCurrentUser --> $uid');
      if (uid != null) {
        _userId = uid;
        _isSignedIn = true;
        _isWaiting = false;
        firestoreServ.startKgmsClassesSubscription();
        notifyListeners();
      } else {
        cacheServ.getUserName().then((uName) {
          _userName = uName;
          _isSignedIn = false;
          _isWaiting = false;
          firestoreServ.stopKgmsClassesSubscription();
          notifyListeners();
        });
      }
    });
    DotEnv.load(fileName: ".env");
  }

  void logIn(String uName) {
    ////print('user logged in --> $uName !');
    _userId = uName;
    _isSignedIn = true;
    firestoreServ.startKgmsClassesSubscription();
    notifyListeners();
  }

  void logOut() {
    //print('user logged out --> $_userId !');
    cacheServ.getUserName().then((uName) {
      _userName = uName;
      _isSignedIn = false;
      firestoreServ.stopKgmsClassesSubscription();
      notifyListeners();
    });
  }

  @override
  void reassemble() {
    //print('Did hot-reload from LoginModel !');
  }
}

class KgmsLoginPage extends StatelessWidget {
  final String userName;
  const KgmsLoginPage({Key key, @required this.userName}) : super(key: key);

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
        appBar: AppBar(
          title: Text('Kgms Admin Login'),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.yellow,
          alignment: Alignment.center,
          // alignment: Alignment.topCenter,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, top: 15),
                    child: Image(
                      image: AssetImage('images/kgms_logo.png'),
                      fit: BoxFit.cover,
                      height: 165,
                    ),
                  ),
                  KgmsLogin(userName: userName),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KgmsLogin extends StatefulWidget {
  final String userName;
  const KgmsLogin({Key key, @required this.userName}) : super(key: key);

  @override
  _KgmsLoginState createState() => _KgmsLoginState();
}

class _KgmsLoginState extends State<KgmsLogin> {
  final _loginFormKey = GlobalKey<FormState>();

  final _uidCtrl = TextEditingController();
  final _passwdCtrl = TextEditingController();

  final _paswFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    //fServ.getCurrentUser().then((uid) {
    //  if (uid != null) {
    //    _loginNavigate(context, KgmsMain(userN: uid));
    //  } else {
    //    cacheServ.getUserName().then((uName) {
    //      this.setState(() {
    //        _uidCtrl.text = uName;
    //      });
    //    });
    //  }
    //});
    this.setState(() {
      _uidCtrl.text = widget.userName;
    });
  }

  @override
  void dispose() {
    _uidCtrl.dispose();
    _passwdCtrl.dispose();
    // //print("login disposed.....");
    super.dispose();
  }

  //void _loginNavigate(BuildContext context, KgmsMain kgm) async {
  //  await Navigator.push(
  //    context,
  //    MaterialPageRoute(
  //      builder: (context) => kgm,
  //    ),
  //  );
  //  cacheServ.getUserName().then((uName) {
  //    this.setState(() {
  //      _uidCtrl.text = uName;
  //    });
  //  });
  //  //final prefs = await SharedPreferences.getInstance();
  //  //this.setState(() {
  //  //  _uidCtrl.text = prefs.getString('kUserName') ?? '';
  //  //});
  //}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.blueAccent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  controller: _uidCtrl,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter valid email id !';
                    } else if (!EmailValidator.validate(value)) {
                      return 'please enter valid email id !';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: '-> user id *',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      //color: Colors.black54,
                    ),
                    border: OutlineInputBorder(),
                    //focusedBorder:
                    //    OutlineInputBorder(borderSide: BorderSide(width: 1.15)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    //focusColor: Colors.blue,
                    //filled: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_paswFocus);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  controller: _passwdCtrl,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter password !';
                    } else if (value.length < 6) {
                      return 'password should be atleast 6 characters !';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: '-> password *',
                    // hintText: 'Your kgms admin password !',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      //color: Colors.black54,
                    ),
                    border: OutlineInputBorder(),
                    //focusedBorder:
                    //    OutlineInputBorder(borderSide: BorderSide(width: 1.15)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    //focusColor: Colors.blue,
                    //filled: true,
                  ),
                  focusNode: _paswFocus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton.icon(
                    //Login button
                    onPressed: () async {
                      if (_loginFormKey.currentState.validate()) {
                        bool _internet = await isInternetAvailable();
                        if (_internet) {
                          final KCircularProgress cp =
                              KCircularProgress(ctx: context);
                          cp.showCircularProgress();
                          bool _signIn = await fServ.signIn(
                              _uidCtrl.text, _passwdCtrl.text);
                          if (_signIn) {
                            //SharedPreferences.getInstance().then((prefs) {
                            //  prefs.setString('kUserName', _uidCtrl.text);
                            //});
                            cacheServ.setUserName(_uidCtrl.text).then((res) {
                              //print('Set user name result --> $res');
                            });
                            String _userEmail = await fServ.getCurrentUser();
                            cp.closeProgress();
                            Provider.of<LoginModel>(context, listen: false)
                                .logIn(_userEmail);
                            //_loginNavigate(context, KgmsMain(userN: _userEmail));
                          } else {
                            cp.closeProgress();
                            kAlert(context, wrongLogin);
                          }
                        } else {
                          kAlert(context, noInternetWidget);
                        }
                      }
                    },
                    label: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        letterSpacing: 1,
                      ),
                    ),
                    // textTheme: ButtonTextTheme.accent,
                    // padding: const EdgeInsets.all(8.0),
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: const Icon(Icons.local_florist, size: 30),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    splashColor: Colors.yellow,
                    color: Colors.green,
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KgmsMain extends StatelessWidget {
  const KgmsMain({Key key, @required this.userN}) : super(key: key);

  //final String _title = 'Kgms Admin';
  final String userN;

  //FloatingActionButton _buildMainButtons(BuildContext context, String s,
  //        Widget slw, IconData ic, bool checkInternet) =>
  //    FloatingActionButton.extended(
  //      label: Text(
  //        '$s',
  //        style: TextStyle(
  //          color: Colors.black87,
  //          fontWeight: FontWeight.bold,
  //          fontSize: 17,
  //        ),
  //      ),
  //      icon: Icon(
  //        ic,
  //        color: Colors.blue,
  //        size: 25,
  //      ),
  //      splashColor: Colors.green,
  //      elevation: 10,
  //      shape: RoundedRectangleBorder(
  //        borderRadius: BorderRadius.all(Radius.circular(18)),
  //      ),
  //      onPressed: () async {
  //        if (slw != null) {
  //          if (checkInternet) {
  //            bool _internet = await isInternetAvailable();
  //            if (_internet) {
  //              Navigator.of(context).push(_createRoute(slw));
  //            } else {
  //              kAlert(context, noInternetWidget);
  //            }
  //          } else {
  //            Navigator.of(context).push(_createRoute(slw));
  //          }
  //        }
  //      },
  //      heroTag: '$s',
  //    );

  FloatingActionButton _buildMainButtons(BuildContext context, String s,
          Widget slw, IconData ic, bool checkInternet) =>
      FloatingActionButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              ic,
              color: Colors.blue,
              size: 30,
            ),
            SizedBox(height: 5.0),
            Text(
              '$s',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
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
    //List<FloatingActionButton> fabList = new List();
    final List<FloatingActionButton> fabList = [];
    fabList
        .add(_buildMainButtons(ctx, 'Event', KgmsEvents(), Icons.event, true));
    fabList.add(_buildMainButtons(
        ctx, 'Class', KgmsClassStudy(), Icons.meeting_room_rounded, true));
    fabList.add(_buildMainButtons(
        ctx, 'Amission', KgmsAdmission(), Icons.business, true));
    fabList.add(_buildMainButtons(
        ctx, 'Students', KgmsStudentsWarpper(), Icons.face, true));
    fabList.add(_buildMainButtons(ctx, 'Collection\nReport',
        KgmsCollectionReport(), Icons.bar_chart, false));
    fabList.add(_buildMainButtons(ctx, 'Daily\nTransaction',
        KgmsCollectionTransactionWrapper(), Icons.timeline, false));
    return fabList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kgms Admin',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.yellow,
              ),
              child: Text(
                'Welcome ~ \n\n $userN',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
            ),
            // ListTile(
            //     leading: Icon(Icons.account_circle),
            //     title: Text('Profile'),
            //     enabled: true,
            //     onTap: () async {
            //       String _uid = await fServ.getCurrentUser();
            //       if (_uid != null) {
            //         //print("uid = ${_uid}");
            //       } else {
            //         //print("uid = null");
            //       }
            //     }),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
                leading:
                    const Icon(Icons.account_balance_wallet_outlined, size: 27),
                title: const Text("Account Settings",
                    style: TextStyle(fontSize: 16, letterSpacing: 0.4)),
                enabled: true,
                onTap: () async {
                  ////print('app settings');
                  //Navigator.pop(context);
                  animatedCustomNonDismissibleAlert(
                      context, _KgmsSettingsDialog());
                }),
            SizedBox(
              height: 15.0,
            ),
            ListTile(
                leading: const Icon(Icons.restore_outlined, size: 27),
                title: const Text("Restore Student",
                    style: TextStyle(fontSize: 16, letterSpacing: 0.4)),
                enabled: true,
                onTap: () async {
                  //print('Restore Student !');
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    Navigator.pop(context);
                    Navigator.of(context).push(_createRoute(
                        KgmsStudentsWarpper(isRestoreStudent: true)));
                  } else {
                    kAlert(context, noInternetWidget);
                  }
                }),
            SizedBox(
              height: 15.0,
            ),
            ListTile(
                leading: const Icon(Icons.exit_to_app, size: 27),
                title: const Text('Sign Out',
                    style: TextStyle(fontSize: 16, letterSpacing: 0.4)),
                enabled: true,
                onTap: () async {
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    bool _isSignOut = await fServ.signOut();
                    if (_isSignOut) {
                      // //print("Sign Out successful");
                      //Navigator.pop(context);
                      Navigator.pop(context);
                      Provider.of<LoginModel>(context, listen: false).logOut();
                    } else {
                      // //print("Sign Out Not successful");
                      kAlert(context, wrongSignOut);
                    }
                  } else {
                    kAlert(context, noInternetWidget);
                  }
                }),
          ],
        ),
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

Route _createRoute(Widget slw) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => slw,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      // var curve = Curves.easeInOutSine;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _KgmsSettingsDialog extends StatefulWidget {
  const _KgmsSettingsDialog({Key key}) : super(key: key);

  @override
  _KgmsSettingsDialogState createState() => _KgmsSettingsDialogState();
}

class _KgmsSettingsDialogState extends State<_KgmsSettingsDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _admissionFeeCtrl = TextEditingController();
  final TextEditingController _tuitionFeeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(milliseconds: 1000),
        () => fileServ.readDataByKey('kgmsSettings').then((data) {
              if (data != 'nil') {
                try {
                  final _jsonObj = convert.jsonDecode(data);
                  _admissionFeeCtrl.text = _jsonObj['admissionFee'];
                  _tuitionFeeCtrl.text = _jsonObj['tuitionFee'];
                } on FormatException catch (e) {
                  //print('getKgmsSettings data = $data and error = $e');
                }
              }
            }));
  }

  Map _accountsToJson() => {
        'admissionFee': _admissionFeeCtrl.text,
        'tuitionFee': _tuitionFeeCtrl.text,
      };

  @override
  void dispose() {
    _admissionFeeCtrl.dispose();
    _tuitionFeeCtrl.dispose();
    super.dispose();
  }

  //void clearKeyBoard(BuildContext context) async {
  //  FocusScopeNode currentFocus = FocusScope.of(context);
  //  if (!currentFocus.hasPrimaryFocus) {
  //    currentFocus.unfocus();
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Settings',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text('Accounts',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          trailing: const Icon(
            Icons.settings,
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: TextFormField(
                      controller: _admissionFeeCtrl,
                      validator: (value) {
                        //if (value.isEmpty) {
                        //  return 'Roll no. empty !';
                        //}
                        if (value.isEmpty) {
                          return 'Admission fee cannot be empty !';
                        } else if (!value.isEmpty && !isNumFromString(value)) {
                          return 'not number !';
                        } else if (int.tryParse(value) <= 0) {
                          return 'not valid number';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Admission fee',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: TextFormField(
                      controller: _tuitionFeeCtrl,
                      validator: (value) {
                        //if (value.isEmpty) {
                        //  return 'Roll no. empty !';
                        //}
                        if (value.isEmpty) {
                          return 'Tuition fee cannot be empty !';
                        } else if (!value.isEmpty && !isNumFromString(value)) {
                          return 'not number !';
                        } else if (int.tryParse(value) <= 0) {
                          return 'not valid number';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tuition fee',
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
                  if (_formKey.currentState.validate()) {
                    //print('validate success');
                    //Navigator.of(context).pop();
                    final jsonStr = convert.jsonEncode(_accountsToJson());
                    //print('json --> $jsonStr');
                    fileServ
                        .writeKeyWithData('kgmsSettings', jsonStr)
                        .then((result) {
                      ////print('writeKeyWithData = key kgmsSettings --> $result');
                      if (result) dataStoreServ.resetFeeStructureFromCache();
                    });
                    clearKeyBoard(context);
                    Navigator.of(context).pop();
                  } else {
                    //print('validate not success');
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
                  clearKeyBoard(context);
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

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  const LifeCycleManager({Key key, @required this.child}) : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    firestoreServ.disposeService();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      //print('state paused = $state');
    } else if (state == AppLifecycleState.resumed) {
      //print('state resumed = $state');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'eventsUi.dart';
import 'self.dart';

void main() => runApp(KgmsApp());

class KgmsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kgms Admin',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: KgmsLoginPage(),
    );
  }
}

class KgmsLoginPage extends StatelessWidget {
  KgmsLoginPage({Key key}) : super(key: key);

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
                  KgmsLogin(),
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
  KgmsLogin({Key key}) : super(key: key);

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
    fServ.getCurrentUser().then((uid) {
      if (uid != null) {
        // print('uid $uid');
        // Navigator.of(context).push(_createRoute(KgmsMain(userN: uid)));
        _loginNavigate(context, KgmsMain(userN: uid));
      }else{
        SharedPreferences.getInstance().then((prefs) {
      this.setState((){
          _uidCtrl.text = prefs.getString('kUserName') ?? '';
        });
    });
      }
    });
  }

  @override
  void dispose() {
    _uidCtrl.dispose();
    _passwdCtrl.dispose();
    // fServ.signOut();
    // print("login disposed.....");
    super.dispose();
  }

  void _loginNavigate(BuildContext context, KgmsMain kgm) async {
    // await Navigator.of(context).push(_createRoute(kgm));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => kgm,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    this.setState((){
        _uidCtrl.text = prefs.getString('kUserName') ?? '';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 1.15)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  focusColor: Colors.blue,
                  filled: true,
                ),
                style: TextStyle(
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
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 1.15)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  focusColor: Colors.blue,
                  filled: true,
                ),
                focusNode: _paswFocus,
                style: TextStyle(
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
                        // print("internet OK...!!");
                        bool _signIn =
                            await fServ.signIn(_uidCtrl.text, _passwdCtrl.text);
                        if (_signIn) {
                          // print("signed successful.......!!");
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('kUserName', _uidCtrl.text);
                          });
                          String _userEmail = await fServ.getCurrentUser();
                          // Navigator.of(context)
                          //     .push(_createRoute(KgmsMain(userN: _userEmail)));
                          _loginNavigate(context, KgmsMain(userN: _userEmail));
                        } else {
                          // print("signed not successful...........!!");
                          kAlert(context, wrongLogin);
                        }
                      } else {
                        // print("internet No...!!");
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
    );
  }
}

class KgmsMain extends StatelessWidget {
  KgmsMain({Key key, @required this.userN}) : super(key: key);

  final String _title = 'Kgms Admin';
  final String userN;

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

  // List<FloatingActionButton> ListMButtons(int count) => List.generate(
  //     count,
  //     (i) => _buildMainButtons(i));

  List<FloatingActionButton> _buildButtonList(BuildContext ctx) {
    List<FloatingActionButton> fabList = new List();
    fabList
        .add(_buildMainButtons(ctx, 'Events', KgmsEvents(), Icons.event, true));
    // fabList.add(_buildMainButtons(ctx, 'Accounts', null, Icons.business));
    return fabList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
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
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
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
            //         print("uid = ${_uid}");
            //       } else {
            //         print("uid = null");
            //       }
            //     }),
            ListTile(
                leading: Icon(Icons.exit_to_app),
                title: const Text('Sign Out'),
                enabled: true,
                onTap: () async {
                  bool _internet = await isInternetAvailable();
                  if (_internet) {
                    bool _isSignOut = await fServ.signOut();
                    if (_isSignOut) {
                      // print("Sign Out successful");
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      // print("Sign Out Not successful");
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
            mainAxisSpacing: 10,
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            children: _buildButtonList(context),
          );
        },
      ),
    );
  }
}

Route _createRoute(StatelessWidget slw) {
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

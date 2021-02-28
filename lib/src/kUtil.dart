import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

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
      CircularProgressIndicator(),
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
  title: Center(
    child: ListTile(
      leading: Icon(
        Icons.block,
        color: Colors.black,
      ),
      title: Text(
        'No internet...!!',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
    ),
  ),
  titleTextStyle: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  elevation: 15,
);

final wrongLogin = AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  title: Center(
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
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Text('please check user id or password.'),
      ),
    ),
  ),
  titleTextStyle: TextStyle(
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
  title: Center(
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
        padding: const EdgeInsets.only(top: 12.0),
        child: Text('Something went wrong. Try later...!!'),
      ),
    ),
  ),
  titleTextStyle: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  elevation: 15,
  // contentPadding: const EdgeInsets.all(5),
);

SnackBar kSnackbar(String msg) => SnackBar(
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          // fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.lightBlue,
      duration: Duration(seconds: 2),
    );

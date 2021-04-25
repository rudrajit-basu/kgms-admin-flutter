import 'package:flutter/material.dart';
import 'self.dart';
//import 'dart:convert' as convert;
//import 'dart:async';

class KgmsStudents extends StatelessWidget {
  const KgmsStudents({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kgms Students'),
      ),
      body: KgmsStudentsBody(),
    );
  }
}

class KgmsStudentsBody extends StatelessWidget {
  KgmsStudentsBody({Key key}) : super(key: key);

  List<_DemoStudentDetails> _getDemoDetailsData() {
    final List<_DemoStudentDetails> _demoData = [];
    _demoData.add(_DemoStudentDetails("d.o.a", '11/04/2021'));
    _demoData.add(_DemoStudentDetails("Paid", '03/2021'));
    _demoData.add(_DemoStudentDetails("Medium", 'Bengali'));
    _demoData.add(_DemoStudentDetails('2nd language', 'English'));
    _demoData.add(_DemoStudentDetails('d.o.b', '14/03/1988'));
    _demoData
        .add(_DemoStudentDetails('Father name', 'Scalable Vector Graphics'));
    _demoData.add(_DemoStudentDetails('Mother name', 'Portable Network'));
    _demoData.add(
        _DemoStudentDetails('Local guardian', 'Portable Document Graphics'));
    _demoData.add(_DemoStudentDetails('Contact 1', '9748434478'));
    _demoData.add(_DemoStudentDetails('Contact 2', ''));
    _demoData.add(_DemoStudentDetails('Email id', 'rbasu.linux@gmail.com'));
    _demoData.add(_DemoStudentDetails('Address 1',
        'Ukilpara, P.s. - Kotwali, P.o & district - Jalpaiguri, pin - 735101, West Bengal'));
    _demoData.add(_DemoStudentDetails('Address 2', ''));
    return _demoData;
  }

  Card _studentTile(BuildContext context) => Card(
        color: Colors.orange[300],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 4.0),
                child: ListTile(
                  title: Text(
                    'Rudrajit Narayan Basu',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      'Class - Dolna Ghar, Sec - B, Roll no. - 59',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        //wordSpacing: 0.9,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Details'),
                      onPressed: () async {
                        //print('student details -->');
                        kDAlert(
                            context,
                            _KgmsStudentDetails(
                                demoData: _getDemoDetailsData()));
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.465)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      child: const Text('Accounts'),
                      onPressed: () {
                        print('student accounts -->');
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.46)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        print('student delete -->');
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black.withOpacity(0.46)),
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _studentTile(context);
  }
}

class _KgmsStudentDetails extends StatelessWidget {
  final List<_DemoStudentDetails> demoData;
  _KgmsStudentDetails({Key key, @required this.demoData}) : super(key: key);

  Widget _lableDataWidget(String label, String data) => ListTile(
        title: Text('$label',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 15,
              letterSpacing: 0.7,
            )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(data.isEmpty ? 'nil' : '$data',
              style: TextStyle(
                //fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 15,
                letterSpacing: 0.25,
              )),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: ListTile(
          title: const Text('Details :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
              )),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text('Rudrajit Narayan Basu',
                style: TextStyle(color: Colors.black, fontSize: 16)),
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
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: demoData.length,
          itemBuilder: (context, index) =>
              _lableDataWidget(demoData[index].label, demoData[index].data),
          separatorBuilder: (context, index) => Divider(
            height: 4.2,
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: ElevatedButton(
            onPressed: () {
              print('edit student !');
            },
            child: const Text('Edit',
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

class _DemoStudentDetails {
  final String _lable;
  final String _data;

  _DemoStudentDetails(this._lable, this._data);

  String get label => _lable;
  String get data => _data;
}

//class ClassPlaylistModel {
//  final String id;
//  final String title;

//  ClassPlaylistModel(this.id, this.title);

//  factory ClassPlaylistModel.fromJson(dynamic json) {
//    return ClassPlaylistModel(json['id'] as String, json['title'] as String);
//  }

//  //Map<String, dynamic> toMap() {
//  //  return {'id': id, 'title': title};
//  //}

//  @override
//  String toString() {
//    return '{${this.id}, ${this.title}}';
//  }
//}

//final Map<String, bool> _classListData = {
//  'Dolna Ghar': false,
//  'O Group': false,
//  'Nursery': false,
//  'Kg': false,
//  'One': false,
//  'Two': false,
//  'Three': false,
//  'Four': false,
//};

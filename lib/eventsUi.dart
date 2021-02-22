import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'self.dart';

//final kEventsCollectionRef = Firestore.instance.collection('kgms-events');
final kEventsCollectionRef =
    FirebaseFirestore.instance.collection('kgms-events');

class _TotalEvents {
  int _totEvents = 7;

  int getTotalEvents() {
    return _totEvents;
  }

  void setTotalEvents(int tEvents) {
    this._totEvents = tEvents;
  }
}

class KgmsEventsBody extends StatelessWidget {
  final _TotalEvents totalEvents;

  KgmsEventsBody({Key key, @required this.totalEvents}) : super(key: key);

  Card _loadingTile(String msg) => Card(
        color: Colors.orange[300],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Text(
            // em.title,
            msg,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
              // em.eventId,
              '0',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  Card _eventTile(BuildContext context, DocumentSnapshot document) => Card(
        color: Colors.orange[300],
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          title: Text(
            // em.title,
            document['header'],
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              // em.subtitle,
              document['date'],
            ),
          ),
          leading: CircleAvatar(
            child: Text(
              // em.eventId,
              document['tagId'].toString(),
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'edit event',
            onPressed: () {
              _eventNavigation(
                  context, KgmsEventsFSD(document: document, isDelete: true));
            },
          ),
        ),
      );

  void _eventNavigation(BuildContext context, KgmsEventsFSD eFsd) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => eFsd,
      ),
    );
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: kEventsCollectionRef.orderBy('tagId').snapshots(),
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
                    // _totEvents = snapshot.data.documents.length;
                    //totalEvents.setTotalEvents(snapshot.data.documents.length);
                    totalEvents.setTotalEvents(snapshot.data.size);
                    return ListView.builder(
                      itemCount: snapshot.data.size,
                      itemBuilder: (context, index) =>
                          _eventTile(context, snapshot.data.docs[index]),
                    );
                  }
              }
          }
        });
  }
}

class KgmsEventsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final _TotalEvents totalEvents;

  KgmsEventsAppBar({Key key, @required this.totalEvents})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  void _eventNavigation(BuildContext context, KgmsEventsFSD eFsd) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => eFsd,
      ),
    );
    // print('result: $result');
    if (result != null) {
      Scaffold.of(context).showSnackBar(kSnackbar(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Event Management'),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'add event',
            onPressed: () {
              // print('totE: $_totEvents');
              if (totalEvents.getTotalEvents() < 10) {
                _eventNavigation(
                    context, KgmsEventsFSD(document: null, isDelete: false));
              } else {
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Max 10 Events Allowed.'));
              }
            },
          ),
        ),
      ],
    );
  }
}

class KgmsEvents extends StatelessWidget {
  KgmsEvents({Key key}) : super(key: key);

  final _totalEvents = _TotalEvents();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KgmsEventsAppBar(totalEvents: _totalEvents),
      body: KgmsEventsBody(totalEvents: _totalEvents),
    );
  }
}

class KgmsEventsFSDAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final DocumentSnapshot document;
  final bool isDelete;

  KgmsEventsFSDAppBar({Key key, this.document, @required this.isDelete})
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
                //await kEventsCollectionRef.document(docID).delete();
                await kEventsCollectionRef.doc(docID).delete();
                cp.closeProgress();
                Navigator.pop(context);
                Navigator.pop(context, 'Event deleted successfully..!!');
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
      title: Text(isDelete ? 'Edit Event' : 'Add Event'),
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
            tooltip: 'delete event',
            onPressed: () async {
              if (!isDelete) {
                // _scaffoldKey2.currentState
                //     .showSnackBar(kSnackbar('Cannot delete new event.'));
                Scaffold.of(context)
                    .showSnackBar(kSnackbar('Cannot delete new event.'));
              } else {
                // print('delete doc: ${document.documentID}');
                //kDAlert(context, _deleteAlertW(context, document.documentID));
                kDAlert(context, _deleteAlertW(context, document.id));
              }
            },
          ),
        ),
      ],
    );
  }
}

class KgmsEventsFSD extends StatelessWidget {
  // final EventModel em;
  final DocumentSnapshot document;
  final bool isDelete;

  KgmsEventsFSD({Key key, this.document, @required this.isDelete})
      : super(key: key);

  // final GlobalKey<ScaffoldState> _scaffoldKey2 = GlobalKey<ScaffoldState>();

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
        // key: _scaffoldKey2,
        appBar: KgmsEventsFSDAppBar(document: document, isDelete: isDelete),
        body: Container(
          color: Colors.orange[300],
          alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              child: KgmsEventsForm(document: document, isDelete: isDelete),
            ),
          ),
        ),
      ),
    );
  }
}

class KgmsEventsForm extends StatefulWidget {
  // final EventModel em;
  final DocumentSnapshot document;
  final bool isDelete;

  KgmsEventsForm({Key key, this.document, this.isDelete}) : super(key: key);

  @override
  _KgmsEventsFormState createState() => _KgmsEventsFormState();
}

class _KgmsEventsFormState extends State<KgmsEventsForm> {
  GlobalKey<FormState> _formKey;
  // String ddbValue;

  final _subtitleFocus = FocusNode();
  final _descFocus = FocusNode();

  String _idCtrl;
  // final _headerCtrl = TextEditingController.fromValue();
  // final _subHeaderCtrl = TextEditingController();
  // final _descCtrl = TextEditingController();
  TextEditingController _headerCtrl;
  TextEditingController _subHeaderCtrl;
  TextEditingController _descCtrl;

  final List<String> _eventNumList = ['1', '2'];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    for (var i = 3; i < 11; i++) {
      _eventNumList.add(i.toString());
    }
    _idCtrl =
        widget.document != null ? widget.document['tagId'].toString() : '1';
    _headerCtrl = TextEditingController(
        text: widget.document != null ? widget.document['header'] : '');
    _subHeaderCtrl = TextEditingController(
        text: widget.document != null ? widget.document['date'] : '');
    _descCtrl = TextEditingController(
        text: widget.document != null ? widget.document['desc'] : '');
  }

  @override
  void dispose() {
    // print('event disposed........');
    _headerCtrl.dispose();
    _subHeaderCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Event Id*',
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
                    _eventNumList.map<DropdownMenuItem<String>>((String value) {
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
              padding: const EdgeInsets.symmetric(vertical: 15),
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
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                ),
                // initialValue: widget.em.title,
                // initialValue:
                //     widget.document != null ? widget.document['header'] : '',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_subtitleFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                controller: _subHeaderCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Sub header cannot be empty !';
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
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                ),
                // initialValue: widget.em.subtitle,
                // initialValue:
                //     widget.document != null ? widget.document['date'] : '',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                focusNode: _subtitleFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_descFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                controller: _descCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Description cannot be empty !';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                ),
                // initialValue: widget.em.desc,
                // initialValue:
                //     widget.document != null ? widget.document['desc'] : '',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.9,
                ),
                textInputAction: TextInputAction.newline,
                maxLines: 10,
                minLines: 4,
                focusNode: _descFocus,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: RaisedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      bool _internet = await isInternetAvailable();
                      if (_internet) {
                        final KCircularProgress cp =
                            KCircularProgress(ctx: context);
                        cp.showCircularProgress();
                        if (widget.isDelete) {
                          bool _isUpdate = false;
                          var kDataMap = Map<String, dynamic>();
                          // print('Editable Event');
                          if (_idCtrl != widget.document['tagId'].toString()) {
                            // print('update event id');
                            _isUpdate = true;
                            kDataMap['tagId'] = int.parse(_idCtrl);
                          }
                          if (_headerCtrl.text != widget.document['header']) {
                            // print('update header');
                            _isUpdate = true;
                            kDataMap['header'] = _headerCtrl.text;
                          }
                          if (_subHeaderCtrl.text != widget.document['date']) {
                            // print('update sub header');
                            _isUpdate = true;
                            kDataMap['date'] = _subHeaderCtrl.text;
                          }
                          if (_descCtrl.text != widget.document['desc']) {
                            // print('update desc');
                            _isUpdate = true;
                            kDataMap['desc'] = _descCtrl.text;
                          }
                          if (_isUpdate) {
                            // print(kDataMap);
                            // print(
                            //     'submit update ${widget.document.documentID}');
                            try {
                              //await kEventsCollectionRef
                              //    .document(widget.document.documentID)
                              //    .updateData(kDataMap);
                              await kEventsCollectionRef
                                  .doc(widget.document.id)
                                  .update(kDataMap);
                              cp.closeProgress();
                              Navigator.pop(context, 'Update success..!!');
                            } catch (e) {
                              cp.closeProgress();
                              Scaffold.of(context).showSnackBar(kSnackbar(
                                  'Update unsuccessful. Please check !'));
                            }
                          } else {
                            // print('nothing to update');
                            cp.closeProgress();
                            Scaffold.of(context).showSnackBar(
                                kSnackbar('Nothing to update..!!'));
                          }
                        } else {
                          // print('New Event');
                          var kDataMap = Map<String, dynamic>();
                          kDataMap['tagId'] = int.parse(_idCtrl);
                          kDataMap['header'] = _headerCtrl.text;
                          kDataMap['date'] = _subHeaderCtrl.text;
                          kDataMap['desc'] = _descCtrl.text;
                          try {
                            final DocumentReference _dR =
                                await kEventsCollectionRef.add(kDataMap);
                            cp.closeProgress();
                            if (_dR != null)
                              Navigator.pop(context, 'New event added...!!');
                            else
                              Scaffold.of(context).showSnackBar(kSnackbar(
                                  'New event unsuccessful. Please check !'));
                          } catch (e) {
                            cp.closeProgress();
                            Scaffold.of(context).showSnackBar(kSnackbar(
                                'New event unsuccessful. Please check !'));
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

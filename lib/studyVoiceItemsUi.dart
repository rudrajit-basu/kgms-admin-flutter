import 'package:flutter/material.dart';

class StudyVoiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  StudyVoiceAppBar({Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const Text('Video :'),
          Text('O group', style: TextStyle(fontSize: 17.5)),
        ],
      ),
    );
  }
}

class StudyVoice extends StatelessWidget {
  StudyVoice({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudyVoiceAppBar(),
      body: Center(
        child: const Text('Voice wala !'),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 57.0,
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton.icon(
                  onPressed: () => print('start recording !'),
                  label: const Text(
                    'Record',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Icon(Icons.keyboard_voice_outlined, size: 25.2),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  //splashColor: Colors.yellow,
                  color: Colors.lightBlue[600],
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      //floatingActionButton: FloatingActionButton(
      //  onPressed: () => print('start recording !'),
      //  tooltip: 'Increment Counter',
      //  child: const Icon(Icons.keyboard_voice, size: 27.5),
      //  backgroundColor: Colors.lightBlue[600],
      //  foregroundColor: Colors.white,
      //),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

# ![alt text][logo] &nbsp;&nbsp;kgms_admin

A Flutter project to create an android app for Khela Ghar Montessory School admin use. (not yet realesed at play store)

The technical details are presented below the screen shots of the app.

The app provides the following options to manage the school's student records, classwise online study materials (notes, pictures, videos and audio) and wesite events.

* Login and Home screen

<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_1.jpg" alt="kgms login" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_2.jpg" alt="Home screen" height="700"/>

* Wesite events @ [Khela Ghar Montessory School Website](https://kgmskid.web.app/)

<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_3.jpg" alt="wesite events" height="700"/>

* School classes and it's classwise online study materials (notes, pictures, videos and audio) @ [Khela Ghar Montessory Study App](https://kgmskid-study.web.app/)

<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_4.jpg" alt="Kgms classes" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_5.jpg" alt="kgms class study home" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_6.jpg" alt="kgms class study notes" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_7.jpg" alt="kgms class study pictures" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_8.jpeg" alt="kgms class study videos list" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_9.jpg" alt="kgms class study videos play" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_10.jpg" alt="kgms class study audio" height="700"/>

* School's student record management system

<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_11.jpg" alt="Kgms stdent admission" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_12.jpg" alt="kgms student list" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_15.jpg" alt="kgms student list" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_13.jpg" alt="kgms student list" height="700"/> &nbsp;&nbsp;&nbsp;<img src="https://github.com/rudrajit-basu/kgms-admin-flutter/blob/master/screenShots/Screenshot_14.jpg" alt="kgms student list" height="700"/>


The app is using two different cloud services as follows
* [Firebase](https://firebase.google.com/) (Firestore, Storage) to manage the school's class online study and website's events.
* [Deta](https://www.deta.sh/) (Base, Micro) to manage the school's student record system.

The server side node.js app running on Deta Micro using Deta Base is [here](https://github.com/rudrajit-basu/kgmskid_accounts_micro).

The third party api used are as follows
* [Email validator](https://pub.dev/packages/email_validator)
* [Shared preferences](https://pub.dev/packages/shared_preferences)
* [File picker](https://pub.dev/packages/file_picker)
* [Cached network image](https://pub.dev/packages/cached_network_image)
* [Provider](https://pub.dev/packages/provider)
* [Oauth2 client](https://pub.dev/packages/oauth2_client)
* [DateTime picker](https://pub.dev/packages/flutter_datetime_picker)
* [Path provider](https://pub.dev/packages/path_provider)
* [Sound recorder](https://pub.dev/packages/flutter_sound)
* [Dot Env](https://pub.dev/packages/flutter_dotenv)
* [Charts](https://pub.dev/packages/charts_flutter)
* [Youtube api v3](https://developers.google.com/youtube/v3/guides/auth/installed-apps)
* [Youtube player](https://developers.google.com/youtube/android/player)

contact @ rudrajit.basu@gmail.com or rbasu.linux@gmail.com.

[logo]: https://github.com/rudrajit-basu/kgms-kid/blob/master/public/kgms_w64.png

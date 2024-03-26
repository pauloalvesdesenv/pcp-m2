// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyArDF3DcSwhocSFg0R_9U2y2YTS7NTzCXA',
    appId: '1:210867609065:web:9f428880737f7af2bc3f78',
    messagingSenderId: '210867609065',
    projectId: 'aco-plus-fa455',
    authDomain: 'aco-plus-fa455.firebaseapp.com',
    storageBucket: 'aco-plus-fa455.appspot.com',
    measurementId: 'G-SVFPP99C61',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCU47wXoaBO8eabFmKUiXIhPe-Xo7sbhaw',
    appId: '1:210867609065:android:91662436a9e9a893bc3f78',
    messagingSenderId: '210867609065',
    projectId: 'aco-plus-fa455',
    storageBucket: 'aco-plus-fa455.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9pDGff2u3kpWYZsreSzkBynG2bl9t24U',
    appId: '1:210867609065:ios:deae8ede003e8115bc3f78',
    messagingSenderId: '210867609065',
    projectId: 'aco-plus-fa455',
    storageBucket: 'aco-plus-fa455.appspot.com',
    iosBundleId: 'com.m2.acoplus.RunnerTests',
  );
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: "AIzaSyC0C0C-Hrj7vpUUS8Iw_XmftAdU6LsZcAg",
    appId: "1:74452436250:web:bf5875afc8982d0001d8a3",
    messagingSenderId: "74452436250",
    projectId: 'openairplayer',
    authDomain: 'openairplayer.firebaseapp.com',
    storageBucket: 'openairplayer.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBt_Hx2GOZ8reLOiNb8uUt-c6_dbizPDNg',
    appId: '1:74452436250:android:9b15a2b095558b1501d8a3',
    messagingSenderId: '74452436250',
    projectId: 'openairplayer',
    storageBucket: 'openairplayer.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARYYuj8lTMJimmQ-ZqyCwuJLDymScalhE',
    appId: '1:74452436250:ios:0a614ecee134f6c801d8a3',
    messagingSenderId: '74452436250',
    projectId: 'openairplayer',
    storageBucket: 'openairplayer.firebasestorage.app',
    iosBundleId: 'com.liquidhive.openair',
  );
}

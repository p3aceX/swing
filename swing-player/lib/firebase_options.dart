import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDa9s9t5nGb_RZqsYrhcFdpJMJB_3XbF0U',
    appId: '1:594513906251:android:bb4fb751232fff7ce41bce',
    messagingSenderId: '594513906251',
    projectId: 'swing-35d52',
    storageBucket: 'swing-35d52.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_YhSxMbQvZhRgQmssZNvuAbNr3iOE56Y',
    appId: '1:594513906251:ios:8b1397b1579b0153e41bce',
    messagingSenderId: '594513906251',
    projectId: 'swing-35d52',
    storageBucket: 'swing-35d52.firebasestorage.app',
    iosBundleId: 'com.swing.swing',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_YhSxMbQvZhRgQmssZNvuAbNr3iOE56Y',
    appId: '1:594513906251:ios:8b1397b1579b0153e41bce',
    messagingSenderId: '594513906251',
    projectId: 'swing-35d52',
    storageBucket: 'swing-35d52.firebasestorage.app',
    iosBundleId: 'com.swing.swing',
  );
}

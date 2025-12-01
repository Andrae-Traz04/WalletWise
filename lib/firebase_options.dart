import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6htj5cHcxk1EQ6xcpDPTltgkLdY4p-7s',
    authDomain: 'walletwiseapp-e0f68.firebaseapp.com',
    projectId: 'walletwiseapp-e0f68',
    storageBucket: 'walletwiseapp-e0f68.firebasestorage.app',
    messagingSenderId: '824489867326',
    appId: 'PASTE_WEB_APP_ID', // ← replace with the Web appId (not the Android one)
    measurementId: 'G-XXXXXXXX', // ← replace with real Measurement ID if using Analytics on web
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6htj5cHcxk1EQ6xcpDPTltgkLdY4p-7s',
    appId: '1:824489867326:android:1d3e6b96a7b0963459f96f',
    messagingSenderId: '824489867326',
    projectId: 'walletwiseapp-e0f68',
    storageBucket: 'walletwiseapp-e0f68.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PASTE_IOS_API_KEY',
    appId: 'PASTE_IOS_APP_ID',
    messagingSenderId: '824489867326',
    projectId: 'walletwiseapp-e0f68',
    storageBucket: 'walletwiseapp-e0f68.firebasestorage.app',
    iosBundleId: 'com.example.flutter_application_1',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }
}
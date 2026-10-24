import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project `bizpilot-ai-2e1ed`.
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnQi0YA-Pu_LZFrsa25XMjgroniBNldus',
    appId: '1:315869780931:android:25d554b79af3d8ddd73b76',
    messagingSenderId: '315869780931',
    projectId: 'bizpilot-ai-2e1ed',
    authDomain: 'bizpilot-ai-2e1ed.firebaseapp.com',
    storageBucket: 'bizpilot-ai-2e1ed.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnQi0YA-Pu_LZFrsa25XMjgroniBNldus',
    appId: '1:315869780931:android:25d554b79af3d8ddd73b76',
    messagingSenderId: '315869780931',
    projectId: 'bizpilot-ai-2e1ed',
    storageBucket: 'bizpilot-ai-2e1ed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnQi0YA-Pu_LZFrsa25XMjgroniBNldus',
    appId: '1:315869780931:ios:63f2301aab27d008d73b76',
    messagingSenderId: '315869780931',
    projectId: 'bizpilot-ai-2e1ed',
    storageBucket: 'bizpilot-ai-2e1ed.firebasestorage.app',
    iosBundleId: 'com.bizpilotai.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBnQi0YA-Pu_LZFrsa25XMjgroniBNldus',
    appId: '1:315869780931:android:25d554b79af3d8ddd73b76',
    messagingSenderId: '315869780931',
    projectId: 'bizpilot-ai-2e1ed',
    storageBucket: 'bizpilot-ai-2e1ed.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBnQi0YA-Pu_LZFrsa25XMjgroniBNldus',
    appId: '1:315869780931:ios:63f2301aab27d008d73b76',
    messagingSenderId: '315869780931',
    projectId: 'bizpilot-ai-2e1ed',
    storageBucket: 'bizpilot-ai-2e1ed.firebasestorage.app',
    iosBundleId: 'com.bizpilotai.app',
  );
}

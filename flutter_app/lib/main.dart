import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/app/app.dart';
import 'package:flutter_app/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e, stackTrace) {
    logger.e(
      'Failed to initialize Firebase. Ensure google-services.json / GoogleService-Info.plist are present.',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }

  runApp(const BizPilotApp());
}

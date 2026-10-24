import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bizpilotai/app/app.dart';
import 'package:bizpilotai/core/utils/app_logger.dart';
import 'package:bizpilotai/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    logger.e(
      'Failed to initialize Firebase.',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(const BizPilotApp());
}

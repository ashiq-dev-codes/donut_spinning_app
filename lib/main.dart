import 'dart:async';

import 'package:flutter/material.dart';
import 'package:donut_spinning_app/root.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await _initializeServices();

      runApp(const AppRoot());
    },
    (error, stackTrace) async {
      // Add your error logging here
    },
  );
}

// Initializes required services before running the app
Future<void> _initializeServices() async {
  // Add your service/DI initialization here
}

// File: lib/main.dart
// Purpose: Application entry point — boots Flutter and hands off to LabourManagementApp.
// Used by: n/a (entry point)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LabourManagementApp()));
}

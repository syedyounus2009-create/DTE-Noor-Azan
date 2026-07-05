import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/timezone_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TimezoneResolver.ensureInitialized();
  runApp(const ProviderScope(child: NoorApp()));
}

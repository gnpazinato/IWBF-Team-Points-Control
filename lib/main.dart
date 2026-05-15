import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/load_spreadsheet_screen.dart';
import 'theme/iwbf_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const IwbfApp());
}

class IwbfApp extends StatelessWidget {
  const IwbfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IWBF Team Points Control',
      debugShowCheckedModeBanner: false,
      theme: buildIwbfTheme(),
      home: const LoadSpreadsheetScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/load_spreadsheet_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC9A24A)),
        scaffoldBackgroundColor: const Color(0xFFFAF8F2),
      ),
      home: const LoadSpreadsheetScreen(),
    );
  }
}

import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Implementação Android/iOS/desktop do saver de templates.
///
/// Grava em `getApplicationDocumentsDirectory()/<filename>` e devolve o
/// caminho final. Chamada apenas quando `dart.library.io` está disponível.
Future<String?> defaultSaveTemplate(String filename, Uint8List bytes) async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

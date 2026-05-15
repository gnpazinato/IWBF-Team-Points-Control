import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Implementação Android/iOS/desktop do saver de templates.
///
/// Abre o diálogo nativo de "Save As" (Storage Access Framework no
/// Android) e deixa o usuário escolher onde gravar o `.xlsx`.
/// Devolve o caminho final escolhido ou `null` quando o usuário
/// cancela o diálogo.
///
/// Versão anterior gravava em `getApplicationDocumentsDirectory()`
/// (`/data/user/0/<pkg>/app_flutter/`), pasta privada do app. O file
/// picker do sistema não enxerga essa pasta, então o usuário baixava
/// o template e ficava sem como recarregá-lo — bug achado pelo Robo
/// Test no Firebase Test Lab (entrada 0036 do log).
Future<String?> defaultSaveTemplate(String filename, Uint8List bytes) async {
  final String? path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save IWBF template',
    fileName: filename,
    type: FileType.custom,
    allowedExtensions: <String>['xlsx'],
    bytes: bytes,
  );
  return path;
}

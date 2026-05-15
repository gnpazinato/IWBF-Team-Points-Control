import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/match_state.dart';
import '../services/cache_service.dart';
import '../services/spreadsheet_parser_service.dart';
import '../services/template_generator_service.dart';
import '../utils/template_saver.dart' as platform_saver;
import '../widgets/iwbf_logo_header.dart';
import 'match_setup_screen.dart';
import 'missing_data_screen.dart';
import 'validation_summary_screen.dart';

/// Função usada para escolher um arquivo `.xlsx`.
///
/// Em produção é ligada ao `file_picker`. Nos testes, recebe uma versão
/// que devolve bytes em memória sem tocar na plataforma.
typedef FilePickerFn = Future<Uint8List?> Function();

/// Função que salva os bytes de um template `.xlsx` em algum lugar
/// acessível ao usuário e devolve o caminho final (ou `null` quando o
/// usuário cancela).
///
/// Em produção: abre o diálogo "Save As" do sistema (SAF no Android)
/// via `file_picker`. Nos testes, recebe um fake em memória.
typedef TemplateSaveFn = Future<String?> Function(
    String filename, Uint8List bytes);

/// Tela inicial do app.
///
/// Permite carregar uma planilha `.xlsx` e oferece restaurar a última
/// sessão quando há cache local.
class LoadSpreadsheetScreen extends StatefulWidget {
  const LoadSpreadsheetScreen({
    super.key,
    SpreadsheetParserService? parser,
    CacheService? cache,
    FilePickerFn? filePicker,
    TemplateGeneratorService? templates,
    TemplateSaveFn? saveTemplate,
  })  : _parser = parser,
        _cache = cache,
        _filePicker = filePicker,
        _templates = templates,
        _saveTemplate = saveTemplate;

  final SpreadsheetParserService? _parser;
  final CacheService? _cache;
  final FilePickerFn? _filePicker;
  final TemplateGeneratorService? _templates;
  final TemplateSaveFn? _saveTemplate;

  @override
  State<LoadSpreadsheetScreen> createState() => _LoadSpreadsheetScreenState();
}

class _LoadSpreadsheetScreenState extends State<LoadSpreadsheetScreen> {
  late final SpreadsheetParserService _parser;
  late final CacheService _cache;
  late final FilePickerFn _pickFile;
  late final TemplateGeneratorService _templates;
  late final TemplateSaveFn _saveTemplate;

  bool _busy = false;
  bool _hasPromptedRestore = false;

  @override
  void initState() {
    super.initState();
    _parser = widget._parser ?? SpreadsheetParserService();
    _cache = widget._cache ?? CacheService();
    _pickFile = widget._filePicker ?? _defaultFilePicker;
    _templates = widget._templates ?? const TemplateGeneratorService();
    _saveTemplate = widget._saveTemplate ?? platform_saver.defaultSaveTemplate;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferRestore());
  }

  Future<Uint8List?> _defaultFilePicker() async {
    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['xlsx'],
      withData: true,
    );
    if (picked == null) return null;
    final PlatformFile file = picked.files.single;
    final Uint8List? bytes = file.bytes;
    return bytes;
  }

  Future<void> _maybeOfferRestore() async {
    if (_hasPromptedRestore) return;
    _hasPromptedRestore = true;
    final bool hasSession = await _cache.hasMatchState();
    if (!mounted || !hasSession) return;
    final bool? restore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Previous data found.'),
          content: const Text(
            'Would you like to restore your previous session or start from scratch?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Start from Scratch'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Restore Previous Session'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (restore == true) {
      final MatchState? state = await _cache.loadMatchState();
      if (!mounted) return;
      if (state == null) {
        _showSnack('Saved session could not be restored.');
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MatchSetupScreen(restored: state),
        ),
      );
    } else {
      await _cache.clear();
    }
  }

  Future<void> _onLoadPressed() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final Uint8List? bytes = await _pickFile();
      if (bytes == null) return;
      final SpreadsheetParseResult result = _parser.parseBytes(bytes);
      if (!mounted) return;
      if (result.hasBlockingIssues && result.teams.isEmpty) {
        // Erro grave: arquivo ilegível ou colunas obrigatórias faltando.
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => MissingDataScreen(result: result),
          ),
        );
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ValidationSummaryScreen(
            result: result,
            cache: _cache,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onDownloadTemplatePressed(TemplateKind kind) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final Uint8List bytes = _templates.build(kind);
      final String filename = _templates.filenameFor(kind);
      final String? savedAt = await _saveTemplate(filename, bytes);
      if (!mounted) return;
      if (savedAt == null) return;
      _showSnack('Template saved to $savedAt');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not save template: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              const IwbfBrandHeader(
                subtitle: 'Wheelchair basketball — team points control',
              ),
              const SizedBox(height: 8),
              const Text(
                'Load the reference spreadsheet to start a match.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                key: const Key('load-spreadsheet-button'),
                onPressed: _busy ? null : _onLoadPressed,
                icon: const Icon(Icons.upload_file),
                label: const Text('Load Reference Spreadsheet'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('download-template-single-sheet'),
                onPressed: _busy
                    ? null
                    : () =>
                        _onDownloadTemplatePressed(TemplateKind.singleSheet),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download Template — Single Sheet'),
              ),
              const _OrDivider(),
              OutlinedButton.icon(
                key: const Key('download-template-per-team'),
                onPressed: _busy
                    ? null
                    : () => _onDownloadTemplatePressed(TemplateKind.perTeam),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download Template — One Sheet per Team'),
              ),
              const Spacer(),
              if (_busy) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Offline app. No login. No internet required.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Separador "or" entre os dois botões de download de template.
/// Deixa explícito que as duas planilhas são alternativas equivalentes.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider(thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: style),
          ),
          const Expanded(child: Divider(thickness: 1)),
        ],
      ),
    );
  }
}

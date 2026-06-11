import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../constants/app_version.dart';
import '../models/saved_roster.dart';
import '../services/cache_service.dart';
import '../services/remote_spreadsheet_service.dart';
import '../services/remote_sync_controller.dart';
import '../services/spreadsheet_parser_service.dart';
import '../services/template_generator_service.dart';
import '../theme/iwbf_theme.dart';
import '../utils/template_saver.dart' as platform_saver;
import '../widgets/iwbf_logo_header.dart';
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
    RemoteSpreadsheetService? remote,
    RemoteSyncController? remoteSync,
  })  : _parser = parser,
        _cache = cache,
        _filePicker = filePicker,
        _templates = templates,
        _saveTemplate = saveTemplate,
        _remote = remote,
        _remoteSync = remoteSync;

  final SpreadsheetParserService? _parser;
  final CacheService? _cache;
  final FilePickerFn? _filePicker;
  final TemplateGeneratorService? _templates;
  final TemplateSaveFn? _saveTemplate;
  final RemoteSpreadsheetService? _remote;
  final RemoteSyncController? _remoteSync;

  @override
  State<LoadSpreadsheetScreen> createState() => _LoadSpreadsheetScreenState();
}

class _LoadSpreadsheetScreenState extends State<LoadSpreadsheetScreen>
    with WidgetsBindingObserver {
  late final SpreadsheetParserService _parser;
  late final CacheService _cache;
  late final FilePickerFn _pickFile;
  late final TemplateGeneratorService _templates;
  late final TemplateSaveFn _saveTemplate;
  late final RemoteSpreadsheetService _remote;
  late final RemoteSyncController _remoteSync;

  final TextEditingController _linkController = TextEditingController();

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
    _remote = widget._remote ?? RemoteSpreadsheetService();
    _remoteSync = widget._remoteSync ?? RemoteSyncController.instance;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferRestore());
  }

  @override
  void dispose() {
    _linkController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ao voltar do segundo plano, refaz a pergunta de restauracao — mas
    // SOMENTE quando a propria Home esta no topo da navegacao. Se o usuario
    // estiver numa partida, em Match Setup ou no Resumo, nada acontece
    // (decisao do usuario: nao interromper essas telas). A Home continua
    // montada por baixo das outras rotas, entao este observer dispara
    // mesmo enquanto elas estao visiveis — por isso o teste `isCurrent`.
    if (state != AppLifecycleState.resumed || !mounted) return;
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    _hasPromptedRestore = false;
    unawaited(_maybeOfferRestore());
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
    final bool hasRoster = await _cache.hasRoster();
    if (!mounted || !hasRoster) return;
    final bool? restore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Previous data found.'),
          content: const Text(
            'Would you like to load the last spreadsheet you used '
            '(all teams and players) or start from scratch?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Start from Scratch'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Load Previous Spreadsheet'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (restore == true) {
      final SavedRoster? roster = await _cache.loadRoster();
      if (!mounted) return;
      if (roster == null || roster.teams.isEmpty) {
        _showSnack('Saved spreadsheet could not be restored.');
        return;
      }
      // Se a planilha veio de um LINK, retoma a sincronização (e verifica
      // já se há versão mais nova). Caso contrário, garante o polling
      // desligado (planilha local não sincroniza).
      if (roster.sourceUrl != null && roster.sourceHash != null) {
        _remoteSync.activate(roster.sourceUrl!, roster.sourceHash!);
        unawaited(_remoteSync.checkNow());
      } else {
        _remoteSync.deactivate();
      }
      // Reconstroi um resultado de parser limpo (sem issues) a partir da
      // planilha salva — leva o usuario ao Resumo da planilha com TODAS as
      // equipes/atletas, de onde pode revisar/editar e seguir para o setup.
      final SpreadsheetParseResult result = SpreadsheetParseResult(
        teams: roster.teams,
        issues: const <ParseIssue>[],
        competitionName: roster.competitionName,
      );
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ValidationSummaryScreen(
            result: result,
            cache: _cache,
            sourceUrl: roster.sourceUrl,
          ),
        ),
      );
    } else {
      _remoteSync.deactivate();
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
      // Planilha local substitui qualquer fonte de link: desliga o polling.
      _remoteSync.deactivate();
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

  /// Carrega a planilha a partir de um link online (SharePoint/OneDrive/
  /// Google). Baixa, parseia, liga a sincronização para a versão atual e
  /// segue para o Resumo. Erros (link inválido, offline, arquivo não-xlsx)
  /// viram um SnackBar amigável.
  Future<void> _onLoadLinkPressed() async {
    if (_busy) return;
    final String url = _linkController.text.trim();
    if (url.isEmpty) return;
    if (!_remote.looksLikeSupportedLink(url)) {
      _showSnack('Enter a valid http(s) link (SharePoint, OneDrive or '
          'Google Drive/Sheets).');
      return;
    }
    setState(() => _busy = true);
    try {
      final RemoteFetchResult fetched = await _remote.fetch(url);
      if (!mounted) return;
      final SpreadsheetParseResult result = _parser.parseBytes(fetched.bytes);
      if (!mounted) return;
      // Liga a sincronização com a versão recém-carregada (hash conhecido,
      // para não re-disparar aviso de "atualização" da mesma versão).
      _remoteSync.activate(url, fetched.contentHash);
      if (result.hasBlockingIssues && result.teams.isEmpty) {
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
            sourceUrl: url,
          ),
        ),
      );
    } on RemoteFetchException catch (e) {
      if (mounted) _showSnack(e.message);
    } catch (_) {
      if (mounted) {
        _showSnack('Could not load the spreadsheet from the link.');
      }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const IwbfBrandHeader(
                subtitle: 'Wheelchair basketball — team points control',
              ),
              const SizedBox(height: 22),
              _UploadCard(onTap: _busy ? null : _onLoadPressed),
              const SizedBox(height: 16),
              _LinkCard(
                controller: _linkController,
                busy: _busy,
                onLoad: _onLoadLinkPressed,
              ),
              const SizedBox(height: 16),
              _TemplatesCard(
                busy: _busy,
                onSingleSheet: () =>
                    _onDownloadTemplatePressed(TemplateKind.singleSheet),
                onPerTeam: () =>
                    _onDownloadTemplatePressed(TemplateKind.perTeam),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _OfflineFooter(),
    );
  }
}

/// "Zona de upload" estilizada: ícone de nuvem em círculo elevado, título
/// e dica. Toda a área é tocável (mesma key/ação do botão antigo).
class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      key: const Key('load-spreadsheet-button'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: IwbfColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: IwbfColors.goldDeep.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: IwbfColors.cardWhite,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  size: 28, color: IwbfColors.goldDeep),
            ),
            const SizedBox(height: 12),
            Text(
              'Load Reference Spreadsheet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to choose your .xlsx file',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: IwbfColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card para carregar a planilha a partir de um link online e mantê-la em
/// sincronia. O download/sync só funciona no app Android (na Web o navegador
/// bloqueia por CORS — o serviço lança erro amigável nesse caso).
class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.controller,
    required this.busy,
    required this.onLoad,
  });

  final TextEditingController controller;
  final bool busy;
  final Future<void> Function() onLoad;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.link_outlined,
                    size: 20, color: IwbfColors.goldDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Load from Online Link',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Paste a SharePoint, OneDrive or Google Drive/Sheets link '
              'shared as "anyone with the link". Edits to that file sync '
              'automatically while you are online.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: IwbfColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('spreadsheet-link-input'),
              controller: controller,
              enabled: !busy,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                hintText: 'https://…',
                prefixIcon: Icon(Icons.cloud_sync_outlined, size: 20),
              ),
              onSubmitted: busy ? null : (_) => unawaited(onLoad()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('load-link-button'),
                onPressed: busy ? null : onLoad,
                icon:
                    const Icon(Icons.download_for_offline_outlined, size: 18),
                label: const Text('Load from Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card agrupando os dois templates de referência, lado a lado.
class _TemplatesCard extends StatelessWidget {
  const _TemplatesCard({
    required this.busy,
    required this.onSingleSheet,
    required this.onPerTeam,
  });

  final bool busy;
  final VoidCallback onSingleSheet;
  final VoidCallback onPerTeam;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.description_outlined,
                    size: 20, color: IwbfColors.goldDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reference Templates',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('download-template-single-sheet'),
                    onPressed: busy ? null : onSingleSheet,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text(
                      'Download Template — Single Sheet',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('download-template-per-team'),
                    onPressed: busy ? null : onPerTeam,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text(
                      'Download Template — One Sheet per Team',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rodapé fixo: app offline + versão.
class _OfflineFooter extends StatelessWidget {
  const _OfflineFooter();

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: IwbfColors.textSecondary);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.cloud_off_outlined,
                    size: 15, color: IwbfColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'No login. Works offline — online link is optional.',
                    style: style,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('Version $kAppVersion', style: style),
          ],
        ),
      ),
    );
  }
}


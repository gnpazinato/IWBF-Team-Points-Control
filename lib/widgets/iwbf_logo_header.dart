import 'package:flutter/material.dart';

import '../theme/iwbf_theme.dart';

/// Logo IWBF na versão branca (pensada para fundos escuros).
const String kIwbfLogoWhiteAsset = 'assets/images/iwbf-logo-white.png';

/// Logo IWBF na versão preta/escura (pensada para fundos claros).
const String kIwbfLogoBlackAsset = 'assets/images/iwbf-logo-black.png';

/// Cabeçalho institucional usado na home (`LoadSpreadsheetScreen`).
///
/// Mostra o logo IWBF (vertical colorido) em destaque, com título e,
/// quando houver, nome da competição abaixo. Em telas estreitas (celular)
/// a altura do logo é reduzida automaticamente para preservar a área
/// útil dos botões.
class IwbfBrandHeader extends StatelessWidget {
  const IwbfBrandHeader({
    super.key,
    this.title = 'IWBF Team Points Control',
    this.subtitle,
    this.maxLogoHeight = 140,
  });

  final String title;
  final String? subtitle;
  final double maxLogoHeight;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext _, BoxConstraints c) {
            final double availableHeight =
                c.maxHeight.isFinite ? c.maxHeight : maxLogoHeight;
            final double height =
                availableHeight < maxLogoHeight ? availableHeight : maxLogoHeight;
            return SizedBox(
              key: const Key('iwbf-brand-logo'),
              height: height,
              child: Image.asset(
                kIwbfLogoBlackAsset,
                fit: BoxFit.contain,
                semanticLabel: 'IWBF logo',
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: IwbfColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Título compacto para `AppBar` — logo pequeno + texto.
///
/// Usar como `appBar: AppBar(title: const IwbfAppBarTitle(text: '...'))`.
class IwbfAppBarTitle extends StatelessWidget {
  const IwbfAppBarTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          key: const Key('iwbf-appbar-logo'),
          height: 32,
          child: Image.asset(
            kIwbfLogoBlackAsset,
            fit: BoxFit.contain,
            semanticLabel: 'IWBF logo',
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

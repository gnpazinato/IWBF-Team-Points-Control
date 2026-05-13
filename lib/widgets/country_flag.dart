import 'package:flutter/material.dart';

import '../services/country_resolver_service.dart';

/// Bandeira do pais ao lado do nome da equipe.
///
/// Usa o emoji nacional Unicode quando o `CountryResolverService` reconhece
/// o nome bruto; cai num icone neutro quando o pais nao e mapeado.
class CountryFlag extends StatelessWidget {
  CountryFlag({
    super.key,
    required this.rawName,
    this.size = 18,
    CountryResolverService? resolver,
  }) : _resolver = resolver ?? CountryResolverService();

  final String rawName;
  final double size;
  final CountryResolverService _resolver;

  @override
  Widget build(BuildContext context) {
    final String? emoji = _resolver.flagEmojiFor(rawName);
    if (emoji != null) {
      return Text(
        emoji,
        style: TextStyle(fontSize: size),
        semanticsLabel: 'Flag of $rawName',
      );
    }
    return Icon(
      Icons.flag_outlined,
      size: size,
      semanticLabel: 'Flag placeholder',
    );
  }
}

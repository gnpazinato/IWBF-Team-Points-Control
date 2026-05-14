import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/services/country_resolver_service.dart';

void main() {
  group('CountryResolverService - resolveCanonical', () {
    final CountryResolverService resolver = CountryResolverService();

    test('reconhece o nome canonico exato', () {
      expect(resolver.resolveCanonical('Brazil'), equals('Brazil'));
    });

    test('reconhece alias em portugues', () {
      expect(resolver.resolveCanonical('Brasil'), equals('Brazil'));
    });

    test('reconhece codigo de tres letras', () {
      expect(resolver.resolveCanonical('BRA'), equals('Brazil'));
    });

    test('ignora caixa', () {
      expect(resolver.resolveCanonical('brazil'), equals('Brazil'));
      expect(resolver.resolveCanonical('BRAZIL'), equals('Brazil'));
      expect(resolver.resolveCanonical('Brazil'), equals('Brazil'));
    });

    test('ignora pontuacao e espacos extras', () {
      expect(resolver.resolveCanonical('U.S.A.'), equals('United States of America'));
      expect(resolver.resolveCanonical('  USA  '), equals('United States of America'));
      expect(resolver.resolveCanonical('United  States'),
          equals('United States of America'));
    });

    test('ignora acentos', () {
      expect(resolver.resolveCanonical('Espana'), equals('Spain'));
      expect(resolver.resolveCanonical('España'), equals('Spain'));
      expect(resolver.resolveCanonical('Italia'), equals('Italy'));
    });

    test('reconhece variantes do USA', () {
      expect(resolver.resolveCanonical('US'), equals('United States of America'));
      expect(resolver.resolveCanonical('USA'), equals('United States of America'));
      expect(resolver.resolveCanonical('United States'),
          equals('United States of America'));
      expect(resolver.resolveCanonical('United States of America'),
          equals('United States of America'));
      expect(resolver.resolveCanonical('Estados Unidos'),
          equals('United States of America'));
    });

    test('reconhece variantes da China', () {
      expect(resolver.resolveCanonical('China'), equals('China'));
      expect(resolver.resolveCanonical('CHN'), equals('China'));
      expect(resolver.resolveCanonical("People's Republic of China"),
          equals('China'));
      expect(resolver.resolveCanonical('PR China'), equals('China'));
    });

    test('reconhece variantes do Reino Unido como Great Britain', () {
      expect(resolver.resolveCanonical('UK'), equals('Great Britain'));
      expect(resolver.resolveCanonical('United Kingdom'),
          equals('Great Britain'));
      expect(resolver.resolveCanonical('Great Britain'),
          equals('Great Britain'));
    });

    test('reconhece Chile (regressao do bug "unknown team: Chile")', () {
      expect(resolver.resolveCanonical('Chile'), equals('Chile'));
      expect(resolver.resolveCanonical('chile'), equals('Chile'));
      expect(resolver.resolveCanonical('CHI'), equals('Chile'));
      expect(resolver.resolveCanonical('CHL'), equals('Chile'));
      expect(resolver.isKnown('Chile'), isTrue);
    });

    test('reconhece todos os paises usados no template oficial', () {
      // Template gera 8 paises (entrada 0027 do AI_WORK_LOG).
      // Nenhum deles pode disparar warning "unknown team".
      const List<String> templateCountries = <String>[
        'Argentina',
        'Brazil',
        'Canada',
        'Chile',
        'Colombia',
        'Mexico',
        'United States of America',
        'Venezuela',
      ];
      for (final String name in templateCountries) {
        expect(resolver.isKnown(name), isTrue,
            reason: 'Pais do template nao foi reconhecido: $name');
      }
    });

    test('cobre todas as zonas IWBF', () {
      // Smoke test rapido de cobertura — uma amostra de cada zona.
      // Americas
      expect(resolver.isKnown('Cuba'), isTrue);
      expect(resolver.isKnown('Puerto Rico'), isTrue);
      // Europa
      expect(resolver.isKnown('Poland'), isTrue);
      expect(resolver.isKnown('Sweden'), isTrue);
      // Asia / Oceania
      expect(resolver.isKnown('New Zealand'), isTrue);
      expect(resolver.isKnown('Chinese Taipei'), isTrue);
      // Africa
      expect(resolver.isKnown('South Africa'), isTrue);
      expect(resolver.isKnown('Egypt'), isTrue);
    });

    test('retorna null para nome desconhecido', () {
      expect(resolver.resolveCanonical('Marte'), isNull);
      expect(resolver.resolveCanonical('Equipe X'), isNull);
    });

    test('retorna null para string vazia ou apenas pontuacao', () {
      expect(resolver.resolveCanonical(''), isNull);
      expect(resolver.resolveCanonical('   '), isNull);
      expect(resolver.resolveCanonical('!!!'), isNull);
    });
  });

  group('CountryResolverService - displayNameFor', () {
    final CountryResolverService resolver = CountryResolverService();

    test('retorna nome canonico quando reconhece', () {
      expect(resolver.displayNameFor('USA'),
          equals('United States of America'));
    });

    test('mantem o nome original quando nao reconhece', () {
      expect(resolver.displayNameFor('Marte'), equals('Marte'));
    });

    test('trim no nome desconhecido', () {
      expect(resolver.displayNameFor('  Marte  '), equals('Marte'));
    });
  });

  group('CountryResolverService - isKnown', () {
    final CountryResolverService resolver = CountryResolverService();

    test('true para nomes na tabela', () {
      expect(resolver.isKnown('Brazil'), isTrue);
      expect(resolver.isKnown('arg'), isTrue);
    });

    test('false para nomes fora da tabela', () {
      expect(resolver.isKnown('Marte'), isFalse);
    });
  });

  group('CountryResolverService - overrides', () {
    test('overrides adicionam novos aliases sem remover os padroes', () {
      final CountryResolverService resolver = CountryResolverService(
        aliasOverrides: <String, String>{
          'time da casa': 'Brazil',
        },
      );
      expect(resolver.resolveCanonical('time da casa'), equals('Brazil'));
      expect(resolver.resolveCanonical('Argentina'), equals('Argentina'));
    });

    test('overrides podem sobrescrever um alias existente', () {
      final CountryResolverService resolver = CountryResolverService(
        aliasOverrides: <String, String>{
          'usa': 'USA Custom',
        },
      );
      expect(resolver.resolveCanonical('USA'), equals('USA Custom'));
    });
  });

  group('CountryResolverService - countryCodeFor', () {
    final CountryResolverService resolver = CountryResolverService();

    test('retorna alpha-2 para paises conhecidos', () {
      expect(resolver.countryCodeFor('Brazil'), equals('BR'));
      expect(resolver.countryCodeFor('USA'), equals('US'));
      expect(resolver.countryCodeFor('Korea'), equals('KR'));
    });

    test('retorna null para paises desconhecidos', () {
      expect(resolver.countryCodeFor('Marte'), isNull);
      expect(resolver.countryCodeFor(''), isNull);
    });
  });

  group('CountryResolverService - flagEmojiFor', () {
    final CountryResolverService resolver = CountryResolverService();

    test('retorna emoji nacional para paises conhecidos', () {
      // 🇧🇷 = 0x1F1E7 + 0x1F1F7
      expect(
        resolver.flagEmojiFor('Brazil'),
        equals(String.fromCharCodes(<int>[0x1F1E7, 0x1F1F7])),
      );
    });

    test('retorna null quando o pais nao for reconhecido', () {
      expect(resolver.flagEmojiFor('Marte'), isNull);
    });
  });

  group('countryFlagEmoji helper', () {
    test('converte alpha-2 em par de Regional Indicator Symbols', () {
      expect(
        countryFlagEmoji('BR'),
        equals(String.fromCharCodes(<int>[0x1F1E7, 0x1F1F7])),
      );
      expect(
        countryFlagEmoji('us'),
        equals(String.fromCharCodes(<int>[0x1F1FA, 0x1F1F8])),
      );
    });

    test('retorna string vazia para entrada invalida', () {
      expect(countryFlagEmoji('B'), equals(''));
      expect(countryFlagEmoji('BRA'), equals(''));
    });
  });
}

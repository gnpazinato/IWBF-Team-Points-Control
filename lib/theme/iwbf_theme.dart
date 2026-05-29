import 'package:flutter/material.dart';

/// Paleta institucional inspirada na identidade visual da IWBF.
///
/// - fundo geral off-white;
/// - textos principais em preto/cinza escuro;
/// - dourado como cor de destaque;
/// - vermelho institucional para o alerta de limite excedido.
abstract class IwbfColors {
  IwbfColors._();

  /// Dourado principal usado em logo, botões primários e bordas selecionadas.
  static const Color gold = Color(0xFFC9A24A);

  /// Variante mais escura para borda/contraste no modo claro.
  static const Color goldDeep = Color(0xFFA67E2D);

  /// Variante translúcida para fundos sutis (cards selecionados).
  static const Color goldSoft = Color(0xFFF0E2BD);

  /// Off-white de fundo geral.
  static const Color offWhite = Color(0xFFFAF8F2);

  /// Tom levemente mais escuro do off-white para superfícies elevadas.
  static const Color offWhiteElevated = Color(0xFFF3EFE3);

  /// Texto principal (quase preto, mais legível que `Colors.black`).
  static const Color textPrimary = Color(0xFF1F1B16);

  /// Texto secundário (grafia mais leve).
  static const Color textSecondary = Color(0xFF5A544A);

  /// Vermelho institucional usado no alerta "Point limit exceeded.".
  static const Color alertRed = Color(0xFFB3261E);

  /// Fundo levemente avermelhado quando o limite é excedido.
  static const Color alertRedSurface = Color(0xFFFDECEC);

  /// Verde institucional de sucesso (validação sem erros).
  static const Color successGreen = Color(0xFF1B8A3A);

  /// Fundo translúcido amarelado para blocos de aviso (warnings).
  static const Color warningSurface = Color(0xFFFFF7E0);

  /// Branco puro para superfícies de card no visual moderno.
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Escala neutra para bordas, divisores e superfícies sutis.
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE6E6E0);
}

/// Tema Material 3 do app, com Material 3, paleta IWBF e densidades
/// adequadas para uso com luvas/dedos durante partidas.
ThemeData buildIwbfTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: IwbfColors.gold,
    brightness: Brightness.light,
    primary: IwbfColors.gold,
    onPrimary: IwbfColors.textPrimary,
    secondary: IwbfColors.goldDeep,
    onSecondary: Colors.white,
    surface: IwbfColors.offWhite,
    onSurface: IwbfColors.textPrimary,
    error: IwbfColors.alertRed,
    onError: Colors.white,
  );

  final TextTheme baseText = ThemeData(brightness: Brightness.light).textTheme;
  final TextTheme textTheme = baseText.apply(
    bodyColor: IwbfColors.textPrimary,
    displayColor: IwbfColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: IwbfColors.offWhite,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: IwbfColors.offWhite,
      foregroundColor: IwbfColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: IwbfColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: IwbfColors.gold,
        foregroundColor: IwbfColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IwbfColors.textPrimary,
        side: const BorderSide(color: IwbfColors.goldDeep, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: IwbfColors.goldDeep,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(IwbfColors.offWhite),
      ),
    ),
    cardTheme: CardThemeData(
      color: IwbfColors.cardWhite,
      elevation: 1,
      shadowColor: const Color(0x14000000),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: IwbfColors.slate200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IwbfColors.slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: IwbfColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: IwbfColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: IwbfColors.goldDeep, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: IwbfColors.alertRed, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: IwbfColors.alertRed, width: 1.5),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return IwbfColors.gold;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(IwbfColors.textPrimary),
      side: const BorderSide(color: IwbfColors.goldDeep, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return IwbfColors.gold;
        }
        return IwbfColors.offWhite;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return IwbfColors.goldSoft;
        }
        return IwbfColors.slate200;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x1A000000),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: IwbfColors.textPrimary,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: IwbfColors.offWhite,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

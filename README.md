# IWBF Team Points Control

App Android offline (Flutter) para comissários conferirem a soma dos pontos de classificação funcional dos atletas em quadra durante partidas oficiais de basquetebol em cadeira de rodas.

Veja [`docs/IWBF_Team_Points_Control_Planejamento.md`](docs/IWBF_Team_Points_Control_Planejamento.md) para o plano completo.

## Workflow 100% nuvem

Este repositório foi configurado para desenvolvimento sem dependências locais:

1. **Editor**: abra o repo no Claude Code Nuvem (seletor de ambiente → "Adicionar ambiente em nuvem" → selecione `gnpazinato/IWBF-Team-Points-Control`) ou em GitHub Codespaces.
2. **Build do APK**: ao fazer push para `main` (ou rodar manualmente o workflow), o GitHub Actions instala Flutter, gera o projeto Android e produz um `.apk` como artifact.
3. **Teste no tablet**: baixe o artifact do Actions e instale no Android via USB ou cloud drive. Nada precisa rodar local. Veja [`docs/INSTALL_ANDROID.md`](docs/INSTALL_ANDROID.md) para o passo-a-passo de sideload em tablet/phone físico e em serviços cloud (BrowserStack, Firebase Test Lab, AWS Device Farm).

## Estrutura inicial

- `lib/main.dart` — scaffold do app
- `pubspec.yaml` — dependências Flutter
- `test/widget_test.dart` — smoke test
- `.github/workflows/build-apk.yml` — pipeline de build do APK
- `assets/images/` — logos da IWBF, ilustração da quadra e imagens dos times
- `docs/` — referências adicionais

## Comandos (quando dentro de um ambiente Flutter cloud)

```bash
flutter create . --project-name iwbf_team_points_control --platforms=android --org com.iwbf
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

`flutter create .` preenche as pastas `android/` e demais arquivos nativos sem sobrescrever o que já existe.

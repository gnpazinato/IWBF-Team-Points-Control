# IWBF Team Points Control — Contexto auto-carregado para o Claude

> Este arquivo é lido automaticamente no início de cada sessão do Claude
> Code neste repositório. Trate-o como verdade. Se algo aqui contradisser
> seu instinto, **siga este arquivo**.

## Branch ativa

**TODO o código de produto está em `claude/review-and-continue-9ZK5v`.**
A `main` ainda é apenas o scaffold inicial (commit `a2cc748`). Se você
abrir `lib/main.dart` e ver só um placeholder, está na branch errada —
**não reimplemente nada do zero, apenas troque:**

```bash
git fetch origin
git checkout claude/review-and-continue-9ZK5v
git pull --ff-only origin claude/review-and-continue-9ZK5v
git log --oneline -10
```

Você deve ver commits `feat(fase-5)...`, `fix(fase-5)...`, `docs(...)...`.
O mais recente em 2026-05-14 é `ab7c654 fix(fase-5): hotfix do
auto-shrink — first name sumindo sem ellipsis` (entrada 0033).

## Estado atual (resumo)

- **Fase atual:** Fase 5 com 11 rodadas de ajustes pós-teste
  (entradas 0023..0033 do `docs/AI_WORK_LOG.md`). MVP completo na branch.
  Última rodada (0033) corrigiu o auto-shrink que ainda cortava o
  first name silenciosamente: `softWrap: false` no `_AutoShrinkText`
  + ellipsis fallback quando o `minFontSize` não cabe — agora
  "THOMPSON, Eth..." em vez de "THOMPSON," silenciosamente cortado.
- **Testers externos:** 2 pessoas têm o link do preview Web
  (https://gnpazinato.github.io/IWBF-Team-Points-Control/), compartilhado
  em 2026-05-14. Aguardando feedback antes de avançar.
- **Última atualização:** 2026-05-14.

## O que fazer quando o usuário abre uma nova conversa

1. Faça `git status` + `git log --oneline -10` para confirmar a branch e
   o último commit.
2. Leia, **nesta ordem**, antes de qualquer outra ação:
   1. `docs/IWBF_Team_Points_Control_Planejamento.md` (escopo do MVP);
   2. `docs/PLANO_DESENVOLVIMENTO_IA.md` (fases e estratégia);
   3. `docs/AI_WORK_LOG.md` (fonte da verdade — estado, decisões,
      convenções, histórico). Em particular: tabela "Estado atual" no
      topo + entradas 0023..0033 (Fase 5 inteira) + seção
      "Prompt curto de continuidade — Fase 5 fechada / aguardando
      testers" no fim.
3. Reporte ao usuário, em **uma frase**, o último commit que viu (sha +
   título) e qual das duas trilhas aplica.

## Duas trilhas possíveis de próximo passo

**TRILHA A — Testers reportaram bugs ou melhorias.**
Peça a lista detalhada ao usuário. Continue na mesma branch. Cada
ajuste vira uma nova entrada (`### 0031`, `### 0032`...) no log.
Convenção de commit: `feat(fase-5):...`, `fix(fase-5):...`.

**TRILHA B — Sem feedback (ou já absorvido). Usuário quer encerrar MVP.**
Confirme com o usuário, garanta `git status` limpo, abra PR
`claude/review-and-continue-9ZK5v -> main` via GitHub MCP
(`mcp__github__create_pull_request`). **Não mergeie sozinho — peça
aprovação.** Depois do merge, registre o fechamento no log e pergunte
ao usuário a próxima direção (Phase 6: estatísticas, scoring, Play
Store, refactor...).

Pergunte ao usuário qual trilha aplica antes de codar.

## Regras de trabalho (não revisitar sem motivo técnico)

- **Branch:** sempre `claude/review-and-continue-9ZK5v`. Nunca trabalhe
  a partir de `main` enquanto o ciclo MVP estiver aberto.
- **Validação local:** se `/root/flutter/bin/flutter` existir, rode
  `flutter pub get && flutter analyze --no-fatal-infos && flutter test`
  antes de cada push. Se Flutter ausente no sandbox, CI valida no push.
- **Não commit `pubspec.lock`** se mudou só por `pub get` local
  (`git restore pubspec.lock` antes do commit).
- **Plugins de plataforma sempre via callback/serviço injetável**
  (`VibrationService`, `WakelockController`, `FilePicker` callback,
  etc.). Sem isso, widget tests quebram com `MissingPluginException`.
- **Em widget tests, NUNCA `await Navigator.push(...)`** — o Future só
  completa quando a rota é popada; causa timeout.
- **Capture `Navigator.of(context)` antes do primeiro `await`** em
  handlers assíncronos para evitar `use_build_context_synchronously`.
- **APIs depreciadas (Flutter 3.41+):** use `Color.withValues(alpha: x)`
  (não `.withOpacity`), `DropdownButtonFormField.initialValue` (não
  `.value`), `PopScope.onPopInvokedWithResult` (não `.onPopInvoked`),
  `CardThemeData`/`DialogThemeData` (não `CardTheme`/`DialogTheme`).
- **Cores de alerta:** sempre via `IwbfColors` (`alertRed`,
  `alertRedSurface`, `goldDeep`) — não `Colors.red.shade*`.

## Rotina por incremento

1. Implementa o menor pedaço útil.
2. `analyze` + `test` verdes localmente (ou push se Flutter ausente).
3. Atualiza `docs/AI_WORK_LOG.md`: nova entrada `### 00NN`, tabela de
   estado, arquivos alterados, testes rodados, próximo passo.
4. Commit + push em `claude/review-and-continue-9ZK5v`.
5. Reporte ao usuário em 4-8 linhas: o que entregou, testes que
   passaram (números reais), pendências, próximo passo.

## Repositório

- GitHub: `gnpazinato/iwbf-team-points-control`
- Preview Web: `https://gnpazinato.github.io/IWBF-Team-Points-Control/`
  (servido a partir da branch ativa, atualiza a cada push).
- CI: `.github/workflows/build-apk.yml` valida `analyze` + `test` e gera
  APK + bundle Web em cada push para `claude/**` ou `main`.

# IWBF Team Points Control — Contexto auto-carregado para o Claude

> Este arquivo é lido automaticamente no início de cada sessão do Claude
> Code neste repositório. Trate-o como verdade. Se algo aqui contradisser
> seu instinto, **siga este arquivo**.

## Branch ativa

**O MVP completo já está na `main`** (PR #5 mergeado). A branch antiga
`claude/review-and-continue-9ZK5v` é histórica — **não trabalhe mais a
partir dela** e ignore avisos antigos de que "main é só scaffold": isso
está desatualizado. `lib/main.dart` na `main` é o app real.

A modernização visual (inspirada no app irmão CBBC, sem perder a
identidade IWBF) está na branch **`claude/visual-modernization`** (criada
a partir de `main`), com PR aberto para `main`. Fluxo:

```bash
git fetch origin
git checkout claude/visual-modernization   # ou main, se o PR já mergeou
git pull --ff-only origin claude/visual-modernization
git log --oneline -12
```

Você deve ver commits `feat(visual): Fase N — ...` e `fix(visual): ...`.

## Estado atual (resumo)

- **Modernização visual (branch `claude/visual-modernization`):** Fases
  1–6 implementadas e verdes no CI; PR aberto para `main` (aguardando
  aprovação do usuário — **não mergear sozinho**). Entregue:
  - **Fase 1:** tema modernizado (cards brancos, sombra `0x14000000`,
    radius 14, inputs/checkbox/switch dourados) + ícone IWBF preto como
    favicon/launcher Android + branding PWA.
  - **Fase 2:** `Player` com **nome unificado** (`name` substitui
    surname+firstName, com back-compat no `fromJson`); `dob`/`gender`
    **opcionais** (não bloqueantes); parser com aliases de colunas +
    recuperação de classe "data-like" (anti-autoformatação Excel);
    templates novos (`competition, team_name, class, name, number, dob,
    gender`) com colunas pré-expandidas.
  - **Fase 3:** nomes na quadra **encolhem e quebram em até 2 linhas**
    (nunca reticências) + **rotação só em tablets** (`shortestSide>=600`),
    celular travado em portrait.
  - **Fase 4:** restyle de home (upload card + templates card + footer
    com versão), match setup (cards com friso dourado) e lineup (placar
    com glow ao estourar limite, limite movido para menu na AppBar,
    chips/botões com ícones).
  - **Fase 5:** **Jersey Color Picker** (cor da camisa por time, guardada
    no `MatchState`) + **edição completa do roster** na tela de validação
    (editar nome/dob/gênero/número/classe, excluir atleta, renomear/
    excluir equipe) + restyle (badges, status pill, issue blocks).
  - **Fase 6:** iconografia `_outlined` padronizada; docs atualizadas.
  - **Fase 7 (PDF) — NÃO feita:** importação de PDF via
    `syncfusion_flutter_pdf` ficou **fora** desta entrega (alto risco +
    licença Syncfusion). Reavaliar como trilha futura isolada.
- **Testers externos:** 2 pessoas com o link do GH Pages
  (`https://gnpazinato.github.io/IWBF-Team-Points-Control/`). O preview
  atualiza a cada push em `claude/**` ou `main`. CF Pages:
  `https://iwbf-team-points-control.pages.dev/`.
- **Validação local:** Flutter **não** está instalado no Codespace; toda
  validação (`analyze`/`test`/`build`) roda no **CI a cada push**.
- **Última atualização:** 2026-05-27.

## O que fazer quando o usuário abre uma nova conversa

1. Faça `git status` + `git log --oneline -10` para confirmar a branch e
   o último commit.
2. Leia, **nesta ordem**, antes de qualquer outra ação:
   1. `docs/IWBF_Team_Points_Control_Planejamento.md` (escopo do MVP);
   2. `docs/PLANO_DESENVOLVIMENTO_IA.md` (fases e estratégia);
   3. `docs/AI_WORK_LOG.md` (fonte da verdade — estado, decisões,
      convenções, histórico). Em particular: tabela "Estado atual" no
      topo + entrada da modernização visual (Fases 1–6).
3. Reporte ao usuário, em **uma frase**, o último commit que viu (sha +
   título) e o estado do PR de modernização visual.

## Próximo passo provável

A modernização visual está implementada (Fases 1–6, CI verde) com PR
aberto `claude/visual-modernization -> main`. Os caminhos típicos:

- **Aprovar/mergear o PR** (decisão do usuário — **não mergeie sozinho**).
  Após o merge, registre o fechamento no log.
- **Ajustes de feedback** dos testers: nova entrada no log, commit
  `fix(visual):...` na branch `claude/visual-modernization` (ou direto em
  `main` se o PR já mergeou e uma nova branch for criada).
- **Fase 7 (PDF)** como trilha futura isolada, se o usuário quiser.

Pergunte ao usuário qual caminho aplica antes de codar.

## Regras de trabalho (não revisitar sem motivo técnico)

- **Branch:** trabalhe em `claude/visual-modernization` (ou numa branch
  `claude/**` nova a partir de `main`). Nunca commite direto na `main`.
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
4. Commit + push em `claude/visual-modernization` (ou branch `claude/**`).
5. Reporte ao usuário em 4-8 linhas: o que entregou, testes que
   passaram (números reais), pendências, próximo passo.

## Repositório

- GitHub: `gnpazinato/iwbf-team-points-control`
- Preview Web (GH Pages — legado, expõe handle pessoal):
  `https://gnpazinato.github.io/IWBF-Team-Points-Control/`
- Preview Web (CF Pages — URL neutra para testers, adicionado na entrada
  0034 do log): `https://iwbf-team-points-control.pages.dev/`
- Ambos são servidos a partir da branch ativa e atualizados a cada push
  em `claude/**` ou `main` via `.github/workflows/deploy-web.yml`.
- CI de build/test: `.github/workflows/build-apk.yml` valida `analyze` +
  `test` e gera APK em cada push.

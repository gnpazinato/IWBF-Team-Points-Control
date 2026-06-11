# IWBF Team Points Control — Contexto auto-carregado para o Claude

> Este arquivo é lido automaticamente no início de cada sessão do Claude
> Code neste repositório. Trate-o como verdade. Se algo aqui contradisser
> seu instinto, **siga este arquivo**.

## Branch ativa

**Tudo está na `main`.** O MVP (PR #5), a modernização visual + ajustes
(Fases 1–6 + 0039–0041, `1.4.0+5`, **PR #6, 2026-06-10**) e a entrada
**0045 (`1.5.0+6`, 2026-06-11): camisa "0"/"00" como texto + carregar
planilha por link online** foram **mergeados na `main`** (aprovados pelo
usuário; a branch `claude/jersey-00-and-online-link` foi mergeada e
**deletada**). As branches `claude/review-and-continue-9ZK5v`,
`claude/visual-modernization` e `claude/jersey-00-and-online-link` são
históricas; **não trabalhe mais a partir delas** e ignore avisos antigos de
que "main é só scaffold". `lib/main.dart` na `main` é o app real e atual.

**Trabalho novo:** crie uma branch `claude/**` nova a partir da `main`.
Nunca commite direto na `main`. Fluxo:

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b claude/<novo-escopo>
git log --oneline -12
```

## Estado atual (resumo)

- **Versão atual:** **`1.5.1+7`** (`kAppVersion = 1.5.1`, build 7) —
  entradas 0045 (camisa "0"/"00" + link online) e **0046** (fix do
  auto-refresh do link: `RemoteSyncController.matchInProgress` segura a
  atualização durante a partida; `ValidationSummary` aplica o `pending`
  também via `addPostFrameCallback` no `initState`; polling 25s→15s; link
  fica "colado" via `CacheService.saveLastLink`; coluna DOB no Summary
  alargada). (Histórico: a `1.4.0+5` saiu de uma confusão `1.5.1+5`→`1.4.0+5`;
  daí em diante o fluxo de versão é normal.)
- **Entrada 0045 (`1.5.0+6`, 2026-06-11) — mergeada na `main`:**
  - **Camisa "0" E "00" (rótulos distintos), ponta a ponta.**
    `Player.shirtNumber` virou **`String`** (preserva zeros à esquerda;
    `fromJson` lê `int` legado por back-compat). Ordenação por
    **`Player.compareShirtLabels`** (valor numérico, mas "0" antes de "00").
    Parser preserva texto "00"/"07" e converte "7.0"→"7"; duplicata por
    `String` (então "0" e "00" **não** são duplicata um do outro). Template
    grava a coluna de número como **TEXTO** (`TextCellValue` +
    `NumFormat.standard_49` = numFmt 49 `"@"`) — **nunca `IntCellValue`** —
    para o Excel não converter `00`→`0`. Edição valida `^\d{1,2}$`.
  - **Carregar planilha por LINK online** (SharePoint/OneDrive corporativo,
    Google Drive, Google Sheets, OneDrive pessoal) com **auto-refresh**, só
    no **APK Android** (sem proxy/sem CORS). Detalhes na seção "Arquitetura
    do link online" abaixo.
  - **GitHub Pages REMOVIDO** (pedido do usuário): `deploy-web.yml`
    deletado; o usuário testa **apenas o APK final**. Não há mais preview
    Web. O código segue web-safe (stubs), então nada quebra se um dia
    rodar `flutter build web`.
- **Modernização visual (mergeada na `main` via PR #6, 2026-06-10):** Fases
  1–6 implementadas e verdes no CI. Entregue:
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
  - **Importação de PDF — DESCARTADA (decisão do usuário, 2026-05-27):**
    complexa/frágil demais; o app foca **somente** nas planilhas template
    já criadas. Não há (nem deve haver) menção a PDF no código ou na UI.
- **Ajustes pós-testers (na mesma branch, após as Fases 1–6):**
  - **Entrada 0039 (v1.2.0):** parser tolerante a nomes de coluna —
    aliases amplos (`country`/`nation`/`full_name`/`jersey`/`bib`...) e
    roteamento dirigido por **conteúdo** (abas com coluna de equipe são a
    fonte de verdade; demais são ignoradas).
  - **Entrada 0040 (v1.3.0):** ao reabrir/voltar do segundo plano na
    Home, o app restaura a **planilha INTEIRA** (todas as equipes, via
    `SavedRoster`/`CacheService`) e abre o Resumo — não só as 2 equipes
    da última partida. Minimizar **durante** a partida volta à partida.
  - **Entrada 0041 (v1.4.0):** **DOB aceita ano de 2 dígitos** e
    separadores `-`/`.` (`24-01-91` → 1991, `12-12-25` → 2025; antes só
    `dd-mm-yyyy` funcionava e `24-01-91` dava erro/era lido como ano 24).
    Pivô POSIX: `00`–`68` → `2000`–`2068`, `69`–`99` → `1969`–`1999`; ISO
    `yyyy-mm-dd` só quando começa com 4 dígitos; anti-overflow rejeita
    `31/02`. Também: **remover jogador tocando no chip da quadra** +
    **bandeiras de países africanos** (Angola etc.). Validado com testes
    (`12-12-25 → 2025`, `05/06/90 → 1990`).
- **Testers externos:** 2 pessoas. Testam **apenas o APK final** (baixado
  do artifact do CI `build-apk.yml`). **Preview Web descartado** — GH Pages
  removido em 2026-06-11 (entrada 0045); Cloudflare Pages já saíra em
  2026-06-10 (0043). Não há mais preview Web ativo.
- **Validação local:** Flutter **não** está instalado no Codespace; toda
  validação (`analyze`/`test`/`build` + APK) roda no **CI a cada push**
  (`build-apk.yml`). O APK sai como artifact `iwbf-team-points-control-
  version-<versão>` em cada run.
- **Última atualização:** 2026-06-11.

## Arquitetura do link online (entrada 0045)

Só funciona no **APK Android** (nativo). A Web lança `UnsupportedError`
(CORS: SharePoint/Drive não enviam `Access-Control-Allow-Origin`, e o
usuário não usa mais Web). Camadas:

- **`lib/services/remote_fetcher.dart`** (+ `_io`/`_web`/`_stub`, padrão de
  import condicional igual ao `template_saver`): baixa os bytes. O `_io` usa
  **`dart:io HttpClient` com redirect MANUAL repassando cookies** — é o que
  faz o link anônimo do SharePoint funcionar (o 1º `302` entrega um
  `FedAuth` anônimo que precisa acompanhar o salto seguinte; sem ele →
  `403`). **Não trocar por `http`/`dio` sem replicar o cookie-jar.**
- **`lib/services/remote_spreadsheet_service.dart`**: `normalize(url)`
  resolve cada provedor → download direto (SharePoint `?download=1`; Google
  Drive `uc?export=download&id`; Google Sheets `export?format=xlsx`;
  OneDrive pessoal `api.onedrive.com/.../shares/u!{base64url}/root/content`;
  senão link direto). Valida assinatura `.xlsx` (`PK`) e calcula
  `contentHashOf` (FNV-1a) para detectar mudanças. `fetcher` é injetável
  nos testes. `normalize` é **idempotente** (o polling renormaliza).
- **`lib/services/remote_sync_controller.dart`**: `ChangeNotifier`
  singleton (`RemoteSyncController.instance`) que faz **polling** (25 s + ao
  voltar do 2º plano via `main.dart`). Inativo (sem timer/rede) até
  `activate(url, hash)`. Quando o hash muda, expõe a versão nova como
  `pending` e notifica — **não aplica sozinho**. Comportamento (pedido do
  usuário): a tela de edição (`ValidationSummary`) **aplica em tempo real**;
  durante a **partida** (`LineupControl`) segura e, ao **sair do jogo**,
  pergunta (dialog `remote-update-dialog`). `SavedRoster` ganhou
  `sourceUrl`/`sourceHash`; a restauração na Home **retoma o sync**.
- **Home** (`load_spreadsheet_screen.dart`): card "Load from Online Link"
  (`spreadsheet-link-input` + `load-link-button`). Upload local chama
  `deactivate()`. `AndroidManifest.xml` tem permissão `INTERNET`.

## O que fazer quando o usuário abre uma nova conversa

1. Faça `git status` + `git log --oneline -10` para confirmar a branch e
   o último commit.
2. Leia, **nesta ordem**, antes de qualquer outra ação:
   1. `docs/IWBF_Team_Points_Control_Planejamento.md` (escopo do MVP);
   2. `docs/PLANO_DESENVOLVIMENTO_IA.md` (fases e estratégia);
   3. `docs/AI_WORK_LOG.md` (fonte da verdade — estado, decisões,
      convenções, histórico). Em particular: tabela "Estado atual" no
      topo + entrada da modernização visual (0038, Fases 1–6) + ajustes
      pós-testers (0039 v1.2.0, 0040 v1.3.0, 0041 v1.4.0).
3. Reporte ao usuário, em **uma frase**, o último commit que viu (sha +
   título). Não há PR aberto (o #6 já foi mergeado).

## Próximo passo provável

Tudo está mergeado na `main` (até a entrada 0045, `1.5.0+6`). **Não há
trabalho em andamento nem PR aberto.** Os caminhos típicos para uma nova
conversa:

- **Atualizar o manual do usuário (.docx)** para a v1.5.0: o manual
  versionado ainda reflete a v1.4.0 (entrada 0044). Os recursos novos da
  0045 — camisa "0"/"00" e **carregar planilha por link online** — ainda
  **não** estão no manual. Provável próximo pedido de documentação.
- **Ajustes de feedback** dos testers ou novos pedidos: crie uma branch
  `claude/**` nova a partir da `main`, adicione entrada no log e abra PR.
- **Escopo futuro possível** (nunca iniciado): estatísticas pós-jogo/
  scoring, publicação na Play Store, multi-idioma. Pergunte ao usuário a
  direção antes de codar.

A importação de PDF foi **descartada** — não sugira como próximo passo.

Pergunte ao usuário qual caminho aplica antes de codar.

## Regras de trabalho (não revisitar sem motivo técnico)

- **Branch:** crie uma branch `claude/**` **nova a partir de `main`**.
  Nunca commite direto na `main`. (A `claude/visual-modernization` é
  histórica — não usar.)
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
- **Camisa é `String` (entrada 0045):** `Player.shirtNumber` é texto e
  preserva zeros à esquerda ("0" ≠ "00"). Ordene com
  `Player.compareShirtLabels` (numérico, mas "0" antes de "00") — **nunca**
  `String.compareTo` direto (daria ordem lexicográfica "10" < "2").
  `fromJson` aceita `int` legado. No template, a coluna de número é
  **TEXTO** (`TextCellValue` + `NumFormat.standard_49`) — **nunca**
  `IntCellValue` (o Excel converteria `00`→`0`).
- **Link online (entrada 0045):** ver "Arquitetura do link online". Só
  Android; a Web é stub (CORS). O fetch nativo (`remote_fetcher_io.dart`)
  precisa do redirect manual com **cookie passthrough** (SharePoint). O
  `RemoteSyncController` é singleton injetável; nos testes passe um próprio
  e chame `deactivate()`/`dispose()` para não vazar `Timer`. Mudou a UI da
  Home (3 cards) — **widget tests que tocam os botões de template precisam
  de `tester.ensureVisible(...)` antes do `tap`** (ficam abaixo da fold da
  viewport 800×600).

## Rotina por incremento

1. Implementa o menor pedaço útil.
2. `analyze` + `test` verdes localmente (ou push se Flutter ausente).
3. Atualiza `docs/AI_WORK_LOG.md`: nova entrada `### 00NN`, tabela de
   estado, arquivos alterados, testes rodados, próximo passo.
4. Commit + push numa branch `claude/**` nova a partir de `main`.
5. Reporte ao usuário em 4-8 linhas: o que entregou, testes que
   passaram (números reais), pendências, próximo passo.

## Repositório

- GitHub: `gnpazinato/iwbf-team-points-control`
- **Sem preview Web.** GitHub Pages foi removido em 2026-06-11 (entrada
  0045): o workflow `deploy-web.yml` foi **deletado**. Cloudflare Pages já
  saíra em 2026-06-10 (0043). O usuário testa apenas o APK.
- **Único workflow:** `.github/workflows/build-apk.yml` — valida `analyze`
  + `test` e **gera o APK release** (artifact `iwbf-team-points-control-
  version-<versão>`) em cada push em `main`/`claude/**` e em PRs para `main`.
  O usuário baixa o APK pela aba **Actions → run → Artifacts**.

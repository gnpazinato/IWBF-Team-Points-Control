# IWBF Team Points Control - AI Work Log

Este arquivo e a fonte de verdade para continuidade do projeto com Codex, Claude Code ou outra IA.

> ## ⚠️ ATENCAO — LEIA ANTES DE QUALQUER COISA ⚠️
>
> **TODO o codigo de produto vive na branch `claude/review-and-continue-9ZK5v`.**
> A `main` ainda tem APENAS o scaffold inicial (commit `a2cc748`) — nao tem
> tela de upload, parser, Summary, Match Setup, Lineup Control nem nada do
> Phase 1-5.
>
> **Antes de fazer qualquer alteracao:**
>
> 1. `git fetch origin && git checkout claude/review-and-continue-9ZK5v`
> 2. `git pull --ff-only origin claude/review-and-continue-9ZK5v`
> 3. Confirmar com `git log --oneline -5` que voce esta vendo commits
>    `feat(fase-5)...`, `fix(fase-5)...` etc. — nao apenas o scaffold.
>
> **Preview Web:** `https://gnpazinato.github.io/IWBF-Team-Points-Control/`
> e servido a partir desta branch (a regra do environment `github-pages`
> esta em "No restriction" — qualquer push em `claude/**` ou `main` publica;
> ver entrada 0022).
>
> Se voce esta vendo apenas o scaffold em `lib/main.dart`, voce esta na
> branch ERRADA. Nao "implemente do zero" — apenas troque de branch.
>
> Quando o ciclo MVP terminar, abriremos PR para `main` e mergeamos.
> Ate la, **NUNCA** trabalhe a partir do `main`.

Antes de qualquer nova tarefa, a IA deve ler:

1. `IWBF_Team_Points_Control_Planejamento.md`
2. `docs/PLANO_DESENVOLVIMENTO_IA.md`
3. `docs/AI_WORK_LOG.md`

Nenhuma fase deve ser refeita se estiver marcada como concluida aqui, a menos que exista uma justificativa tecnica registrada.

## Estado atual

| Campo | Valor |
|---|---|
| Branch de trabalho | **`claude/review-and-continue-9ZK5v`** (NAO main) |
| Data da ultima atualizacao | 2026-05-14 |
| Status geral | **Fase 5 — sexta rodada: variantes de genero (M/F/W/Man/Mens/Masc/Femenino...) + aliases extras (USA "United States America", PRC, IRI, GB, Korea Republic) aceitos no parser.** |
| Fase atual | **Fase 5 (ajustes pos-teste manual) — entradas 0023..0030 fechadas.** |
| Proximo passo recomendado | Aguardar smoke test do usuario com planilha contendo variantes mistas (ex.: "Arg Men", "USA F", "Argentina Masculino"). |
| Ultimos testes executados | Sem `flutter` localmente nesta sessao (ambiente sem Flutter SDK). CI valida no push. |
| APK gerado | Sim, via CI a cada push. Preview Web em https://gnpazinato.github.io/IWBF-Team-Points-Control/ tambem regenerado a cada push. |

## Ritual obrigatorio para a IA

Antes de implementar:

- confirmar a fase atual neste log;
- localizar o primeiro item pendente;
- revisar decisoes ja registradas;
- evitar refazer trabalho concluido;
- se encontrar divergencia entre codigo e log, registrar a divergencia antes de corrigir.

Depois de implementar:

- atualizar checklist da fase;
- adicionar entrada em "Historico de trabalho";
- listar arquivos criados/alterados;
- listar comandos de teste executados;
- registrar falhas ou pendencias;
- escrever o proximo passo recomendado.

## Decisoes registradas

| Data | Decisao | Motivo |
|---|---|---|
| 2026-05-12 | Flutter sera a tecnologia principal | Melhor equilibrio para Android, layout visual e APK |
| 2026-05-12 | MVP sera offline, sem login e sem backend | Uso em jogos oficiais com estabilidade e simplicidade |
| 2026-05-12 | O log sera obrigatorio antes de novas etapas | Evitar que IA refaca etapas ja concluidas |
| 2026-05-12 | Desenvolvimento sera organizado em 4 fases | Avancar rapido sem perder controle |
| 2026-05-12 | Testes automatizados entram desde a Fase 1 | Reduzir correcao manual repetitiva |
| 2026-05-12 | App sera local-first/offline em tempo de uso | Nao exigir backend, hospedagem, Play Store ou internet durante a partida |
| 2026-05-12 | MVP suportara `.xlsx`; `.csv` fica para melhoria posterior e `.xls` fica fora do MVP | Reduzir complexidade inicial e manter template oficial estavel |
| 2026-05-12 | `competition_name` sera opcional | Permitir planilhas simples sem bloquear o uso |
| 2026-05-12 | App ficara travado em retrato na primeira versao | Uso principal sera tablet/celular na vertical durante jogos |
| 2026-05-12 | Pacote Android inicial sera `org.iwbf.teampointscontrol` | Nome institucional simples e estavel |
| 2026-05-12 | DOB aceitara `YYYY-MM-DD` e `DD/MM/YYYY` | Facilitar importacao sem criar bloqueios desnecessarios |
| 2026-05-12 | Tablet tera layout com listas laterais e quadra central; celular tera abas Team A, Court e Team B | Manter usabilidade em telas pequenas sem complicar o MVP |
| 2026-05-12 | Bandeiras serao assets locais com fallback generico | Garantir funcionamento 100% offline |
| 2026-05-12 | Icones masculino/feminino serao usados apenas quando `gender` existir; caso contrario, icone padrao da equipe | Evitar depender de dado opcional |
| 2026-05-12 | Testes do MVP seriam feitos em emuladores Android no Mac; decisao substituida em 2026-05-13 | Plano anterior antes da estrategia Codespaces/cloud-first |
| 2026-05-13 | Antes de instalar ferramentas Android localmente, avaliar alternativa cloud-first | Mac atual tem pouco espaco livre e emuladores/SDKs sao pesados |
| 2026-05-13 | Estrategia principal mudou para GitHub Codespaces/cloud-first | Reduzir instalacoes e uso de armazenamento no Mac |
| 2026-05-13 | Android Studio, Android SDK, JDK e emuladores locais nao sao pre-condicao do MVP | Dependencias pesadas devem ficar no Codespace ou em CI |
| 2026-05-13 | Repositorio GitHub passa a ser fonte de verdade do projeto | Permitir apagar copia local depois de commit/push seguro |
| 2026-05-13 | Validacao Android sera separada entre testes/build remotos e servico cloud de device/emulador Android | Evitar Android fisico e emulador local no Mac |
| 2026-05-13 | Logos IWBF recebidos na pasta local | Assets `Vertical IWBF Logo Coloured Black.png` e `Vertical IWBF Logo Coloured White.png` devem ser registrados/otimizados no projeto |
| 2026-05-13 | Android fisico esta descartado para o desenvolvimento | Usuario nao possui dispositivo Android fisico |
| 2026-05-13 | Android Emulator dentro do Codespace nao deve ser assumido como caminho principal | Codespace sera usado para codigo, testes automatizados e build; validacao visual/manual fica em device/emulator cloud |
| 2026-05-13 | `Team.displayName` e `Player` ficam sem `countryCode`/`teamCode`; exibicao usa somente o `teamName` completo | Simplificacao pedida pelo usuario: tirar o codigo do pais e a manipulacao para extrai-lo. Bandeiras passam a ser mapeadas pelo `CountryResolverService` (Fase 2) usando o nome completo. |
| 2026-05-13 | `MissingDataScreen` da Fase 2 e tela de diagnostico no MVP, sem edicao inline | Reduzir escopo da Fase 2 para entregar fluxo end-to-end. Edicao inline (preencher numero de camiseta sem reabrir Excel) fica como refinamento futuro. |
| 2026-05-13 | Flutter SDK 3.41.9 instalado em `/root/flutter` para validacao autonoma local | Permite rodar `flutter analyze` e `flutter test` direto, antes de depender da CI. |
| 2026-05-13 | Vibracao e wakelock viraram servicos mockaveis (`VibrationService`, `WakelockController`) | Permite widget tests sem `MissingPluginException` e isola plugins de plataforma do core. |
| 2026-05-13 | Dropdowns usam `initialValue` (nao `value`) | `DropdownButtonFormField.value` deprecado no Flutter 3.41+. |
| 2026-05-13 | `PopScope` usa `onPopInvokedWithResult` | `onPopInvoked` deprecado no Flutter 3.41+. |
| 2026-05-13 | Capturar `Navigator.of(context)` antes do `await` em callbacks assincronos | Evita lint `use_build_context_synchronously` sem precisar checar `context.mounted`. |
| 2026-05-13 | Em widget tests, nunca `await Navigator.push(...)` | O Future do `push` so completa quando a rota e popada — `await` causa timeout do teste. |

## Checklist por fase

### Fase 1 - Fundacao testavel

- [x] Criar ou conectar repositorio GitHub do projeto.
- [x] Subir arquivos atuais para o repositorio remoto antes de apagar qualquer copia local.
- [ ] Criar configuracao inicial de Codespaces/devcontainer.
- [ ] Confirmar que `flutter doctor` esta sem erros bloqueantes para Android dentro do Codespace.
- [ ] Escolher servico cloud de device/emulador Android para validacao visual/manual.
- [x] Criar projeto Flutter Android.
- [x] Configurar nome do app.
- [x] Definir pacote Android inicial.
- [x] Organizar pastas `lib/`, `assets/` e `test/`.
- [x] Registrar assets existentes no `pubspec.yaml`.
- [x] Criar modelos `Player`, `Team` e `MatchState`.
- [x] Criar constantes de classes funcionais aceitas.
- [x] Criar constantes de limites de pontuacao.
- [x] Criar testes unitarios basicos.
- [x] Rodar `flutter analyze` (via CI no push da branch).
- [x] Rodar `flutter test` (via CI no push da branch).
- [x] Atualizar este log com arquivos alterados e resultados.

### Fase 2 - Planilha, validacao e cache base

- [x] Implementar importacao `.xlsx`.
- [x] Manter `.csv` fora do MVP e registrar como melhoria futura.
- [x] Criar fixtures de planilha para testes (geradas in-memory via `excel` + dados puros via `SheetData`).
- [x] Interpretar modelo de aba unica.
- [x] Interpretar modelo de uma aba por equipe.
- [x] Validar colunas obrigatorias.
- [x] Validar classes funcionais.
- [x] Detectar atletas sem numero.
- [x] Detectar equipes nao reconhecidas.
- [x] Criar tela de resumo da planilha.
- [x] Criar tela de correcao de dados (versao MVP: tela de diagnostico, sem edicao inline; edicao inline fica como refinamento futuro).
- [x] Criar `CountryResolverService`.
- [x] Criar `CacheService`.
- [x] Cobrir parser e validacoes com testes.
- [x] Atualizar este log com formatos suportados de fato.

### Fase 3 - Fluxo de partida funcional

- [x] Criar tela de selecao de Team A, Team B e Point Limit.
- [x] Bloquear Team A e Team B iguais.
- [x] Criar tela principal de controle.
- [x] Exibir quadra central.
- [x] Exibir listas de atletas por equipe.
- [x] Selecionar e desselecionar atletas por toque.
- [x] Bloquear sexto atleta.
- [x] Somar pontos automaticamente.
- [x] Mostrar alerta persistente acima do limite.
- [x] Acionar vibracao leve ao cruzar o limite.
- [x] Implementar Clear Team A.
- [x] Implementar Clear Team B.
- [x] Implementar Clear All.
- [x] Implementar Change Teams.
- [x] Implementar Load New Spreadsheet.
- [x] Confirmar antes de sair da partida.
- [x] Manter tela ativa durante a partida.
- [x] Restaurar sessao anterior.
- [x] Cobrir fluxo critico com testes.

### Fase 4 - Polimento, APK e validacao Android cloud

- [x] Aplicar identidade visual (tema base — `buildIwbfTheme` + `IwbfColors`; logo IWBF no header de todas as telas via `IwbfBrandHeader` / `IwbfAppBarTitle`).
- [x] Ajustar layout para tablet (Row com listas laterais + quadra central; quadra em portrait via `RotatedBox` + slots fracionarios).
- [x] Ajustar layout para celular (`DefaultTabController` com 3 abas Team A / Court / Team B + breakpoint < 720dp).
- [x] Incluir logos, quadra e icones finais (logos: feito; quadra: feito via `court.png`; icones: feito via `PlayerJerseyIcon`).
- [ ] Incluir bandeiras locais ou solucao equivalente. (Adiada para uma fase futura; `CountryResolverService` ja resolve nome → `flagAssetPath` mas o asset path continua nulo. Decisao: bandeiras nao bloqueiam a Fase 4 nem o MVP — sao polimento incremental que pode entrar numa Fase 5 sem refazer codigo.)
- [x] Criar templates baixaveis (`TemplateGeneratorService` + botoes na Load Spreadsheet).
- [x] Revisar textos em ingles (mensagens do parser, alertas e telas).
- [x] Rodar `flutter analyze` (apos tema + Fase 4 inteira).
- [x] Rodar `flutter test` (apos tema + Fase 4 inteira).
- [x] Gerar APK debug no Codespace ou GitHub Actions (delegado a `build-apk.yml` em cada push para `claude/**`).
- [ ] Testar em perfil tablet via servico cloud de device/emulador Android (passo manual do usuario — `docs/INSTALL_ANDROID.md` cobre BrowserStack / Firebase Test Lab / AWS Device Farm).
- [ ] Testar em perfil phone via servico cloud de device/emulador Android (mesma docs).
- [x] Gerar APK release no Codespace ou GitHub Actions (`flutter build apk --release` esta no workflow `build-apk.yml`).
- [x] Documentar instalacao manual no servico cloud escolhido (`docs/INSTALL_ANDROID.md`).

## Historico de trabalho

### 0001 - 2026-05-12 - Planejamento operacional criado

Resumo:

- Lido o arquivo `IWBF_Team_Points_Control_Planejamento.md`.
- Criado plano operacional curto em 4 fases.
- Criado log de continuidade obrigatorio para IA.
- Definida rotina de testes desde o inicio.
- Registradas ferramentas e contas necessarias.

Arquivos criados:

- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Ainda nao ha codigo de aplicativo.

Proximo passo recomendado:

- Criar o projeto Flutter Android e iniciar a Fase 1.

### 0002 - 2026-05-12 - Decisoes em aberto fechadas

Resumo:

- Confirmado que o MVP sera local-first, sem necessidade de contas de backend, hospedagem, loja ou GitHub.
- Fechadas as principais decisoes antes do inicio do codigo.
- Ajustado o plano para tratar GitHub como opcional e Git local como suficiente.

Arquivos alterados:

- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Alteracao apenas documental.

Proximo passo recomendado:

- Criar o projeto Flutter Android e iniciar a Fase 1.

### 0003 - 2026-05-12 - Testes definidos como emulator-first (plano substituido)

Resumo:

- Plano anterior ajustava o MVP para nao exigir tablet ou celular Android fisico durante o desenvolvimento.
- Plano anterior previa emulador Android tablet e phone no Mac.
- Esse caminho foi substituido em 2026-05-13 pelo plano 100% cloud com Codespaces e servico cloud de device/emulador Android.
- Validacao de vibracao continua por teste automatizado/mocked.

Arquivos alterados:

- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Alteracao apenas documental.

Proximo passo recomendado:

- Plano posteriormente substituido: configurar repositorio GitHub, Codespaces e servico cloud de device/emulador Android.

### 0004 - 2026-05-13 - Estrategia de armazenamento local registrada

Resumo:

- Adicionada orientacao para verificar espaco livre antes de instalar ferramentas Android.
- Registrada meta minima/ideal de espaco livre.
- Registrado que Docker, Claude, Google Drive e backups importantes nao devem ser apagados como requisito do MVP.
- Registrado plano anterior de usar o SSD interno do Mac, depois substituido por Codespaces/cloud-first.

Arquivos alterados:

- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Alteracao apenas documental.

Proximo passo recomendado:

- Plano posteriormente substituido: avaliar Codespaces/cloud-first antes de instalar Android Studio/SDK/emuladores.

### 0005 - 2026-05-13 - Revisao final antes de iniciar com Claude

Resumo:

- Removidas mencoes a uso de outro disco como parte do plano de desenvolvimento.
- Removidas recomendacoes de ferramentas que nao fazem parte do fluxo local por terminal.
- Ajustado o plano para deixar `.csv` e `.xls` fora do MVP.
- Reforcado plano anterior de validar em emuladores Android no Mac, depois substituido por Codespaces/cloud-first.
- Ajustado o estado atual para preparar ambiente local antes de iniciar a Fase 1.

Arquivos alterados:

- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Alteracao apenas documental.

Proximo passo recomendado:

- Plano posteriormente substituido: criar/conectar repositorio GitHub e configurar Codespaces/cloud-first.

### 0006 - 2026-05-13 - Estrategia Codespaces registrada

Resumo:

- Revisado o plano para adotar GitHub Codespaces/cloud-first como caminho principal.
- Removida a obrigatoriedade de instalar Android Studio, Android SDK, JDK e emuladores no Mac para iniciar o MVP.
- Registrado que o repositorio GitHub sera a fonte de verdade antes de apagar a copia local.
- Alinhado o planejamento principal para `.xlsx` como unico formato de planilha no MVP.
- Atualizada a lista antiga de pontos em aberto com decisoes ja fechadas e tarefas de preparacao.
- Registrados os novos logos IWBF enviados para a pasta.
- Registrados ajustes de assets, Git/.gitignore, cache temporario e validacao Android separada.

Arquivos alterados:

- `IWBF_Team_Points_Control_Planejamento.md`
- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Alteracao apenas documental.

Proximo passo recomendado:

- Criar/conectar repositorio GitHub, subir arquivos atuais, configurar Codespaces/devcontainer e rodar `flutter doctor` dentro do Codespace.

### 0007 - 2026-05-13 - Plano 100% cloud confirmado

Resumo:

- Confirmado que o usuario nao usara Android fisico.
- Registrado que o Mac nao deve receber Flutter, Android Studio, Android SDK, JDK ou emuladores locais.
- Registrado que Codespaces sera usado para codigo, testes automatizados e build APK.
- Registrado que Android Emulator dentro do Codespace nao deve ser assumido como caminho principal.
- Registrado que validacao visual/manual Android deve ocorrer em servico cloud de device/emulador.
- Ajustados checklist e criterios para perfis tablet/phone em Android cloud.

Arquivos alterados:

- `IWBF_Team_Points_Control_Planejamento.md`
- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

Testes executados:

- Nenhum. Alteracao apenas documental.

Proximo passo recomendado:

- Criar/conectar repositorio GitHub, subir arquivos atuais, configurar Codespaces/devcontainer, rodar `flutter doctor` dentro do Codespace e escolher servico cloud de device/emulador Android.

### 0008 - 2026-05-13 - Fase 1: modelos, constantes e testes unitarios

Resumo:

- Estruturada a pasta `lib/` com subpastas `constants/` e `models/`.
- Criadas constantes oficiais da IWBF: classes funcionais aceitas (1.0 ate 4.5, passo 0.5), limites de pontuacao (13.0 ate 16.0, passo 0.5), limite padrao (14.0) e maximo de 5 atletas por equipe.
- Criados modelos `Player`, `Team` e `MatchState` com serializacao JSON pronta para o `CacheService` da Fase 2.
- `Player.displayName` segue padrao `SURNAME, First Name`.
- `Team.displayName` resolve `Name - CODE` quando ha `countryCode`.
- `MatchState` cobre: selecao/deselecao por id, toggle, bloqueio do 6o atleta, soma automatica das classes, alerta de limite excedido, clear A/B/all, troca de point limit com validacao.
- Adicionado parser tolerante `parsePlayerClass` que aceita virgula como decimal e rejeita classes fora da tabela.
- Cobertura de testes para constantes, `Player`, `Team` e `MatchState` (selecao, pontuacao, limpeza, point limit, serializacao roundtrip).

Arquivos criados:

- `lib/constants/player_classes.dart`
- `lib/constants/point_limits.dart`
- `lib/models/player.dart`
- `lib/models/team.dart`
- `lib/models/match_state.dart`
- `test/constants/player_classes_test.dart`
- `test/constants/point_limits_test.dart`
- `test/models/player_test.dart`
- `test/models/team_test.dart`
- `test/models/match_state_test.dart`

Arquivos alterados:

- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` e `flutter test` via workflow `build-apk.yml` (a CI dispara automaticamente em push para `claude/**`). Validacao local nao foi feita: o ambiente atual nao tem Flutter/Dart instalados conforme decisao cloud-first.

Pendencias:

- Confirmar resultado da CI no push para `claude/review-and-continue-9ZK5v` antes de iniciar a Fase 2.
- Criar configuracao `.devcontainer` em momento oportuno (continua em aberto).
- Escolher servico cloud de device/emulador Android (continua em aberto).

Proximo passo recomendado:

- Iniciar Fase 2: parser `.xlsx` (lib `excel` ja esta no `pubspec.yaml`) com fixtures de planilha em `test/fixtures/`, `CountryResolverService` e `CacheService`.

### 0009 - 2026-05-13 - Simplificacao do display de equipe

Resumo:

- Decisao do usuario: tirar a complexidade de extrair/manter o codigo de pais (`countryCode`) e padronizar a exibicao da equipe apenas pelo nome completo.
- `Team.displayName` passou a retornar somente `teamName`.
- Removidos `countryCode` e os campos correlatos `teamCode`/`countryCode` do `Player` para deixar o modelo enxuto. `flagAssetPath` permanece no `Team` e sera preenchido pelo `CountryResolverService` (Fase 2) com base no nome.
- Decisao registrada na tabela de "Decisoes registradas".

Arquivos alterados:

- `lib/models/team.dart`
- `lib/models/player.dart`
- `test/models/team_test.dart`
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` e `flutter test` via workflow `build-apk.yml` (CI dispara automaticamente em push para `claude/**`).

Pendencias:

- O usuario precisa confirmar que o run mais recente do `build-apk.yml` em `claude/review-and-continue-9ZK5v` ficou verde antes de iniciar a Fase 2.

Proximo passo recomendado:

- Confirmar CI verde e iniciar a Fase 2: parser `.xlsx`, fixtures de planilha em `test/fixtures/`, `CountryResolverService` (resolve nome -> bandeira local) e `CacheService`.

### 0010 - 2026-05-13 - Fase 2 (sem UI): parser .xlsx, resolver de paises e cache

Resumo:

- Criada a camada de servicos da Fase 2 (logica pura, sem telas):
  - `CountryResolverService`: tabela inicial de aliases (Brasil, Argentina, USA, China, Reino Unido, Alemanha, Espanha, Italia, Japao, Coreia do Sul, Mexico, Holanda, Paraguai, Peru, Uruguai, Venezuela, Turquia, Australia, Iran). Normaliza caixa, acentos e pontuacao. Permite overrides no construtor.
  - `SpreadsheetParserService`: detecta automaticamente modelo aba unica (`Players`) ou modelo aba-por-equipe; valida colunas obrigatorias; valida classes funcionais (aceita virgula); detecta atletas sem numero, sem classe, sem DOB ou com nome incompleto como erros bloqueantes; equipe nao reconhecida e duplicidade de camiseta entram como warning (nao bloqueiam). Tem camada intermediaria `SheetData` para testar a logica sem depender de bytes binarios.
  - `CacheService`: persiste `MatchState` como JSON em `shared_preferences` (chave `iwbf.match_state.v1`); tolera JSON corrompido retornando `null` em vez de lancar.
- Decisao confirmada: `.csv` continua fora do MVP. `.xls` continua fora do MVP. Somente `.xlsx`.
- Decisao registrada: `Player.id` agora e gerado pelo parser no padrao `${teamId}::${shirtNumber}`. `Team.id` segue padrao `team-<nome-slugificado>`.

Decisoes registradas:

- `Player.id` e composto pelo parser para garantir idempotencia entre reimportacoes da mesma planilha.
- `CacheService.loadMatchState()` engole erros de decodificacao silenciosamente e devolve `null`. O motivo: cache temporario, partida nao pode ser bloqueada por corrupcao residual.

Arquivos criados:

- `lib/services/country_resolver_service.dart`
- `lib/services/spreadsheet_parser_service.dart`
- `lib/services/cache_service.dart`
- `test/services/country_resolver_service_test.dart`
- `test/services/spreadsheet_parser_service_test.dart`
- `test/services/cache_service_test.dart`

Arquivos alterados:

- `docs/AI_WORK_LOG.md`

Testes executados:

- Delegados a CI via push em `claude/review-and-continue-9ZK5v`. Geram: `flutter analyze --no-fatal-infos`, `flutter test` e build APK.

Pendencias:

- Confirmar CI verde do push antes de iniciar a UI da Fase 2.
- Telas da Fase 2 (Load Spreadsheet, Validation Summary, Missing Data Correction) ainda pendentes.
- Bandeiras (`CountryResolverService.flagAssetPathFor`) continuam retornando `null` ate a Fase 4.

Proximo passo recomendado:

- Implementar telas da Fase 2 ligando a UI ao parser e ao cache. Sugestao: comecar pela tela de upload + integracao com `file_picker` (ja no pubspec) e tela de resumo.

### 0011 - 2026-05-13 - Fase 2 (UI): telas e fluxo ponta-a-ponta + Flutter SDK local

Resumo:

- Telas implementadas:
  - `LoadSpreadsheetScreen`: tela inicial com botao de upload `.xlsx` (via `file_picker` real, injetavel para testes) + detecao de cache + dialogo "Restore Previous Session / Start from Scratch".
  - `ValidationSummaryScreen`: cabecalho com competition, contagem de equipes e atletas; blocos coloridos para errors (vermelho) e warnings (amarelo); botao "Continue" so habilita quando nao ha erros bloqueantes.
  - `MissingDataScreen`: agrupa issues por categoria com hint pratica para cada tipo de erro (numero de camiseta, classe invalida, DOB, etc.). MVP nao edita inline.
  - `MatchSetupScreen`: placeholder da Fase 3 com aviso e listagem dos teams recebidos. Aceita lista de teams ou `MatchState` restaurado.
- `main.dart`: substitui scaffold placeholder por `LoadSpreadsheetScreen`.
- `widget_test.dart`: atualizado para verificar boot na nova tela.
- Cobertura de testes: 18 widget tests novos (load=7, validation=5, missing=3, match=3). Total geral: 112 testes passando.
- Decisao registrada: edicao inline de dados ausentes fica como refinamento futuro. MVP usa diagnostico textual claro.
- Flutter SDK 3.41.9 stable instalado em `/root/flutter` para validacao autonoma local (`flutter analyze` + `flutter test`).

Arquivos criados:

- `lib/screens/load_spreadsheet_screen.dart`
- `lib/screens/validation_summary_screen.dart`
- `lib/screens/missing_data_screen.dart`
- `lib/screens/match_setup_screen.dart`
- `test/screens/load_spreadsheet_screen_test.dart`
- `test/screens/validation_summary_screen_test.dart`
- `test/screens/missing_data_screen_test.dart`
- `test/screens/match_setup_screen_test.dart`

Arquivos alterados:

- `lib/main.dart`
- `test/widget_test.dart`
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 112 passed, 0 failed, 0 skipped (executado em 11.1s).

Pendencias da Fase 2:

- Nenhuma. Todas as checkboxes fechadas.
- Refinamento futuro registrado: edicao inline em `MissingDataScreen` (preencher numero de camiseta sem reabrir Excel).
- Refinamento futuro registrado: templates `.xlsx` para download (Fase 4).

Proximo passo recomendado:

- Iniciar Fase 3 - Fluxo de partida funcional. Comecar pela tela real de configuracao de partida (selecao Team A / Team B / Point Limit) substituindo o placeholder atual.

### 0012 - 2026-05-13 - Fase 3 (item 1): Match Setup real

Resumo:

- `MatchSetupScreen` deixou de ser placeholder e virou tela real:
  - dropdowns "Select Team A" e "Select Team B" listando o `Team.displayName` de todas as equipes carregadas;
  - bloqueio reativo: quando a mesma equipe e escolhida nos dois dropdowns, aparece a mensagem `Team A and Team B must be different.` e o `Start Match` permanece desabilitado;
  - dropdown de Point Limit usando `kAcceptedPointLimits` (13.0 a 16.0, passo 0.5), com `kDefaultPointLimit` (14.0) como valor inicial;
  - `Start Match` so habilita quando ha duas equipes diferentes selecionadas;
  - quando a sessao e restaurada (`restored: MatchState`), os tres campos vem pre-preenchidos a partir do cache;
  - mensagem de fallback quando nao ha teams carregados ("No teams loaded. Go back and import a spreadsheet.").
- Criado `LineupControlScreen` como placeholder do proximo passo da Fase 3 (recebe `MatchState` via construtor; testes verificam nome do AppBar e dados basicos).
- Detalhe tecnico: dropdowns usam `initialValue` (a partir do Flutter 3.41+) para evitar warning `deprecated_member_use`.

Decisoes registradas:

- `Start Match` apenas navega para a `LineupControlScreen` (placeholder). A persistencia do `MatchState` via `CacheService` entra junto com o item de Lineup Control real (proximo incremento), porque so faz sentido salvar quando ha selecoes de jogadores.

Arquivos alterados:

- `lib/screens/match_setup_screen.dart`
- `test/screens/match_setup_screen_test.dart`

Arquivos criados:

- `lib/screens/lineup_control_screen.dart`
- `docs/AI_WORK_LOG.md` (entrada nova)

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 105 passed, 0 failed, 0 skipped (era 99 antes; +9 novos testes do Match Setup real, -3 testes do placeholder removidos).

Pendencias:

- Lineup Control real (itens 2 a 10 da Fase 3): quadra, listas laterais / abas, selecao ate 5 com bloqueio do 6, soma de pontos, alerta persistente, vibracao via servico mockavel, botoes Clear/Change/Load, confirmacao de saida, wakelock, persistencia via `CacheService`.

Proximo passo recomendado:

- Implementar `LineupControlScreen` real (substituir o placeholder criado neste incremento) com `VibrationService` mockavel injetavel e `CacheService` salvando o `MatchState` a cada mudanca relevante.

### 0030 - 2026-05-14 - Fase 5 - sexta rodada: variantes de genero amplas + aliases extras (USA, PRC, IRI, GB)

Resumo:

- Usuario perguntou se a planilha aceita formas como `"Argentina M"`, `"Argentina Man"`, `"Arg Mans"` e variacoes longas/curtas para USA (`"United States"`, `"United States America"`, `"USA"`, `"US"`...). Pre-checagem mostrou que a rodada anterior (0029) ja cobria `Men`/`Mens`/`Men's`/`Male`/`Female`/`Masculino`/`Feminino` no strip, mas faltavam:
  - letras unicas `M`/`F`/`W`;
  - singular `Man`/`Woman` + plurals nao-possessivos `Mans`/`Womans`;
  - abreviacoes `Masc`/`Fem`/`Mas`;
  - variantes EN/ES/PT: `Masculine`/`Masculina`/`Feminine`/`Feminina`/`Femenino`/`Femenina`;
  - USA sem o "of": `"United States America"`;
  - aliases extras: `PRC` (China), `IRI` (Iran, codigo IOC), `Korea Republic`, `GB`, `Britain`.

**Mudancas no `SpreadsheetParserService`:**

- Constante nova `_genderKeywordPattern` agrupando todos os tokens aceitos. Documenta EN/PT/ES + abreviacoes. Compartilhada entre o strip e o gender column parser para nao divergir.
- `_stripGenderKeyword` agora usa a constante na regex `(?:\s+|\s*-+\s*)(?:<pattern>)$`. Continua exigindo separador (espaco ou hifen) antes do keyword — entao `"ArgM"` (sem separador) nao e tocado e cai como nome desconhecido.
- `_genderFromString` (gender column) trocou os ifs hard-coded por dois `Set<String>` (`_maleGenderTokens`, `_femaleGenderTokens`) com a mesma cobertura.
- Tokens reconhecidos:
  - **Male**: `m`, `male`, `males`, `man`, `men`, `mans`, `mens`, `man's`, `men's`, `masculine`, `masculino`, `masculina`, `masc`, `mas`.
  - **Female**: `f`, `w`, `female`, `females`, `woman`, `women`, `womans`, `womens`, `woman's`, `women's`, `feminine`, `feminino`, `feminina`, `femenino`, `femenina`, `fem`.

**Mudancas no `CountryResolverService`:**

- USA: `"united states america"` (sem o "of"), `"estados unidos de america"`, `"eua"` (abreviacao PT).
- China: `"prc"`.
- Iran: `"iri"` (codigo IOC, complemento ao IRN do ISO).
- South Korea: `"korea republic"` (inversao de `"republic of korea"`).
- Great Britain: `"gb"`, `"britain"`.

Edge case considerado:
- O codigo IOC `MAS` (Malaysia) coincide com o token `mas` para masculino, **mas so no `_genderFromString` que le a coluna `gender` por atleta**. O `CountryResolverService` ja resolve `MAS` para Malaysia antes — `_stripGenderKeyword` so e chamado no `team_name`, nao no codigo da coluna gender. Sem cruzamento real.

Arquivos alterados:

- `lib/services/spreadsheet_parser_service.dart` — `_genderKeywordPattern`, `_maleGenderTokens`/`_femaleGenderTokens`, regex do `_stripGenderKeyword` reescrita, `_genderFromString` simplificado via Set lookup.
- `lib/services/country_resolver_service.dart` — aliases extras para USA, China, Iran, South Korea, Great Britain.
- `test/services/country_resolver_service_test.dart` — assertion nova `"United States America"`, `"EUA"`; teste agrupando `PRC`, `IRI`, `Korea Republic`, `GB`, `Britain`.
- `test/services/spreadsheet_parser_service_test.dart` — grupo novo `"variantes de genero (entrada 0030)"`:
  - 13 sufixos male validados (`Argentina M`, `Argentina Men`, `Argentina Mens`, `Argentina Men's`, `Argentina Man`, `Argentina Mans`, `Argentina Male`, `Argentina Males`, `Argentina Masculine`, `Argentina Masculino`, `Argentina Masculina`, `Argentina Masc`, `Argentina MAS`).
  - 15 sufixos female validados (`Argentina F`, `Argentina W`, `Argentina Women`, `Argentina Womens`, `Argentina Women's`, `Argentina Woman`, `Argentina Womans`, `Argentina Female`, `Argentina Females`, `Argentina Feminine`, `Argentina Feminino`, `Argentina Feminina`, `Argentina Femenino`, `Argentina Femenina`, `Argentina Fem`).
  - Combinacoes `Arg Man`, `ARG Mens`, `ARG F`.
  - Hifen com keyword curto: `Arg - M`, `Argentina-W`.
  - Gender column aceita `Mens`, `Masc`, `Woman`, `Femenino`.
  - Caso longo USA: planilha com `United States America Men`, `USA M`, `US Fem` produz 2 times (`USA - Men` com 2 atletas, `USA - Women` com 1).
  - Negativo: `ArgM` (sem separador) NAO e stripado — fica literal e gera warning unknownTeam.
- `docs/AI_WORK_LOG.md` — esta entrada + tabela de estado.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI valida no push.

Pendencias / smoke test:

- Usuario validar com uma planilha real misturando variantes (algumas linhas com `team_name = "Argentina Masculino"`, outras com `team_name = "Argentina"` + gender column `MASC`).

Proximo passo recomendado:

- Aguardar feedback do usuario. Se a cobertura ainda nao for suficiente, ampliar Sets/Regex sem refatorar o parser.

### 0029 - 2026-05-14 - Fase 5 - quinta rodada: Chile + cobertura IWBF, displayName com hifen, dialog Men vs Women

Resumo:

- Sessao dedicada a tres ajustes reportados pelo usuario apos testar os templates novos da rodada anterior (entrada 0027).

**1. Bug "unknown team: Chile" (e variantes "Chile Men"/"Chile Women").** Era um bug real: o template pre-preenchido (rodada 4) trazia Chile entre os 8 paises, mas Chile **NAO estava** no `CountryResolverService`. Resultado: a planilha single-sheet gerava `Unknown team: Chile` e a per-team gerava `Unknown team: Chile Men` / `Unknown team: Chile Women` (a string de warning usa o nome bruto antes do strip de genero, por isso aparece o sufixo no caso per-team).
   - Correcao direta: adicionar `chile`/`chi`/`chl` ao mapa de aliases e `Chile: CL` ao mapa de codigos alpha-2.

**2. Cobertura IWBF expandida.** Ao corrigir Chile o usuario pediu para garantir que nenhum outro pais oficial dispare o mesmo warning. Reescrevi `_defaultAliases` para cobrir as quatro zonas IWBF:
   - **Americas** (22 paises): Argentina, Bolivia, Brazil, Canada, **Chile**, Colombia, Costa Rica, Cuba, Dominican Republic, Ecuador, El Salvador, Guatemala, Haiti, Honduras, Mexico, Nicaragua, Panama, Paraguay, Peru, Puerto Rico, USA, Uruguay, Venezuela.
   - **Europa** (32 paises): Austria, Belgium, Bosnia and Herzegovina, Croatia, Czech Republic, Denmark, Estonia, Finland, France, Germany, Great Britain, Greece, Hungary, Iceland, Ireland, Israel, Italy, Latvia, Lithuania, Luxembourg, Netherlands, Norway, Poland, Portugal, Romania, Russia, Serbia, Slovakia, Slovenia, Spain, Sweden, Switzerland, Turkey, Ukraine.
   - **Asia/Oceania** (29 paises): Afghanistan, Australia, Cambodia, China, Chinese Taipei, Hong Kong, India, Indonesia, Iran, Iraq, Japan, Jordan, Kazakhstan, Lebanon, Malaysia, Mongolia, New Zealand, Pakistan, Philippines, Qatar, Saudi Arabia, Singapore, South Korea, Sri Lanka, Syria, Thailand, Uzbekistan, Vietnam.
   - **Africa** (13 paises): Algeria, Cameroon, Cote d'Ivoire, Egypt, Ethiopia, Kenya, Morocco, Nigeria, Senegal, South Africa, Tunisia, Uganda, Zimbabwe.
   - Total: ~96 paises com alias + alpha-2. Cobre todos os membros recorrentes em campeonatos zonais e Paralimpiadas.
   - Aliases incluem nome local quando relevante (`Brasil`, `Espana`, `Suomi`, `Turkiye`, `Hrvatska`) e codigos IOC/ISO 3 letras (`BRA`, `KOR`, `KSA`).
   - Pegadinha de normalizacao: `_normalize` derruba apostrofes **sem inserir espaco**, entao `Cote d'Ivoire` vira `cote divoire` (com `d` colado em `ivoire`). Adicionei o alias na forma normalizada **e** a forma com espaco para cobrir variacoes manuais. Mesma logica para Bosnia: cobertura `bosnia and herzegovina` + `bosnia herzegovina` (sem o "and").

**3. Separador hifen no `Team.displayName`.** Pedido visual do usuario: nomes longos como `United States of America Women` viravam parede de texto no dropdown. Trocado para `"<Pais> - Men"` / `"<Pais> - Women"` / `"<Pais> - Mixed"`. Exemplo: `Argentina - Men`, `United States of America - Men`. Sem genero (unspecified), continua `"<Pais>"` sem sufixo.
   - Tambem expandi o regex de `_stripGenderKeyword` no parser para aceitar `\s*-+\s*` alem de `\s+` antes do keyword. Cobre os tres formatos: `Brazil Women`, `Brazil-Women`, `Brazil - Women`. Importante porque o `displayName` agora sai com `" - "` e o usuario pode copiar de volta para o `team_name` da planilha.

**4. Dialog de confirmacao Men vs Women.** Quando Team A e Men e Team B e Women (ou vice-versa), o app agora:
   - mostra um aviso inline (caixa vermelha clara com icone de warning) abaixo dos dropdowns, indicando que oficialmente so se joga same-gender;
   - intercepta o `Start Match` com um `AlertDialog` que tem dois botoes: `Cancel` (mantem na tela) e `Continue anyway` (segue para o LineupControl).
   - Casos com `mixed` ou `unspecified` em qualquer um dos dois lados NAO disparam o aviso — sem dado, sem alarme. Same-gender (Men x Men, Women x Women) tambem nao dispara.
   - Implementacao via `_hasGenderMismatch` getter + `_onStartPressed` async que chama `showDialog<bool>` e so navega quando o retorno e `true`.

Arquivos alterados:

- `lib/services/country_resolver_service.dart` — `_defaultAliases` expandido para ~96 paises das 4 zonas IWBF; `_countryCodes` com todos os alpha-2 correspondentes; aliases extras para nomes com apostrofe (`Cote d'Ivoire`) e variacoes regionais.
- `lib/models/team.dart` — `displayName` agora usa `" - "` como separador antes do sufixo de genero. Docstring atualizada.
- `lib/services/spreadsheet_parser_service.dart` — regex de `_stripGenderKeyword` aceita `\s*-+\s*` alem de `\s+` antes do keyword. Comentario na docstring atualizado.
- `lib/screens/match_setup_screen.dart` — getter `_hasGenderMismatch`, callback async `_onStartPressed`, dialog `_showGenderMismatchDialog`, caixa de aviso inline `Key('gender-mismatch-warning')` quando Men x Women.
- `test/services/country_resolver_service_test.dart` — teste de regressao explicito para Chile, teste cobrindo os 8 paises do template oficial, smoke test das 4 zonas IWBF.
- `test/models/team_test.dart` — assertions atualizadas para o novo formato `"Brazil - Men"`; teste novo para nome longo (`United States of America - Men`).
- `test/services/spreadsheet_parser_service_test.dart` — assertions atualizadas no grupo "genero"; teste novo confirmando que `Brazil - Women` (com hifen) e stripado para `Brazil`; grupo novo "regressao Chile" com dois testes (single sheet e per-team) confirmando que Chile nao gera mais warning.
- `test/screens/match_setup_screen_test.dart` — `_team` helper agora aceita `gender`; novo grupo "gender mismatch" com 4 testes (warning + dialog em Men x Women, Cancel mantem, Continue avanca, Men x Men nao dispara).
- `docs/AI_WORK_LOG.md` — esta entrada e tabela de estado atualizada.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI valida no push.

Pendencias / smoke test pos-deploy:

- Confirmar no preview Web que o template per-team com 16 abas (incluindo Chile Men e Chile Women) carrega sem warning "Unknown team".
- Confirmar que o dropdown de Team A/B mostra os 16 nomes no formato `Pais - Genero`.
- Confirmar que selecionar `Brazil - Men` em Team A e `Argentina - Women` em Team B exibe a caixa vermelha inline + dispara o dialog ao clicar Start Match.

Proximo passo recomendado:

- Aguardar smoke test do usuario. Se OK, considerar fechar o ciclo da Fase 5 e abrir PR `claude/review-and-continue-9ZK5v -> main` para mergear o codigo.

### 0028 - 2026-05-14 - Docs-only PR para main (#2): branch warning persistente

Resumo:

- Push direto na `main` foi bloqueado (HTTP 403 — proteção da branch). Solução: branch nova `docs/sync-warning-to-main` com apenas os 4 arquivos de doc atualizados, PR #2 aberto em https://github.com/gnpazinato/IWBF-Team-Points-Control/pull/2.
- Quando o usuário mergear, qualquer chat futuro que pousar em `main` lê os docs com o aviso de branch e o estado real de Fase 1-5 — não vai mais cair no equívoco de "Fase 1 ainda pendente".

Arquivos no PR (modificados em `main`):

- `README.md`
- `docs/IWBF_Team_Points_Control_Planejamento.md`
- `docs/PLANO_DESENVOLVIMENTO_IA.md`
- `docs/AI_WORK_LOG.md`

`lib/`, `pubspec.yaml`, `android/`, `web/`, workflows, assets — intocados em `main`.

Quando o ciclo MVP fechar e o PR de **código** (`claude/review-and-continue-9ZK5v → main`) for mergeado, os blocos de aviso podem ser removidos.

Próximo passo recomendado:

- Usuário merge o PR #2 (docs).
- Continuar Fase 5 com novos ajustes na branch `claude/review-and-continue-9ZK5v`.

### 0027 - 2026-05-14 - Fase 5 - quarta rodada: gender por equipe, templates ricos, Point Limit ampliado, "or" na home + branch warning nos docs

Resumo:

- Sessão dedicada a 4 ajustes pos-teste do usuário **+ uma medida preventiva** depois de outro chat ter olhado a `main` (que só tem o scaffold) e diagnosticado erradamente que "nada estava implementado".

**0. Branch warning nos docs.** Topo do `docs/AI_WORK_LOG.md` e do `docs/PLANO_DESENVOLVIMENTO_IA.md` agora carregam um bloco em destaque explicando que **TODO o trabalho está em `claude/review-and-continue-9ZK5v`** e que `main` é só scaffold. Inclui comandos `git checkout` exatos. Estado atual da tabela passa a listar `Branch de trabalho` explicitamente.

**1. Separador "or" entre os botões de download de template** na home (`LoadSpreadsheetScreen`). Novo widget `_OrDivider` com dois `Divider`s laterais e o texto "or" centralizado.

**2. Templates `.xlsx` pre-preenchidos com 16 equipes (8 países × 2 gêneros) × 12 atletas = 192 entradas.**
   - Países: Argentina, Brazil, Canada, Chile, Colombia, Mexico, United States of America, Venezuela.
   - Cada equipe tem 12 atletas com nomes culturalmente apropriados (latino-americanos / norte-americanos), shirt numbers 4-15, classes oficiais `[1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0×3, 4.5×3]` (soma 35.5/equipe), DOBs variadas entre 1988-2004.
   - `competition_name`: `"IWBF America's Cup"`.
   - Single sheet: 192 linhas numa aba `Players`.
   - Per-team: 16 abas (`Argentina Men`, `Argentina Women`, `Brazil Men`, ...) com 12 linhas cada.
   - O usuário pode importar o template direto e testar o app sem digitar dados.

**3. Gender por equipe.** Mudança grande, em camadas:
   - `Team` ganhou `enum TeamGender { men, women, mixed, unspecified }` e o campo `gender`. `displayName` agora retorna `"Brazil Men"`, `"Brazil Women"`, `"Brazil Mixed"` ou apenas `"Brazil"` conforme o gênero. `toJson`/`fromJson` persistem o campo; ausência cai em `unspecified` (backward compat).
   - **Parser** agora agrupa por `(country_canonico, player_gender)`. Helpers:
     - `_stripGenderKeyword`: remove `Men`/`Women`/`Male`/`Female`/`Masculino`/`Feminino`/`Men's`/`Women's` no final do `team_name` ou nome da aba.
     - `_teamGenderFromPlayerGender`: mapeia o gênero do atleta pro gênero do time.
     - `_teamIdWithGender`: id determinístico com sufixo `-men`/`-women`/`-mixed`/vazio.
   - Resultado: se a planilha tem Argentina com atletas mistos, o parser produz `Argentina Men` e `Argentina Women` como teams distintos. Sem coluna `gender`, vira um time `unspecified` (compat).
   - **Summary** agrupa as equipes em seções `Men's Teams`, `Women's Teams`, `Mixed Teams` e `Other Teams` (esta última só aparece se houver gêneros mistos no resultado). Cada seção ordena alfabeticamente. Implementado via novo `_SectionHeader`.
   - **Match Setup, Lineup Control e lista lateral** já usam `team.displayName` — então automaticamente passam a mostrar `"Argentina Women"` etc. sem mudança extra.

**4. Point Limit ampliado de 7.0 até 16.0** em incrementos de 0.5 (`kAcceptedPointLimits` agora tem 19 valores em vez de 7). Default permanece 14.0. Cobre categorias menos restritivas (júnior/escolar/mistas) sem perder os limites IWBF oficiais (13.0–16.0).

Arquivos alterados:

- `docs/AI_WORK_LOG.md`, `docs/PLANO_DESENVOLVIMENTO_IA.md` — branch warning + tabela atualizada.
- `lib/constants/point_limits.dart` — faixa expandida 7.0-16.0.
- `lib/models/team.dart` — `TeamGender`, `gender` field, `displayName` com sufixo, JSON.
- `lib/services/spreadsheet_parser_service.dart` — agrupamento por (team, gender), helpers `_stripGenderKeyword`, `_teamGenderFromPlayerGender`, `_teamIdWithGender`, `_TeamBucket`.
- `lib/services/template_generator_service.dart` — reescrito com `_sampleTeams` (8 países × 2 gêneros × 12 atletas).
- `lib/screens/load_spreadsheet_screen.dart` — `_OrDivider` entre os botões de template.
- `lib/screens/validation_summary_screen.dart` — `_teamTiles` agrupa por gênero, novo `_SectionHeader`.
- `test/constants/point_limits_test.dart` — assertions atualizadas pra 19 valores.
- `test/models/team_test.dart` — testes de gender suffix + roundtrip.
- `test/services/spreadsheet_parser_service_test.dart` — grupo novo "genero" com 3 testes (split, strip, sem-coluna).
- `test/services/template_generator_service_test.dart` — atualizado pra 16 equipes / 192 atletas / competição "IWBF America's Cup".

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI valida no push.

Pendencias:

- Smoke test no preview Web pos-deploy para confirmar render do separador "or", os 16 cards de equipe na Summary com seções por gênero, e o dropdown de Point Limit com a faixa nova.
- Quando o ciclo MVP fechar, abrir PR `claude/review-and-continue-9ZK5v → main` para oficializar.

Proximo passo recomendado:

- Aguardar feedback do usuário. Se OK, partir pra Fase 6 / próximas etapas.

### 0026 - 2026-05-14 - Fase 5 - terceira rodada: ordem por shirt, slots adaptativos, court posicionamento por slot

Resumo:

- Quinta rodada de feedback pos-teste do usuario. Cinco itens:

1. **Lista lateral ordenada por shirt number.** `_TeamPlayerList` agora ordena `team.players` por `shirtNumber` antes de renderizar — mesma regra ja aplicada na Summary. Resolve caso do screenshot onde o atleta 55 aparecia no topo.

2. **Cards adaptativos pelo tamanho da tela.** `_TeamPlayerList` envolve a lista em `LayoutBuilder` e calcula `slotHeight = (listHeight / playerCount).clamp(28, 56)`. `ListView.builder` com `itemExtent: slotHeight`. `_PlayerCard` recebe `height` e deriva `iconSize`, `fontSize` e `verticalPadding` proporcionalmente. Times com 6 atletas mostram cards maiores; times com 12 cabem com folga. Acaba o espaco vazio no rodape e o numero da camiseta cresce junto.

3. **Numero do icone mais destacado.** `PlayerJerseyIcon`: area do numero ampliada (margens 0.18 vs 0.22) e `letterSpacing: -1` pra numeros de 2 digitos ficarem mais compactos sem perder peso. O peso `w900` foi mantido. Com cards maiores (item 2), o numero ganha presenca natural.

4. **Court com posicionamento por slot fixo.** `MatchState` reescrito: trocou `Set<String> _selectedTeamA/B` por `List<String?> _teamASlots/_teamBSlots` (length 5). `togglePlayer` agora:
   - Se atleta ja esta num slot → nula o slot (sai da quadra, espaço fica vazio).
   - Se nao esta → preenche o primeiro slot `null` (entra na primeira vaga livre).
   - Se todos os slots cheios → bloqueia.
   Resultado: ao remover o atleta 2, sua posicao em quadra fica vazia ate o proximo clique. O atleta novo vai exatamente para aquela vaga vazia. A API antiga (`selectedTeamAIds`, `selectedTeamAPlayers`, etc.) foi mantida derivada dos slots — testes existentes continuam validos. `_CourtView` agora itera `state.teamASlotPlayers` (length 5, com nulls) em vez da lista filtrada — slot `i` cai exatamente na coordenada `_teamATargets[i]`.

5. **Hot-fix do bug "Start Match → tela em branco"** (na verdade ja entrou no commit 5f31d96 da rodada anterior, registrado aqui pra fechar o ciclo). Causa: `Row(crossAxisAlignment: CrossAxisAlignment.stretch)` nos score cells sem altura bounded gerava erro de layout no Flutter Web e silenciosamente nao renderizava o body. Com os dois cells tendo a mesma altura natural via `SizedBox(height: 14)` reservado, a stretch ja era redundante — bastou remover.

Sobre serializacao do cache:
- Novo formato: `teamASlots: List<String?>` e `teamBSlots: List<String?>`.
- Mantida compat retroativa: se o JSON ainda tiver `selectedTeamA/B` (formato antigo, antes desta entrada), o `MatchState.fromJson` aceita e converte pra slots preenchendo as primeiras posicoes. Caches anteriores nao quebram.

Arquivos alterados:

- `lib/models/match_state.dart` — refatoracao slot-based + compat de serializacao.
- `lib/screens/lineup_control_screen.dart`:
  - `_TeamPlayerList` ordena por shirt + `LayoutBuilder` com `slotHeight` adaptativo.
  - `_PlayerCard` aceita `height` e dimensiona icon/font/padding proporcionalmente.
  - `_CourtView` itera `teamASlotPlayers` (5 com nulls) em vez de lista compacta.
- `lib/widgets/player_jersey_icon.dart` — margens do numero mais agressivas + `letterSpacing: -1`.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). Os testes de `MatchState` foram revisados manualmente — todos usam `selectedTeamAIds`/`selectedTeamAPlayers` (Set/lista filtrada), que continuam funcionando com a refatoracao slot-based. CI valida no push.

Pendencias / observacoes:

- Usuario confirmou que documentacao em `AI_WORK_LOG.md` continua obrigatoria. Ja estava sendo feita — entradas 0023, 0024, 0025 e agora 0026 cobrem toda a Fase 5.
- Em portrait sem espaco para 12 jogadores (telas muito pequenas, <600dp altura), o clamp(28, 56) deixa o slot em 28dp e ListView vira scrollavel mesmo com poucos atletas. Aceitavel — alternativa seria reduzir min para 24dp se aparecer.

Proximo passo recomendado:

- Smoke test no preview Web pos-deploy. Apos validar, partir pra Fase 6 (proximas etapas que o usuario mencionou).

### 0025 - 2026-05-14 - Fase 5 - segunda rodada de ajustes pos-teste

Resumo:

- Usuario testou o preview Web e reportou multiplos ajustes em sequencia. Resolvi todos em uma sessao.

Itens:

1. **Centralizar nome da competicao + AppBar.** Texto da competicao no header agora usa `textAlign: TextAlign.center`. `centerTitle: true` foi setado globalmente no `AppBarTheme` do `iwbf_theme`, centralizando o logo + texto em todas as telas.

2. **Logo IWBF na versao horizontal.** Usuario forneceu `Horizontal IWBF Logo Coloured Black.png` via Drive. Salvo como `assets/images/iwbf-logo-horizontal-black.png`. `IwbfAppBarTitle` agora usa a versao horizontal (aspect ratio ~1.89:1) com `FilterQuality.high` — renderiza muito mais nitida no AppBar do que a vertical encolhida. `IwbfBrandHeader` (home) continua com a vertical, onde tem espaco. Constante `kIwbfLogoHorizontalBlackAsset` adicionada.

3. **Nova quadra sem estrela.** Usuario forneceu novo `court.png` via Drive. Substituido o anterior (1716x917, sem o canto-estrela que estava antes).

4. **Player icon vetorial (CustomPainter).** Decisao do usuario apos ver os PNGs antigos com muito detalhe e numero ilegivel. `PlayerJerseyIcon` reescrita como `CustomPainter` desenhando uma camiseta tank-top (decote em V, alcas, A-line) com numero grande no peito. Branco com numero preto pro Team A; preto com numero branco pro Team B; borda dourada IWBF. Nitida em qualquer tamanho, sem PNG.

5. **PNGs de cadeira-de-rodas removidos.** `team-a/b-men/women.png` deletados (eram ~85-95KB cada, agora 0 — alem do icone vetorial ser superior).

6. **Score boxes Team A/Team B com mesma altura.** Antes, quando uma equipe estourava o limite, sua box ficava mais alta (tinha texto "Point limit exceeded." extra). Agora cada `_ScoreCell` reserva sempre `SizedBox(height: 14)` pro texto de alerta — ele aparece dentro quando estoura, fica vazio quando nao. Resultado: os dois boxes sempre tem altura identica.

7. **Ordem alfabetica em todas as listas de equipes.** `ValidationSummaryScreen._teamTiles` e `MatchSetupScreen._availableTeams` agora ordenam por `team.displayName` case-insensitive. Argentina vem antes de Brazil, Brazil antes de Canada, etc.

8. **Expansao por equipe na Summary.** Cada card de equipe em "Teams found" agora e um `ExpansionTile`. Ao clicar, abre lista de jogadores ordenada por numero da camiseta com `#NUMERO  SURNAME, FirstName` + `DOB DD/MM/YYYY  •  Class X.Y`. Helper `_formatDob` formata datas.

9. **Layout compacto pra mostrar 12 jogadores.** Usuario reportou que so 9 jogadores apareciam em retrato (uso principal). Tudo apertado:
   - `_Header`: padding 12→8/6, `titleMedium`→`titleSmall`, `flag size 18→16`, `Point Limit` em isDense + fontSize 14, spacing entre rows reduzido.
   - `_ScoreCell`: padding 8→6/4, fontSize 20→18, label fontSize 12, alert reservado em 14dp.
   - `_TeamPlayerList`: padding 8→6/4, header bottom 8→4, **centralizado** (mainAxisAlignment.center, antes era Expanded esquerda), flag 18→16, fontSize 13.
   - `_PlayerCard`: outer padding vertical 2→1, inner 12/8→6/3, icon 36→26, fontSize 12, maxLines: 1.
   - Resultado estimado: ~36dp por card vs ~56dp antes. Cabem 12 cards com folga em portrait ~800dp.

Arquivos alterados:

- `assets/images/iwbf-logo-horizontal-black.png` (novo, ~108KB).
- `assets/images/court.png` (substituido — nova quadra sem estrela).
- `assets/images/team-a-men.png`, `team-a-women.png`, `team-b-men.png`, `team-b-women.png` **REMOVIDOS** (PNG antigos nao usados mais).
- `lib/widgets/iwbf_logo_header.dart` (constante `kIwbfLogoHorizontalBlackAsset`, `IwbfAppBarTitle` usa horizontal).
- `lib/widgets/player_jersey_icon.dart` (reescrita completa — agora `CustomPainter` vetorial).
- `lib/theme/iwbf_theme.dart` (`centerTitle: true`).
- `lib/screens/lineup_control_screen.dart` (header centralizado/compactado, score boxes c/ altura fixa, team header centralizado, player cards compactos, court chip ja usa `PlayerJerseyIcon`).
- `lib/screens/match_setup_screen.dart` (ordenacao alfabetica via `_availableTeams`).
- `lib/screens/validation_summary_screen.dart` (ordenacao alfabetica, `ExpansionTile` por equipe, lista de jogadores ordenada por shirt).
- `test/widgets/player_jersey_icon_test.dart` (reescrito — testes de `resolveJerseyAsset` removidos, novos testes pro icone vetorial).

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI no push.

Pendencias:

- Validar visualmente no preview Web pos-deploy:
  - 12 jogadores cabendo na tela em portrait;
  - icones vetoriais nitidos em qualquer DPR;
  - score boxes alinhadas em ambos os estados;
  - alfabetacao funcionando.

Proximo passo recomendado:

- Smoke test no preview Web. Eventuais novos ajustes em uma rodada nova.

### 0024 - 2026-05-13 - Fase 5 (itens 2 a 5): templates, jerseys limpos, bandeiras Unicode, chip da quadra com icone

Resumo:

- Quatro itens da entrada 0023 fechados em sequencia. Ambiente sem Flutter SDK local — todas as mudancas validadas por leitura cuidadosa do codigo + leitura dos testes existentes (atualizados para acompanhar as mudancas estruturais).

**Item 1 (templates `.xlsx`):**
- `player_class` agora sai como texto `2,0` (uma casa decimal, vírgula). O parser ja aceita tanto `2.0` quanto `2,0` via `parsePlayerClass`.
- `dob` agora sai em `DD/MM/YYYY`. O parser ja aceita tanto `YYYY-MM-DD` quanto `DD/MM/YYYY`.
- `competition_name` adicionado ao `perTeamHeaders` (template per-team agora bate com o single-sheet nessa coluna). Valor `IWBF Sample Championship` para os 4 atletas exemplo.
- Helpers `_formatPlayerClass` e `_formatDob` adicionados em `template_generator_service.dart`.

**Item 2 (icones dos jogadores):**
- Os 4 PNGs `team-a/b-men/women.png` vinham como 2048x2048 ~5MB cada, com `10` estampado na camiseta (interferia com o numero overlay e estourava o bundle).
- Script Python (PIL + scipy.ndimage) detectou os digitos `1` e `0` da camiseta como componentes conexos isolados na ROI central do peito, dilatou a mascara (`binary_dilation iterations=8`) para pegar o halo antialiased e pintou tudo com a cor da camiseta (branco para Team A, preto para Team B). Depois redimensionei para 256x256 com filtro LANCZOS.
- Resultado: ~85-95 KB cada (vs ~5 MB original — reducao de ~98%) e camiseta limpa, sem o `10` embutido. Validacao visual via `Read` direto dos PNGs no pos-processamento.
- `PlayerJerseyIcon` reposicionado: numero agora em `Alignment(0, -0.20)` (alinhado ao peito da camiseta onde o `10` estava), com `FilterQuality.high`, `FontWeight.w900` e `fontSize: size * 0.32`. Numero preto no Team A (camiseta clara) e branco no Team B (camiseta escura), conforme contraste pedido.

**Item 3 (bandeiras):**
- `CountryResolverService` agora expoe `countryCodeFor(rawName)` (ISO 3166-1 alpha-2 a partir do nome canonico — `Brazil` -> `BR`) e `flagEmojiFor(rawName)` (par de Regional Indicator Symbols Unicode).
- Funcao top-level `countryFlagEmoji(alpha2)` faz a conversao `BR` -> `🇧🇷` somando `0x1F1E6 + (letra - 'A')`. Funciona em Web e Android moderno via fonte do sistema, sem dependencia nova.
- Mapa interno cobre os 22 paises que ja estavam nos aliases (Argentina/Brazil/USA/Korea/etc.).
- Novo widget `lib/widgets/country_flag.dart` exibe o emoji ou cai num `Icon(Icons.flag_outlined)` quando o pais nao for reconhecido.
- Bandeiras intercaladas em: `ValidationSummaryScreen` (cards de equipe), `MatchSetupScreen` (dropdowns Team A/B), `LineupControlScreen` (header e titulos das listas laterais).
- Metodo antigo `flagAssetPathFor` removido. Teste correspondente substituido por testes de `countryCodeFor`, `flagEmojiFor` e do helper `countryFlagEmoji`.

**Item 4 (chip da quadra com icone):**
- `_CourtPlayerChip` em `lib/screens/lineup_control_screen.dart` agora usa `PlayerJerseyIcon` (size 36) no topo, em cima de `SURNAME` (caixa alta) e da classe.
- Antes mostrava `#shirt` / `SURNAME` / `classe` so como texto.

Arquivos alterados:

- `assets/images/team-a-men.png`, `team-a-women.png`, `team-b-men.png`, `team-b-women.png` (regenerados 256x256 sem o `10` embutido).
- `lib/services/template_generator_service.dart` (formato `2,0` para classe, `DD/MM/YYYY` para DOB, `competition_name` no per-team).
- `lib/widgets/player_jersey_icon.dart` (`FilterQuality.high`, numero reposicionado, peso/tamanho ajustados).
- `lib/services/country_resolver_service.dart` (`countryCodeFor`, `flagEmojiFor`, helper `countryFlagEmoji`, mapa alpha-2; remocao do antigo `flagAssetPathFor`).
- `lib/widgets/country_flag.dart` (novo).
- `lib/screens/validation_summary_screen.dart`, `lib/screens/match_setup_screen.dart`, `lib/screens/lineup_control_screen.dart` (uso do `CountryFlag` + reorganizacao do header em widgets separados; chip da quadra com icone).
- `test/services/country_resolver_service_test.dart` (testes do antigo `flagAssetPathFor` substituidos pelos novos).
- `test/screens/lineup_control_screen_test.dart` (header espera widgets separados; chip espera `SURNAME1` ao inves de `#1`).
- `test/screens/match_setup_screen_test.dart` (mesma adaptacao do header).

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). Confianca via revisao dos testes pre-existentes e do impacto das mudancas. CI valida no push.

Pendencias / Item 6 da entrada 0023:

- Pendente: usuario havia mencionado "varios outros pequenos ajustes" alem dos 5 itens. Continuam pendentes ate o usuario detalhar.
- Validar visualmente no preview Web pos-deploy:
  - bandeiras renderizam (Web/Chrome tipicamente OK; em algumas distros Linux pode faltar emoji font color — ainda assim o widget cai bem no `Icon` se o glifo nao tiver cobertura);
  - numero da camiseta legivel agora que o `10` foi removido;
  - chip da quadra mostra o icone certo (claro/escuro por equipe).

Proximo passo recomendado:

- Aguardar smoke test do usuario. Se algo mais aparecer, abrir nova sessao com a lista detalhada.

### 0023 - 2026-05-13 - Fase 5 aberta (1/5): logo IWBF preto sobre fundo claro

Resumo:

- Usuario testou o preview Web em `https://gnpazinato.github.io/IWBF-Team-Points-Control/` e reportou 5 bugs visuais (validacao manual que minha rotina `analyze + test` nao pega).
- Item 1 corrigido nesta sessao (trivial, ~1 min): `IwbfBrandHeader` e `IwbfAppBarTitle` usavam `kIwbfLogoWhiteAsset` (logo branco, pensado para fundos escuros). Sobre o fundo off-white do tema, ficava ilegivel. Trocado para `kIwbfLogoBlackAsset` (logo preto/escuro, pensado para fundos claros). Docstrings das duas constantes tambem ajustadas para deixar claro o uso de cada uma.
- Itens 2 a 5 ficam para uma sessao nova (Fase 5 completa). Lista abaixo (na ordem em que o usuario reportou):

Fase 5 — Lista de bugs visuais (pos-teste manual no preview Web):

1. **[FEITO]** `IwbfBrandHeader` / `IwbfAppBarTitle` usavam logo branco sobre fundo off-white. Trocado para `kIwbfLogoBlackAsset` (commit nesta sessao).

2. **[ABERTO] `PlayerJerseyIcon` — numero duplicado/ilegivel:** os assets `team-a/b-men/women.png` ja tem o numero `10` estampado na camiseta (era o exemplo do PNG original). O overlay numerico do `PlayerJerseyIcon` aparece POR CIMA do 10, ficando ilegivel. Decidir entre:
   (a) trocar os 4 assets por versoes sem numero embutido (preferencia: SVG ou PNG vetorial);
   (b) reposicionar/cobrir a regiao do 10 com um badge solido sobre o ponto exato;
   (c) outra abordagem (ex.: passar a usar so um avatar com cor + numero overlay, sem o PNG).

3. **[ABERTO] Qualidade/pixelacao dos icones:** mesmo em alta densidade os PNGs estao mostrando borrado/serrilhado. Investigar:
   - filtering do `Image.asset` (`filterQuality: FilterQuality.high`?);
   - dimensoes efetivas vs original (2048x2048 sendo escalado para 36-40dp);
   - regerar ou substituir os assets por SVG (`flutter_svg` ja avaliada no planejamento mas nao adicionada).

4. **[ABERTO] Quadra sem icones dos jogadores selecionados:** hoje o `_CourtPlayerChip` em `lib/screens/lineup_control_screen.dart` mostra apenas texto (`#shirt / SURNAME / class`). O planejamento original (`IWBF_Team_Points_Control_Planejamento.md` secao 16.2) pede icone na quadra tambem. Trocar o chip por uma versao com `PlayerJerseyIcon` (apos resolver item 2).

5. **[ABERTO] Dados incorretos no template `.xlsx`:** o usuario mencionou que as informacoes pre-preenchidas no template gerado estao com algo errado, mas nao detalhou ainda. Pedir a lista exata do que esta errado no inicio da nova sessao e revisar `_sampleRoster` em `lib/services/template_generator_service.dart`.

6. **[ABERTO] "Varios outros pequenos ajustes":** o usuario mencionou que existem outros ajustes alem dos 5 acima. Pedir a lista completa na nova sessao antes de codar.

Arquivos alterados (item 1):

- `lib/widgets/iwbf_logo_header.dart` (3 lugares: docstrings das 2 constantes + asset usado em `IwbfBrandHeader` + asset usado em `IwbfAppBarTitle`).
- `docs/AI_WORK_LOG.md`.

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 145 passed, 0 failed, 0 skipped.

Pendencias:

- Itens 2-6 da lista acima. **Devem ser tratados numa nova sessao de chat** (esta ja tem ~200k tokens de contexto).

Proximo passo recomendado:

- Abrir nova conversa com o prompt da secao "Prompt curto de continuidade — Fase 5" no final deste arquivo. O prompt ja inclui a lista acima (sem o item 1, ja resolvido).

### 0022 - 2026-05-13 - GitHub Pages destravado para branches `claude/*`

Resumo:

- Os 22 runs anteriores do `deploy-web.yml` em `claude/review-and-continue-9ZK5v` (commits 8 a 23) buildavam o Flutter Web com sucesso mas falhavam na etapa final `Deploy to GitHub Pages` com:
  `Branch 'claude/review-and-continue-9ZK5v' is not allowed to deploy to github-pages due to environment protection rules.`
- Causa: o environment `github-pages` no GitHub Settings vinha com "Deployment branches and tags" restrito (provavelmente `main` only, default do GH Pages).
- Solucao: usuario foi em Settings → Environments → github-pages → "Deployment branches and tags" → mudou para **No restriction** ("Environment changes successfully saved: all branches can deploy.").
- Apos a mudanca, runs #22 e #23 foram re-rodados e ficaram verdes. Confirma que o build Web e os assets estavam corretos desde o `tema IWBF` (Fase 4 item 1).
- Pushei commit vazio `3b17b1d` para disparar o run #24 e confirmar que a regra funciona para novos pushes daqui em diante.

Decisao registrada:

- Environment protection do `github-pages` fica em "No restriction" durante o ciclo MVP — qualquer push em `claude/*` ou `main` publica. Quando o projeto for para producao real, vale revisitar para travar de novo a `main`.

Arquivos alterados:

- `docs/AI_WORK_LOG.md`
- Sem mudancas de codigo.
- Commit `3b17b1d` e empty commit para disparar workflow.

Testes executados:

- Nenhum local (mudanca apenas em config remoto do GitHub).

Pendencias:

- Nenhuma. Preview Web ja servindo `b8fa23a` em `https://gnpazinato.github.io/IWBF-Team-Points-Control/`.

Proximo passo recomendado:

- Smoke test manual no navegador. Quando estiver OK, abrir PR `claude/review-and-continue-9ZK5v → main` e mergear.

### 0021 - 2026-05-13 - Hotfix Web: template saver via conditional imports

Resumo:

- `LoadSpreadsheetScreen._defaultSaveTemplate` usava `dart:io` + `path_provider`. Isso compila no Web (Flutter Web tem shim do `dart:io`) MAS `path_provider.getApplicationDocumentsDirectory()` lanca `MissingPluginException` em runtime — quem clicasse em "Download Template" no preview Web teria visto erro.
- Solucao: extrair o saver default para um modulo separado com conditional imports:
  - `lib/utils/template_saver.dart` — fachada, faz `import 'template_saver_stub.dart' if (dart.library.io) 'template_saver_io.dart' if (dart.library.html) 'template_saver_web.dart'`.
  - `lib/utils/template_saver_io.dart` — Android/iOS/desktop: `path_provider` + `dart:io`.
  - `lib/utils/template_saver_web.dart` — Web: `package:web` + `dart:js_interop`, cria `Blob`, gera `Object URL`, dispara `<a download>`.
  - `lib/utils/template_saver_stub.dart` — fallback que so lanca `UnsupportedError` (nao deveria ser alcancado).
- `LoadSpreadsheetScreen` agora importa `package:.../utils/template_saver.dart as platform_saver` e usa `platform_saver.defaultSaveTemplate` como default — sem `dart:io` direto na tela.
- `web: ^1.1.0` virou dep direta (antes era transitive). pubspec.lock atualizado.
- Verificado:
  - `flutter analyze --no-fatal-infos` -> No issues found (zero, incluindo info-level).
  - `flutter test` -> 145 passed, 0 failed.
  - `flutter build web --release` -> ✓ Built build/web (62 MB, ~50s).

Decisao tecnica registrada:

- Para "salvar arquivo" multiplaforma no Flutter, conditional imports com `dart.library.io` / `dart.library.html` sao o padrao recomendado (em vez de `kIsWeb`). Mantem o `dart:io` longe do bundle Web e evita `MissingPluginException` em runtime.
- `dart:html` esta deprecated no Flutter 3.41+. Usar `package:web` + `dart:js_interop` (Blob, URL, HTMLAnchorElement).

Arquivos criados:

- `lib/utils/template_saver.dart`
- `lib/utils/template_saver_io.dart`
- `lib/utils/template_saver_web.dart`
- `lib/utils/template_saver_stub.dart`

Arquivos alterados:

- `lib/screens/load_spreadsheet_screen.dart` (removido `dart:io` e `path_provider`; default agora vem de `template_saver.dart`)
- `pubspec.yaml` (adicionado `web: ^1.1.0`)
- `pubspec.lock` (web virou direct main)
- `docs/AI_WORK_LOG.md`

Pendencias:

- Nenhuma do codigo. Preview Web em `https://gnpazinato.github.io/IWBF-Team-Points-Control/` depende de Pages estar habilitado: Settings → Pages → Source: "GitHub Actions". Se 403 persistir, e isso.

Proximo passo recomendado:

- Apos o `deploy-web.yml` rodar nesse push, abrir o URL no Mac/iPhone/iPad e exercitar o app inteiro (Carregar template baixado → Validation Summary → Match Setup → Lineup Control com selecao + alerta).

### 0020 - 2026-05-13 - Fase 4 (item 7/7): APK release + docs de instalação

Resumo:

- Workflow `build-apk.yml` ja gera `flutter build apk --release` em cada push para `claude/**` e expoe o APK como artifact `iwbf-team-points-control-apk`. Apos este push final, a CI ira regenerar com todo o polimento aplicado.
- Criado `docs/INSTALL_ANDROID.md` com o passo-a-passo completo de sideload:
  1. Como baixar o APK do GitHub Actions.
  2. Instalacao em tablet/phone fisico (Settings → Apps → Special app access → Install unknown apps).
  3. Instalacao via BrowserStack App Live.
  4. Instalacao via Firebase Test Lab (`gcloud firebase test android run`).
  5. Instalacao via AWS Device Farm.
  6. Checklist de smoke test apos abrir o app (golden path: download template → load → escolher equipes → seleccionar 5 jogadores → mudar point limit → ver alerta + vibracao).
  7. Permissoes usadas (storage / vibration / wake lock) e desinstalacao.
- README.md atualizado para apontar para `docs/INSTALL_ANDROID.md` em vez da frase generica "instale no Android via USB ou cloud drive".

Decisao tecnica registrada:

- Bandeiras locais ficam adiadas para uma Fase 5 — nao bloqueiam o MVP nem a Fase 4. `CountryResolverService.flagAssetPathFor()` ja retorna `null` para todos os paises e a UI nao depende disso. Quando entrar, sera plug-and-play: a Fase 4 nao deixou dividas tecnicas para a Fase 5 nessa frente.
- Validacao visual em device fica explicitamente fora do meu escopo (regra do usuario: minha validacao e `flutter analyze` + `flutter test`). O `INSTALL_ANDROID.md` cobre o que o usuario precisa fazer em device cloud.

Arquivos criados:

- `docs/INSTALL_ANDROID.md`

Arquivos alterados:

- `README.md` (link para o novo doc)
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 145 passed, 0 failed, 0 skipped (sem mudanca; revisao apenas em docs).

Pendencias da Fase 4:

- Nenhuma do lado do codigo. Itens restantes do checklist sao manuais para o usuario:
  - testar perfil tablet em device cloud (depende do servico escolhido);
  - testar perfil phone em device cloud (mesmo).
- Bandeiras locais: adiadas para Fase 5 (registrado).

Proximo passo recomendado:

- Esperar o run mais recente do `build-apk.yml` em `claude/review-and-continue-9ZK5v` ficar verde, baixar o artifact `iwbf-team-points-control-apk` do GitHub Actions, e seguir `docs/INSTALL_ANDROID.md` para instalar no servico cloud Android escolhido. Quando isso estiver feito, abrir PR de `claude/review-and-continue-9ZK5v` -> `main`.

### 0019 - 2026-05-13 - Fase 4 (item 6/7): revisão final de copy em inglês

Resumo:

- Traduzidas todas as mensagens de erro/warning do `SpreadsheetParserService` para ingles. Antes: "Colunas obrigatórias ausentes...", "Atleta sem número de camiseta", "Equipe não reconhecida", "Data de nascimento ausente ou inválida", "Classe funcional inválida para...", "Número de camiseta #X aparece Y vezes na equipe...", etc. Agora todas iniciam por verbo/substantivo institucional em ingles: "Required columns missing...", "Player is missing shirt number", "Unknown team", "Date of birth is missing or invalid", "Invalid functional class for...", "Shirt number #X appears Y times in...".
- Mensagens institucionais de bloqueio do `parseBytes`/`parseSheets`: "Could not read .xlsx file", "Spreadsheet has no data", "Sheet has no valid header row".
- `MatchState.setPointLimit` e `_bucketFor`: `ArgumentError` em ingles.
- Test fixtures que passavam strings PT em `ParseIssue` (apenas como data, nao asserts) tambem atualizadas para os mesmos textos em ingles, para evitar confusao em uma futura leitura.

Decisao registrada:

- Comentarios de codigo (`//`, `///`) e nomes de teste em portugues continuam OK — sao dev-facing, fora da "100% em ingles" do app. So strings que cruzam para a UI estao em ingles.
- Nomes de pessoas em dados de exemplo (`João`, `SOUZA, Pedro`) ficam em portugues — sao dados de exemplo realistas e nao texto de UI.

Arquivos alterados:

- `lib/services/spreadsheet_parser_service.dart` (12 mensagens traduzidas + 3 mensagens de `SpreadsheetParseResult.error` traduzidas)
- `lib/models/match_state.dart` (2 ArgumentError traduzidos)
- `test/screens/missing_data_screen_test.dart` (4 messages em fixtures)
- `test/screens/validation_summary_screen_test.dart` (4 messages em fixtures)
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 145 passed, 0 failed, 0 skipped (sem mudanca de contagem; mesmos testes, mensagens em ingles).

Pendencias da Fase 4:

- Item 7: APK release via CI + docs de instalacao manual + escolha do servico cloud Android.

Proximo passo recomendado:

- Item 7/7: confirmar que o workflow `build-apk.yml` continua verde apos o polimento, gerar APK release, e documentar no `README.md` (ou em `docs/`) como o usuario faria sideload manual num dispositivo Android cloud (passos: GitHub Actions → artifact `iwbf-release.apk` → BrowserStack/Firebase Test Lab → instalar via `adb install` ou upload no painel).

### 0018 - 2026-05-13 - Fase 4 (item 5/7): templates `.xlsx` baixáveis

Resumo:

- Criado `lib/services/template_generator_service.dart` com `TemplateGeneratorService` que gera dois layouts via `package:excel`:
  - `TemplateKind.singleSheet`: aba `Players` com colunas oficiais (competition_name, team_name, shirt_number, surname, first_name, player_class, dob, gender) + 4 linhas de exemplo (2 Brazil, 2 Argentina, com classes funcionais 1.5/2.0/2.5/3.0 e mistura de gender male/female).
  - `TemplateKind.perTeam`: uma aba por equipe (`Brazil`, `Argentina`) com colunas minimas + as mesmas 4 linhas distribuidas. Aba default `Sheet1` removida.
- API publica: `build(TemplateKind)` retorna `Uint8List`, `filenameFor(TemplateKind)` devolve o nome sugerido (`iwbf_template_single_sheet.xlsx` / `iwbf_template_per_team.xlsx`).
- `LoadSpreadsheetScreen` agora:
  - aceita `TemplateGeneratorService` e `TemplateSaveFn` injetaveis;
  - default `TemplateSaveFn` escreve em `getApplicationDocumentsDirectory()/<filename>` via `path_provider` (ja no `pubspec.yaml`);
  - botoes "Download Template — Single Sheet" e "Download Template — One Sheet per Team" agora chamam o servico, salvam de verdade e mostram snackbar com o caminho ou erro (sem mais snack "Fase 4 placeholder");
  - botoes ganharam Keys (`download-template-single-sheet`, `download-template-per-team`).
- Teste anti-regressao chave: o `SpreadsheetParserService` consegue re-ler os templates gerados sem erros bloqueantes (round-trip valido) — garante que o que o usuario baixar e o que o app aceita.

Decisao tecnica:

- Saver e injetavel via construtor (`TemplateSaveFn`) para nao depender de `path_provider` em widget tests. Default usa `getApplicationDocumentsDirectory()` em runtime real. Mesmo padrao usado para `FilePicker`, `Vibration`, `Wakelock`, `SharedPreferences` no resto do app.

Arquivos criados:

- `lib/services/template_generator_service.dart`
- `test/services/template_generator_service_test.dart` (6 testes: bytes nao vazios, round-trip parser, filename sugerido — para os dois layouts)

Arquivos alterados:

- `lib/screens/load_spreadsheet_screen.dart` (`TemplateSaveFn` typedef, `_defaultSaveTemplate`, `_onDownloadTemplatePressed(kind)`, keys nos botoes)
- `test/screens/load_spreadsheet_screen_test.dart` (+3 testes para download single/per-team/saver null; teste antigo "snackbar coming soon" virou "saved to path")
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 145 passed, 0 failed, 0 skipped (era 137; +8 novos = 6 service + 3 widget - 1 removido).

Pendencias da Fase 4:

- Item 6: revisao final de copy em ingles (procurar PT residual: "Templates ficam disponiveis...", erros etc.).
- Item 7: APK release via CI + docs de instalacao manual.

Proximo passo recomendado:

- Item 6/7: rodar `grep -rn "Templates ficam\|Fase 4\|Sucesso\|Erro\b" lib/` para achar copy PT residual e padronizar tudo em ingles institucional.

### 0017 - 2026-05-13 - Fase 4 (item 4/7): ícones de jogador por gender

Resumo:

- Criado `lib/widgets/player_jersey_icon.dart` com:
  - Helper `resolveJerseyAsset({required isTeamA, required gender})` que mapeia `(isTeamA, PlayerGender)` → asset (`team-a/b-men/women.png`). `unspecified` cai no masculino (decisao registrada).
  - Widget `PlayerJerseyIcon` que sobrepoe o numero da camiseta sobre o icone do uniforme via `Stack` + sombra leve, com cor do numero adaptativa (escura para Team A claro, branca para Team B escuro).
  - Constantes publicas: `kTeamAMenAsset`, `kTeamAWomenAsset`, `kTeamBMenAsset`, `kTeamBWomenAsset`.
- `_PlayerCard` (lista lateral) agora recebe `isTeamA` e usa `PlayerJerseyIcon` em vez de `CircleAvatar` com texto. Para isso `_TeamPlayerList`, `_TabletBody._PhoneBody` foram atualizados para repassar `isTeamA`.
- `_CourtPlayerChip` (chip na quadra) ficou intencionalmente como esta (texto simples) — substituicao por icone full na quadra exigiria slot maior e checagem visual; o numero ja aparece no chip.

Decisao registrada:

- Quando `Player.gender == PlayerGender.unspecified`, o app usa o icone masculino (default da equipe). Isso esta alinhado com a decisao anterior de 2026-05-12: "icones masculino/feminino entram apenas se gender existir; caso contrario, icone padrao da equipe."

Arquivos criados:

- `lib/widgets/player_jersey_icon.dart`
- `test/widgets/player_jersey_icon_test.dart` (8 testes: 5 unit testes do helper `resolveJerseyAsset` + 3 widget testes)

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart` (`_TabletBody`, `_PhoneBody`, `_TeamPlayerList`, `_PlayerCard` passam a propagar `isTeamA`; card usa `PlayerJerseyIcon`)
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 137 passed, 0 failed, 0 skipped (era 129; +8 novos do jersey icon).

Pendencias da Fase 4:

- Item 5: templates `.xlsx` baixaveis.
- Item 6: revisao final de copy em ingles.
- Item 7: APK release via CI + docs de instalacao manual.

Proximo passo recomendado:

- Item 5/7: gerar templates `.xlsx` (Single Sheet `Players` e One Sheet per Team) usando a lib `excel` + salvar em diretorio acessivel via `path_provider`; ligar nos dois botoes "Download Template — ..." que hoje so mostram snack placeholder.

### 0016 - 2026-05-13 - Fase 4 (item 3/7): court.png + posicionamento simétrico

Resumo:

- `_CourtView` deixou de ser o retangulo marrom com `Wrap`: agora usa `assets/images/court.png` (2816x1504 landscape) como background, rotacionado 90° via `RotatedBox(quarterTurns: 1)` para ficar em retrato (aspect ratio pos-rotacao 1504/2816 ≈ 0.534).
- Posicionamento simétrico via `Stack` + `LayoutBuilder` + `FractionalTranslation(-0.5, -0.5)`. Cada equipe tem 5 slots fracionarios `(dx, dy)` em coordenadas (0..1) da box:
  - Team A (metade superior): (0.30, 0.10), (0.70, 0.10), (0.30, 0.28), (0.70, 0.28), (0.50, 0.40).
  - Team B (metade inferior, espelho): (0.30, 0.90), (0.70, 0.90), (0.30, 0.72), (0.70, 0.72), (0.50, 0.60).
- Hints "Tap players in Team A list" / "Tap players in Team B list" agora aparecem em pill com fundo branco translucido (`Colors.white.withValues(alpha: 0.85)`), centralizados verticalmente na sua metade da quadra (Alignment y = -0.55 / +0.55) sobre o asset.
- Chips de jogador na quadra ganharam `BoxShadow` leve e bordas dourado escuro para Team A, preto institucional para Team B.
- Constante publica `kCourtAsset` para reuso e teste.
- Removida a classe interna `_CourtHalf` (não tem mais função após o refactor).
- Aspect ratio garante que a quadra mantém forma mesmo em phone/tablet, sem distorcer o desenho original.

Decisao tecnica:

- Posicoes fracionarias em vez de coordenadas em pixels — `LayoutBuilder` resolve para o tamanho real do container, garantindo que o layout escala em tablet e celular sem hardcode.
- `withOpacity` foi trocado por `withValues(alpha: ...)` (Flutter 3.41+ recomenda; `withOpacity` esta deprecated a partir do Material 3 + Flutter 3.41+).

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart` (`_CourtView`, novo `_CourtPlayerSlot`, novo `_CourtHint`, `_CourtPlayerChip` atualizado com sombra; removido `_CourtHalf`)
- `test/screens/lineup_control_screen_test.dart` (+2 testes no grupo `LineupControlScreen — court`)
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 129 passed, 0 failed, 0 skipped (era 127; +2 novos no grupo court).

Pendencias da Fase 4:

- Item 4: icones de jogador por gender (substituir `CircleAvatar` numerico).
- Item 5: templates `.xlsx` baixaveis.
- Item 6: revisao final de copy em ingles.
- Item 7: APK release via CI + docs de instalacao manual.

Proximo passo recomendado:

- Item 4/7: criar `_PlayerAvatar` que escolhe `team-a-men/women.png` ou `team-b-men/women.png` conforme `Player.gender` (ou fallback para o icone neutro da equipe quando `gender` ausente).

### 0015 - 2026-05-13 - Fase 4 (item 2/7): header com logo IWBF

Resumo:

- Criado `lib/widgets/iwbf_logo_header.dart` com dois widgets reutilizaveis:
  - `IwbfBrandHeader`: logo IWBF grande (max 140dp, responsivo ao container) + titulo padrao "IWBF Team Points Control" + subtitle opcional. Usado na home (`LoadSpreadsheetScreen`) substituindo o `AppBar` e o titulo solto.
  - `IwbfAppBarTitle`: logo pequeno (32dp) + texto, usado como `AppBar.title` nas demais telas (`Validation Summary`, `Missing Data`, `Match Setup`, `Lineup Control`).
- Assets `iwbf-logo-white.png` (RGBA, fundo claro) e `iwbf-logo-black.png` continuam registrados em `assets/images/`. Header usa o `white` por enquanto (fundo off-white do tema).
- Constantes publicas: `kIwbfLogoWhiteAsset` e `kIwbfLogoBlackAsset` em `iwbf_logo_header.dart` (facilita reuso em outras telas/testes).
- Removido o `AppBar` da `LoadSpreadsheetScreen` para dar espaco ao header maior.

Arquivos criados:

- `lib/widgets/iwbf_logo_header.dart`
- `test/widgets/iwbf_logo_header_test.dart` (4 widget tests: render basico, subtitle, titulo customizado, IwbfAppBarTitle)

Arquivos alterados:

- `lib/screens/load_spreadsheet_screen.dart`
- `lib/screens/validation_summary_screen.dart`
- `lib/screens/missing_data_screen.dart`
- `lib/screens/match_setup_screen.dart`
- `lib/screens/lineup_control_screen.dart`
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 127 passed, 0 failed, 0 skipped (era 123; +4 novos do `iwbf_logo_header_test.dart`).

Pendencias da Fase 4:

- Item 3: `_CourtView` -> `court.png` + posicionamento simetrico dos 5 jogadores.
- Item 4: icones de jogador por gender (team-a-men/women, team-b-men/women).
- Item 5: templates `.xlsx` baixaveis.
- Item 6: revisao final de copy em ingles.
- Item 7: APK release via CI + docs de instalacao manual.

Proximo passo recomendado:

- Item 3/7: substituir o `_CourtView` simplificado (browns) pelo asset `court.png` como background da quadra e posicionar os 5 jogadores selecionados em layout simetrico (2 perto da tabela, 2 a frente, 1 perto do centro) em cada metade.

### 0014 - 2026-05-13 - Fase 4 (item 1/7): tema IWBF off-white + dourado

Resumo:

- Criado `lib/theme/iwbf_theme.dart` com paleta institucional `IwbfColors` (`gold`, `goldDeep`, `goldSoft`, `offWhite`, `offWhiteElevated`, `textPrimary`, `textSecondary`, `alertRed`, `alertRedSurface`) e factory `buildIwbfTheme()` Material 3.
- `main.dart` passa a usar `buildIwbfTheme()` no `MaterialApp` (theme antes era inline com cores soltas).
- `AppBarTheme` padronizado: fundo off-white, texto preto institucional, sem elevation, titulo bold 18.
- `FilledButtonTheme` agora pinta com dourado IWBF e padding maior, mais legivel sob luz.
- `OutlinedButtonTheme` ganha borda dourada escura (`goldDeep`) consistente em todas as telas.
- `CardThemeData` (renomeado em 3.41+) e `DialogThemeData` ajustados para fundo off-white sem tint material.
- `SnackBarTheme` usa preto institucional com texto branco e behavior `floating`.
- `_ScoreCell` (lineup) e `_IssueBlock`/`_Header` (validation summary) trocam vermelho/amber generico (`Colors.red.shade*`, `Colors.amber.shade*`) por tokens da paleta: `alertRed`, `alertRedSurface`, e warning em amarelo claro com borda `goldDeep`.
- `_Header` da lineup troca `Colors.grey.shade100` por `IwbfColors.offWhiteElevated`.
- `MissingDataScreen` e `MatchSetupScreen` tambem migraram para `IwbfColors.alertRed` (icones de erro e mensagem "Team A and Team B must be different").
- Browns da `_CourtView` ficam intencionalmente intocados — serao substituidos pelo asset `court.png` no item 3.

Decisao tecnica:

- `CardTheme`/`DialogTheme` ficam como `CardThemeData`/`DialogThemeData` no Flutter 3.41+ (deprecated nos nomes antigos). Registrado nas convencoes de codigo.

Arquivos criados:

- `lib/theme/iwbf_theme.dart`

Arquivos alterados:

- `lib/main.dart`
- `lib/screens/lineup_control_screen.dart`
- `lib/screens/validation_summary_screen.dart`
- `lib/screens/missing_data_screen.dart`
- `lib/screens/match_setup_screen.dart`
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 123 passed, 0 failed, 0 skipped.

Pendencias da Fase 4:

- Header com logo IWBF reutilizavel (item 2).
- `_CourtView` -> `court.png` + posicionamento simetrico (item 3).
- Icones de jogador por gender (item 4).
- Templates `.xlsx` baixaveis (item 5).
- Revisao final de copy em ingles (item 6).
- APK release via CI + docs de instalacao (item 7).

Proximo passo recomendado:

- Item 2/7: criar `IwbfLogoHeader` (logo + nome da competicao quando houver) e usar nas telas principais.

### 0013 - 2026-05-13 - Fase 3 (itens 2 a 10): Lineup Control real

Resumo:

- Substitui o placeholder do `LineupControlScreen` pela tela real, fechando os 9 itens restantes da Fase 3 num so incremento (a tela e indivisivel — todos os pedacos compartilham o mesmo `MatchState`).
- Layout responsivo via `LayoutBuilder` com breakpoint `>= 720dp`:
  - tablet: `Row` com listas laterais (Team A esq., Team B dir.) e quadra central;
  - celular: `DefaultTabController` com 3 abas (Team A / Court / Team B).
- Header (`_Header`): nome da competicao (se houver), `Brazil  vs  Argentina`, dois `_ScoreCell` com `total / limit` e badge "Point limit exceeded." quando aplicavel, dropdown de Point Limit reativo (mudar limite reavalia alerta e dispara vibracao se cruzar).
- Selecao por toque (`_PlayerCard` com `InkWell`): toque seleciona, toque novamente desseleciona; o 6º atleta e bloqueado com snackbar `Only 5 players can be selected for Team X.`.
- Quadra (`_CourtView` + `_CourtHalf`): area marrom-clara dividida ao meio, jogadores selecionados aparecem como chips em `Wrap` (Team A em cima, Team B embaixo). MVP funcional; substituicao por asset `court.png` + posicionamento simetrico fica para a Fase 4.
- Vibracao (`VibrationService`, novo): leve (`Vibration.vibrate(duration: 1500)`) acionada **uma vez por cruzamento** por equipe — usa flags `_wasOverA` / `_wasOverB`, ativa apenas na transicao "abaixo → acima".
- Wakelock (`WakelockController`, novo): wrapper mockavel sobre `wakelock_plus`, habilita no `initState` e desabilita no `dispose`.
- Persistencia (`CacheService`): `saveMatchState` chamado no `initState` (snapshot inicial) e a cada mudanca relevante (selecao, point limit, clear). Erros do plugin sao engolidos.
- Botoes operacionais (`_OperationalButtons`): Clear Team A / Clear Team B / Clear All / Change Teams / Load New Spreadsheet em `Wrap` para nao estourar layout.
- Confirmacao antes de sair (`_confirmLeave`): `AlertDialog` "Are you sure you want to leave this match? Current selections may be lost." com botoes Stay / Leave. Disparado por `Change Teams`, `Load New Spreadsheet` E pelo `PopScope` (botao back do Android / gesto).
- `Load New Spreadsheet` faz `cache.clear()` e `popUntil(isFirst)` apos a confirmacao.

Decisoes tecnicas:

- `togglePlayer` retorna `false` para "deselected" e para "blocked"; o screen distingue capturando `bucket.contains(id)` antes do toggle.
- Vibracao e wakelock viraram `services/` mockaveis em vez de chamadas estaticas para nao quebrar widget tests com `MissingPluginException`.
- Dropdowns usam `initialValue` (Flutter 3.41+); `value` esta deprecated.
- `PopScope` usa `onPopInvokedWithResult` (`onPopInvoked` esta deprecated).
- Capturei `Navigator.of(context)` antes do `await` no handler do `PopScope` para evitar `use_build_context_synchronously`.

Arquivos criados:

- `lib/services/vibration_service.dart`
- `lib/services/wakelock_controller.dart`
- `test/screens/lineup_control_screen_test.dart`

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart` (placeholder → tela real, ~480 linhas)
- `test/screens/match_setup_screen_test.dart` (assertions do teste de navegacao alinhadas com a tela real)
- `docs/AI_WORK_LOG.md`

Testes executados:

- `flutter analyze --no-fatal-infos` -> No issues found.
- `flutter test` -> 123 passed, 0 failed, 0 skipped (era 105; +18 novos no Lineup Control).

Cobertura de testes do Lineup Control (18 cenarios):

- Header: render basico (competition + nomes + Point Limit) e mudanca de Point Limit re-avaliando alerta.
- Layout responsivo: tablet (>=720dp) mostra listas laterais; celular (<720dp) mostra abas.
- Selecao: tap seleciona/atualiza score, tap novamente desseleciona, 5 maximo com snackbar bloqueando o 6.
- Alerta + vibracao: cruzar limite mostra alerta + vibra 1x; voltar abaixo limpa alerta sem vibrar; cruzar de novo vibra mais 1x; alerta de uma equipe nao afeta a outra.
- Botoes: Clear Team A / B / All com isolamento entre equipes.
- Saida: Change Teams (confirmacao Stay/Leave), Load New Spreadsheet (confirmacao + cache.clear + popUntil first), back do Android (PopScope dispara dialog).
- Lifecycle: wakelock enable no init + disable no dispose; cache.saveMatchState no init.

Pendencias:

- Nenhuma da Fase 3.
- Refinamento futuro registrado: posicionamento simetrico real dos 5 jogadores na quadra (nao em Wrap), uso do asset `court.png` como background, icones `team-a-men/women` e `team-b-men/women` nos cards (depende de `gender`).

Proximo passo recomendado:

- Iniciar Fase 4 (polimento + APK + validacao Android cloud). Sugestao de ordem: 1) substituir `_CourtView` pelo asset `court.png` com posicionamento simetrico; 2) icones de jogador conforme `gender`; 3) header com logo IWBF; 4) tema off-white + dourado consistente; 5) templates `.xlsx` baixaveis; 6) build APK release via CI; 7) validacao em device cloud (tablet + phone).

## Registro de testes

| Data | Comando | Resultado | Observacao |
|---|---|---|---|
| 2026-05-12 | Nao aplicavel | Nao executado | Projeto ainda nao criado |
| 2026-05-13 | `flutter analyze --no-fatal-infos` | Delegado a CI | Validacao via workflow `build-apk.yml` no push para `claude/**` |
| 2026-05-13 | `flutter test` | Delegado a CI | Validacao via workflow `build-apk.yml` no push para `claude/**` |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Flutter 3.41.9 stable instalado em `/root/flutter` |
| 2026-05-13 | `flutter test` (local) | 112 passed, 0 failed, 0 skipped | Inclui 18 widget tests novos das telas da Fase 2 |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos Match Setup real (Fase 3, item 1) |
| 2026-05-13 | `flutter test` (local) | 105 passed, 0 failed, 0 skipped | Match Setup real cobre 9 cenarios; placeholder antigo (3 testes) removido |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos Lineup Control real (Fase 3, itens 2-10) |
| 2026-05-13 | `flutter test` (local) | 123 passed, 0 failed, 0 skipped | +18 novos testes do Lineup Control fechando a Fase 3 inteira |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos tema IWBF (Fase 4 item 1) |
| 2026-05-13 | `flutter test` (local) | 123 passed, 0 failed, 0 skipped | Tema IWBF nao quebra widget tests existentes |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos header com logo IWBF (Fase 4 item 2) |
| 2026-05-13 | `flutter test` (local) | 127 passed, 0 failed, 0 skipped | +4 novos testes do `iwbf_logo_header` |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos court.png + slots fracionarios (Fase 4 item 3) |
| 2026-05-13 | `flutter test` (local) | 129 passed, 0 failed, 0 skipped | +2 novos no grupo "LineupControlScreen — court" |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos icones por gender (Fase 4 item 4) |
| 2026-05-13 | `flutter test` (local) | 137 passed, 0 failed, 0 skipped | +8 novos testes do `PlayerJerseyIcon` (5 unit + 3 widget) |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos templates baixaveis (Fase 4 item 5) |
| 2026-05-13 | `flutter test` (local) | 145 passed, 0 failed, 0 skipped | +6 service + 3 widget; -1 antigo "snackbar coming soon" |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos revisao final de copy em ingles (Fase 4 item 6) |
| 2026-05-13 | `flutter test` (local) | 145 passed, 0 failed, 0 skipped | Mesma cobertura; mensagens dos fixtures atualizadas |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Final da Fase 4 (item 7) — `docs/INSTALL_ANDROID.md` adicionado |
| 2026-05-13 | `flutter test` (local) | 145 passed, 0 failed, 0 skipped | Mudanca apenas em docs; cobertura intacta |
| 2026-05-13 | `flutter analyze --no-fatal-infos` (local) | No issues found! | Apos hotfix Web (conditional imports + package:web) |
| 2026-05-13 | `flutter test` (local) | 145 passed, 0 failed, 0 skipped | Cobertura intacta apos extracao do saver |
| 2026-05-13 | `flutter build web --release` (local) | ✓ Built build/web (62 MB) | Verifica que o bundle Web sai limpo sem `dart:io` direto |

## Pendencias e perguntas abertas

- Confirmar se o repositorio GitHub sera privado ou publico. Recomendacao: privado durante o MVP.
- Confirmar se o usuario quer usar apenas Codespaces pelo navegador ou tambem permitir acesso via VS Code/GitHub CLI.
- Escolher o servico cloud de device/emulador Android para validacao visual/manual (Fase 4).
- Definir paleta dourada final (Fase 4 — identidade visual IWBF).

Decisoes fechadas:

- `.xlsx` entra no MVP; `.csv` fica para melhoria posterior; `.xls` fica fora do MVP.
- Pacote Android inicial: `org.iwbf.teampointscontrol`.
- Orientacao retrato travada desde a primeira versao.
- DOB aceita `YYYY-MM-DD` e `DD/MM/YYYY`.
- Bandeiras serao assets locais, com fallback generico.
- `competition_name` permanece opcional.
- Desenvolvimento principal sera feito em GitHub Codespaces/cloud-first.
- Android Studio, Android SDK, JDK e emuladores locais nao sao pre-condicao do MVP.
- Build APK e testes automatizados devem rodar no Codespace ou em GitHub Actions.
- Android fisico esta descartado.
- Validacao visual/manual Android deve usar servico cloud de device/emulador.
- Nao assumir Android Emulator dentro do Codespace como caminho principal.
- `Team.displayName` retorna apenas `teamName` (sem codigo de pais). `countryCode`/`teamCode` removidos dos modelos.
- `Player.id` segue o padrao `${teamId}::${shirtNumber}`. `Team.id` segue `team-<slug-do-nome>`.
- `MissingDataScreen` no MVP e tela de **diagnostico** (sem edicao inline). Edicao inline e refinamento futuro.
- Vibracao e wakelock viraram servicos (`VibrationService`, `WakelockController`), injetaveis para widget tests.
- Dropdowns usam `initialValue` (Flutter 3.41+); `value` esta deprecated.
- `PopScope` usa `onPopInvokedWithResult`; `onPopInvoked` esta deprecated.

## Convencoes de codigo (sessao 2026-05-13)

- Sempre que uma tela depender de plugin de plataforma (`FilePicker`, `SharedPreferences`, `Vibration`, `WakelockPlus`), criar callback ou servico injetavel via construtor e default para o plugin real. Isso permite widget tests deterministicos.
- Para evitar lint `use_build_context_synchronously`: capturar `Navigator.of(context)` antes do primeiro `await`, ou checar `context.mounted` depois.
- Em testes de navegacao, NUNCA `await` em `Navigator.push(...)` (o Future so completa quando a rota e popada — causa timeout). Usar `unawaited(...)` ou disparar push via `tester.tap` em botao.
- Em assertions de scores no widget test, garantir que Team A e Team B tenham valores distintos antes de usar `findsOneWidget` no formato `total / limit` — caso contrario use `findsNWidgets(2)`.
- `CardTheme` e `DialogTheme` foram renomeados para `CardThemeData` e `DialogThemeData` no Flutter 3.41+. Os nomes antigos so existem como typedefs deprecated e geram erro de tipo quando passados em `ThemeData(...)`.
- Cores usadas em alertas e estados (limite excedido, erros de planilha, warnings) devem vir de `IwbfColors` (`alertRed`, `alertRedSurface`, `goldDeep`) e nao de `Colors.red.shade*`/`Colors.amber.shade*`, para manter o tema consistente.
- `Color.withOpacity(x)` foi deprecated no Flutter 3.41+: usar `Color.withValues(alpha: x)`.
- Para posicionar elementos sobre uma imagem mantendo proporcao em todos os tamanhos de tela: `AspectRatio` + `Stack` + `LayoutBuilder` + `Positioned(left/top = w*dx, h*dy)` + `FractionalTranslation(-0.5, -0.5)` para centralizar no ponto. Evita coordenadas em pixels e funciona igualmente em tablet/phone.

## Prompt curto de continuidade

```text
Voce esta retomando o IWBF Team Points Control (Flutter offline para
comissarios de basquetebol em cadeira de rodas).

Antes de qualquer coisa, leia nesta ordem:
1. docs/IWBF_Team_Points_Control_Planejamento.md
2. docs/PLANO_DESENVOLVIMENTO_IA.md
3. docs/AI_WORK_LOG.md  (estado atual + decisoes + convencoes + proximo passo)

Branch de trabalho: claude/review-and-continue-9ZK5v
Repositorio: gnpazinato/iwbf-team-points-control

Estado atual: Fases 1, 2 e 3 fechadas. flutter analyze --no-fatal-infos
= 0 issues; flutter test = 123 passed. Proximo passo: Fase 4 (polimento
visual, identidade IWBF, templates xlsx, build APK release, validacao em
device cloud Android).

Regras do usuario:
- Flutter local em /root/flutter/bin/flutter. Se nao existir, instalar
  com o snippet do prompt de continuidade no AI_WORK_LOG (Fase 4 mantem
  os mesmos comandos).
- Valide tudo localmente antes de cada push: flutter pub get, flutter
  analyze --no-fatal-infos (0 issues), flutter test (todos verdes).
  Corrija lint info-level (prefer_const, unnecessary_const, etc.) antes
  do push, mesmo com --no-fatal-infos.
- Nao commit pubspec.lock se ele so mudou por pub get local
  (git restore pubspec.lock antes do commit).
- Para telas: preferir callbacks/servicos injetaveis em vez de plugins
  estaticos (FilePicker.platform, SharedPreferences.getInstance,
  Vibration, WakelockPlus). Sem essa abstracao, widget tests quebram.
- Nao pedir validacao manual em navegador, emulador ou device. A
  validacao e flutter analyze + flutter test (incluindo widget tests).
- Decisoes ja fechadas (ver tabela no log) nao devem ser revisitadas
  sem motivo tecnico claro.

Trabalhe em incrementos pequenos: cada incremento termina com analyze
+ test verdes, log atualizado (nova entrada ### 00NN no historico,
checklist da fase atualizado, arquivos alterados, testes rodados,
proximo passo) e commit/push com mensagem convencional.

Ao final de cada incremento, me reporte em 4-8 linhas: o que entregou,
testes que passaram (numeros reais), pendencias, proximo passo.

Comece pelo proximo passo recomendado do AI_WORK_LOG e me confirme
em uma frase qual e o estado atual antes de codar.
```

## Prompt curto de continuidade — Fase 5

```text
Você está retomando o IWBF Team Points Control (Flutter offline para
comissários de basquete em cadeira de rodas).

Antes de qualquer coisa, leia nesta ordem:
1. docs/IWBF_Team_Points_Control_Planejamento.md
2. docs/PLANO_DESENVOLVIMENTO_IA.md
3. docs/AI_WORK_LOG.md  ← fonte da verdade (estado, decisões, convenções, próximo passo)

Branch de trabalho: claude/review-and-continue-9ZK5v (já existe no remoto)
Repositório: gnpazinato/iwbf-team-points-control

Estado atual: Fase 4 completa. Preview Web em
https://gnpazinato.github.io/IWBF-Team-Points-Control/ ativo.
flutter analyze 0 issues, flutter test 145 passed, build web OK.
Item 1 da Fase 5 (logo IWBF preto sobre fundo claro) ja foi resolvido
na sessao anterior. Veja entrada 0023 do AI_WORK_LOG para a lista
completa de itens da Fase 5.

Próximo passo: Fase 5 — Ajustes de polimento visual pós-teste manual.
Lista de bugs/ajustes (entrada 0023 do AI_WORK_LOG tem detalhes):

2. PlayerJerseyIcon: os assets team-a/b-men/women.png ja tem numero 10
   estampado. Overlay numerico fica por cima do 10 e fica ilegivel.
   Decidir: trocar assets (preferencia SVG) OU reposicionar overlay.

3. Icones pixelados/borrados no preview. Investigar filterQuality,
   dimensoes, ou regerar como SVG (flutter_svg).

4. Quadra sem icones dos jogadores: _CourtPlayerChip mostra so texto.
   Planejamento pede icone na quadra. Trocar por PlayerJerseyIcon
   apos resolver item 2.

5. Template .xlsx com dados pre-preenchidos incorretos. Pedir lista
   detalhada do que esta errado em _sampleRoster (lib/services/
   template_generator_service.dart) antes de codar.

6. Usuario mencionou outros pequenos ajustes alem destes — pedir a
   lista completa antes de codar.

Regras (não revisitar sem motivo técnico):
- Flutter local em /root/flutter/bin/flutter (se faltar, ver snippet
  no log).
- Sempre flutter pub get → analyze --no-fatal-infos (0 issues) →
  test (tudo verde) antes do push.
- Não commit pubspec.lock se mudou só pelo pub get local.
- Plugins de plataforma sempre via callback/serviço injetável.
- Não pedir validação manual; sua validação é analyze + test.
- Em widget tests, nunca await Navigator.push(...).
- Commits convencionais: feat(fase-5):..., fix(fase-5):..., chore(fase-5):...

Rotina por incremento: implementa o menor pedaço útil → analyze + test
local verdes → atualiza AI_WORK_LOG.md (nova entrada ### 00NN +
checklist da Fase 5 + arquivos alterados + testes + próximo passo) →
commit + push em claude/review-and-continue-9ZK5v → me reporta em 4-8
linhas.

Comece confirmando que leu os docs e pedindo (a) a lista detalhada
do que esta errado no template (item 5) e (b) a lista completa dos
"outros pequenos ajustes" (item 6) antes de codar o item 2.
```

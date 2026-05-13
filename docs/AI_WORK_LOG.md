# IWBF Team Points Control - AI Work Log

Este arquivo e a fonte de verdade para continuidade do projeto com Codex, Claude Code ou outra IA.

Antes de qualquer nova tarefa, a IA deve ler:

1. `IWBF_Team_Points_Control_Planejamento.md`
2. `docs/PLANO_DESENVOLVIMENTO_IA.md`
3. `docs/AI_WORK_LOG.md`

Nenhuma fase deve ser refeita se estiver marcada como concluida aqui, a menos que exista uma justificativa tecnica registrada.

## Estado atual

| Campo | Valor |
|---|---|
| Data da ultima atualizacao | 2026-05-13 |
| Status geral | Fase 4 em andamento. Itens 1/7 (tema) e 2/7 (header com logo IWBF) entregues: `IwbfBrandHeader` (logo grande + titulo + subtitle) na Load Spreadsheet; `IwbfAppBarTitle` (logo pequeno + texto) nas demais telas (Validation / Missing / Match Setup / Lineup). |
| Fase atual | Fase 4 em andamento (2/7 itens) |
| Proximo passo recomendado | Fase 4 item 3: substituir `_CourtView` simplificado pelo asset `court.png` (`assets/images/court.png`) como background da quadra e posicionar os 5 jogadores selecionados de forma simetrica (2 perto da tabela, 2 a frente, 1 perto do centro) em cada metade. |
| Ultimos testes executados | `flutter analyze --no-fatal-infos` 0 issues + `flutter test` 127 passed (locais, Flutter 3.41.9 stable, apos header com logo) |
| APK gerado | Sim, debug+release via CI na PR #1 (ainda nao regenerado apos polimento; sera regenerado no item 7) |

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
- [ ] Ajustar layout para tablet.
- [ ] Ajustar layout para celular.
- [ ] Incluir logos, quadra e icones finais (logos: feito; quadra: pendente; icones: pendente).
- [ ] Incluir bandeiras locais ou solucao equivalente.
- [ ] Criar templates baixaveis.
- [ ] Revisar textos em ingles.
- [x] Rodar `flutter analyze` (apos tema).
- [x] Rodar `flutter test` (apos tema).
- [ ] Gerar APK debug no Codespace ou GitHub Actions.
- [ ] Testar em perfil tablet via servico cloud de device/emulador Android.
- [ ] Testar em perfil phone via servico cloud de device/emulador Android.
- [ ] Gerar APK release no Codespace ou GitHub Actions.
- [ ] Documentar instalacao manual no servico cloud escolhido.

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

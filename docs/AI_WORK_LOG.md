# IWBF Team Points Control - AI Work Log

Este arquivo e a fonte de verdade para continuidade do projeto com Codex, Claude Code ou outra IA.

> ## ⚠️ ATENCAO — LEIA ANTES DE QUALQUER COISA ⚠️
>
> **O MVP COMPLETO JA ESTA NA `main` (PR #5 mergeado).** `lib/main.dart` na
> `main` e o app real (upload, parser, Summary, Match Setup, Lineup Control).
> Avisos antigos de que "main e so scaffold" e de que o codigo vive em
> `claude/review-and-continue-9ZK5v` estao **DESATUALIZADOS** — aquela branch
> e historica; **nao trabalhe mais a partir dela**.
>
> **Branch de trabalho atual:** `claude/visual-modernization` (criada a
> partir de `main`), com a modernizacao visual (Fases 1-6) + ajustes
> pos-testers (entradas 0039, 0040, 0041). **PR aberto para `main` —
> aguardando aprovacao do usuario; NAO mergear sozinho.**
>
> ```bash
> git fetch origin
> git checkout claude/visual-modernization   # ou main, se o PR ja mergeou
> git pull --ff-only origin claude/visual-modernization
> git log --oneline -12
> ```
>
> **Versao atual:** `1.4.0+5` (`kAppVersion = 1.4.0`, build 5). Houve uma
> confusao de numeracao: um commit gravou `1.5.1+5`, depois **corrigido para
> `1.4.0+5`** (o "1.5.1" pulava a 1.4.0 e quebrava o fluxo minor++). O
> conteudo e o mesmo — so o numero foi normalizado.
>
> **Preview Web:** `https://gnpazinato.github.io/IWBF-Team-Points-Control/`
> (GH Pages, legado) e `https://iwbf-team-points-control.pages.dev/`
> (CF Pages, URL neutra). Qualquer push em `claude/**` ou `main` publica
> (ver entradas 0022 e 0034).
>
> Nunca commite direto na `main`; trabalhe em `claude/visual-modernization`
> ou numa branch `claude/**` nova a partir de `main`.

Antes de qualquer nova tarefa, a IA deve ler:

1. `IWBF_Team_Points_Control_Planejamento.md`
2. `docs/PLANO_DESENVOLVIMENTO_IA.md`
3. `docs/AI_WORK_LOG.md`

Nenhuma fase deve ser refeita se estiver marcada como concluida aqui, a menos que exista uma justificativa tecnica registrada.

## Estado atual

| Campo | Valor |
|---|---|
| Branch de trabalho | **`claude/visual-modernization`** (a partir de `main`; NAO usar `claude/review-and-continue-9ZK5v`, que e historica) |
| Versao atual | **`1.4.0+5`** (`kAppVersion = 1.4.0`, build 5). Numeracao normalizada apos um commit ter gravado `1.5.1+5` por engano (ver bloco ATENCAO acima). |
| Data da ultima atualizacao | 2026-06-10 |
| Status geral | **MVP na `main` (PR #5). Modernizacao visual (Fases 1-6, entrada 0038) + 3 rodadas de ajustes pos-testers vivem em `claude/visual-modernization`, com PR aberto para `main` (NAO mergeado — aguardando aprovacao do usuario). Ajustes pos-testers: entrada 0039 (v1.2.0, parser tolerante a nomes de coluna), entrada 0040 (v1.3.0, restaura a planilha INTEIRA na Home), entrada 0041 (v1.4.0, DOB com ano de 2 digitos + remover jogador pelo chip da quadra + bandeiras africanas). CI verde a cada push; 2 previews Web operacionais (GH Pages + CF Pages).** |
| Fase atual | **Modernizacao visual implementada (Fases 1-6) + ajustes 0039..0041 fechados. PR `claude/visual-modernization -> main` aberto. Importacao de PDF DESCARTADA (decisao do usuario, 2026-05-27) — nao reabrir. Sem trabalho em andamento; aguardando proximo pedido do usuario.** |
| Proximo passo recomendado | Decisao do usuario: aprovar/mergear o PR `claude/visual-modernization -> main` (NAO mergear sozinho) ou solicitar novos ajustes (nova entrada no log + commit `fix(visual):...` na branch). Escopo futuro possivel (nao iniciado): estatisticas pos-jogo/scoring, Play Store, multi-language. |
| Testers externos | 2 pessoas com link do preview Web (compartilhado em 2026-05-14): GH Pages https://gnpazinato.github.io/IWBF-Team-Points-Control/ e CF Pages https://iwbf-team-points-control.pages.dev/. |
| Ultimos testes executados | Validados no CI (`build-apk.yml`) a cada push — `Analyze` + `Run tests` verdes; APK release gerado como artifact. **Flutter NAO esta instalado no Codespace atual** — toda validacao roda no CI no push. (A sessao de 2026-05-15 rodou 176/176 testes localmente com Flutter 3.41.9, mas esse SDK nao persiste neste sandbox.) |
| APK gerado | Sim, via CI a cada push, na versao `1.4.0+5`. Preview Web em https://gnpazinato.github.io/IWBF-Team-Points-Control/ (GH Pages) e https://iwbf-team-points-control.pages.dev/ (CF Pages, entrada 0034) a cada push em `claude/**` ou `main`. |

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

### 0041 - 2026-06-06 - Ajustes v1.4.0: datas 2 digitos, remover chip da quadra, bandeiras africanas

Contexto: 3 ajustes pedidos pelo usuario apos testes externos.

Entregue:

- **1) DOB com ano de 2 digitos e separadores `-`/`.`** (`spreadsheet_parser_service.dart` `_parseDateOfBirth`): aceita `12-12-25`, `12-12-2025`, `05/06/90`, etc. ISO `yyyy-mm-dd` so e tentado quando comeca com 4 digitos (evita que `12-12-25` vire ano 12). Pivo de 2 digitos estilo POSIX: `00`-`68` -> `2000`-`2068`, `69`-`99` -> `1969`-`1999`. Adicionada validacao anti-overflow (rejeita `31/02`).
- **2) Remover jogador tocando no chip da quadra** (`lineup_control_screen.dart`): `_CourtView`/`_CourtPlayerSlot`/`_CourtPlayerChip` recebem `onTap`; o chip vira `GestureDetector` (key `court-chip-<id>`) que chama o MESMO `_onPlayerTap` das listas laterais — como o jogador ja esta selecionado, `togglePlayer` o remove. Antes so dava para remover pelas listas/menus laterais.
- **3) Bandeiras de paises africanos faltantes** (`country_resolver_service.dart`): a causa do "erro" do usuario era que Angola (e varios outros) NAO estavam nas tabelas `_defaultAliases`/`_countryCodes` — o resolver retornava `null` e o widget caia no icone generico (`Icons.flag_outlined`); nao havia crash. Adicionados Angola (AO), Botswana, Congo, DR Congo, Ghana, Libya, Madagascar, Mali, Mozambique, Namibia, Rwanda, Sudan, Tanzania, Zambia (+ aliases PT/IOC). A bandeira emoji e derivada do ISO alpha-2, entao basta mapear o codigo.
- **Versao:** `pubspec.yaml` 1.3.0+4 -> **1.4.0+5**; `kAppVersion` 1.3.0 -> **1.4.0** (segue o fluxo minor++ das versoes anteriores; o "1.5.1" inicialmente cogitado pulava a 1.4.0 e usava patch .1, fora do padrao).

Arquivos alterados: `lib/services/spreadsheet_parser_service.dart`, `lib/screens/lineup_control_screen.dart`, `lib/services/country_resolver_service.dart`, `lib/constants/app_version.dart`, `pubspec.yaml`, `test/services/spreadsheet_parser_service_test.dart` (+3 testes de DOB), `test/services/country_resolver_service_test.dart` (+1 teste bandeiras africanas), `test/screens/lineup_control_screen_test.dart` (+1 teste remover via chip).

Testes: validados no CI (Flutter ausente no Codespace).

Proximo passo recomendado: usuario valida no preview/APK; segue no fluxo do PR (nao mergear sozinho).

### 0040 - 2026-05-29 - Restaurar a PLANILHA INTEIRA na tela inicial (v1.3.0)

Contexto:

- Ao fim de uma partida o usuario costuma fechar o app ou voltar varias telas ate a inicial. Pedido: quando o app e **encerrado**, sofre **crash** ou volta do **segundo plano** (ex.: no dia seguinte), a tela inicial deve perguntar "começar do zero" ou "carregar a planilha anterior". Ja existia essa pergunta, mas ela restaurava apenas o `MatchState` (as **2 equipes** da ultima partida). O usuario quer carregar a planilha **INTEIRA** (todas as equipes/atletas da ultima planilha usada — a mais recente, caso varias tenham sido usadas).
- **Excecao:** se o usuario esta **numa partida**, minimiza e volta, deve cair **exatamente na tela da partida** (sem pergunta). A pergunta so reaparece quando o usuario **sai da partida** (voltar de pagina / crash / encerrar) e volta a Home.

Decisoes do usuario (perguntadas antes de codar):

- **Destino do restore:** abre o **Resumo da planilha** (Validation Summary) com TODAS as equipes — usuario revisa/edita e segue para o Match Setup. (Nao vai direto ao Match Setup.)
- **Resume fora da partida:** so refaz a pergunta **se ja estiver na Home**. Em Match Setup / Resumo, voltar do segundo plano **nao interrompe** (fica onde estava). Isso dispensou rastrear rotas / mexer no `main.dart`.

Entregue:

- **`lib/models/saved_roster.dart` (novo):** `SavedRoster { teams, competitionName }` com `toJson`/`fromJson` (reusa `Team.toJson`). Persiste a planilha inteira, separada do `MatchState`.
- **`CacheService`:** nova chave `iwbf.roster.v1` + `saveRoster`/`loadRoster`/`hasRoster`/`clearRoster`. `clear()` agora limpa **roster E match state** (ambos os callers — "Start from Scratch" e "Load New Spreadsheet" — querem tela limpa).
- **`ValidationSummaryScreen._continue`:** salva `SavedRoster(_teams, competitionName)` no cache (planilha validada/editada = "ultima planilha usada") antes de ir ao Match Setup. Navigator capturado antes do await (evita `use_build_context_synchronously`).
- **`LoadSpreadsheetScreen`:** pergunta passa a checar `hasRoster()` (nao `hasMatchState()`); "Load Previous Spreadsheet" reconstroi um `SpreadsheetParseResult` limpo (sem issues) da planilha salva e abre o **Resumo** com todas as equipes. Vira `WidgetsBindingObserver`: em `resumed`, se a Home esta no topo (`ModalRoute.isCurrent`), reseta o guard e refaz a pergunta; senao nao faz nada (partida/setup/resumo intactos). Textos do dialog atualizados ("Load Previous Spreadsheet" / "...all teams and players...").
- **Versao:** `pubspec.yaml` 1.2.0+3 -> **1.3.0+4**; `kAppVersion` 1.2.0 -> **1.3.0**.
- **Nota:** o `MatchSetupScreen(restored:)` continua existindo (usado em testes), mas a Home nao usa mais esse caminho. Apos crash/kill o app NAO volta a partida exata (por design, conforme pedido): volta a Home e oferece a planilha inteira.

Arquivos alterados: `lib/models/saved_roster.dart` (novo), `lib/services/cache_service.dart`, `lib/screens/{validation_summary,load_spreadsheet}_screen.dart`, `lib/constants/app_version.dart`, `pubspec.yaml`, `test/services/cache_service_test.dart` (grupo roster), `test/screens/load_spreadsheet_screen_test.dart` (seed por roster; restore -> Resumo com 3 equipes incl. Canada; 2 testes de ciclo de vida resume on/off-Home).

Testes: validados no CI (Flutter ausente no Codespace). Novos: roster save/load/has/clear + clear() limpa ambos; dialog gateado por roster; "Load Previous Spreadsheet" abre Resumo com Brazil+Argentina+Canada (prova planilha inteira); resume na Home refaz a pergunta; resume fora da Home (no Resumo) nao interrompe.

Proximo passo recomendado:

- Usuario testa no preview/APK: encerrar/crashar/minimizar e confirmar (a) pergunta na Home, (b) restore traz a planilha inteira, (c) minimizar durante a partida volta a partida. Se aprovado, segue no fluxo do PR `claude/visual-modernization -> main` (**nao mergear sozinho**).

### 0039 - 2026-05-27 - Parser tolerante a nomes de coluna (aliases amplos + planilha real)

Contexto:

- O usuario anexou uma planilha real estilo IWBF (`COMPETITION, COUNTRY, CLASS, FULL NAME, NUMBER, FIRST NAME, LAST NAME, DOB, ROLE, CS`) e pediu que o app interprete colunas com titulos **levemente diferentes** pela informacao que carregam, nao pelo titulo exato. Obrigatorias minimas: `team_name`, `class`, `full_name`, `number`. `dob`/`gender` ausentes **nao** bloqueiam (ficam em branco). Colunas irrelevantes (`role`, `cs`/`class_status`, `first_name`/`last_name` quando ha `full_name`) devem ser **ignoradas**.

Entregue (em `lib/services/spreadsheet_parser_service.dart`):

- **Aliases ampliados** no mapa `_columnAliases` (tokens ja normalizados): `team_name` agora aceita `country`/`nation`/`nationality`/`pais`/`equipe`...; `class` aceita `sport_class`/`classification`/`functional_class`/`classe`...; `competition` aceita `tournament`/`event`/`championship`/`torneio`...; `name` aceita `full_name`/`player`/`athlete`/`nome`...; `number` aceita `jersey`/`bib`/`numero`...; `dob` aceita `birthday`/`born`/`nascimento`... O importante e a informacao da coluna, nao o titulo.
- **Par legado de nome** (`surname`/`first_name`) virou coluna logica com aliases proprios (`last_name`/`family_name`/`sobrenome`, `given_name`/`forename`/`nome_proprio`). `_hasLogicalColumn` e `_buildPlayer` agora resolvem via `_columnIndex` (antes liam o token cru `surname`/`first_name`).
- **Fallback de nome unificado:** quando NAO ha coluna de nome completo, junta sobrenome + nome no formato dos templates **"SOBRENOME, Nome"** (`_composeName`, ex.: `SILVA, João`) — antes era `firstName surname`.
- **Roteamento dirigido por CONTEUDO (titulo da aba e irrelevante):** o antigo `_parseSingleSheet(SheetData)` virou `_parseTeamColumnSheets(List<SheetData>)`. Regra nova em `parseSheets`: abas que tem coluna de equipe (`team_name`/`country`/...) listam equipes por linha — sao a fonte de verdade; havendo ao menos uma, **todas** elas sao combinadas (mesma equipe espalhada em abas distintas mescla por id) e as **demais abas sao ignoradas** (resumos, instrucoes). So quando NENHUMA aba tem coluna de equipe e que caimos no modelo "uma aba por equipe" (`_parseMultiSheet`, nome = titulo da aba). Removido o special-case do nome "Players" (agora subsumido pela deteccao por conteudo). Cobre: planilha anexada (aba generica com varios paises), aba com titulo aleatorio + coluna `country`, master + aba de instrucoes ignorada, e multiplas abas com coluna de equipe combinadas.

Arquivos alterados: `lib/services/spreadsheet_parser_service.dart`, `test/services/spreadsheet_parser_service_test.dart` (novo grupo "aliases de coluna (entrada 0039)" + 2 assertions de nome atualizadas para o formato "SOBRENOME, Nome").

Testes: validados no CI a cada push (Flutter ausente no Codespace). Novos casos: planilha real IWBF (COUNTRY/FULL NAME + colunas ignoradas, 3 paises -> 3 equipes), aliases `country/classification/tournament/player_name/jersey_number`, reconstrucao `SOBRENOME, Nome` de `last_name`+`first_name`, obrigatorias minimas sem dob/gender, titulo de aba irrelevante, aba "todas as equipes" vence (demais ignoradas), multiplas abas combinadas.

Proximo passo recomendado:

- Usuario testa importando a planilha real no preview Web. Se aprovado, segue no fluxo do PR `claude/visual-modernization -> main` (**nao mergear sozinho**).

### 0038 - 2026-05-27 - Modernizacao visual (Fases 1-6) na branch claude/visual-modernization

Contexto:

- O app irmao CBBC (fork deste) recebeu um refinamento visual/UX e ficou mais moderno. O usuario pediu para trazer esse refinamento para o IWBF **sem perder a identidade** (paleta dourada `IwbfColors`, fonte atual, 3 logos IWBF, bandeiras, UI em ingles, regras sem bonificacao, parser/fluxo). Apos analise dos prompts (Antigravity/Claude/Codex) e respostas do usuario, o escopo cresceu alem do visual e incluiu mudancas estruturais aprovadas.
- **Correcao de estado:** ao contrario do que dizia o CLAUDE.md/log antigos, a `main` JA TEM o app completo (PR #5 mergeado). O trabalho partiu de `main` numa branch nova `claude/visual-modernization`. Flutter NAO esta instalado no Codespace -> toda validacao roda no CI a cada push.

Entregue (cada fase deixou o CI verde):

- **Fase 1 — tema + icone + PWA:** tokens novos em `IwbfColors` (`successGreen`, `warningSurface`, `cardWhite`, `slate50/100/200`); `cardTheme` branco (elevation 1, sombra `0x14000000`, radius 14, borda slate200); `inputDecorationTheme` (fill slate50, foco dourado), `checkboxTheme`/`switchTheme` dourados; raios FilledButton 14 / OutlinedButton 12. Icone do app = logo preto IWBF (gerado com Pillow) em `web/favicon.png`, `web/icons/Icon-{192,512}` + maskable e `android/.../mipmap-*/ic_launcher.png`. `web/manifest.json`/`index.html` com nome humano + cores douradas. `lib/constants/app_version.dart` (`kAppVersion`).
- **Fase 2 — modelo + parser + templates:** `Player` passa a ter **`name` unico** (substitui surname+firstName; `fromJson` faz back-compat lendo o formato antigo do cache). `dob`/`gender` **opcionais** (dob em branco nao gera issue; invalido vira warning, nao erro). Parser com **aliases de colunas** (formatos antigos continuam abrindo) + **recuperacao de classe "data-like"** (`classFromDateLikeString` em `player_classes.dart` reconstroi a classe que o Excel autoformatou como data, ex. `2026-05-02` -> `2.5`). Templates novos (`competition, team_name, class, name, number, dob, gender`) com **colunas pre-expandidas** (`setColumnWidth`).
- **Fase 3 — nomes adaptaveis + orientacao:** `_AutoShrinkText` reescrito — encolhe a fonte e, se ainda nao couber, **quebra em ate 2 linhas (nunca reticencias)**; nome completo sempre visivel. Chip da quadra usa `player.name`. **Rotacao so em tablets** (`shortestSide>=600`); celular travado em portrait (`_applyOrientationPreference` em `main.dart`).
- **Fase 4 — restyle das telas:** home com upload card (circulo + nuvem), card "Reference Templates" com 2 botoes lado a lado e footer com versao; match setup com cards de friso dourado; lineup com placar em `AnimatedContainer` (glow vermelho ao estourar limite, tabular figures), limite de pontos movido para `PopupMenuButton` na AppBar, quadra com borda/sombra, chips e botoes com icones. Telas viraram `SingleChildScrollView` para nao estourar viewport.
- **Fase 5 — features novas:** **Jersey Color Picker** (cor da camisa por time guardada no `MatchState`, defaults preservam o visual atual; propagada a `PlayerJerseyIcon`/chips/lista) + **edicao completa do roster** na tela de validacao (editar nome, numero, data de nascimento via `showDatePicker`, genero, classe; excluir atleta com confirmacao; renomear/excluir equipe com confirmacao). Restyle do summary: badges (X Teams / Y Players), status pill, issue blocks com barra-acento. Classe invalida destaca o dropdown em `alertRedSurface`.
- **Fase 6 — polish + docs:** iconografia padronizada para `_outlined` (`warning_amber_outlined`, `file_upload_outlined`; demais ja eram outlined ou intencionalmente solidos como `play_arrow` no CTA). CLAUDE.md/log corrigidos (estado da branch).

Fora de escopo (DESCARTADO):

- **Importacao de PDF (`syncfusion_flutter_pdf`):** avaliada e **descartada pelo usuario em 2026-05-27** — complexa/fragil demais (extracao depende do layout do PDF) + exigiria Community License Syncfusion. O app foca **somente** nas planilhas template ja criadas. Nao ha menção a PDF no codigo nem na UI; nao reabrir sem novo pedido explicito.

Arquivos principais alterados: `lib/theme/iwbf_theme.dart`, `lib/constants/{app_version,player_classes}.dart`, `lib/models/{player,match_state}.dart`, `lib/services/{spreadsheet_parser_service,template_generator_service}.dart`, `lib/main.dart`, `lib/screens/{load_spreadsheet,match_setup,validation_summary,lineup_control,missing_data}_screen.dart`, `lib/widgets/player_jersey_icon.dart`, assets de icone web/android, + testes em lockstep (nome unificado, dob opcional, jersey colors, limite na AppBar, exclusao no roster).

Testes: validados no CI (`build-apk.yml`) a cada push — `Analyze` + `Run tests` verdes; APK release gerado como artifact. Preview Web atualizado a cada push em `claude/**` (GH Pages + CF Pages).

Proximo passo recomendado:

- Usuario revisa o preview no navegador (portrait + landscape, desktop + mobile) e o APK no Android (icone IWBF na home). Se aprovado, mergear o PR `claude/visual-modernization -> main` (**nao mergear sozinho**). PDF foi descartado; proximo escopo a definir pelo usuario.

### 0037 - 2026-05-15 - Encerramento da Fase 5 e preparacao do merge MVP -> main

Resumo:

- Apos a entrada 0036 (fix do template SAF "Save As"), usuario rodou 3 Robo Tests no Firebase Test Lab usando o APK release do commit `368436f`:
  1. **Pixel 5 / API 30 / portrait** (mesma config da entrada 0036).
  2. **Galaxy Tab A9+ / API 34 / portrait** — tablet 10" para validar o layout split (listas laterais + quadra central).
  3. **Pixel Tablet / API 34 / portrait** — segundo tablet 10" para reforcar coverage.
- Resultado: **todos os 3 launchs OK, app renderiza sem crash, sem ANR**. Robo crawler nao consegue navegar dialogos do sistema (SAF "Save As", file picker) — isso e **comportamento by design** do Robo (ele tenta navegar apenas a UI do app, nao processa system dialogs nativos do Android), nao bug do app. Real user humano completa o ciclo normalmente.
- Layout tablet 10" portrait (quadra central + listas laterais) **validado via CF Pages no DevTools Chrome em modo tablet 10" portrait** durante a sessao — o split layout aparece corretamente, listas laterais com avatars/numeros, quadra central com chips de jogadores em quadra.
- Usuario decidiu: **fechar MVP**. Esta entrada prepara o PR `claude/review-and-continue-9ZK5v -> main` (trilha B do CLAUDE.md).

Decisoes desta entrada:

- **Estrategia de merge:** merge commit simples (NAO squash). Preserva historico das 37 entradas do log + commits feat/fix/docs por fase. Squash apagaria a granularidade que e o valor do `AI_WORK_LOG.md` cruzado com o git log.
- **Branch `claude/review-and-continue-9ZK5v` nao sera deletada apos o merge.** Razao: ela e a production-source atual do CF Pages (entrada 0034). Deletar = URL publica `https://iwbf-team-points-control.pages.dev/` para de atualizar (no melhor caso fica em cache do ultimo deploy; no pior, 404 dependendo do DNS). Usuario faz o switch da production-branch para `main` manualmente pelo dashboard Cloudflare (https://dash.cloudflare.com/ → projeto `iwbf-team-points-control` → Settings → Builds & deployments → Production branch). Apos o switch, a branch pode ser deletada com seguranca.
- **GH Pages continua em paralelo.** Os 2 testers atuais ja tem o link `https://gnpazinato.github.io/IWBF-Team-Points-Control/`; nao removemos esse deploy ate eles migrarem voluntariamente para o link CF Pages (sem handle pessoal).

Arquivos alterados:

- `docs/AI_WORK_LOG.md` (esta entrada + tabela de Estado atualizada com encerramento da Fase 5 e indicacao do PR).

Testes executados nesta sessao:

- `flutter analyze --no-fatal-infos` -> 1 info-level pre-existente em `spreadsheet_parser_service_test.dart:360` (`no_leading_underscores_for_local_identifiers` em `_expectArgentinaTeam`), nao bloqueante, registrado desde a entrada 0035.
- `flutter test` -> **176 passed, 0 failed, 0 skipped** (mesmo numero da entrada 0035; nenhum teste novo, nenhuma regressao).
- `git status` limpo antes desta entrada (commit 368436f).

Pendencias / smoke test pos-merge:

- Apos merge para `main`, CI roda automaticamente em `main`:
  - `Build Flutter Web (GitHub Pages)` + `Deploy to GitHub Pages` -> atualiza `https://gnpazinato.github.io/IWBF-Team-Points-Control/`.
  - `Build and Deploy to Cloudflare Pages` -> gera **preview deploy** num subdominio com hash (porque a production-branch CF Pages ainda e `claude/review-and-continue-9ZK5v`).
  - `Build release APK` -> artifact `iwbf-team-points-control-apk` disponivel.
- Apos usuario fazer switch manual da production-branch CF Pages -> `main`, qualquer push em `main` vira production deploy, e a URL publica passa a ser servida do `main`. A branch `claude/review-and-continue-9ZK5v` pode entao ser deletada.
- Smoke test manual em device fisico (docs/INSTALL_ANDROID.md § 4): instalar APK release do `main`, abrir, baixar template via "Save As" (SAF), recarregar via file picker, configurar Match Setup, navegar Lineup Control, encerrar.

Limitacoes conhecidas registradas (nao bloqueiam o MVP):

- **Robo Test + SAF:** Robo crawler nao navega dialogos do sistema (Save As / file picker SAF). E by design do Robo Test. Para coverage automatizado do ciclo Download Template -> Load Spreadsheet -> Match Setup -> Lineup em CI seria necessario um Espresso/Patrol/Integration Test, fora do escopo do MVP.
- **`path_provider` continua em `pubspec.yaml`** mesmo nao sendo mais usado em `lib/` ou `test/` apos a entrada 0036. Pode ser removido em uma Fase 6 de housekeeping (escopo minimo do fix da 0036 evitou tocar dependencias).

Proximo passo recomendado:

- Mergear o PR `claude/review-and-continue-9ZK5v -> main` via `mcp__github__merge_pull_request` (merge commit simples). Aguardar CI verde em `main`. Acionar usuario para fazer o switch manual da production-branch CF Pages e decidir Fase 6.

### 0036 - 2026-05-15 - Fase 5 — decima segunda rodada: fix do template inacessivel no Android (Robo Test surfou bug de UX)

Resumo:

- Usuario criou projeto no Firebase Test Lab, fez upload do APK release do commit 5c38d8b (entrada 0035), e rodou primeiro Robo Test no Pixel 5 API 30 portrait. Resultado da matrix: "Aprovada" (0 falhas, 1 stable, 1 device — sem crash, sem ANR).
- "Aprovada" tecnicamente, mas o teste surfou um bug de UX que bloqueia real users no Android: ao tocar "Download Template — Single Sheet", a snackbar mostrou `Template saved to /data/user/0/com.iwbf.teampointscontrol/app_flutter/iwbf_template_single_sheet.xlsx`. Em seguida, ao tocar "Load Reference Spreadsheet", o file picker do sistema abriu vazio ("No items"). Robo nao consegue passar dali; real user idem.

Causa raiz:

- `lib/utils/template_saver_io.dart:11` usava `getApplicationDocumentsDirectory()` (do `path_provider`), que no Android devolve `/data/user/0/<pkg>/app_flutter/` — storage **privado** do app.
- O file picker do sistema (Files app / SAF) so enxerga: (1) pastas publicas (Downloads, Documents, Pictures...); (2) Drive / outros providers via SAF; (3) pastas app-scoped EXTERNAS. NAO enxerga `/data/user/0/<pkg>/` de outro app.
- Resultado: template gerado e gravado com sucesso, mas funcionalmente inacessivel pelo usuario para o re-upload. No Web isso nao acontece porque `template_saver_web.dart` dispara `<a download>` que vai pra pasta Downloads do browser, que o file picker do browser enxerga sem problema.

Correcao aplicada:

- `lib/utils/template_saver_io.dart` reescrito: troca `path_provider.getApplicationDocumentsDirectory()` por `FilePicker.platform.saveFile(bytes: ...)` do `file_picker ^8.1.2` (ja era dependencia do projeto, usado para o caminho de Load). Abre o dialogo nativo "Save As" — SAF no Android, document picker no iOS, save dialog no desktop. Usuario escolhe destino (Downloads, Drive, qualquer pasta visivel) e o file_picker grava via SAF — sem precisar de permissao runtime. Devolve o caminho final escolhido ou `null` se cancelar.
- `lib/utils/template_saver.dart` (docstring): atualizado para refletir "Save As" via SAF em vez de `getApplicationDocumentsDirectory`.
- `lib/screens/load_spreadsheet_screen.dart` (docstring do typedef `TemplateSaveFn`): mesma atualizacao.

Arquitetura preservada:

- A tela continua recebendo um `TemplateSaveFn` callback injetavel — testes de widget seguem usando `_FakeTemplateSaver` em memoria sem tocar a plataforma (regra do CLAUDE.md: plugins de plataforma sempre via callback/servico injetavel).
- Web (`template_saver_web.dart`) intocado — continua funcionando via `<a download>`.
- Contrato do `defaultSaveTemplate(filename, bytes) -> Future<String?>` nao mudou — testes existentes nao precisam de mudanca.

Arquivos alterados:

- `lib/utils/template_saver_io.dart` (reescrito, -3 / +9 linhas: removeu `import 'package:path_provider/...'` e `getApplicationDocumentsDirectory()`; adicionou `FilePicker.platform.saveFile` com `bytes`).
- `lib/utils/template_saver.dart` (docstring atualizado, ~4 linhas).
- `lib/screens/load_spreadsheet_screen.dart` (docstring do typedef, 2 linhas).
- `docs/AI_WORK_LOG.md` (esta entrada + tabela de Estado atualizada).

Testes executados:

- Flutter SDK ausente no sandbox desta sessao (`/root/flutter/bin/flutter` nao existe). CI valida no push: `flutter analyze --no-fatal-infos` + `flutter test` (esperado 176/176, mesmo numero da entrada 0035 — nenhum teste novo tocou plataforma e os testes existentes usam o `FakeSaver` injetado).
- `path_provider` continua no `pubspec.yaml` (nao removido nesta entrada para manter o escopo minimo do fix; nada mais no `lib/` ou `test/` usa o pacote, entao pode ser removido em entrada futura se desejado).

Pendencias / smoke test pos-CI:

- Aguardar CI do push verde: `Build Flutter Web (GitHub Pages)`, `Deploy to GitHub Pages`, `Build and Deploy to Cloudflare Pages`, `Build release APK`. Sem CI verde, APK release novo nao sai.
- Apos APK release novo, baixar artifact `iwbf-team-points-control-apk` do workflow `Build Android APK` em `claude/review-and-continue-9ZK5v` e re-rodar Robo Test no Firebase Test Lab. Plano esperado:
  1. Robo aperta "Download Template — Single Sheet" → dialogo SAF "Save As" abre.
  2. Robo aceita destino default (geralmente Downloads) → arquivo salvo em `/storage/emulated/0/Download/iwbf_template_single_sheet.xlsx`.
  3. Robo aperta "Load Reference Spreadsheet" → file picker do sistema abre.
  4. Robo navega ate Downloads, acha o `.xlsx`, abre.
  5. App valida planilha, navega para Match Setup, depois Lineup Control.
  6. Robo conclui o golden path.
- Idealmente expandir matrix no proximo run: alem do Pixel 5 / API 30 (Android 11, ja rodado), adicionar 1 tablet 10" portrait (Pixel Tablet ou Galaxy Tab A8) para validar o layout split (listas laterais + quadra central) e 1 phone moderno (Pixel 8 API 34) para Android 14.

Proximo passo recomendado:

- Push imediato; aguardar CI verde; baixar APK release novo; re-rodar Robo Test (mesma config Pixel 5/API 30) para confirmar que o ciclo Download → Load → Match Setup agora flui. Se passar, expandir matrix para tablet + phone modernos.

### 0035 - 2026-05-15 - Destrava `flutter test` no CI (15 falhas em widget tests, APK voltou a sair)

Resumo:

- Usuario pediu APK pra subir no Firebase Test Lab. Investigando, o job `Build release APK` (`.github/workflows/build-apk.yml`) estava falhando ha varios commits no step `flutter test`: 161 passed, **15 failed**. Sem `flutter test` verde, `flutter build apk` nao roda → nenhum APK como artifact.
- Bisect rapido (rodando `flutter test` em `7e3faed`, antes da entrada 0033): as falhas **ja existiam ali** — nao sao regressao da entrada 0033 sozinha. A entrada 0033 piorou (assertion ellipsis quebrou) mas as 13 outras ja vinham. O autor das entradas 0031..0033 marcou "Sem flutter localmente, CI valida no push" em todas — e o CI vinha vermelho silenciosamente porque ninguem olhava o status do `build-apk.yml`.
- Setup nesta sessao: `git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /root/flutter`, `flutter pub get`. Flutter 3.41.9 stable, mesma versao que o CI usa (`subosito/flutter-action@v2 channel: stable`). Reproduzi as 15 falhas exatamente.

Diagnostico das 3 causas raiz:

1. **RenderFlex overflow sub-pixel no `_CourtPlayerChip`** (13 testes): o Column da linha 931 do `lineup_control_screen.dart` estava overflowando 0.39 a 1.5 pixels no bottom. Causa: a soma das alturas dos children (`PlayerJerseyIcon` + `SizedBox(gap)` + `_AutoShrinkText` + `Text(playerClass)`) ficava no limite do espaco disponivel; o **line-height default** dos Texts (geralmente 1.15 a 1.4 vezes o fontSize, dependendo da fonte) consumia a folga. Em produccao isso e invisivel (sub-pixel + clipped pela borda do chip), mas o `flutter_test` framework dispara assertion em qualquer overflow.

2. **Assertion vs comportamento atual do `_AutoShrinkText`** (1 teste — `nome longo no card lateral nao usa TextOverflow.ellipsis`): o teste verificava que NENHUM Text descendente do `_PlayerCard` tinha `TextOverflow.ellipsis`. Mas a entrada 0033 introduziu fallback explicito de ellipsis quando o `idealFontSize` cai abaixo do `minFontSize` (justamente para evitar o bug do "MACDONALD, Olivier" sumindo silenciosamente). Os dois estavam em conflito direto. O comportamento atual e o correto (preferir ellipsis explicito a corte silencioso); o teste e que estava desatualizado.

3. **`DropdownButtonFormField` nao renderizando items fora da viewport** (1 teste — `lista todos os limites aceitos no dropdown`): o teste abre o dropdown do Point Limit e procura `find.text('7.0')` ate `'16.0'` (19 items). Em viewport baixa (default do test runner), o overlay do dropdown lazy-builda items, entao items distantes do scroll inicial nao chegam a entrar na arvore de widgets. `find.text` retorna 0.

Correcoes aplicadas:

- `lib/screens/lineup_control_screen.dart`:
  - `_AutoShrinkText.build` Text: adicionado `style: TextStyle(..., height: 1.0)`. Garante que `Text.height` (vertical line-height) seja igual ao fontSize, sem multiplicador extra. Resolve overflow sub-pixel.
  - `_CourtPlayerChip` Text(playerClass): mesmo ajuste, `height: 1.0`.

- `test/screens/lineup_control_screen_test.dart`:
  - Teste `nome longo no card lateral nao usa TextOverflow.ellipsis` substituido por **`card lateral nunca corta nome silenciosamente (auto-shrink + ellipsis explicito como fallback)`**. Verifica que `find.text("SURNAME1, First")` encontra o Text dentro do card. (`find.text` compara `Text.data`, nao o texto pintado — entao o nome continua "presente" no widget tree mesmo quando aparece com ellipsis no canvas. Ellipsis e o **fallback aceito**, nao o **bug**.)

- `test/screens/match_setup_screen_test.dart`:
  - Teste `lista todos os limites aceitos no dropdown` agora seta `tester.view.physicalSize = Size(1200, 2400)` no inicio. Viewport alta permite que o overlay do dropdown renderize todos os 19 items sem lazy-skip. Comentario inline explica por que.

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart` (+2 linhas: `height: 1.0` em 2 lugares).
- `test/screens/lineup_control_screen_test.dart` (~+45/-15: teste ellipsis reescrito).
- `test/screens/match_setup_screen_test.dart` (+11 linhas: viewport setup).
- `docs/AI_WORK_LOG.md` (esta entrada + tabela de estado atualizada).

Testes executados:

- `flutter analyze --no-fatal-infos` -> 1 info-level pre-existente em `spreadsheet_parser_service_test.dart:360` (no_leading_underscores_for_local_identifiers em `_expectArgentinaTeam`), nao bloqueante e nao introduzido por esta entrada.
- `flutter test` -> **176 passed, 0 failed, 0 skipped** (antes: 161/15).

Pendencias / smoke test:

- Aguardar CI do push validar: `Build Flutter Web (GitHub Pages)`, `Deploy to GitHub Pages`, `Build and Deploy to Cloudflare Pages`, `Build release APK` — todos devem ficar verdes.
- Depois do CI verde, baixar APK release do artifact do workflow `Build Android APK`.
- Validar APK no Firebase Test Lab via Robo test em 1 tablet 10" + 1 phone (portrait).

Proximo passo recomendado:

- Push imediato; checar CI; baixar APK; Firebase Test Lab.

### 0034 - 2026-05-15 - Integracao Cloudflare Pages no CI (URL publica sem o handle pessoal)

Resumo:

- Usuario confirmou que o preview Web do GH Pages (https://gnpazinato.github.io/IWBF-Team-Points-Control/) ja esta sendo usado pelos 2 testers, mas o link expoe o handle pessoal `gnpazinato`. Para uso institucional futuro (IWBF Americas) e para nao expor o handle aos testers, criar URL paralela no Cloudflare Pages: `iwbf-team-points-control.pages.dev` (sem owner no dominio).
- Tentativa anterior do usuario via dashboard CF caiu no fluxo Workers (UI nova empurra Workers como default no cartao "Upload your static files"), deployou os arquivos crus de `web/` (sem `flutter build web` rodar) e gerou `iwbf-team-points-control.gustavonpaz.workers.dev` — site quebrado (faltava `main.dart.js`, `flutter.js` etc.) e ainda expondo `gustavonpaz`. Worker deletado pelo usuario; PR #3 (autoconfig de Workers gerado pelo bot do CF) sera fechado sem mergear.
- Caminho B escolhido (do plano discutido em chat): GitHub Actions ja builda Flutter Web; adicionar deploy direto para CF Pages via `wrangler pages deploy`, mantendo o GH Pages em paralelo por enquanto (testers atuais nao perdem acesso ao link antigo).
- Diferenca importante entre os dois destinos: **GH Pages** serve em sub-path `/IWBF-Team-Points-Control/` (precisa `--base-href "/IWBF-Team-Points-Control/"` no build); **CF Pages** serve na raiz `/` (build default sem `--base-href`). Por isso o job CF roda um build separado sem a flag.
- Secrets adicionados no GitHub (passos manuais do usuario): `CLOUDFLARE_API_TOKEN` (permissoes `Account → Cloudflare Pages → Edit` + `Account → Account Settings → Read`) e `CLOUDFLARE_ACCOUNT_ID` (copiado do Account Home no dashboard CF).
- Production branch do projeto CF Pages configurada como `claude/review-and-continue-9ZK5v` (igual a branch ativa). Quando o MVP for fechado (merge para `main`), trocar para `main` via dashboard CF ou via `wrangler pages project edit`.

Arquivos alterados:

- `.github/workflows/deploy-web.yml`:
  - nome do workflow renomeado para `Deploy Web (GitHub Pages + Cloudflare Pages)`;
  - jobs `build` (GH Pages com base-href) e `deploy` (deploy-pages action) mantidos como estavam;
  - novo job `cloudflare-pages` em paralelo: faz checkout + setup Flutter (com cache) + `flutter create . --platforms=web` + `flutter pub get` + `flutter build web --release` (sem base-href) + `wrangler pages project create` idempotente (`if/grep/else create`) + `wrangler pages deploy build/web --project-name=iwbf-team-points-control --branch=${GITHUB_REF_NAME}`;
  - usa `npx --yes wrangler@latest` direto em `run:` em vez de `cloudflare/wrangler-action@v3` para ter controle do shell script idempotente de criar/listar projeto.

- `docs/AI_WORK_LOG.md`:
  - tabela de Estado atual atualizada (data 2026-05-15, status geral com a entrada 0034, fase atual estendida ate 0034, proximo passo apontando para validar deploy CF Pages, secao Testers externos com os 2 destinos, APK gerado mencionando ambos previews);
  - esta entrada.

- `CLAUDE.md`:
  - secao "Repositorio" agora lista os dois previews (GH Pages legacy + CF Pages novo) e referencia o workflow renomeado.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK e sem credenciais CF para teste local). Validacao acontece no primeiro push pelo CI: o job `cloudflare-pages` precisa rodar end-to-end (project create + deploy) sem erro.

Pendencias / smoke test:

- Primeiro run do workflow nesta branch (`claude/cf-pages-deploy`) deve criar o projeto CF Pages (`wrangler pages project create iwbf-team-points-control --production-branch=claude/review-and-continue-9ZK5v`) sem falhar — a etapa tem `if/else` que so cria se nao existir.
- Primeiro deploy desta branch deve gerar URL preview no formato `<hash>.iwbf-team-points-control.pages.dev` (preview porque `claude/cf-pages-deploy` nao bate com a production-branch).
- Apos merge em `claude/review-and-continue-9ZK5v`, push subsequentes nessa branch viram production deploy e a URL `iwbf-team-points-control.pages.dev` passa a servir o app.
- Validar visualmente que o app abre na URL CF Pages com o mesmo conteudo do GH Pages (sem path prefixo).

Proximo passo recomendado:

- Aprovar e mergear o PR `claude/cf-pages-deploy → claude/review-and-continue-9ZK5v`. Apos merge, fazer push de qualquer commit (ou re-disparar o workflow via `workflow_dispatch`) em `claude/review-and-continue-9ZK5v` para forcar production deploy. Validar `https://iwbf-team-points-control.pages.dev/`. Quando confirmado, compartilhar URL nova com os 2 testers atuais e parar de compartilhar a do GH Pages para testers futuros.

### 0033 - 2026-05-14 - Fase 5 - nona rodada: hotfix do auto-shrink (first name sumindo silenciosamente)

Resumo:

- Usuario testou a entrada 0032 no preview Web e mandou dois prints mostrando que nomes longos como `MACDONALD, Olivier`, `WILLIAMS, Benjamin`, `THOMPSON, Ethan` apareciam cortados sem ellipsis: na tela aparecia apenas `MACDONALD,` (com a virgula no fim), e o first name simplesmente sumia. Pior que ellipsis — silencioso, sem aviso visual de que tem mais conteudo.

- **Causa raiz**: o `Text` widget dentro de `_AutoShrinkText` tinha `maxLines: 1` mas `softWrap` no default (`true`). Quando o texto natural era maior que a largura disponivel mesmo apos o auto-shrink, o Flutter quebrava `"MACDONALD, Olivier"` em duas linhas (`["MACDONALD,", "Olivier"]`), e o `maxLines: 1` escondia a segunda linha sem indicador visual.

- **Correcao** em `_AutoShrinkText`:
  - **`softWrap: false`** no Text → impede a quebra em multiplas linhas. Texto sempre numa linha unica.
  - **Ellipsis fallback explicito**: o calculo do `idealFontSize` agora detecta quando ele cairia abaixo do `minFontSize`. Quando isso acontece, trava no piso E aplica `TextOverflow.ellipsis`. Resultado: `"THOMPSON, Eth..."` em vez de `"THOMPSON,"` silenciosamente cortado.
  - **Margem de seguranca 98%**: quando o `idealFontSize` e usado, multiplico por 0.98 para evitar 1-2px de overflow por arredondamento de fonte.
  - **`minFontSize` no card lateral baixou de 8.0 para 7.0**: da mais espaco antes de cair no ellipsis. 7dp ainda e legivel em tablet.

- **Fluxo final do `_AutoShrinkText`**:
  1. Mede `naturalWidth` do texto a `maxFontSize` via `TextPainter`.
  2. Se cabe na largura disponivel → renderiza no `maxFontSize`.
  3. Se nao cabe, calcula `idealFontSize = maxFontSize * maxWidth / naturalWidth`.
  4. Se `idealFontSize >= minFontSize` → renderiza em `idealFontSize * 0.98` (texto inteiro, fonte menor).
  5. Se `idealFontSize < minFontSize` → renderiza em `minFontSize` com `TextOverflow.ellipsis`.

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart`:
  - `_AutoShrinkText`: `softWrap: false` no Text, branching idealFontSize vs minFontSize, ellipsis fallback, margem 98%;
  - `_PlayerCard`: `minFontSize` do `_AutoShrinkText` baixou de 8.0 para 7.0.

- `docs/AI_WORK_LOG.md` — esta entrada + tabela de estado.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI valida no push. Os testes existentes da entrada 0032 continuam validos (incluindo a verificacao de que nenhum Text do card usa ellipsis quando nao precisa — agora ellipsis so aparece quando o texto realmente nao cabe nem no piso).

Pendencias / smoke test:

- Tablet portrait estreito: nomes ate ~17 chars devem caber inteiros encolhidos; nomes muito longos (>17-20 chars dependendo da largura) caem em ellipsis explicito (`"...`"), nunca somem sem aviso.

Proximo passo recomendado:

- Smoke test do usuario com os mesmos prints anteriores.

### 0032 - 2026-05-14 - Fase 5 - oitava rodada: chips da quadra com tamanho FIXO + auto-shrink robusto via TextPainter

Resumo:

- Usuario validou a entrada 0031 no preview Web e reportou que a correcao falhou em DOIS pontos visiveis no print:
  1. **Nomes longos ainda cortados com "..."** ("GONZALEZ, Seba...", "MACDONALD, Oliv...", "WILLIAMS, Benja...") — `FittedBox(scaleDown)` dentro de `Align` dentro de `Expanded` recebe constraints frouxas e nao escala confiavelmente em todos os cenarios. Conclusao: FittedBox nao e o approach robusto aqui.
  2. **Chips da quadra com tamanhos diferentes E sobrepondo** — `ConstrainedBox(maxWidth, maxHeight)` permitia o chip encolher conforme o conteudo, criando variacao visual. Alem disso, o gap vertical entre row 2 (y=0.28) e center (y=0.40) era apenas 0.12 * h, insuficiente para chips de 0.17 * h.

**1. Auto-shrink robusto: novo widget `_AutoShrinkText`.**
   - Usa `LayoutBuilder` para obter o `BoxConstraints` real da posicao no layout.
   - Mede a largura natural do texto via `TextPainter.layout()` com o `maxFontSize` configurado.
   - Calcula `finalFontSize = maxFontSize * maxWidth / naturalWidth` quando excede, clamped por `minFontSize`.
   - Renderiza um `Text` puro com o `fontSize` calculado — sem `TextOverflow.ellipsis`, sem corte.
   - Por que e mais robusto que `FittedBox(scaleDown)`: medicao explicita do `TextPainter` funciona mesmo quando o pai da constraints frouxas (`Align`, `Container` sem dimensoes fixas, etc.). Tambem dispensa o wrapper `Align`.

   Aplicado em dois lugares:
   - `_PlayerCard` (lista lateral): `Expanded > _AutoShrinkText(displayName, maxFontSize: fontSize, minFontSize: 8)`. Substitui o `Align > FittedBox > Text` da entrada 0031.
   - `_CourtPlayerChip` (chip da quadra): substitui o `FittedBox > Text` do surname.

**2. Chips da quadra com tamanho FIXO uniforme.**
   - `_CourtView` agora computa `slotMaxWidth = (w * 0.34).clamp(60, 150)` e `slotMaxHeight = (h * 0.12).clamp(46, 110)` — clamps adicionais evitam chip minusculo em viewports muito pequenos e chip gigante em telas wide.
   - `_CourtPlayerChip` agora usa `SizedBox(width: maxWidth, height: maxHeight)` em vez de `ConstrainedBox` — **forca todos os chips a terem EXATAMENTE as mesmas dimensoes externas**.
   - Dentro do `SizedBox`, Column com `mainAxisAlignment.center + mainAxisSize.max` centraliza o conteudo verticalmente. Quando o surname e curto, o chip ainda tem o tamanho cheio; o surname so encolhe se o `_AutoShrinkText` precisar (independente do tamanho externo do chip).
   - Formulas internas conservadoras (`iconSize = base * 0.46`, `fontSize = base * 0.15`, etc.) garantem que a soma das alturas dos filhos < maxHeight mesmo no piso 46dp.

**3. Slots reposicionados para mais gap vertical.**
   - Antes: Team A em y=(0.10, 0.28, 0.40); gap row2→center = 0.12 * h. Apertado.
   - Depois: Team A em y=(0.08, 0.26, 0.42); gap row2→center = 0.16 * h. Folgado.
   - Tambem afastei a coluna horizontal de 0.30/0.70 para 0.28/0.72 — gap horizontal aumenta de 0.40 para 0.44 * w.
   - Team B mirror: y=(0.92, 0.74, 0.58). Gap entre os dois centers (Team A 0.42 vs Team B 0.58) = 0.16 * h.
   - Com chip maxHeight = 0.12 * h, sobra 0.04 * h de gap em todos os pares — visivel mesmo em h_court pequeno.

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart`:
  - novo widget `_AutoShrinkText` no fim do arquivo;
  - `_PlayerCard`: trocou Align/FittedBox por `_AutoShrinkText`;
  - `_CourtView`: clamps adicionais em `slotMaxWidth`/`slotMaxHeight`, slots reposicionados;
  - `_CourtPlayerChip`: `SizedBox` em vez de `ConstrainedBox`, `_AutoShrinkText` no surname, formulas internas conservadoras.

- `test/screens/lineup_control_screen_test.dart`:
  - grupo `"responsive court chips (entrada 0032)"` substitui o de 0031:
    - 5 surnames presentes em viewport 720x1280;
    - regressao explicita: todos os 5 chips na quadra renderizam (court-view key presente);
    - regressao do bug do print: nenhum Text descendente do card lateral usa `TextOverflow.ellipsis`.

- `docs/AI_WORK_LOG.md` — esta entrada + tabela de estado atualizada.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI valida no push.

Pendencias / smoke test:

- Tablet portrait estreito (720x1280): chips na quadra com tamanho identico, sem sobreposicao, nomes longos no card lateral aparecem inteiros encolhidos.
- Desktop wide (>1200dp): chips mantem tamanho controlado pelos clamps (max 150x110), proporcional.

Proximo passo recomendado:

- Aguardar smoke test do usuario.

### 0031 - 2026-05-14 - Fase 5 - setima rodada: chips da quadra escalam por largura + FittedBox em nomes longos

Resumo:

- Usuario testou o preview Web simulando tablet portrait estreito e reportou dois problemas visuais:
  1. **Cards na quadra se sobrepondo** — os chips dos jogadores estavam com tamanho fixo (`PlayerJerseyIcon(size: 36)` + padding/fontes hard-coded) enquanto a quadra encolhia, causando overlap horizontal e vertical.
  2. **Nomes longos cortados com "..."** na lista lateral (ex.: `MACDONALD, Olivi...`, `WILLIAMS, Benjam...`). Usuario sugeriu reduzir o tamanho da fonte antes de cortar — eu fui de FittedBox + scaleDown, que e a versao mais profissional dessa ideia (encolhe proporcionalmente, mantem a legibilidade do nome inteiro).

**1. Quadra responsiva.** `_CourtView` agora calcula `slotMaxWidth = w * 0.34` e `slotMaxHeight = h * 0.17` (passo entre slots adjacentes — 0.40w horizontal e 0.18h vertical, com margem para nao encostar) e propaga essas dimensoes para `_CourtPlayerSlot` → `_CourtPlayerChip`. O chip:
   - usa `ConstrainedBox(maxWidth, maxHeight)` para nunca exceder o slot;
   - deriva `iconSize`, `fontSize`, `horizontalPad`, `verticalPad` e `gap` do `base = maxHeight.clamp(40, 96)`. Limites baixos garantem legibilidade minima em telas muito pequenas; limites altos evitam icone gigante em desktop largo;
   - envolve o surname num `FittedBox(scaleDown)` para que nomes como `MACDONALD`/`HERNANDEZ`/`SUAREZ` encolham proporcionalmente em vez de cortar.

   Em tablet portrait estreito (~720x1280), com a quadra ocupando ~280x520, o chip cai para ~40dp de icone e ~10dp de fonte — cinco chips por equipe cabem confortavelmente. Em desktop wide, o chip estende para o teto de 44dp de icone + 11dp de fonte (limite do clamp). A imagem PNG da quadra continua usando `AspectRatio + BoxFit.cover`, entao a quadra escala junto sem distorcer.

**2. Auto-shrink nos cards laterais.** `_PlayerCard` trocou `Text(overflow: ellipsis)` por `Align(centerLeft) + FittedBox(scaleDown, alignment: centerLeft) + Text`. Resultado:
   - nomes curtos renderizam no tamanho natural (fontSize derivado da altura do slot, como antes);
   - nomes longos encolhem proporcionalmente ate caberem, sem "..." e sem cortar letras.
   - O `alignment: centerLeft` no FittedBox preserva a aparencia esquerda-justificada que o `Expanded` ja tinha.

Decisao de design: `FittedBox(scaleDown)` foi escolhido em vez de "reduzir fontSize por contagem de caracteres" porque (a) e visualmente proporcional a largura disponivel real, nao a heuristica; (b) suporta variacoes de DPR sem ajuste manual; (c) e a forma idiomatica de auto-shrink em Flutter.

Arquivos alterados:

- `lib/screens/lineup_control_screen.dart`:
  - `_CourtView` calcula `slotMaxWidth` e `slotMaxHeight` no `LayoutBuilder` e propaga;
  - `_CourtPlayerSlot` ganha `slotMaxWidth`/`slotMaxHeight` no construtor e repassa pro chip;
  - `_CourtPlayerChip` reescrito: dimensoes derivadas do `maxHeight`, ConstrainedBox, FittedBox no surname;
  - `_PlayerCard` (lista lateral): `Align(centerLeft) + FittedBox(scaleDown)` em vez de `TextOverflow.ellipsis`.

- `test/screens/lineup_control_screen_test.dart`:
  - Novo grupo "responsive court chips (entrada 0031)" com 2 testes:
    - chip da quadra: 5 jogadores cabem em tela 720x1280, surnames `SURNAME1`..`SURNAME5` todos encontraveis;
    - card lateral: descendente FittedBox presente no widget tree, comprovando o mecanismo de auto-shrink.

- `docs/AI_WORK_LOG.md` — esta entrada + tabela de estado atualizada.

Testes executados:

- Nenhum local (ambiente sem Flutter SDK). CI valida no push.

Pendencias / smoke test:

- Validar visualmente no preview Web pos-deploy:
  - tablet portrait estreito (Galaxy Tab A9+ em portrait, ~800x1340 dpr-aware): chips na quadra cabem sem overlap, nomes longos da lista lateral aparecem inteiros encolhidos;
  - desktop wide (>1200dp): chips mantem tamanho confortavel pelo teto do clamp.

Proximo passo recomendado:

- Aguardar feedback. Se OK, considerar fechar o ciclo MVP (Trilha B do prompt de continuidade) e abrir PR `claude/review-and-continue-9ZK5v -> main`.

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

## Prompts de continuidade — HISTÓRICOS (NÃO usar)

> ⚠️ **Os dois prompts abaixo estão OBSOLETOS** (falam em Fase 4/Fase 5 e na
> branch histórica `claude/review-and-continue-9ZK5v`). A continuidade hoje é
> feita pelo **`CLAUDE.md`** (auto-carregado pelo Claude Code) + a tabela
> **"Estado atual"** no topo deste log. Estado real: MVP na `main`,
> modernização visual + ajustes 0039-0041 na `claude/visual-modernization`
> (versão `1.4.0+5`), PR aberto. Mantidos apenas como registro histórico.

### Prompt histórico 1 — Fase 4 (obsoleto)

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

### Prompt histórico 2 — Fase 5 fechada / aguardando testers (OBSOLETO)

> ⚠️ OBSOLETO — assume Fase 5 (entradas 0023..0033) e a branch histórica
> `claude/review-and-continue-9ZK5v`. NÃO usar; a fonte de verdade hoje é o
> `CLAUDE.md` + a tabela "Estado atual" no topo deste log.

```text
Você está retomando o IWBF Team Points Control (Flutter offline para
comissários de basquete em cadeira de rodas).

Antes de qualquer coisa, leia nesta ordem:
1. docs/IWBF_Team_Points_Control_Planejamento.md
2. docs/PLANO_DESENVOLVIMENTO_IA.md
3. docs/AI_WORK_LOG.md  ← fonte da verdade. Em particular: a tabela
   "Estado atual" (topo) e as entradas 0023..0033 que cobrem TODA a
   Fase 5 (11 rodadas de ajustes pos-teste manual).

Branch de trabalho: claude/review-and-continue-9ZK5v (já existe no
remoto, sincronizada). Repositório: gnpazinato/iwbf-team-points-control.

Confirme o estado executando antes de codar qualquer coisa:
  git fetch origin
  git checkout claude/review-and-continue-9ZK5v
  git pull --ff-only origin claude/review-and-continue-9ZK5v
  git log --oneline -10
Você deve ver commits "feat(fase-5)..." recentes — o último é o da
entrada 0030 ("variantes de genero amplas + aliases extras"). Se a
única coisa que aparecer for o scaffold inicial, VOCÊ ESTÁ NA BRANCH
ERRADA — não reimplemente do zero, troque de branch.

Estado atual:
- Fase 5 fechada com 11 rodadas (entradas 0023..0033). MVP completo:
  upload de planilha .xlsx, validação, correção, Match Setup com
  bandeira + gender no dropdown, dialog de confirmação Men vs Women,
  Lineup Control com quadra real (court.png + slots fixos), vibração
  no cruzamento de limite, cache, wakelock, templates pre-preenchidos
  com 16 equipes (8 países x 2 gêneros x 12 atletas), aliases de
  países cobrindo as 4 zonas IWBF (~96 países), variantes de gênero
  (M/F/W/Men/Mens/Man/Mans/Male/Females/Masculino/Femenino/Masc/Fem
  etc.) no team_name e na coluna gender, chips da quadra com tamanho
  fixo uniforme + auto-shrink robusto via _AutoShrinkText (Layout
  Builder + TextPainter + softWrap:false + ellipsis fallback) — nomes
  longos como "MACDONALD, Olivier" encolhem ou caem em ellipsis,
  nunca somem sem aviso.
- Preview Web em https://gnpazinato.github.io/IWBF-Team-Points-Control/
  servido a partir desta branch — atualiza a cada push.
- Usuário compartilhou o link com 2 testers externos em 2026-05-14.

Há DUAS trilhas possíveis. Pergunte ao usuário qual aplica:

▸ TRILHA A — Testers reportaram bugs / melhorias.
  Comportamento: peça a lista detalhada de bugs/sugestões dos testers
  antes de codar. Para cada item, decida se é:
    - bug visual → ajuste no widget afetado;
    - bug de lógica → ajuste no service/parser/model + teste novo;
    - sugestão de copy/UX → ajuste pontual.
  Continue na mesma branch. Adicione entrada ### 0034 (ou superior)
  no AI_WORK_LOG. Convenção de commit: feat(fase-5):... / fix(fase-5):...

▸ TRILHA B — Sem feedback (ou já absorvido) / usuário quer encerrar
  o ciclo MVP.
  Comportamento:
    1. Confirme com o usuário que TRILHA B é o que ele quer.
    2. Verifique git status limpo + push em dia.
    3. Abra PR `claude/review-and-continue-9ZK5v -> main` via GitHub
       MCP (mcp__github__create_pull_request). Título sugerido:
       "feat: IWBF Team Points Control MVP — Fases 1-5 completas".
       Body com resumo das 5 fases (use o checklist do log) +
       link para o preview Web + nota sobre o branch warning nos
       docs que devera ser removido apos merge.
    4. NÃO mergeie sozinho — peça aprovação do usuário antes.
    5. Após o merge, abra entrada nova no log registrando o fechamento
       do ciclo MVP e proponha próximos passos (estatísticas, scoring,
       Play Store, refactor — pedir ao usuário qual direção).

Regras de trabalho (não revisitar sem motivo técnico):
- Flutter local em /root/flutter/bin/flutter quando disponível.
  Se faltar, validação cai na CI no push.
- Sempre rodar localmente (quando Flutter disponível): flutter pub get
  → flutter analyze --no-fatal-infos (0 issues) → flutter test
  (tudo verde). Se Flutter ausente no sandbox, push direto — CI valida.
- Não commit pubspec.lock se mudou só por pub get local
  (git restore pubspec.lock antes do commit).
- Plugins de plataforma sempre via callback/serviço injetável
  (VibrationService, WakelockController, FilePicker callback, etc.).
- Em widget tests, NUNCA await Navigator.push(...) — o Future só
  completa quando a rota é popada, causa timeout.
- Capture Navigator.of(context) antes do primeiro await em handlers
  assíncronos para evitar use_build_context_synchronously.
- Color.withValues(alpha: x), nunca .withOpacity(x) (deprecated).
- DropdownButtonFormField.initialValue, nunca .value (deprecated).
- PopScope.onPopInvokedWithResult, nunca .onPopInvoked (deprecated).
- Cores de alerta sempre via IwbfColors (alertRed, alertRedSurface,
  goldDeep) — não Colors.red.shade*.

Rotina por incremento: implementa o menor pedaço útil → analyze +
test verdes (ou push se Flutter ausente, deixando CI validar) →
atualiza AI_WORK_LOG.md (nova entrada ### 00NN + tabela de estado +
arquivos alterados + testes + próximo passo) → commit + push em
claude/review-and-continue-9ZK5v → me reporta em 4-8 linhas.

Comece confirmando em UMA frase:
- Qual o último commit que você vê (sha + título);
- Qual trilha (A ou B) aplica.
Só depois disso, pergunte ou implemente.
```

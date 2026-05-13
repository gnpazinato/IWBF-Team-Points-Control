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
| Status geral | Fase 1 em andamento; scaffold + CI prontos, modelos e constantes implementados |
| Fase atual | Fase 1 - Fundacao testavel (modelos e testes unitarios) |
| Proximo passo recomendado | Aguardar CI rodar `flutter analyze` e `flutter test` na branch `claude/review-and-continue-9ZK5v`; depois iniciar Fase 2 (parser `.xlsx`) com `CountryResolverService` e `CacheService` |
| Ultimos testes executados | Push para CI em `claude/review-and-continue-9ZK5v` (flutter analyze + flutter test) |
| APK gerado | Sim, debug+release via CI na PR #1 |

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

- [ ] Implementar importacao `.xlsx`.
- [ ] Manter `.csv` fora do MVP e registrar como melhoria futura.
- [ ] Criar fixtures de planilha para testes.
- [ ] Interpretar modelo de aba unica.
- [ ] Interpretar modelo de uma aba por equipe.
- [ ] Validar colunas obrigatorias.
- [ ] Validar classes funcionais.
- [ ] Detectar atletas sem numero.
- [ ] Detectar equipes nao reconhecidas.
- [ ] Criar tela de resumo da planilha.
- [ ] Criar tela de correcao de dados.
- [ ] Criar `CountryResolverService`.
- [ ] Criar `CacheService`.
- [ ] Cobrir parser e validacoes com testes.
- [ ] Atualizar este log com formatos suportados de fato.

### Fase 3 - Fluxo de partida funcional

- [ ] Criar tela de selecao de Team A, Team B e Point Limit.
- [ ] Bloquear Team A e Team B iguais.
- [ ] Criar tela principal de controle.
- [ ] Exibir quadra central.
- [ ] Exibir listas de atletas por equipe.
- [ ] Selecionar e desselecionar atletas por toque.
- [ ] Bloquear sexto atleta.
- [ ] Somar pontos automaticamente.
- [ ] Mostrar alerta persistente acima do limite.
- [ ] Acionar vibracao leve ao cruzar o limite.
- [ ] Implementar Clear Team A.
- [ ] Implementar Clear Team B.
- [ ] Implementar Clear All.
- [ ] Implementar Change Teams.
- [ ] Implementar Load New Spreadsheet.
- [ ] Confirmar antes de sair da partida.
- [ ] Manter tela ativa durante a partida.
- [ ] Restaurar sessao anterior.
- [ ] Cobrir fluxo critico com testes.

### Fase 4 - Polimento, APK e validacao Android cloud

- [ ] Aplicar identidade visual.
- [ ] Ajustar layout para tablet.
- [ ] Ajustar layout para celular.
- [ ] Incluir logos, quadra e icones finais.
- [ ] Incluir bandeiras locais ou solucao equivalente.
- [ ] Criar templates baixaveis.
- [ ] Revisar textos em ingles.
- [ ] Rodar `flutter analyze`.
- [ ] Rodar `flutter test`.
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

## Registro de testes

| Data | Comando | Resultado | Observacao |
|---|---|---|---|
| 2026-05-12 | Nao aplicavel | Nao executado | Projeto ainda nao criado |
| 2026-05-13 | `flutter analyze --no-fatal-infos` | Delegado a CI | Validacao via workflow `build-apk.yml` no push para `claude/**` |
| 2026-05-13 | `flutter test` | Delegado a CI | Validacao via workflow `build-apk.yml` no push para `claude/**` |

## Pendencias e perguntas abertas

- Confirmar se o repositorio GitHub sera privado ou publico. Recomendacao: privado durante o MVP.
- Confirmar se o usuario quer usar apenas Codespaces pelo navegador ou tambem permitir acesso via VS Code/GitHub CLI.
- Escolher o servico cloud de device/emulador Android para validacao visual/manual.

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

## Prompt curto de continuidade

```text
Leia primeiro:
1. IWBF_Team_Points_Control_Planejamento.md
2. docs/PLANO_DESENVOLVIMENTO_IA.md
3. docs/AI_WORK_LOG.md

Continue somente a partir do proximo item pendente no log.
Nao refaca etapas concluidas sem justificar.
Implemente o menor incremento util, rode os testes relevantes e atualize docs/AI_WORK_LOG.md ao final.
```

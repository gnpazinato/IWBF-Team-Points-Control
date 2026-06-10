# IWBF Team Points Control - Plano de Desenvolvimento com IA

Este plano complementa o arquivo principal `IWBF_Team_Points_Control_Planejamento.md`.
Ele transforma o planejamento inicial em um roteiro curto, testavel e facil de continuar com Codex, Claude Code ou outra IA de desenvolvimento.

> ## ⚠️ ATENCAO — BRANCH ATIVA ⚠️
>
> **O MVP completo (Fases 1-5) JA ESTA NA `main`** (PR #5 mergeado). Avisos
> antigos de que "main so tem scaffold" e de que o codigo vive em
> `claude/review-and-continue-9ZK5v` estao DESATUALIZADOS — aquela branch e
> historica. A branch de trabalho atual e **`claude/visual-modernization`**
> (modernizacao visual Fases 1-6 + ajustes pos-testers 0039-0041, versao
> `1.4.0+5`), com PR aberto para `main`. Antes de qualquer coisa:
>
> ```bash
> git fetch origin
> git checkout claude/visual-modernization   # ou main, se o PR ja mergeou
> git pull --ff-only origin claude/visual-modernization
> ```
>
> O estado completo e a fonte da verdade estao em `docs/AI_WORK_LOG.md`
> (tabela "Estado atual" no topo + entradas 0038-0041).

## Regra principal

Antes de qualquer nova tarefa de desenvolvimento, a IA deve ler, nesta ordem:

1. `IWBF_Team_Points_Control_Planejamento.md`
2. `docs/PLANO_DESENVOLVIMENTO_IA.md`
3. `docs/AI_WORK_LOG.md`

Depois disso, a IA deve:

1. Identificar a fase atual e o proximo item pendente no log.
2. Trabalhar somente no item necessario para avancar.
3. Rodar os testes correspondentes.
4. Atualizar `docs/AI_WORK_LOG.md` com o que fez, arquivos alterados, testes executados e proximo passo.

Se o log indicar que uma etapa ja foi concluida, ela nao deve ser refeita sem motivo tecnico claro.

## Objetivo do MVP

Criar um app Flutter para Android, 100% offline, instalado por APK, que permita:

- carregar planilha de atletas;
- validar dados obrigatorios;
- escolher Team A e Team B;
- selecionar ate 5 atletas por equipe;
- somar classes funcionais automaticamente;
- alertar quando o limite de pontos for ultrapassado;
- manter cache local para evitar perda de dados durante a partida.

Prioridade do produto:

```text
Estabilidade > simplicidade operacional > clareza visual > beleza visual
```

## Fases de desenvolvimento

O projeto deve avancar em 4 fases. Cada fase precisa terminar com codigo funcional, testes relevantes e log atualizado.

### Fase 1 - Fundacao testavel

Objetivo: criar a base do projeto sem entrar ainda em toda a complexidade da partida.

Entregas:

- criar projeto Flutter Android;
- configurar nome do app e pacote inicial;
- organizar pastas sugeridas em `lib/`, `assets/` e `test/`;
- registrar assets existentes da pasta raiz no projeto;
- criar modelos principais: `Player`, `Team`, `MatchState`;
- criar constantes de classes funcionais e limites de pontuacao;
- criar testes unitarios iniciais para modelos e soma de pontos;
- configurar comandos de validacao para rodar no Codespace/CI.

Testes minimos:

```bash
flutter analyze
flutter test
```

Critério de conclusao:

- app abre com uma tela simples;
- modelos principais existem;
- testes unitarios basicos passam;
- log atualizado com estrutura criada.

### Fase 2 - Planilha, validacao e cache base

Objetivo: transformar planilhas em dados confiaveis antes da tela de partida.

Entregas:

- importar `.xlsx` como formato principal;
- deixar `.csv` para uma melhoria posterior;
- deixar `.xls` fora do MVP;
- aceitar modelo de aba unica e modelo de uma aba por equipe;
- validar colunas obrigatorias;
- validar `player_class`;
- aceitar conversao segura de `2,5` para `2.5`;
- detectar atletas sem numero;
- detectar equipes nao reconhecidas;
- criar tela de resumo da planilha;
- criar tela de correcao de dados obrigatorios;
- criar `CountryResolverService` com lista inicial de paises/codigos/aliases;
- criar `CacheService` para salvar dados carregados, correcoes e configuracao inicial.

Testes minimos:

```bash
flutter analyze
flutter test
```

Fixtures recomendadas em `test/fixtures/`:

- planilha valida de aba unica;
- planilha valida com abas por equipe;
- planilha sem numero de camiseta;
- planilha com classe invalida;
- planilha com equipe desconhecida.

Critério de conclusao:

- uma planilha valida gera lista de equipes e atletas;
- planilhas invalidas bloqueiam o fluxo com erro claro;
- dados corrigidos podem ser salvos no cache;
- log atualizado com formatos suportados de fato.

### Fase 3 - Fluxo de partida funcional

Objetivo: entregar o nucleo operacional do app.

Entregas:

- tela de selecao de Team A, Team B e Point Limit;
- bloqueio para impedir Team A e Team B iguais;
- tela principal em retrato com quadra central e listas laterais;
- selecao/deselecao por toque;
- limite de 5 atletas por equipe;
- bloqueio do sexto atleta com mensagem curta;
- soma automatica das classes;
- alerta persistente quando a equipe ultrapassar o limite;
- vibracao leve apenas no momento em que cruza o limite;
- botoes Clear Team A, Clear Team B, Clear All, Change Teams e Load New Spreadsheet;
- confirmacao antes de sair da tela de partida;
- manter tela ativa durante a partida;
- restaurar sessao anterior ao reabrir o app.

Testes minimos:

```bash
flutter analyze
flutter test
```

Testes recomendados:

- widget test da selecao ate 5 atletas;
- widget test tentando selecionar o sexto atleta;
- widget test do alerta de limite excedido;
- teste de serializacao/restauracao de `MatchState`;
- integration test curto do fluxo: carregar dados fixture -> escolher equipes -> selecionar atletas -> alerta.

Critério de conclusao:

- usuario consegue simular uma partida completa com dados de teste;
- cache restaura o estado principal;
- comportamento critico coberto por testes automatizados;
- log atualizado com cenarios testados.

### Fase 4 - Polimento, APK e validacao Android cloud

Objetivo: preparar um APK usavel, gerado em Codespaces/GitHub Actions e validado em servico cloud de device/emulador Android.

Entregas:

- aplicar identidade visual inspirada na IWBF;
- ajustar responsividade para tablet e celular;
- incluir logos, quadra e icones de atletas;
- incluir bandeiras locais ou pacote de assets definido;
- criar templates de planilha baixaveis pelo app;
- revisar textos em ingles;
- gerar APK debug para testes no Codespace ou em GitHub Actions;
- gerar APK release quando estiver estavel;
- testar em perfil Android tablet via servico cloud de device/emulador;
- testar em perfil Android phone via servico cloud de device/emulador;
- documentar instalacao manual do APK.

Testes minimos:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Antes de release:

```bash
flutter build apk --release
```

Checklist manual em Android cloud:

- instalar APK no device/emulador cloud escolhido;
- carregar planilha valida;
- corrigir numero ausente;
- selecionar duas equipes;
- selecionar 5 atletas por equipe;
- tentar selecionar sexto atleta;
- ultrapassar limite e confirmar alerta visual;
- verificar vibracao por teste automatizado/mocked service;
- simular bloqueio/desbloqueio quando disponivel;
- alternar para outro app e voltar;
- fechar app e restaurar sessao;
- trocar equipes sem reenviar planilha.

Critério de conclusao:

- APK e gerado remotamente e instala em pelo menos um alvo Android cloud;
- fluxo essencial funciona em formato tablet e phone via servico cloud de device/emulador Android;
- todos os testes automatizados passam;
- log atualizado com versao do APK, servico/alvo Android cloud testado e pendencias.

Observacao: Android fisico, Android Studio e emuladores locais no Mac ficam descartados para o plano atual. Nao assumir que o Android Emulator roda dentro do Codespace; a validacao visual/manual deve usar um servico cloud de device/emulador Android.

## Rotina de trabalho com Codex ou Claude

Use este prompt no inicio de cada nova sessao:

```text
Leia primeiro:
1. IWBF_Team_Points_Control_Planejamento.md
2. docs/PLANO_DESENVOLVIMENTO_IA.md
3. docs/AI_WORK_LOG.md

Depois continue somente a partir do proximo item pendente no log.
Nao refaca etapas concluidas sem justificar.
Implemente o menor incremento util, rode os testes relevantes e atualize docs/AI_WORK_LOG.md com:
- o que foi feito;
- arquivos alterados;
- comandos de teste executados;
- resultado dos testes;
- proximo passo recomendado.
```

Para tarefas maiores, peça a IA para trabalhar em incrementos de no maximo uma fase parcial, por exemplo:

```text
Continue a Fase 2 ate concluir apenas o parser de XLSX e seus testes. Atualize o log ao final.
```

## Estrategia de testes

Os testes devem ser tratados como parte do desenvolvimento, nao como etapa final.

### Testes unitarios

Cobrir:

- modelos (`Player`, `Team`, `MatchState`);
- soma de pontos;
- limite de 5 atletas;
- validacao de classe funcional;
- normalizacao de decimal com virgula;
- resolucao de pais/codigo;
- serializacao e desserializacao do cache.

### Testes de parser

Cobrir:

- `.xlsx` de aba unica;
- `.xlsx` com abas por equipe;
- colunas obrigatorias ausentes;
- dados obrigatorios vazios;
- classe invalida;
- DOB ausente;
- atleta sem numero;
- equipe desconhecida.

### Testes de widget

Cobrir:

- tela de resumo de planilha;
- tela de correcao de dados;
- selecao Team A/Team B;
- bloqueio de equipes iguais;
- tela de controle com listas e quadra;
- botao Clear Team A;
- botao Clear Team B;
- botao Clear All;
- alerta de limite excedido.

### Testes de integracao

Criar pelo menos um fluxo feliz:

```text
carregar fixture -> validar -> escolher equipes -> iniciar partida -> selecionar atletas -> ultrapassar limite -> limpar selecao
```

### Testes manuais Android cloud

Durante o desenvolvimento cloud-first, testar manualmente em servico cloud de device/emulador Android:

- instalacao manual do APK no alvo cloud escolhido;
- manter tela ativa;
- comportamento apos bloqueio/desbloqueio;
- retorno apos alternar para outro app;
- legibilidade em formato tablet;
- legibilidade em formato celular.

Observacao: vibracao e toque devem ter teste automatizado/mocked. Servicos cloud podem nao representar vibracao real com fidelidade.

## Ambiente de desenvolvimento recomendado

Decisao atual: usar uma estrategia cloud-first com GitHub Codespaces e servico cloud de device/emulador Android, para evitar instalar Flutter, Android Studio, Android SDK, JDK e emuladores no Mac.

Obrigatorio no Mac:

- navegador para acessar GitHub/Codespaces quando necessario;
- acesso ao Codex/Claude via navegador ou integracao conectada, se forem usados para desenvolvimento assistido;
- uma copia local temporaria dos arquivos apenas enquanto o repositorio remoto ainda nao estiver criado e sincronizado.

Obrigatorio na nuvem:

- conta GitHub pessoal;
- repositorio GitHub do projeto, preferencialmente privado;
- GitHub Codespaces habilitado para o repositorio;
- configuracao `.devcontainer` versionada no repositorio;
- Flutter SDK, Android command-line tools, JDK e dependencias instalados dentro do Codespace;
- GitHub Actions ou comando no Codespace para gerar APK;
- servico cloud de device/emulador Android para validacao visual/manual em perfis tablet e phone.

Fora do plano atual no Mac:

- Android Studio;
- Android SDK local;
- Android Emulator local;
- imagens locais de emulador tablet/phone;
- JDK local;
- VS Code local;
- dispositivo Android fisico.

Observacao: Android Studio, emuladores locais e Android fisico nao fazem parte do plano atual. O MVP deve priorizar testes automatizados, build APK remoto e validacao visual/manual em servico cloud de device/emulador Android. O Codespace e para desenvolver/buildar; nao e o alvo principal para rodar o Android Emulator.

## Armazenamento local no Mac

O objetivo e manter o Mac quase sem dependencias de desenvolvimento. Depois que todos os arquivos estiverem versionados no GitHub e o Codespace estiver funcionando, a copia local pode ser removida se o usuario quiser.

Antes de apagar a copia local, confirmar:

- todos os arquivos foram adicionados ao Git;
- as alteracoes foram commitadas;
- o commit foi enviado para o repositorio remoto;
- os assets originais importantes tambem estao no repositorio ou em outro backup confiavel.

O Codespace nao deve ser usado como unico local permanente do projeto. O repositorio GitHub e a fonte de verdade. Codespaces sao ambientes de trabalho que podem ser parados, recriados ou apagados.

Pre-condicao para iniciar a Fase 1:

- criar ou conectar um repositorio GitHub;
- subir os arquivos atuais;
- adicionar configuracao inicial de Codespaces/devcontainer;
- iniciar um Codespace e rodar `flutter doctor` dentro dele;
- escolher ou testar um servico cloud de device/emulador Android para a validacao visual/manual;
- registrar no log qualquer pendencia que ainda aparecer.

## Contas e plataformas necessarias

Como a estrategia atual e cloud-first, uma conta GitHub passa a ser necessaria para hospedar o repositorio e usar Codespaces.

Necessarias apenas se voce for usar ferramentas de IA especificas:

- OpenAI/Codex, se for usar Codex;
- Anthropic/Claude, se for usar Claude Code.

Recomendadas, mas opcionais:

- GitHub Actions, para gerar APK remoto de forma reproduzivel.

Para validacao Android cloud, avaliar uma plataforma de teste/device cloud. Exemplos possiveis: BrowserStack, Firebase Test Lab, AWS Device Farm ou alternativa equivalente.

Necessarias apenas se decidir publicar futuramente:

- Google Play Console, somente se o app for publicado na Play Store;

Nao sao necessarias para o MVP:

- Firebase como backend/banco;
- Supabase;
- banco online;
- servidor backend;
- conta de hospedagem;
- Apple Developer Account.

## Decisoes recomendadas antes de codar

Para evitar atrasos no MVP, ficam assumidas as seguintes decisoes:

- suportar `.xlsx` no MVP;
- deixar `.csv` para uma melhoria posterior, depois do fluxo principal estar estavel;
- deixar `.xls` fora do MVP;
- `competition_name` opcional;
- app travado em orientacao retrato na primeira versao;
- pacote Android inicial: `org.iwbf.teampointscontrol`, salvo se houver preferencia institucional diferente;
- DOB aceito nos formatos `YYYY-MM-DD` e `DD/MM/YYYY`, com normalizacao interna;
- celular com layout em abas simples: Team A, Court e Team B;
- tablet com listas laterais e quadra central;
- bandeiras como assets locais, com fallback generico quando uma bandeira nao existir;
- icones masculino/feminino entram apenas se o dado `gender` vier na planilha; caso contrario, usar icone padrao da equipe.

Essas decisoes podem ser alteradas, mas qualquer mudanca deve ser registrada em `docs/AI_WORK_LOG.md`.

## Ajustes pre-desenvolvimento registrados

Antes de iniciar o codigo, manter estes ajustes como tarefas de preparacao:

1. Trocar o setup principal de local completo para Codespaces/cloud-first.
2. Alinhar todos os documentos para `.xlsx` como unico formato de planilha no MVP.
3. Remover ou atualizar listas antigas de perguntas ja decididas.
4. Criar versoes otimizadas dos assets de imagem, mantendo os originais como referencia.
5. Registrar os logos IWBF presentes na pasta e definir a estrategia final de bandeiras locais.
6. Criar repositorio Git, `.gitignore` e fluxo de commit/push antes de apagar qualquer copia local.
7. Documentar que cache local do app e temporario e deve ser limpavel, por conter dados de atletas.
8. Separar validacao automatizada/build remoto de validacao visual/manual em servico cloud de device/emulador Android.
9. Nao planejar Android Emulator dentro do Codespace como caminho principal.

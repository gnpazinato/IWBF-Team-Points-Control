# IWBF Team Points Control — Planejamento Inicial do Aplicativo Android

> Documento de planejamento para conferência, ajustes e posterior uso como base para desenvolvimento com Flutter, Claude Code, Codex ou outra ferramenta de programação assistida por IA.

> ## ⚠️ ATENCAO — LEIA ANTES DE CODAR ⚠️
>
> **TODO o trabalho de Fase 1-5 ja existe na branch `claude/review-and-continue-9ZK5v`.**
> A `main` ainda esta com o scaffold inicial (commit `a2cc748`). Se voce
> abrir `lib/main.dart` e ver so um placeholder, voce esta na branch
> errada — nao reimplemente do zero, apenas troque:
>
> ```bash
> git fetch origin
> git checkout claude/review-and-continue-9ZK5v
> git pull --ff-only origin claude/review-and-continue-9ZK5v
> ```
>
> Confirme com `git log --oneline -5` que voce ve commits `feat(fase-5)...`,
> nao apenas o scaffold.
>
> Detalhes completos do estado atual estao em `docs/AI_WORK_LOG.md`
> (entradas 0001-0031). **Sempre leia esse log antes de qualquer
> alteracao.** Sao 31 entradas que mostram exatamente onde paramos.
> O prompt de continuidade pronto para uso esta na ultima secao do
> log ("Prompt curto de continuidade — Fase 5 fechada / aguardando
> testers").

---

## 1. Visão geral

O aplicativo **IWBF Team Points Control** será uma ferramenta Android offline, instalada via arquivo `.APK`, para auxiliar **comissários durante jogos oficiais** de basquetebol em cadeira de rodas.

A função principal do app será permitir que o usuário carregue uma planilha de referência com atletas e, durante a partida, selecione os jogadores que estão em quadra para cada equipe. O aplicativo calculará automaticamente a soma dos pontos de classificação funcional dos jogadores selecionados e exibirá um alerta quando a pontuação ultrapassar o limite configurado.

O aplicativo deverá ser:

- 100% offline;
- leve;
- estável para uso durante jogos oficiais;
- compatível com tablet Android;
- utilizável também em celulares Android, com layout responsivo;
- instalado manualmente via `.APK`;
- sem login;
- sem banco de dados online;
- com cache local temporário para evitar perda de dados durante o uso.

---

## 2. Objetivo principal

Permitir que comissários confiram rapidamente, durante uma partida oficial, se a soma dos pontos de classificação dos cinco atletas em quadra por equipe está dentro do limite permitido.

O aplicativo não terá, na primeira versão, objetivo de registrar estatísticas, placar do jogo, histórico oficial de substituições ou relatórios finais. Ele será uma ferramenta visual e operacional de conferência da pontuação em quadra.

---

## 3. Usuário principal

O usuário principal será:

- comissário da partida;
- pessoa responsável por acompanhar os atletas em quadra;
- equipe técnica/organizacional que precise conferir rapidamente o limite de pontos.

---

## 4. Escopo do MVP

A primeira versão funcional do aplicativo deverá incluir:

1. Tela inicial com upload de planilha de referência.
2. Opção para baixar dois modelos de planilha:
   - modelo com todos os atletas em uma única aba;
   - modelo com uma aba por equipe.
3. Leitura de planilhas em formatos comuns.
4. Validação dos dados obrigatórios.
5. Tratamento de atletas sem número de camiseta.
6. Cache local temporário.
7. Tela para escolher Team A e Team B.
8. Tela principal de controle da partida.
9. Exibição visual da quadra em orientação vertical.
10. Listagem dos atletas das duas equipes nas laterais.
11. Seleção e desseleção dos atletas em quadra.
12. Exibição dos atletas selecionados sobre a quadra.
13. Soma automática dos pontos de classificação por equipe.
14. Limite de pontuação configurável por dropdown.
15. Alerta visual persistente quando o limite for ultrapassado.
16. Vibração leve de 1 a 2 segundos quando o limite for ultrapassado.
17. Botões para limpar Team A, Team B e todos os jogadores.
18. Opção de mudar as equipes sem precisar reenviar a planilha.
19. Confirmação antes de sair da tela da partida.
20. Manutenção da tela ativa durante o uso.

---

## 5. Fora do escopo inicial

Na primeira versão, o aplicativo **não precisa** incluir:

- login;
- internet;
- banco de dados online;
- sincronização entre dispositivos;
- relatório final da partida;
- histórico de substituições;
- placar do jogo;
- cronômetro;
- publicação na Play Store;
- painel administrativo online;
- integração com sistema oficial da IWBF;
- registro oficial de dados pós-jogo.

Essas funcionalidades podem ser avaliadas em versões futuras, mas não devem fazer parte do MVP inicial para manter o app simples, leve e estável.

---

## 6. Plataforma e tecnologia recomendada

### 6.1. Plataforma-alvo

- Android tablet como prioridade;
- Android phone como compatibilidade secundária;
- instalação manual via `.APK`;
- funcionamento offline obrigatório;
- Android 10 ou superior como alvo mínimo recomendado.

### 6.2. Tecnologia recomendada

A tecnologia recomendada para o desenvolvimento é:

```text
Flutter
```

### 6.3. Justificativa

Flutter é indicado para este projeto porque:

- permite criar interface visual bonita e customizada;
- facilita o desenvolvimento de layout responsivo para tablet e celular;
- permite gerar `.APK` com relativa facilidade;
- funciona bem em Android;
- facilita o desenho da quadra e posicionamento dos jogadores;
- permite build e testes automatizados em Codespaces/GitHub Actions;
- permite validacao visual/manual em servicos cloud de device/emulador Android;
- permite evolução futura para outras plataformas, caso necessário.

### 6.4. Alternativa possível

A alternativa mais nativa seria:

```text
Kotlin + Jetpack Compose
```

Essa opção poderia oferecer integração Android mais direta, mas teria maior curva de desenvolvimento. Para este projeto, considerando velocidade, visual e facilidade de prototipagem, Flutter parece ser a melhor escolha inicial.

---

## 7. Orientação e layout geral

### 7.1. Orientação preferencial

O aplicativo deverá funcionar preferencialmente em:

```text
Portrait / Vertical mode
```

O usuário prefere o tablet ou celular na vertical.

### 7.2. Conceito visual da tela principal

A tela principal deverá ter:

- informações gerais no topo;
- lista de atletas da Team A em uma lateral;
- lista de atletas da Team B na outra lateral;
- quadra de basquete no centro;
- Team A posicionada na parte superior da quadra;
- Team B posicionada na parte inferior da quadra;
- informações de pontuação e alertas próximas ao topo ou rodapé;
- botões operacionais na parte inferior.

### 7.3. Representação da quadra

A quadra deverá ser uma vista aérea vertical, semelhante à imagem de referência fornecida, mas simplificada.

Requisitos visuais da quadra:

- fundo em madeira ou textura discreta de quadra;
- linhas brancas;
- linha central dividindo a quadra;
- linhas laterais e linhas de fundo;
- garrafão ou área próxima à tabela simplificada;
- não é necessário desenhar linhas de três pontos na primeira versão;
- a quadra deve servir como área visual para posicionar os cinco atletas de cada equipe.

### 7.4. Distribuição dos jogadores na quadra

Para cada equipe, os cinco jogadores selecionados devem aparecer distribuídos de forma simétrica.

Sugestão para Team A, na metade superior:

- 2 jogadores próximos à tabela superior;
- 2 jogadores mais à frente;
- 1 jogador próximo ao centro da quadra.

Sugestão para Team B, na metade inferior:

- 2 jogadores próximos à tabela inferior;
- 2 jogadores mais à frente;
- 1 jogador próximo ao centro da quadra.

Os jogadores devem estar visualmente “de frente” um para o outro, ou seja:

- Team A orientada para baixo;
- Team B orientada para cima.

---

## 8. Identidade visual

### 8.1. Nome do aplicativo

Nome definido para o app:

```text
IWBF Team Points Control
```

### 8.2. Inspiração visual

A identidade visual pode ser inspirada no site da IWBF e nos materiais enviados.

Direção visual sugerida:

- fundo geral off-white;
- textos principais em preto ou cinza escuro;
- detalhes em dourado;
- elementos institucionais em azul, vermelho, amarelo e verde quando fizer sentido;
- visual limpo, institucional e moderno.

### 8.3. Uso do logo

O usuário informou que o uso do logo IWBF está autorizado para este contexto.

Arquivos de referência enviados:

- logo IWBF vertical colorido com fundo preto;
- logo IWBF vertical colorido com fundo branco;
- símbolo IWBF isolado;
- ícones de atleta masculino e feminino em cadeira de rodas;
- ícones para uniforme claro e uniforme escuro;
- imagem de quadra.

### 8.4. Ícones dos jogadores

O app deverá usar ícones inspirados nas imagens fornecidas:

- Team A com uniforme claro/branco;
- Team B com uniforme escuro/preto;
- ícones de atleta em cadeira de rodas;
- versões masculina e feminina, se possível;
- número da camiseta exibido dentro da camiseta;
- nome e classe abaixo do ícone.

Regra visual importante:

```text
Team A = light uniform
Team B = dark uniform
```

No basquetebol, a Team A normalmente usa uniforme claro e a Team B usa uniforme escuro. O aplicativo deve seguir essa convenção visual.

---

## 9. Estrutura da planilha de referência

### 9.1. Formatos aceitos

No MVP, o aplicativo deve aceitar apenas:

- `.xlsx`.

O `.xlsx` deve ser o formato do template oficial.

Formatos fora do MVP:

- `.csv` pode entrar como melhoria posterior;
- `.xls` fica fora do MVP.

Essa decisao reduz a complexidade inicial do parser e deixa o template oficial mais estavel.

### 9.2. Dois modelos aceitos

O aplicativo deverá aceitar dois formatos de planilha.

---

### Modelo 1 — Uma única aba com todos os jogadores

Nome recomendado da aba:

```text
Players
```

Colunas obrigatórias:

```text
competition_name
team_name
shirt_number
surname
first_name
player_class
dob
```

Coluna opcional:

```text
gender
```

Observação: `competition_name` pode ser opcional do ponto de vista técnico, mas recomendado para aparecer na interface do app.

---

### Modelo 2 — Uma aba por equipe

Nesse modelo, cada aba representa uma equipe.

Exemplo de abas:

```text
Brazil
Argentina
Canada
United States of America
```

Em cada aba, as colunas obrigatórias seriam:

```text
shirt_number
surname
first_name
player_class
dob
```

Colunas opcionais:

```text
gender
team_name
competition_name
```

Se `team_name` não estiver presente em uma aba, o app deve usar o nome da aba como nome da equipe.

---

## 10. Colunas da planilha

### 10.1. Colunas obrigatórias

| Coluna | Obrigatória | Observação |
|---|---:|---|
| `team_name` | Sim no modelo de aba única | Nome da equipe/país em inglês |
| `shirt_number` | Sim | Número da camiseta, indispensável |
| `surname` | Sim | Sobrenome do atleta |
| `first_name` | Sim | Primeiro nome do atleta |
| `player_class` | Sim | Classe funcional do atleta |
| `dob` | Sim | Data de nascimento para diferenciar atletas com nomes iguais ou parecidos |

### 10.2. Colunas opcionais

| Coluna | Obrigatória | Observação |
|---|---:|---|
| `gender` | Não | Pode ajudar a escolher ícone masculino/feminino |
| `competition_name` | Não | Pode aparecer no topo da tela |
| `country_code` | Não | Pode ajudar a localizar bandeira, mas não deve ser obrigatório |

---

## 11. Regras para nome da equipe e bandeiras

### 11.1. Exibição da equipe

A equipe deve aparecer no padrão:

```text
Brazil - BRA
```

Exemplos:

```text
Argentina - ARG
Brazil - BRA
Canada - CAN
United States of America - USA
China - CHN
```

### 11.2. Entrada pelo usuário

A planilha pode trazer apenas o nome da equipe em inglês, por exemplo:

```text
Brazil
China
United States
USA
United States of America
```

O aplicativo deve tentar normalizar esse nome automaticamente.

### 11.3. Normalização de nomes de países

O aplicativo deve conter uma lista interna de países, códigos e aliases.

Exemplo:

```text
United States
United States of America
USA
U.S.A.
US
```

Todos esses exemplos devem ser associados a:

```text
United States of America - USA
```

Outro exemplo:

```text
China
People's Republic of China
PR China
CHN
```

Associar a:

```text
China - CHN
```

### 11.4. Quando o app não reconhecer a equipe

Se o aplicativo não conseguir reconhecer o nome ou código, deve permitir que o usuário corrija manualmente antes de avançar.

Mensagem sugerida:

```text
We could not identify the country for this team. Please select the correct country.
```

### 11.5. Bandeiras

O aplicativo deve vir com bandeiras pré-instaladas.

Requisitos:

- bandeiras devem ser carregadas automaticamente com base no país/equipe;
- a planilha não deve precisar conter imagens;
- o app deve ter um banco local de bandeiras em assets;
- se não houver bandeira reconhecida, exibir ícone genérico.

---

## 12. Regras para classe funcional

### 12.1. Valores aceitos

A classe funcional deve usar ponto como separador decimal.

Valores esperados:

```text
1.0
1.5
2.0
2.5
3.0
3.5
4.0
4.5
```

### 12.2. Validação

Se a planilha trouxer valor fora desse padrão, o app deve bloquear o avanço e mostrar erro.

Exemplo:

```text
Invalid player class for SILVA, João. Accepted values are 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0 and 4.5.
```

### 12.3. Separador decimal

O padrão oficial do app deve ser ponto decimal:

```text
2.5
```

Não usar vírgula:

```text
2,5
```

Se o usuário importar `2,5`, o app pode converter automaticamente para `2.5`, mas deve preferir o padrão com ponto nos templates.

---

## 13. Regras para número da camiseta

### 13.1. Obrigatoriedade

O número da camiseta é obrigatório.

O usuário não pode avançar para a partida se houver atleta sem número.

### 13.2. Tratamento de atletas sem número

Se a planilha tiver atleta sem número, o app deverá abrir uma tela de correção.

Mensagem sugerida:

```text
Some players are missing shirt numbers.
Please complete the missing information before continuing.
```

Para cada atleta sem número, mostrar:

```text
Team: Brazil - BRA
Player: SILVA, João
DOB: 01/01/1998
Shirt Number: [input field]
```

O usuário deve preencher manualmente o número faltante.

### 13.3. Avanço bloqueado

Enquanto todos os atletas não tiverem número de camiseta preenchido, o botão de continuar deve ficar bloqueado.

---

## 14. Dados internos do aplicativo

### 14.1. Modelo de atleta

Estrutura sugerida:

```text
Player {
  id
  teamName
  teamCode
  countryCode
  shirtNumber
  surname
  firstName
  playerClass
  dateOfBirth
  gender
}
```

### 14.2. Modelo de equipe

```text
Team {
  id
  displayName
  teamName
  countryCode
  flagAssetPath
  players
}
```

### 14.3. Estado da partida

```text
MatchState {
  competitionName
  teamA
  teamB
  pointLimit
  selectedPlayersTeamA
  selectedPlayersTeamB
  totalPointsTeamA
  totalPointsTeamB
  isTeamAOverLimit
  isTeamBOverLimit
}
```

---

## 15. Fluxo do aplicativo

### 15.1. Tela 1 — Initial screen / Load Spreadsheet

Título sugerido:

```text
IWBF Team Points Control
```

Elementos:

```text
Load Reference Spreadsheet
Download Template - Single Sheet
Download Template - One Sheet per Team
```

O usuário deve obrigatoriamente carregar uma planilha ou restaurar uma sessão anterior.

Se existir cache temporário, mostrar:

```text
Previous data found.
Would you like to restore your previous session or start from scratch?
```

Botões:

```text
Restore Previous Session
Start from Scratch
```

---

### 15.2. Tela 2 — Spreadsheet Validation

Após o upload, o app valida:

- formato do arquivo;
- abas;
- colunas obrigatórias;
- nomes das equipes;
- bandeiras;
- classes funcionais;
- números de camiseta;
- datas de nascimento.

Se estiver tudo correto:

```text
Spreadsheet loaded successfully.
```

Exibir resumo:

```text
Competition: Americas Championship
Teams found: 12
Players found: 144
```

Exemplo de lista:

```text
Brazil - BRA: 12 players
Argentina - ARG: 12 players
Canada - CAN: 11 players
```

Botão:

```text
Continue
```

---

### 15.3. Tela 3 — Missing Data Correction

Essa tela aparece apenas se houver dados obrigatórios faltando.

Casos:

- atleta sem número de camiseta;
- equipe não reconhecida;
- classe funcional inválida;
- data de nascimento ausente;
- nome ou sobrenome ausente.

O usuário deve corrigir antes de continuar.

---

### 15.4. Tela 4 — Match Setup

Campos:

```text
Competition Name
Team A
Team B
Point Limit
```

O nome da competição pode vir da planilha. Caso não exista, pode ficar em branco.

Team A e Team B devem ser selecionadas por dropdown.

O app deve impedir que Team A e Team B sejam iguais.

Point Limit deve vir como dropdown com sete opções:

```text
13.0
13.5
14.0
14.5
15.0
15.5
16.0
```

Valor padrão:

```text
14.0
```

Botão:

```text
Start Match
```

---

### 15.5. Tela 5 — Lineup Control

Essa é a tela principal do app.

Componentes:

1. Topo:
   - logo IWBF pequeno;
   - nome da competição, se houver;
   - Team A vs Team B;
   - point limit.

2. Área de pontuação:
   - total da Team A;
   - total da Team B;
   - limite atual;
   - alerta de limite excedido.

3. Laterais:
   - lista de atletas da Team A;
   - lista de atletas da Team B.

4. Centro:
   - quadra vertical;
   - cinco posições para Team A;
   - cinco posições para Team B.

5. Rodapé:
   - Clear Team A;
   - Clear Team B;
   - Clear All;
   - Change Teams;
   - Load New Spreadsheet.

---

## 16. Cards dos atletas

### 16.1. Atleta na lista lateral

Cada atleta na lista lateral deve aparecer com:

```text
[ícone com número na camiseta]
SILVA, João
Class 2.5
```

O número da camiseta deve estar dentro da camiseta do ícone.

### 16.2. Atleta dentro da quadra

Quando selecionado, o atleta deve aparecer dentro da quadra com:

```text
#7
SILVA
2.5
```

Ou, usando o ícone:

```text
[ícone com número 7]
SILVA
2.5
```

A informação dentro da quadra deve ser mais compacta do que a lista lateral.

### 16.3. Nome exibido

Padrão definido:

```text
SURNAME, First Name
```

Exemplo:

```text
SILVA, João
```

Dentro da quadra, pode ser usado apenas o sobrenome:

```text
SILVA
```

---

## 17. Regras de seleção

### 17.1. Número máximo de atletas

Cada equipe pode ter no máximo cinco jogadores selecionados.

Regra:

```text
Max 5 players per team.
```

### 17.2. Permitir menos de cinco

O aplicativo deve permitir que a equipe tenha de 0 a 5 jogadores selecionados.

Isso é importante porque, durante substituições, o usuário pode desselecionar todos os atletas e selecionar novos jogadores.

### 17.3. Bloquear sexto jogador

Se o usuário tentar selecionar um sexto atleta, o app deve bloquear e exibir:

```text
Only 5 players can be selected for Team A.
```

Ou:

```text
Only 5 players can be selected for Team B.
```

### 17.4. Seleção/deseleção

O usuário deve selecionar ou desselecionar atletas por toque.

A interação deve funcionar como checkbox, mas visualmente pode ser um card selecionável.

Quando selecionado:

- o card lateral fica destacado;
- o atleta aparece na quadra;
- a soma de pontos é atualizada.

Quando desselecionado:

- o card lateral volta ao estado normal;
- o atleta sai da quadra;
- a soma de pontos é atualizada.

---

## 18. Regras de pontuação

### 18.1. Soma automática

O app deve somar automaticamente as classes dos atletas selecionados.

Exemplo:

```text
1.0 + 2.0 + 3.0 + 3.5 + 4.0 = 13.5
```

### 18.2. Point Limit

O limite deve aparecer em local visível na tela:

```text
Point Limit: 14.0
```

### 18.3. Alteração durante a partida

O limite deve poder ser alterado durante a partida por dropdown.

Opções permitidas:

```text
13.0
13.5
14.0
14.5
15.0
15.5
16.0
```

### 18.4. Valor padrão

Valor padrão:

```text
14.0
```

### 18.5. Alerta de limite excedido

Se a pontuação de uma equipe ultrapassar o limite, o app deve mostrar alerta persistente.

Exemplo:

```text
Team A: 14.5 / 14.0
Point limit exceeded.
```

Ou:

```text
Team B: 15.0 / 14.0
Point limit exceeded.
```

### 18.6. Vibração

Quando uma equipe ultrapassar o limite, o app deve vibrar de forma leve por 1 a 2 segundos.

Regras:

- sem alerta sonoro;
- vibração apenas no momento em que o limite for ultrapassado;
- mensagem visual deve permanecer enquanto a pontuação estiver acima do limite.

---

## 19. Cache local e persistência temporária

### 19.1. Regra geral

O app não terá banco online e não exigirá login.

Porém, para garantir estabilidade, deve usar cache local temporário.

### 19.2. Por que usar cache

O cache é necessário porque, durante uma partida, o Android pode:

- bloquear a tela;
- receber chamada;
- receber notificação;
- colocar o app em segundo plano;
- encerrar processo por economia de bateria;
- rotacionar a tela;
- deixar o app inativo por muito tempo.

O usuário não pode perder a seleção atual por causa disso.

### 19.3. O que deve ser salvo no cache

O cache deve guardar:

- dados carregados da planilha;
- equipes reconhecidas;
- atletas;
- correções manuais feitas pelo usuário;
- Team A e Team B selecionadas;
- jogadores atualmente em quadra;
- point limit atual.

### 19.4. Tela ao reabrir o app

Se houver cache, o app deve perguntar:

```text
Previous data found.
Would you like to restore your previous session or start from scratch?
```

Botões:

```text
Restore Previous Session
Start from Scratch
```

### 19.5. Limpeza de cache

O cache deve ser limpo quando o usuário escolher:

```text
Start from Scratch
```

ou:

```text
Load New Spreadsheet
```

---

## 20. Estabilidade durante o jogo

### 20.1. Manter tela ativa

Durante a tela de controle da partida, o app deve manter a tela ativa.

Função:

```text
Keep screen awake during match
```

Essa opção deve estar ativada por padrão.

### 20.2. Persistência após bloqueio de tela

Se o usuário bloquear a tela sem querer e desbloquear depois, o app deve manter:

- planilha carregada;
- equipes selecionadas;
- atletas selecionados;
- pontuação atual;
- limite atual.

### 20.3. Persistência após alternar de app

Se o usuário abrir outro app ou receber ligação, ao voltar para o aplicativo os dados devem permanecer.

### 20.4. Confirmação antes de sair

Ao tentar sair da tela de partida:

```text
Are you sure you want to leave this match?
Current selections may be lost.
```

Botões:

```text
Stay
Leave
```

---

## 21. Botões operacionais na tela principal

A tela principal deve conter:

```text
Clear Team A
Clear Team B
Clear All
Change Teams
Load New Spreadsheet
```

### 21.1. Clear Team A

Remove todos os atletas selecionados da Team A.

### 21.2. Clear Team B

Remove todos os atletas selecionados da Team B.

### 21.3. Clear All

Remove todos os atletas selecionados das duas equipes.

### 21.4. Change Teams

Volta para a tela de seleção de equipes, mantendo a planilha carregada.

Esse botão é importante para o fim de um jogo e início de outro, sem precisar reenviar a planilha.

### 21.5. Load New Spreadsheet

Volta para o início, limpa o cache e exige novo upload.

---

## 22. Textos principais do aplicativo

O app deve ser 100% em inglês, com frases curtas e diretas.

Sugestões:

```text
Load Reference Spreadsheet
Download Template - Single Sheet
Download Template - One Sheet per Team
Spreadsheet loaded successfully.
Some players are missing shirt numbers.
Please complete the missing information before continuing.
Select Team A
Select Team B
Point Limit
Start Match
Only 5 players can be selected for Team A.
Only 5 players can be selected for Team B.
Point limit exceeded.
Clear Team A
Clear Team B
Clear All
Change Teams
Load New Spreadsheet
Previous data found.
Restore Previous Session
Start from Scratch
Are you sure you want to leave this match?
Current selections may be lost.
```

---

## 23. Responsividade: tablet e celular

### 23.1. Tablet

O tablet é o uso principal.

O layout deve priorizar:

- quadra maior;
- listas laterais visíveis;
- ícones de atletas mais confortáveis;
- botões grandes para toque.

### 23.2. Celular

O app pode funcionar em celular, mas a tela será naturalmente mais limitada.

Não muda radicalmente a lógica do app, mas exige layout responsivo.

Sugestão para celular:

- quadra continua no centro;
- listas laterais podem ficar em painéis recolhíveis;
- ou as listas podem aparecer em abas:
  - Team A;
  - Court;
  - Team B.

### 23.3. Decisão recomendada

Desenvolver desde o início com layout responsivo, mas declarar que o uso recomendado é:

```text
Recommended device: Android tablet.
```

---

## 24. Compatibilidade com tablets Android

### 24.1. Requisitos mínimos sugeridos

Para uso estável em jogo oficial, recomenda-se tablet com:

- Android 10 ou superior;
- pelo menos 4 GB de RAM;
- tela de 10 polegadas ou maior;
- bateria em bom estado;
- armazenamento interno suficiente;
- boa resposta ao toque;
- possibilidade de instalação manual de APK;
- modo “install unknown apps” disponível;
- boa estabilidade de sistema.

### 24.2. Recomendação prática

Para uso em eventos, evitar tablets muito antigos, genéricos ou com pouca RAM.

Priorizar marcas como:

- Samsung;
- Lenovo;
- Xiaomi/Redmi/POCO, se o modelo tiver boa reputação e Android recente.

### 24.3. Modelos a considerar

Modelos que fazem sentido avaliar:

```text
Samsung Galaxy Tab A9+
Samsung Galaxy Tab S9 FE
Samsung Galaxy Tab S10 FE, se disponível no orçamento
Lenovo Tab P12
Lenovo Tab M11
Xiaomi Pad 6 ou sucessores equivalentes
```

### 24.4. Melhor custo-benefício provável

Para este app, que será visual e precisa de estabilidade, o melhor equilíbrio tende a ser:

```text
Samsung Galaxy Tab A9+ com 8 GB RAM / 128 GB
```

ou, se o orçamento permitir:

```text
Samsung Galaxy Tab S9 FE
```

O Tab S9 FE tende a ser mais robusto e institucional, enquanto o Tab A9+ tende a ser mais custo-benefício.

### 24.5. Observação sobre instalação por APK

Em tablets Android modernos, a instalação manual de APK normalmente é possível, desde que o usuário autorize a instalação por fontes desconhecidas.

O procedimento típico é:

```text
Settings > Apps > Special app access > Install unknown apps
```

A nomenclatura pode variar conforme a marca e a versão do Android.

---

## 25. Estrutura de desenvolvimento sugerida

### 25.1. Organização de pastas

Estrutura inicial sugerida para Flutter:

```text
iwbf_team_points_control/
  android/
  assets/
    images/
      logos/
      players/
      court/
      flags/
    templates/
      players_single_sheet.xlsx
      players_by_team.xlsx
  lib/
    main.dart
    app.dart
    models/
      player.dart
      team.dart
      match_state.dart
    services/
      spreadsheet_parser_service.dart
      country_resolver_service.dart
      cache_service.dart
      vibration_service.dart
    screens/
      load_spreadsheet_screen.dart
      validation_summary_screen.dart
      missing_data_screen.dart
      match_setup_screen.dart
      lineup_control_screen.dart
    widgets/
      player_card.dart
      court_view.dart
      team_score_panel.dart
      point_limit_dropdown.dart
      app_logo_header.dart
  pubspec.yaml
```

---

## 26. Bibliotecas Flutter prováveis

Bibliotecas a avaliar:

```text
file_picker
excel
shared_preferences
path_provider
wakelock_plus
vibration
flutter_svg
country_flags ou assets próprios de bandeiras
```

Observações:

- `file_picker` para escolher a planilha;
- `excel` para ler `.xlsx`;
- `shared_preferences` ou arquivo local para cache;
- `path_provider` para salvar cache local;
- `wakelock_plus` para manter a tela ativa;
- `vibration` para alerta leve;
- `flutter_svg` se os ícones forem vetoriais;
- bandeiras podem ser assets locais para evitar dependência de internet.

---

## 27. Estratégia de desenvolvimento em etapas

### Etapa 1 — Protótipo visual sem lógica completa

Objetivo:

- criar tela principal;
- exibir quadra;
- exibir listas laterais;
- exibir cards fictícios de atletas;
- posicionar cinco atletas na quadra.

Resultado esperado:

```text
Visual aprovado antes de desenvolver toda a lógica.
```

---

### Etapa 2 — Modelo de dados e leitura da planilha

Objetivo:

- ler planilha `.xlsx`;
- interpretar modelo de aba única;
- interpretar modelo de abas por equipe;
- transformar linhas em objetos `Player`;
- criar equipes automaticamente.

Resultado esperado:

```text
Planilha carregada e resumo exibido.
```

---

### Etapa 3 — Validação dos dados

Objetivo:

- validar colunas obrigatórias;
- validar classes;
- validar números de camiseta;
- validar DOB;
- identificar equipes;
- corrigir dados faltantes.

Resultado esperado:

```text
Usuário só avança quando os dados estiverem consistentes.
```

---

### Etapa 4 — Seleção de equipes

Objetivo:

- escolher Team A;
- escolher Team B;
- impedir equipes iguais;
- configurar point limit.

Resultado esperado:

```text
Partida configurada corretamente.
```

---

### Etapa 5 — Tela de controle funcional

Objetivo:

- selecionar atletas;
- desselecionar atletas;
- bloquear sexto atleta;
- somar pontos;
- mostrar alertas;
- atualizar quadra.

Resultado esperado:

```text
Funcionalidade principal funcionando.
```

---

### Etapa 6 — Cache e estabilidade

Objetivo:

- salvar estado localmente;
- restaurar sessão anterior;
- manter dados após bloqueio de tela;
- manter tela ativa durante a partida;
- confirmar saída.

Resultado esperado:

```text
App seguro para uso durante jogos.
```

---

### Etapa 7 — Polimento visual

Objetivo:

- aplicar identidade IWBF;
- ajustar cores;
- inserir logos;
- melhorar ícones;
- inserir bandeiras;
- ajustar botões e textos.

Resultado esperado:

```text
App com aparência institucional.
```

---

### Etapa 8 — Build APK e testes cloud

Objetivo:

- gerar APK debug/release em Codespaces ou GitHub Actions;
- testar em perfil tablet via servico cloud de device/emulador Android;
- testar em perfil phone via servico cloud de device/emulador Android;
- instalar manualmente no alvo cloud escolhido;
- simular partidas no ambiente cloud.

Resultado esperado:

```text
APK funcional, gerado remotamente e validado em Android cloud.
```

---

## 28. Testes necessários

### 28.1. Testes de planilha

Testar:

- planilha correta em `.xlsx`;
- planilha com aba única;
- planilha com abas por equipe;
- atleta sem número;
- atleta sem classe;
- classe inválida;
- equipe não reconhecida;
- DOB ausente;
- nomes repetidos;
- números repetidos;
- equipes com menos de 12 atletas;
- equipes com mais de 12 atletas.

### 28.2. Testes de partida

Testar:

- selecionar 5 atletas;
- tentar selecionar 6º atleta;
- desselecionar todos;
- alterar point limit durante a partida;
- ultrapassar limite;
- voltar abaixo do limite;
- limpar Team A;
- limpar Team B;
- limpar tudo;
- trocar equipes sem reenviar planilha.

### 28.3. Testes de estabilidade

Testar:

- bloquear tela e voltar;
- alternar para outro app e voltar;
- deixar app aberto por mais de 2 horas;
- receber notificação;
- mudar orientação do dispositivo, se permitido;
- fechar app e restaurar sessão;
- iniciar do zero e limpar cache.

---

## 29. Critérios de aceite do MVP

O MVP será considerado funcional quando:

1. O usuário conseguir carregar uma planilha válida.
2. O app validar corretamente os dados obrigatórios.
3. O app identificar equipes e bandeiras.
4. O usuário conseguir corrigir atletas sem número.
5. O usuário conseguir selecionar Team A e Team B.
6. O usuário conseguir selecionar até 5 jogadores por equipe.
7. O app bloquear o sexto jogador.
8. O app somar corretamente os pontos de cada equipe.
9. O app alertar quando ultrapassar o limite.
10. O app permitir alterar o limite durante a partida.
11. O app manter os dados após bloqueio de tela.
12. O app restaurar sessão anterior via cache.
13. O app permitir trocar equipes sem reenviar planilha.
14. O app gerar um APK Android instalável e validado em perfil tablet via serviço cloud.
15. O app funcionar totalmente offline.

---

## 30. Prompt-base para Claude Code ou Codex

```text
You are helping me build an Android Flutter app called "IWBF Team Points Control".

The app is an offline Android app for wheelchair basketball commissioners during official games. It must be installable as an APK and work without internet, login, or online database.

Core functionality:
1. The user loads a reference spreadsheet containing player data.
2. The app supports two spreadsheet formats:
   - one single sheet named "Players" with all players;
   - one sheet per team.
3. The app validates required player data:
   - team_name, when using the single-sheet format;
   - shirt_number;
   - surname;
   - first_name;
   - player_class;
   - dob.
4. Optional data:
   - gender;
   - competition_name.
5. Player class must support only:
   1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5.
6. Shirt number is mandatory. If missing, the app must show a correction screen and prevent the user from continuing until all missing numbers are filled.
7. The app must resolve team/country names into a standardized display format like "Brazil - BRA" and load local flag assets.
8. After validation, the user selects Team A and Team B.
9. Team A must use a light uniform icon. Team B must use a dark uniform icon.
10. The user chooses a point limit from a dropdown:
    13.0, 13.5, 14.0, 14.5, 15.0, 15.5, 16.0.
    The default is 14.0.
11. The main screen must be portrait/vertical.
12. The center of the screen must show a simplified vertical basketball court.
13. Team A selected players appear in the upper half of the court.
14. Team B selected players appear in the lower half of the court.
15. Each team can have 0 to 5 selected players.
16. The app must block selecting a 6th player and show a short message.
17. The app must automatically sum selected player classes for each team.
18. If the total exceeds the point limit, show a persistent "Point limit exceeded." message for that team and trigger a light vibration for 1-2 seconds.
19. No sound alerts.
20. The app must provide:
    - Clear Team A;
    - Clear Team B;
    - Clear All;
    - Change Teams;
    - Load New Spreadsheet.
21. The app must use local temporary cache to restore the previous session if the app is closed, the screen locks, or Android interrupts the app.
22. When opening the app and previous data exists, ask:
    "Previous data found. Would you like to restore your previous session or start from scratch?"
23. The app must keep the screen awake during the match screen.
24. The app must ask for confirmation before leaving the match screen.
25. The app must be visually inspired by IWBF branding:
    - off-white background;
    - black/dark text;
    - gold details;
    - IWBF logo assets;
    - wheelchair basketball player icons.
26. The app must be stable and optimized for Android tablets, but also responsive enough to work on Android phones.

Please build this project step by step, starting with:
1. Flutter project structure;
2. data models;
3. spreadsheet parser;
4. validation flow;
5. match setup screen;
6. lineup control screen;
7. cache and stability features;
8. APK build instructions.
9. Cloud device/emulator validation instructions.
```

---

## 31. Ajustes antes do desenvolvimento

Decisoes que ja foram fechadas e devem guiar a primeira versao:

1. O MVP aceita `.xlsx`; `.csv` fica para melhoria posterior; `.xls` fica fora do MVP.
2. `competition_name` e opcional.
3. Celular usa abas simples: Team A, Court e Team B.
4. Tablet usa listas laterais e quadra central.
5. Bandeiras serao assets locais, com fallback generico.
6. Icones masculino/feminino entram apenas se `gender` existir; caso contrario, usar icone padrao da equipe.
7. DOB aceita `YYYY-MM-DD` e `DD/MM/YYYY`, com normalizacao interna.
8. O pacote Android inicial sera `org.iwbf.teampointscontrol`.
9. A primeira versao ficara travada em orientacao retrato.
10. O desenvolvimento deve usar estrategia Codespaces/cloud-first para reduzir instalacoes no Mac.
11. A validacao visual/manual Android deve usar servico cloud de device/emulador.
12. Android fisico e emulador local no Mac ficam descartados no plano atual.

Tarefas de preparacao que ainda devem ser feitas:

1. Criar repositorio Git/GitHub e `.gitignore`.
2. Adicionar configuracao `.devcontainer` para Codespaces.
3. Registrar os assets de logo IWBF enviados.
4. Criar versoes otimizadas dos assets de imagem para uso no app, mantendo os originais como referencia.
5. Definir a lista inicial de bandeiras locais ou o pacote de assets offline.
6. Documentar que o cache local do app e temporario e deve ser limpavel.
7. Separar build/testes automatizados remotos da validacao manual em servico cloud de device/emulador Android.
8. Registrar que o Android Emulator dentro do Codespace nao e caminho principal.

---

## 32. Decisões já consolidadas

| Item | Decisão |
|---|---|
| Nome | IWBF Team Points Control |
| Idioma | Inglês |
| Plataforma | Android |
| Instalação | APK manual |
| Internet | Não |
| Login | Não |
| Banco online | Não |
| Cache local | Sim |
| Uso principal | Comissários durante jogos oficiais |
| Orientação preferencial | Vertical/retrato |
| Tecnologia recomendada | Flutter |
| Dispositivo principal | Tablet Android |
| Compatibilidade secundária | Celular Android |
| Limite padrão | 14.0 |
| Limites disponíveis | 13.0 a 16.0, de 0.5 em 0.5 |
| Alerta sonoro | Não |
| Vibração | Sim, leve |
| Bandeiras | Sim, assets locais |
| Logos IWBF | Sim |
| Ícones de atletas | Sim, inspirados nos anexos |
| Histórico de substituições | Não |
| Relatório final | Não |
| Placar do jogo | Não |
| Cronômetro | Não |

---

## 33. Observação final

A prioridade deste aplicativo deve ser:

```text
Estabilidade > simplicidade operacional > clareza visual > beleza visual
```

Como será usado durante jogos oficiais, o aplicativo não pode depender de internet, não pode perder dados facilmente e não pode exigir muitos passos durante a partida.

A melhor primeira versão é aquela que faz muito bem o essencial:

```text
Carregar planilha → selecionar equipes → selecionar jogadores → somar pontos → alertar excesso.
```

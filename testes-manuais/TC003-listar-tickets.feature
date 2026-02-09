# language: pt
Feature: Listar Tickets no Sistema Helpdesk
  Como um usuário/support agent
  Quero visualizar uma lista de tickets
  Para entender o status geral de todas as solicitações abiertas

  Contexto (Background):
    Pré-condições que se aplicam a todos os cenários
    - Usuário deve estar autenticado no sistema
    - Deve existir pelo menos alguns tickets no banco de dados
    - Sistema deve estar funcionando normalmente

  Resumo de Critérios de Aceite:
    ✅ Listagem deve exibir: ID, Título, Status, Prioridade, Data de Criação, Responsável
    ✅ Deve suportar paginação (limite de rows por página: 10, 25, 50)
    ✅ Deve permitir filtrar por Status: Aberto, Em Andamento, Fechado, Reaberto
    ✅ Deve permitir filtrar por Prioridade: Baixa, Média, Alta, Crítica
    ✅ Deve permitir buscar por título/descrição
    ✅ Deve permitir ordenar por: Data (asc/desc), Prioridade (asc/desc), Status, ID
    ✅ Cada linha clicável deve levar ao detalhe do ticket
    ✅ Cores visuais devem indicar status: Aberto (vermelho), Em Andamento (amarelo), Fechado (verde)
    ✅ Ícones devem indicar prioridade: Baixa (azul), Média (amarelo), Alta (laranja), Crítica (vermelho)
    ✅ Total de tickets deve ser exibido em tempo real
    ✅ Sem tickets: exibir mensagem "Nenhum ticket encontrado"
    ✅ Responsivo em mobile (breakpoint 375px)

---

## ✅ CENÁRIOS POSITIVOS (Happy Path)

@smoke @critical
Scenario: Listar todos os tickets cadastrados
  Given que estou autenticado no sistema como "user@exemplo.com"
  And que existem 35 tickets no banco de dados com variados status
  And que estou na página de "Listagem de Tickets"
  And que a listagem está totalmente carregada
  
  When a página renderiza
  Then vejo uma tabela com as colunas:
    | Coluna            | Tipo         | Obrigatório |
    | ID                | Numérico     | Sim         |
    | Título            | Texto        | Sim         |
    | Status            | Badge        | Sim         |
    | Prioridade        | Badge        | Sim         |
    | Data de Criação   | DateTime     | Sim         |
    | Responsável       | Avatar+Nome  | Não         |
    | Ações             | Button       | Não         |
  
  And no topo da tabela, vejo um resumo: "Mostrando 10 de 35 tickets"
  And a tabela exibe exatamente 10 tickets (paginação padrão)
  And cada linha exibe:
    | Ticket | ID    | Título              | Status       | Prior | Data       | Resp. |
    | 1      | 12345 | Erro ao fazer login | 🔴 Aberto    | 🔴Alta    | 2026-02-08 | João  |
    | 2      | 12344 | Botão não funciona  | 🟡 Em Andam. | 🟡 Média  | 2026-02-08 | Maria |
    | 3      | 12343 | Typo no relatório   | 🟢 Fechado   | 🔵 Baixa  | 2026-02-07 | -     |
  
  When clico na primeira linha (ticket 12345)
  Then sou redirecionado para: /tickets/12345
  And a página de detalhes do ticket é exibida

---

@smoke
Scenario: Listar apenas tickets com status "Aberto"
  Given que estou na página de listagem de tickets
  And que existem 35 tickets no total com distribuição:
    | Status       | Quantidade |
    | Aberto       | 15         |
    | Em Andamento | 12         |
    | Fechado      | 8          |
  
  When clico no filtro "Status"
  Then um dropdown com opções é exibido:
    | Status       | Quantidade |
    | Todos        | 35         |
    | Aberto       | 15         |
    | Em Andamento | 12         |
    | Fechado      | 8          |
    | Reaberto     | 0          |
  
  When seleciono "Aberto"
  Then a listagem é filtrada para mostrar apenas tickets com status "Aberto"
  And o contador no topo muda para: "Mostrando 10 de 15 tickets"
  And todos os tickets exibidos têm um badge "🔴 Aberto"
  And a URL muda para: /tickets?status=aberto
  And o barra de filtros mostra: [Status: Aberto] [x] (com botão de remover)

---

Scenario: Listar tickets com status "Em Andamento"
  Given que estou na página de listagem de tickets
  And o filtro está em "Todos"
  
  When clico em "Status" → seleciono "Em Andamento"
  Then a listagem exibe apenas 12 tickets com status "Em Andamento"
  And o badge de cada linha é "🟡 Em Andamento"
  And o total mostra: "Mostrando 10 de 12 tickets"

---

Scenario: Listar tickets com status "Fechado"
  Given que estou na página de listagem de tickets
  
  When clico em "Status" → seleciono "Fechado"
  Then a listagem exibe apenas 8 tickets com status "Fechado"
  And o badge de cada linha é "🟢 Fechado"
  And o total mostra: "Mostrando 8 de 8 tickets" (cabe em uma página)
  And não há botão "Próxima página"

---

@important
Scenario: Listar tickets por prioridade Alta
  Given que estou na página de listagem de tickets
  And existem 35 tickets com distribuição de prioridade:
    | Prioridade | Quantidade |
    | Baixa      | 8          |
    | Média      | 15         |
    | Alta       | 10         |
    | Crítica    | 2          |
  
  When clico no filtro "Prioridade"
  Then um dropdown é exibido com opções
  
  When seleciono "Alta"
  Then apenas 10 tickets com prioridade "Alta" são exibidos
  And cada linha mostra ícone "🟠 Alta"
  And o total mostra: "Mostrando 10 de 10 tickets"
  And a URL muda para: /tickets?priority=alta

---

Scenario: Listar tickets com prioridade Crítica
  Given que estou filtrando por prioridade
  
  When seleciono "Crítica"
  Then apenas 2 tickets são exibidos
  And cada linha mostra ícone de prioridade crítica: "🔴 Crítica"
  And estes tickets aparecem destacados (cor de fundo mais escura ou borda)

---

Scenario: Combinar filtros: Status "Aberto" E Prioridade "Alta"
  Given que estou na página de listagem
  
  When aplico filtro Status = "Aberto"
  Then 15 tickets são exibidos
  
  When também aplico filtro Prioridade = "Alta"
  Then a listagem é reduzida para intersecção: apenas 5 tickets
  And ambos os filtros são mostrados na barra de filtros:
    [Status: Aberto] [x]  [Prioridade: Alta] [x]
  And o contador mostra: "Mostrando 5 de 5 tickets"

---

@important
Scenario: Validar paginação com limite padrão (10 por página)
  Given que estou na página de listagem de tickets
  And existem 35 tickets no total
  And a listagem está exibindo 10 tickets por página
  
  When visualizo a página atual
  Then vejo tickets de 1 a 10
  And no rodapé (footer) vejo:
    | Elemento          | Valor                    |
    | Texto             | Mostrando 1-10 de 35     |
    | Página            | Página 1 de 4            |
    | Botão Anterior    | Desabilitado (disabled)  |
    | Botão Próxima     | Habilitado               |
    | Selector de tamanho | [✓10] [25] [50]       |
  
  When clico em "Próxima página" ou no botão ">>"
  Then a página muda para a página 2
  And os tickets exibidos são de 11 a 20
  And a URL muda para: /tickets?page=2&limit=10
  And o botão "Anterior" agora fica habilitado
  And o rodapé mostra: "Mostrando 11-20 de 35"

---

Scenario: Paginação com limite de 25 por página
  Given que estou na página 1 com limite padrão (10)
  
  When clico em "[25]" no seletor de tamanho de página
  Then a listagem recarrega e exibe 25 tickets
  And a URL muda para: /tickets?page=1&limit=25
  And o rodapé mostra: "Mostrando 1-25 de 35"
  And o número de páginas muda para: "Página 1 de 2"
  And o botão "Próxima" fica habilitado

---

Scenario: Paginação com limite de 50 por página
  Given que estou na listagem de 35 tickets
  
  When clico em "[50]" no seletor de tamanho
  Then a listagem exibe todos os 35 tickets em uma única página
  And o rodapé mostra: "Mostrando 1-35 de 35"
  And o número de páginas mostra: "Página 1 de 1"
  And ambos os botões "Anterior" e "Próxima" estão desabilitados

---

@important
Scenario: Ordenar tickets por Data de Criação (descendente)
  Given que estou na listagem de tickets
  And a coluna "Data de Criação" exibe um ícone de ordenação
  
  When a página carrega inicialmente
  Then a data de criação mostra ordem DESCENDENTE (mais recentes primeiro)
  And o ícone da coluna "Data" mostra: ↓ (seta para baixo)
  And o primeiro ticket tem data: 2026-02-08 14:35
  And o último ticket tem data: 2026-02-01 09:10

---

Scenario: Inverter ordenação para Data (ascendente)
  Given que estou na listagem e a data está em ordem descendente
  
  When clico no cabeçalho da coluna "Data de Criação"
  Then a listagem é reordenada para ordem ASCENDENTE
  And o ícone da coluna muda para: ↑ (seta para cima)
  And o primeiro ticket tem data: 2026-02-01 09:10
  And o último ticket tem data: 2026-02-08 14:35
  And a URL muda para: /tickets?sort=data&order=asc

---

Scenario: Ordenar tickets por Prioridade (Alta → Baixa)
  Given que estou na listagem de tickets
  
  When clico no cabeçalho da coluna "Prioridade"
  Then os tickets são reordenados por prioridade em ordem descendente
  And a ordem é: Crítica → Alta → Média → Baixa
  And o ícone da coluna mostra: ↓
  And o URL muda para: /tickets?sort=prioridade&order=desc

---

Scenario: Ordenar tickets por Status
  Given que estou na listagem de tickets
  
  When clico no cabeçalho da coluna "Status"
  Then os tickets são reordenados por status
  And a ordem é: Aberto → Em Andamento → Reaberto → Fechado
  And cada agrupamento mostra sua contagem visual

---

@important
Scenario: Buscar tickets por título
  Given que estou na listagem de tickets
  And vejo um campo de busca (search box) no topo
  
  When digito "Erro ao fazer login" no campo de busca
  And pressiono Enter ou aguardo 500ms (autocomplete)
  
  Then a listagem filtra para mostrar apenas tickets com esse termo
  And os resultados destacam o termo pesquisado em amarelo: "**Erro** ao fazer **login**"
  And o contador mostra: "Mostrando 1 de 1 tickets"
  And a URL muda para: /tickets?search=erro+ao+fazer+login

---

Scenario: Buscar tickets por descrição
  Given que estou usando o campo de busca
  
  When digito "pagamento" (termo que está na descrição, não no título)
  Then a busca encontra tickets que contêm "pagamento" na descrição
  And o resultado mostra: "2 tickets encontrados"
  And o termo é destacado no resumo da descrição (prevew)

---

Scenario: Busca sem resultados
  Given que estou no campo de busca
  
  When digito "xyz123abc" (termo que não existe)
  And pressiono Enter
  
  Then a listagem exibe uma mensagem: "Nenhum ticket encontrado"
  And um ícone de "sem resultados" é mostrado
  And um botão "Limpar filtros" permite voltar à listagem completa

---

@mobile
Scenario: Listar tickets em mobile (responsividade)
  Given que estou em um dispositivo mobile (375px de largura)
  And que a página de listagem foi carregada
  
  When a página renderiza em mobile
  Then a tabela se adapta para o layout mobile:
    - Mostras apenas: ID, Título, Status (em cards verticais)
    - Prioridade e Data são mostradas ao expandir o card
  Or a tabela transforma em carousel horizontal scrollável
  Or exibe a lista como cards empilhados
  
  And cada card mostra:
    | Elemento  | Layout   |
    | ID        | #12345   |
    | Título    | Muito grande / wrapping |
    | Status    | Badge 🔴 |
    | Prioridade| Ícone 🟠 |
    | Versão de toque: tap para expandir detalhes |

---

Scenario: Carregar listagem com muitos tickets (performance)
  Given que existem 10.000 tickets no banco de dados
  And que a conexão está em 4G (simulado: 5Mbps download)
  
  When vou para a página de listagem
  Then a página carrega em menos de 3 segundos
  And os primeiros 10 tickets aparecem em menos de 1 segundo
  And a interatividade/cliques não lagam
  And ao clicar em "Próxima página", a próxima página carrega em < 2s

---

## ❌ CENÁRIOS NEGATIVOS (Error Cases)

@critical
Scenario: Tentar acessar listagem sem autenticação
  Given que NÃO estou autenticado no sistema
  And que vou manualmente para a URL: /tickets
  
  When a página tenta carregar
  Then sou redirecionado para: /login
  And vejo a mensagem: "Faça login para acessar a listagem de tickets"
  And nenhum dado de ticket é exibido

---

@critical
Scenario: Listar tickets quando a listagem está vazia
  Given que estou autenticado no sistema
  And que NÃO há nenhum ticket no banco de dados
  
  When vou para a página de listagem
  Then nenhuma tabela é exibida
  And vejo uma mensagem centralizada: "Nenhum ticket encontrado"
  And um ícone de caixa vazia é mostrado
  E um botão primário: "Criar Primeiro Ticket"
  
  When clico em "Criar Primeiro Ticket"
  Then sou redirecionado para: /tickets/create

---

Scenario: Erro ao carregar listagem de tickets (erro de servidor)
  Given que estou autenticado no sistema
  And que clico para ir à página de listagem
  
  When o servidor retorna erro HTTP 500
  Then vejo uma mensagem de erro: "Erro ao carregar listagem. Tente novamente."
  And um botão "Recarregar" é exibido
  And a nenhuma tabela é mostrada (apenas erro)
  
  When clico em "Recarregar"
  Then a página tenta carregar novamente
  And o servidor responde normalmente
  And a listagem é exibida corretamente

---

Scenario: Timeout ao carregar listagem com conexão lenta
  Given que estou em uma conexão de internet muito lenta (2G simulado)
  And que vou para a página de listagem
  
  When a requisição demora mais de 10 segundos
  Then vejo um spinner/loading indicator
  And uma mensagem: "Carregando tickets..."
  
  When o timeout de 30 segundos é atingido
  Then vejo uma mensagem: "A página está demorando. Verifique sua conexão"
  And um botão "Recarregar" permite tentar novamente

---

Scenario: Filtro com zero resultados
  Given que estou filtrando por Status = "Aberto" E Prioridade = "Crítica"
  And não há tickets que combinam esses critérios
  
  When a busca retorna
  Then vejo: "Nenhum ticket encontrado com os filtros aplicados"
  And a barra de filtros mostra: [Status: Aberto] [x] [Prioridade: Crítica] [x]
  And um botão "Limpar Filtros" permite voltar a ver todos

---

Scenario: Ordenação com campos nulos
  Given que alguns tickets não têm "Responsável" preenchido
  
  When ordeno por "Responsável"
  Then os tickets SEM responsável aparecem primeiro ou último (consistente)
  And não há erros vizuais (valores nulos não quebram layout)

---

Scenario: Paginação com filtro aplicado
  Given que apliquei filtro Status = "Aberto"
  And que resultam em 15 tickets
  And estou na página 1 (10 tickets)
  
  When clico em "Próxima página"
  Then vejo os tickets 11-15 com status "Aberto"
  And o número de páginas correto é mantido: "Página 2 de 2"
  And ao remover o filtro depois, voltamos ao total correto

---

Scenario: Busca com caracteres especiais
  Given que estou no campo de busca
  
  When digito caracteres especiais: "<script>alert('xss')</script>"
  And pressiono Enter
  
  Then a busca não quebra
  And nenhum código é executado (XSS protection)
  And a mensagem é: "Nenhum ticket encontrado"

---

Scenario: Atualização em tempo real da lista
  Given que tenho 2 abas abertas da listagem
  And ambas mostram 15 tickets
  
  When em outra sessão, um novo ticket é criado
  Then a Aba 1 não atualiza automaticamente (refresh manual esperado)
  
  When clico em "Atualizar" ou F5
  Then a listagem recarrega
  And agora mostra 16 tickets (o novo criado está visível)

---

Scenario: Remover múltiplos filtros mantendo estado
  Given que tenho aplicados 3 filtros:
    [Status: Aberto] [x]
    [Prioridade: Alta] [x]
    [Search: erro] [x]
  
  When clico em [x] do primeiro filtro (Status)
  Then apenas esse filtro é removido
  And os outros 2 permanecem ativos
  And a listagem é recarregada com os 2 filtros remanescentes
  And a URL reflete a mudança: ?priority=alta&search=erro

---

Scenario: Voltar na história do navegador (back button) mantém estado
  Given que estou em /tickets?status=aberto&page=2
  And tenho uma página já carregada
  
  When clico no botão "Voltar" do navegador
  Then volta para a página anterior
  When clico em "Avançar"
  Then retorna para /tickets?status=aberto&page=2
  And o estado (filtros, página) é restaurado sem recarregar a tabela

---

## 📊 DISTRIBUIÇÃO DE DADOS NA LISTA

Exemplo de como a listagem deve aparecer com 15 tickets:

```
┌─────┬──────────┬──────────────────────────┬─────────────┬──────────┬──────────────┬──────────┐
│ ID  │ Título   │ Status                   │ Prioridade  │ Data     │ Responsável  │ Ações    │
├─────┼──────────┼──────────────────────────┼─────────────┼──────────┼──────────────┼──────────┤
│12345│ Erro ao  │ 🔴 Aberto                │ 🔴 Crítica  │ 08 feb   │ 👤 João     │ 👁️ Ver |
│ * 5 │ fazer... │ (Criado há 2 min)       │             │ 14:35    │ (5.0)       │ ✏️ Editar│
├─────┼──────────┼──────────────────────────┼─────────────┼──────────┼──────────────┼──────────┤
│12344│ Botão    │ 🟡 Em Andamento         │ 🟠 Alta     │ 08 feb   │ 👤 Maria    │ 👁️ Ver |
│ * 4 │ não...   │ (1 hora)                │             │ 10:20    │ (4.7)       │ ✏️ Editar│
└─────┴──────────┴──────────────────────────┴─────────────┴──────────┴──────────────┴──────────┘
Mostrando 1-10 de 35 tickets | Página 1 de 4 | [◄ Anterior] [Próxima ►] | Mostrar [✓10] [25] [50]
```

---

## 🏷️ TAGS DE PRIORIDADE

@smoke       → Testes essenciais (10 min)
@critical    → Bugs bloqueadores (20 min)
@important   → Funcionalidades chave (40 min)
@mobile      → Responsividade mobile

---

## 📋 CHECKLIST DE EXECUÇÃO

Salvar em `testes-manuais/execution-logs/TC003-YYYY-MM-DD-executor.md`:

```markdown
# TC003 - Listar Tickets - Execution Log

**Data**: 2026-02-08
**Executor**: [Seu nome]
**Navegador**: [Chrome] - [131.0]
**Ambiente**: [staging]
**Tempo Total**: [45 min]

## Resumo
- [ ] Scenario 1 (Listar todos): ✅ PASSOU
- [ ] Scenario 2 (Filtrar por Status): ✅ PASSOU
- [ ] Scenario 3 (Paginação): ✅ PASSOU
- [ ] Scenario 4 (Ordenação): ✅ PASSOU
- [ ] Scenario 5 (Busca): ❌ FALHOU

## Bugs Encontrados
- BUG-003-listagem-filtro-prioridade-lag

## Status Final
✅ 85% PASSOU (17/20 cenários)
```

---

**Documento criado**: Fevereiro 2026
**Última atualização**: 2026-02-08
**Status**: 📋 Pronto para execução manual

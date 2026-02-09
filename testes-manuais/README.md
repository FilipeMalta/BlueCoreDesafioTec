# Testes Manuais - Helpdesk QA

**Versão**: 1.0  
**Data**: Fevereiro 2026  
**Status**: 📋 Documentação operacional  
**Responsável**: QA Manual Testing Team

---

## 📋 Índice

1. [Propósito dos Testes Manuais](#propósito-dos-testes-manuais)
2. [Quando Executar Testes Manuais](#quando-executar-testes-manuais)
3. [Estrutura dos Arquivos .feature (BDD/Gherkin)](#estrutura-dos-arquivos-feature-bddgherkin)
4. [Como Executar os Cenários Manualmente](#como-executar-os-cenários-manualmente)
5. [Template de Execução](#template-de-execução)
6. [Critérios de Aceite](#critérios-de-aceite)
7. [Como Reportar Bugs Encontrados](#como-reportar-bugs-encontrados)
8. [Checklist de Execução](#checklist-de-execução)

---

## Propósito dos Testes Manuais

### Qual é o objetivo?

**Testes manuais** complementam a automação. Enquanto testes automatizados validam **caminho feliz** e casos predefinidos, testes manuais exploram **cenários não mapeados**, **contextos humanos** e **edge cases**.

### Por que preciso de testes manuais?

```
┌─────────────────────────────────────────────────────────────┐
│                    PIRÂMIDE DE TESTES                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    🧑‍💻 MANUAL EXPLORATION                   │
│                    (Testes exploratórios)                   │
│                                                             │
│              👁️ VISUAL & UX TESTING                        │
│              (Responsividade, acessibilidade)              │
│                                                             │
│         ⚡ AUTOMATED E2E & API TESTS                       │
│         (Caminhos críticos, regressão)                    │
│                                                             │
│    🔧 UNIT TESTS                                           │
│    (Lógica, funções puras)                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tipos de Testes Manuais

| Tipo | Propósito | Público | Tempo |
|------|-----------|---------|-------|
| **Exploratório** | Descobrir bugs não mapeados | QA experiente | 1-2h |
| **Usabilidade** | Avaliar fluxo de UX | QA + UX designer | 2-3h |
| **Regressão Manual** | Validar áreas críticas pre-release | QA todos os níveis | 30-60min |
| **Compatibilidade** | Testar em browsers/devices não automatizados | QA | 1h |
| **Carga/Stress** | Comportamento sob carga (load testing) | QA experiente | 1h |
| **Acessibilidade** | WCAG compliance + screen readers | QA + accessibility expert | 1-2h |

---

## Quando Executar Testes Manuais

### Timeline Recomendado

```
DESENVOLVIMENTO
├─ Diariamente: Testes exploratórios (dev)
├─ Antes de PR: Testes de regressão manual (critical path)
│
PRÉ-RELEASE
├─ Staging: Testes de usabilidade + exploratório (QA)
├─ Antes de deploy: Regressão manual completa
│
PÓS-RELEASE
├─ Production: Smoke testing manual
├─ 24h após: Testes exploratórios em prod (com cuidado)
```

### Prioridade

```
🔴 CRÍTICO (Sempre fazer)
- Login/Autenticação
- Criar/Deletar Ticket
- Relatório de bugs críticos

🟠 IMPORTANTE (Fazer antes de release)
- Filtros e busca
- Edição de tickets
- Notificações

🟡 DESEJÁVEL (Quando há tempo)
- Edge cases
- Performance visual
- Compatibilidade mobile
```

---

## Estrutura dos Arquivos .feature (BDD/Gherkin)

### O que é Gherkin?

**Gherkin** é linguagem natural estruturada que permite **não-técnicos** entenderem testes.

```
Given        = PRÉ-CONDIÇÃO (estado inicial)
When         = AÇÃO (o que o usuário faz)
Then         = RESULTADO (o que deve acontecer)
And          = Continuar a condição/ação/resultado anterior
But          = Negar a condição anterior
```

### Template Básico

```gherkin
# features/helpdesk/01-criar-ticket.feature
Feature: Criar Ticket
  Descrição do que o sistema deve fazer

  Scenario: Descripção do cenário
    Given     Pré-condição 1
    And       Pré-condição 2
    When      Ação que o usuário faz
    And       Outra ação
    Then      Resultado esperado 1
    And       Resultado esperado 2
```

### Exemplo Real: Criar Ticket

```gherkin
# features/helpdesk/01-criar-ticket.feature
Feature: Criar Novo Ticket
  Como usuário do Helpdesk
  Quero criar um ticket de suporte
  Para relatar um problema/solicitação

  Background:
    Given que estou autenticado como "user@example.com"
    And estou na página de listagem de tickets

  Scenario: Criar ticket com dados válidos
    When clico no botão "Criar Novo Ticket"
    And preencho o formulário com:
      | Campo       | Valor               |
      | Título      | Pagamento falhou    |
      | Descrição   | Erro ao processar   |
      | Prioridade  | Alta                |
      | Categoria   | Pagamento           |
    And clico em "Enviar"
    Then vejo a mensagem "Ticket criado com sucesso"
    And sou redirecionado para a página de detalhes do ticket
    And o ticket aparece na lista com status "Aberto"

  Scenario: Título é obrigatório
    When clico em "Criar Novo Ticket"
    And deixo o título vazio
    And tento enviar o formulário
    Then vejo a mensagem de erro "Título é obrigatório"
    And o botão "Enviar" permanece desabilidado

  Scenario: Descrição deve ter mínimo 10 caracteres
    When clico em "Criar Novo Ticket"
    And preencho o título com "Teste"
    And digito apenas "12345" na descrição
    Then vejo o erro "Mínimo 10 caracteres"
    And o botão "Enviar" fica desabilitado

  Scenario: Criar ticket com anexo
    When clico em "Criar Novo Ticket"
    And preencho o formulário com dados válidos
    And clico em "Adicionar Anexo"
    And seleciono o arquivo "screenshot.png"
    And clico em "Enviar"
    Then o ticket é criado com o anexo
    And consigo baixar o arquivo na página de detalhes

  @smoke @critical
  Scenario: Cancelar criação mantém rascunho
    When clico em "Criar Novo Ticket"
    And preencho o título com "Meu problema"
    And clico em "Cancelar"
    Then sou retornado à lista de tickets
    When clico em "Criar Novo Ticket" novamente
    Then o rascunho "Meu problema" ainda está preenchido
```

### Estrutura de Diretórios

```
testes-manuais/
├── README.md (este arquivo)
├── features/
│   ├── helpdesk/
│   │   ├── 01-criar-ticket.feature
│   │   ├── 02-atualizar-status.feature
│   │   ├── 03-listar-tickets.feature
│   │   ├── 04-filtrar-pesquisar.feature
│   │   ├── 05-editar-ticket.feature
│   │   ├── 06-deletar-ticket.feature
│   │   ├── 07-adicionar-comentario.feature
│   │   └── 08-autenticacao.feature
│   └── mobile/
│       ├── 01-responsividade.feature
│       └── 02-touch-interactions.feature
├── execution-logs/
│   ├── 2026-02-08-user1.md
│   └── 2026-02-08-user2.md
└── bug-reports/
    ├── BUG-001-login-timeout.md
    └── BUG-002-filter-unicode.md
```

### Boas Práticas ao Escrever .feature

**✅ BOM**: Claro, objetivo, testável

```gherkin
Scenario: Criar ticket com prioridade alta
  When preencho o título com "Servidor offline"
  And seleciono prioridade "Alta"
  And clico em "Enviar"
  Then vejo mensagem de sucesso
  And o ticket mostra prioridade "Alta" no detalhe
```

❌ **RUIM**: Ambíguo, múltiplas responsabilidades

```gherkin
Scenario: Sistema funciona quando criei um ticket importante
  When faço tudo certo no formulário e mando salvar
  Then tudo funciona bem e nada quebra
```

---

## Como Executar os Cenários Manualmente

### Pré-requisitos

- [ ] Acesso à aplicação (URL, credenciais)
- [ ] Navegador atualizado (Chrome, Firefox, Safari)
- [ ] Arquivo `.feature` disponível
- [ ] Template de execução preenchido
- [ ] Ferramenta para reportar (GitHub Issues)

### Passo a Passo

#### 1️⃣ Selecionar Cenário

Escolha um arquivo `.feature` e um `Scenario`.

```bash
# Exemplo: testes-manuais/features/helpdesk/01-criar-ticket.feature
# Cenário: "Criar ticket com dados válidos"
```

#### 2️⃣ Preparar Ambiente (Background)

Execute as pré-condições (Background):

```gherkin
Background:
  Given que estou autenticado como "user@example.com"
  And estou na página de listagem de tickets
```

**Acionáveis**:
- [ ] Abrir navegador
- [ ] Ir para `https://helpdesk.com`
- [ ] Fazer login com `user@example.com` / `password123`
- [ ] Verificar que estou na listagem de tickets

#### 3️⃣ Executar Passos (Steps)

**When** = Ações do usuário

```gherkin
When clico no botão "Criar Novo Ticket"
And preencho o formulário com:
  | Campo       | Valor             |
  | Título      | Pagamento falhou  |
  | Descrição   | Erro ao processar |
```

**Acionáveis**:
- [ ] Localizar e clicar no botão "Criar Novo Ticket"
- [ ] Preencher campo "Título" com "Pagamento falhou"
- [ ] Preencher campo "Descrição" com "Erro ao processar"

#### 4️⃣ Validar Resultados (Then)

**Then** = O que deve acontecer

```gherkin
Then vejo a mensagem "Ticket criado com sucesso"
And sou redirecionado para a página de detalhes do ticket
```

**Validações**:
- [ ] Mensagem "Ticket criado com sucesso" aparece ✨
- [ ] URL muda para `/tickets/{id}` 🔗
- [ ] Detalhes do ticket são exibidos 📄

#### 5️⃣ Documentar Resultado

Preencher template com:
- ✅ **PASSOU**: Todos os "Then" validados
- ❌ **FALHOU**: Qual "Then" não foi validado
- 🟡 **PARCIAL**: Comportamento inesperado

---

## Template de Execução

### Formato: Markdown

Salvar cada execução em `testes-manuais/execution-logs/YYYY-MM-DD-username.md`

```markdown
# Execução de Testes Manuais

**Data**: 2026-02-08
**Executor**: João Silva
**Navegador**: Chrome 131.0
**Ambiente**: Staging
**Tempo Total**: 45 minutos

---

## 1. Criar Ticket com Dados Válidos

**Feature**: 01-criar-ticket.feature  
**Scenario**: Criar ticket com dados válidos  
**Status**: ✅ PASSOU

### Passo a Passo

| Passo | Ação | Resultado Esperado | Resultado Real | Status |
|-------|------|-------------------|----------------|--------|
| 1 | Fazer login | Redirecionado para dashboard | Redirecionado corretamente | ✅ |
| 2 | Clique "Criar Ticket" | Formulário abre | Abriu em modal | ✅ |
| 3 | Preencher título | Campo aceita texto | Aceitou "Pagamento falhou" | ✅ |
| 4 | Preencher descrição | Campo com 10+ chars | Aceitou 50 caracteres | ✅ |
| 5 | Selecionar prioridade | Dropdown abre | Abriu com 4 opções | ✅ |
| 6 | Clicar "Enviar" | Mensagem de sucesso | "Ticket criado!" apareceu | ✅ |
| 7 | Verificar redirecionamento | Ir para detalhe do ticket | Redireciona para `/tickets/123` | ✅ |
| 8 | Verificar dados | Dados aparecem no detalhe | Título, descr, prioridade corretos | ✅ |

### Observações
Tudo funcionou corretamente. Formulário é intuitivo.

### Screenshots/Evidências
- [Captura 1: Formulário preenchido](evidence/1.png)
- [Captura 2: Sucesso](evidence/2.png)

---

## 2. Título é Obrigatório

**Feature**: 01-criar-ticket.feature  
**Scenario**: Título é obrigatório  
**Status**: ❌ FALHOU

### Passo a Passo

| Passo | Ação | Resultado Esperado | Resultado Real | Status |
|-------|------|-------------------|----------------|--------|
| 1 | Abrir form | Formulário em branco | Abriu com sucesso | ✅ |
| 2 | Deixar título vazio | Campo de título vazio | Vazio corretamente | ✅ |
| 3 | Preencher descrição | Descrição com texto | "Teste de validação" | ✅ |
| 4 | Clicar "Enviar" | Erro "Título obrigatório" | **Nenhum erro aparece** | ❌ |
| 5 | Botão enviar | Deve estar desabilitado | **Botão ainda está habilitado** | ❌ |

### Bug Encontrado
🐛 **BUG-001**: Validação de campo obrigatório não funciona
- Campo "Título" permite enviar sem dados
- Botão "Enviar" não é desabilitado quando título está vazio
- Não há mensagem de erro inline no formulário

### Screenshots/Evidências
- [Captura: Form sem validação](evidence/bug-001.png)

---

## 3. Descrição Mínimo 10 Caracteres

**Feature**: 01-criar-ticket.feature  
**Scenario**: Descrição deve ter mínimo 10 caracteres  
**Status**: 🟡 PARCIAL

### Passo a Passo

| Passo | Ação | Resultado Esperado | Resultado Real | Status |
|-------|------|-------------------|----------------|--------|
| 1 | Preench título | Título válido | "Meu problema" | ✅ |
| 2 | Digitar 5 chars | Deve rejeitar | "teste" foi aceito | ❌ |
| 3 | Validação inline | Erro sob campo | Não há erro visível | ❌ |
| 4 | Contador de chars | Mostra "5/10" | Não há contador | ❌ |

### Observação
Validação de minLength não está implementada. Campo aceita qualquer tamanho.

---

## Resumo

| Cenário | Status | Bugs |
|---------|--------|------|
| Criar com dados válidos | ✅ | - |
| Título obrigatório | ❌ | BUG-001 |
| Descrição minLength | 🟡 | Sem validação |

**Total**: 3 cenários, 2 bugs encontrados
**Ações**: Reportar issues no GitHub para dev

---

**Assinado**: João Silva  
**Data**: 2026-02-08 14:30  
**Tempo**: 45 min
```

### Template Simplificado (Quick Check)

Para execução rápida:

```markdown
# Quick Manual Test - 2026-02-08

**Executor**: Maria  
**Cenário**: Login

| Step | Action | Status |
|------|--------|--------|
| 1 | Ir para login | ✅ |
| 2 | Email + senha válidos | ✅ |
| 3 | Clicar "Entrar" | ✅ |
| 4 | Vejo dashboard | ✅ |

**Resultado**: ✅ PASSOU
**Bugs**: Nenhum
```

---

## Critérios de Aceite

### Para cada Scenario, validar:

#### ✅ PASSOU (Green)
- [ ] **Todos** os "Then" foram validados com sucesso
- [ ] Comportamento matches spec
- [ ] Sem erros console/network
- [ ] UI responsiva e rápida

#### ❌ FALHOU (Red)
- [ ] Um ou mais "Then" **não** validados
- [ ] Comportamento não matches spec
- [ ] Erro visual ou funcional
- [ ] **DEVE** reportar como bug

#### 🟡 PARCIAL (Yellow)
- [ ] Comportamento parcialmente correto
- [ ] Comportamento não esperado mas "aceitável"
- [ ] Pode ser melhorado, não é blocker
- [ ] Exemplos:
  - Mensagem de sucesso demora 2s (esperado: 0.5s)
  - Campo de busca case-sensitive (esperado: case-insensitive)
  - Mobile: botão pequeno (esperado: 44px mínimo)

### Checklist por Tipo de Teste

#### Teste Exploratório
- [ ] Tentei fluxos não documentados?
- [ ] Testei combinações inusitadas?
- [ ] Validei performance (load time)?
- [ ] Testei em diferentes navegadores?
- [ ] Verifiquei mensagens de erro?

#### Teste de Usabilidade
- [ ] Interface é intuitiva?
- [ ] Textos estão claros?
- [ ] Ícones são compreensíveis?
- [ ] Botões são fáceis de clicar?
- [ ] Fluxo faz sentido lógico?

#### Teste de Regressão
- [ ] Feature A ainda funciona?
- [ ] Feature B não foi impactada?
- [ ] Integração ainda OK?
- [ ] Performance não degradou?
- [ ] Banco de dados em estado limpo?

---

## Como Reportar Bugs Encontrados

### Quando Reportar

- ❌ Teste marcado como **FALHOU**
- 🟡 Comportamento **PARCIAL** que afeta UX
- 🔴 Regressão (algo que funciona antes agora quebrou)
- ⚠️ Erro console/network (mesmo que pareça funcionar)

### Criar GitHub Issue

**Título (Conciso, acionável)**:
```
❌ BUG: Validação de título não funciona ao criar ticket
```

**Template (Preencher tudo)**:

```markdown
## 📋 Descrição do Bug

Ao criar um novo ticket, deixando o título vazio, o sistema permite enviar 
o formulário sem exibir erro.

## 🔴 Severidade
- [ ] CRÍTICA (bloqueia feature)
- [x] ALTA (funcionalidade quebrada)
- [ ] MÉDIA (afeta user experience)
- [ ] BAIXA (cosmético)

## 🔍 Passos para Reproduzir

1. Fazer login em staging
2. Ir para "Criar Ticket"
3. Deixar campo "Título" vazio
4. Preencher "Descrição" com texto válido
5. Clicar "Enviar"

## ❌ Resultado Esperado

- Mensagem de erro "Título é obrigatório"
- Botão "Enviar" desabilitado/greyed out
- Foco no campo de título

## ❌ Resultado Atual

- Formulário é submetido sem erro
- Ticket é criado com título vazio
- Não há indicação visual de que título é obrigatório

## 🖼️ Screenshots

[Anexar captura de tela do formulário]

## 📝 Informações Técnicas

- **Navegador**: Chrome 131.0
- **SO**: Windows 11
- **Ambiente**: Staging
- **Data**: 2026-02-08 14:30
- **URL**: https://staging-helpdesk.com/tickets/create

## 🔗 Referências

- Spec: docs/01-estrategia-qa.md (section Criteria)
- Feature: testes-manuais/features/helpdesk/01-criar-ticket.feature
- Executor: João Silva

## ✅ DoD (Definition of Done)

- [ ] Desenvolvedor investigou
- [ ] Root cause identificada
- [ ] Fix implementado
- [ ] QA validou o fix
- [ ] Goes to production
```

### Padrão de Nomenclatura

```
BUG-{numero}-{feature}-{descrição}

Exemplos:
- BUG-001-criar-ticket-validacao-titulo
- BUG-002-login-timeout-erro-generico
- BUG-003-mobile-responsividade-botoes
```

### Prioridade do Bug

| Prioridade | Quando | Exemplos |
|-----------|--------|----------|
| 🔴 **P0** | Bloqueia feature crítica | Login não funciona, Dados perdidos |
| 🔴 **P1** | Bloqueia funcionalidade | Botão não responde, Validação quebrada |
| 🟠 **P2** | Afeta UX significativamente | Lentidão, Mensagem confusa |
| 🟡 **P3** | Cosmético ou edge case | Typo, Espaçamento errado |

---

## Checklist de Execução

### Antes de Começar

```markdown
## PRÉ-EXECUÇÃO

Data: 2026-02-08
Executor: [Seu nome]

- [ ] Ambiente está funcionando (https://helpdesk.com)
- [ ] Tenho credenciais de teste válidas
- [ ] Navegador está atualizado
- [ ] .feature files foram lidas
- [ ] Tenho acesso para reportar issues
- [ ] Console do navegador está aberto (F12)
```

### Durante a Execução

```markdown
## DURANTE

Cenário: [Nome]

- [ ] Executei Background corretamente
- [ ] Testei cada Given/When/Then
- [ ] Documentei resultados em tempo real
- [ ] Tirei screenshots de comportamentos inesperados
- [ ] Verifiquei console por erros
- [ ] Testei em pelo menos 2 navegadores
```

### Depois de Terminar

```markdown
## PÓS-EXECUÇÃO

- [ ] Preenchei execution log
- [ ] Reportei bugs encontrados
- [ ] Adicionei screenshots/evidências
- [ ] Assinei com nome e data
- [ ] Fiz commit dos arquivos:
  git add testes-manuais/execution-logs/
  git commit -m "Manual tests: 2026-02-08 - João Silva"
```

---

## Dicas Práticas

### ⚡ Otimizar Tempo

```bash
# Teste rápido (15 min)
- 3-4 cenários críticos
- Apenas caminho feliz
- Sem screenshots detalhadas

# Teste completo (45 min)
- 10-15 cenários
- Happy path + sad paths
- Screenshots de bugs
- Anotações de UX

# Teste exploratório (90 min)
- Testar além do spec
- Combinar comportamentos
- Performance testing
- Acessibilidade spot check
```

### 🔍 Encontrar Bugs Mais Rapidamente

```
1. Pensar como usuário final
   - Por que ele faria X?
   - O que faria mal?
   
2. Testar limites
   - Campo vazio
   - Caracteres especiais
   - Números muito grandes
   
3. Testar integrações
   - Criar → Editar → Deletar
   - Criar → Filtrar → Buscar
   
4. Verificar Performance
   - Carregamento lento?
   - Lag ao clicar?
   
5. Validar Mensagens
   - São claras?
   - São em português correto?
```

### 📸 Boas Screenshots

```
✅ BOM
- Mostra o ponto específico do bug
- Inclui URL e dados relevantes
- Legítivel (não 10pt font)

❌ RUIM
- Tela inteira sem zoom
- Sem contexto (qual página?)
- Não mostra o problema
```

---

## FAQ - Perguntas Frequentes

### P: Preciso saber programar para fazer teste manual?
**R**: Não! Testes manuais são executados manualmente no navegador. Basta entender Gherkin (Given/When/Then).

### P: Qual a diferença entre teste manual e automação?
**R**: 
| Manual | Automação |
|--------|-----------|
| Humano clica | Script clica |
| Demora mais | Demora menos |
| Explora edge cases | Valida casos conhecidos |
| Vê UX | Valida lógica |

### P: Quantos bugs devo encontrar?
**R**: Depende do escopo. Nos guiamos por:
- Feature nova: 3-5 bugs (baixo risco)
- Feature complexa: 5-10 bugs (médio risco)
- Integração: 2-3 bugs (alto impacto)

### P: Devo reportar typos?
**R**: Sim, mas com prioridade BAIXA (P3). Exemplos:
- "Tiulo do ticket" (deveria ser "Título")
- Espaçamento inconsistente
- Ícones desalinhados

### P: E se quebrei algo ao testar?
**R**: Não há problema! Reporte normalmente:
1. Documentar exatamente o que fez
2. Passar URL e dados
3. Dev consegue replicar e investigar

### P: Tenho que testar em mobile?
**R**: Idealmente sim, mas:
- Chrome DevTools (responsividade)
- Telefone real (performance, toque)
- Mínimo: 2 breakpoints (mobile 375px, tablet 768px)

---

## Recursos Úteis

- 📖 **Gherkin Syntax**: https://cucumber.io/docs/guides/writing-gherkin/
- 🎯 **BDD Best Practices**: https://cucumber.io/docs/bdd/
- 🔧 **Playwright Inspector**: `npx playwright codegen https://helpdesk.com`
- 📊 **Google Sheets Template**: [Link da planilha compartilhada]

---

## Suporte

**Dúvidas sobre**:

- 📋 Estrutura dos testes → Veja `features/*.feature`
- 🎯 Como reportar → Veja seção "Como Reportar Bugs"
- ⏱️ Tempo de execução → Depende de escopo (15-90 min)
- 🉐 Linguagem → Sempre português (Brasil)

**Contato**: QA Team (#qa-manual no Slack)

---

**Documento aprovado**: Fevereiro 2026  
**Próxima revisão**: Abril 2026  
**Responsável**: QA Lead

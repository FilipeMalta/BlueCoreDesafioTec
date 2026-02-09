# BlueCoreDesafioTec - QA Automation Portfolio

> Estratégia e automação de testes profissional para sistema **Helpdesk** (gerenciamento de tickets)

### Badges

<div align="center">

![TypeScript](https://img.shields.io/badge/TypeScript-5.9%2B-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Playwright](https://img.shields.io/badge/Playwright-1.58%2B-45B7D1?style=flat-square&logo=playwright&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=flat-square&logo=node.js&logoColor=white)
![npm](https://img.shields.io/badge/npm-v10%2B-CB3837?style=flat-square&logo=npm&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-green?style=flat-square)
![License](https://img.shields.io/badge/License-ISC-yellow?style=flat-square)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)](/.github/workflows/tests.yml)
![Last Updated](https://img.shields.io/badge/Last%20Updated-Feb%202026-blue?style=flat-square)

</div>

---

## 📑 Índice de Conteúdo

- [Visão Geral](#-visão-geral)
- [Funcionalidades do Sistema](#-funcionalidades-do-sistema)
- [Estratégia de QA](#️-estratégia-de-qa)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Tecnologias Utilizadas](#️-tecnologias-utilizadas)
- [Requisitos & Instalação](#-requisitos--instalação)
- [Como Executar os Testes](#-como-executar-os-testes)
- [Todos os Comandos npm](#-todos-os-comandos-npm)
- [Automação Implementada](#️-automação-implementada)
- [Cobertura de Testes](#-cobertura-de-testes)
- [Pipeline CI/CD](#-pipeline-cicd)
- [Screenshots & Exemplos](#-screenshots--exemplos)
- [Próximas Melhorias](#-próximas-melhorias)
- [Documentação Complementar](#-documentação-complementar)
- [Como Contribuir](#-como-contribuir)
- [Dúvidas & Suporte](#-dúvidas--suporte)
- [Licença](#-licença)

---

## 📋 Visão Geral

Este projeto implementa uma **estratégia completa de QA** para um sistema de gerenciamento de tickets (Helpdesk), combinando análise de riscos, cases de teste manuais e **automação robusta** com Playwright + TypeScript.

**Objetivo**: Garantir qualidade, confiabilidade e performance do sistema através de testes estruturados e automatizados.

---

## 🎯 Funcionalidades do Sistema

O sistema Helpdesk a ser testado oferece:

| Feature | Descrição | Prioridade |
|---------|-----------|-----------|
| **Criar Ticket** | Criar novo ticket com título, descrição, prioridade e categoria | 🔴 Critical |
| **Listar Tickets** | Exibir lista de tickets com filtros (status, prioridade, data) | 🔴 Critical |
| **Consultar Ticket** | Visualizar detalhes completos de um ticket por ID | 🔴 Critical |
| **Atualizar Status** | Alterar status do ticket (open → in-progress → resolved → closed) | 🔴 Critical |
| **Editar Ticket** | Modificar título, descrição, prioridade de um ticket | 🟠 High |
| **Deletar Ticket** | Remover ticket do sistema | 🟠 High |
| **Comentários** | Adicionar/visualizar comentários em tickets | 🟡 Medium |
| **Busca** | Pesquisar tickets por título/descrição | 🟡 Medium |

---

## 🛡️ Estratégia de QA

### Análise de Riscos - Principais Vulnerabilidades Identificadas

#### 🔴 Riscos Críticos
- **Perda de dados**: Deleção sem confirmação ou sem backup
- **Concorrência**: Múltiplos usuários editando mesmo ticket
- **Validação de input**: Injeção SQL, XSS em comentários/descrição
- **Autenticação**: Acesso não autorizado a tickets de outros usuários
- **Performance**: Timeout em listas com 10k+ tickets

#### 🟠 Riscos Moderados
- **Estado inconsistente**: Transições de status inválidas
- **UI/UX**: Elementos não responsivos em mobile
- **Integração**: Falhas em comunicação com backend
- **Relatórios**: Dados inconsistentes em exports

#### 🟡 Riscos Baixos
- **Acessibilidade**: Falta de suporte a screen readers
- **Compatibilidade**: Browsers antigos (IE11, etc)

**Status**: Detalhado em [docs/analise-riscos.md](docs/analise-riscos.md)

### Tipos de Testes Essenciais

```yaml
Camadas de Teste:
  Unitários:
    - Validadores (email, telefone, data)
    - Formatadores de string/data
    - Lógica de cálculo de prioridade
    Cobertura: 80%+

  Integração:
    - API ↔ Banco de dados
    - Serviços de notificação
    - Autenticação/Autorização
    Cobertura: 60%+

  E2E (UI):
    - Fluxos completos de usuário
    - Interações críticas
    - Testes em múltiplos browsers
    Cobertura: 40% (casos críticos)

  API:
    - Validação de endpoints
    - Tratamento de erros HTTP
    - Contrato de payload
    Cobertura: 70%+

  Regressão:
    - Suite de testes após deploy
    - Valida funcionalidades existentes
    - Roda em todo push para main
    
  Exploratórios:
    - Descoberta de edge cases
    - Cenários inesperados
    - Manual (~2h/sprint)
```

### Priorização de Automação - Justificativa Técnica

**Automação prioritária (ROI Alto):**
1. ✅ Criar ticket → Fluxo crítico, executado 100x/dia, determinístico
2. ✅ Atualizar status → Casos de teste variados, regressão frequente
3. ✅ Listar & Filtrar → Complexidade lógica alta, fácil quebrar
4. ✅ Validações de input → Deve falhar consistentemente
5. ✅ API de tickets → Consumida por múltiplos clientes

**Automação secundária (ROI Médio):**
- Comentários e interações de UI
- Testes de performance
- Testes mobile (smoke test apenas)

**Não automatizar (ROI Baixo):**
- Design visual (usar testes manuais)
- Upload de arquivos pesados
- Interações com auth externa (SSO)

---

## 📁 Estrutura do Projeto

```
BlueCoreDesafioTec/
├── .github/
│   └── workflows/
│       └── tests.yml                    # ✨ Pipeline CI/CD (GitHub Actions)
│
├── docs/
│   ├── analise-riscos.md                # 🛡️ Análise de riscos técnicos
│   ├── estrategia-testes.md             # 📋 Estratégia QA detalhada
│   └── matriz-rastreabilidade.md        # 🔗 Requisitos ↔ Testes
│
├── tests/
│   ├── e2e/
│   │   └── tickets/
│   │       ├── criar-ticket.spec.ts     # ✅ TC-001: Criação de tickets (10 cenários)
│   │       ├── atualizar-status.spec.ts # ✅ TC-002: Atualização de status (10 cenários)
│   │       ├── ticket-listing.spec.ts   # ⏳ TC-003: Listagem e filtros (27 cenários)
│   │       └── ticket-details.spec.ts   # ⏳ TC-004: Detalhes de ticket (20 cenários)
│   │
│   ├── api/
│   │   ├── tickets.api.spec.ts          # 🔌 Testes de API REST
│   │   ├── validations.spec.ts          # ✓ Validação de payloads
│   │   └── error-handling.spec.ts       # ❌ Testes de erro
│   │
│   ├── pages/ (Page Object Model)
│   │   ├── BasePage.ts                  # 🏗️ Classe base (25 métodos comuns)
│   │   ├── TicketsPage.ts               # 📋 Listagem de tickets (20 métodos)
│   │   ├── CriarTicketPage.ts           # ➕ Criação de tickets (21 métodos)
│   │   ├── DetalhesTicketPage.ts        # 🔍 Detalhes de ticket (24 métodos)
│   │   └── LoginPage.ts                 # 🔐 Login (quando implementado)
│   │
│   ├── fixtures/
│   │   ├── test-data.ts                 # 📊 Dados de teste (5 válidos + 8 inválidos)
│   │   └── mock-responses.ts            # 🤖 Respostas mockadas (quando necessário)
│   │
│   └── utils/
│       ├── helpers.ts                   # 🛠️ 18 funções auxiliares
│       ├── api-client.ts                # 🌐 Cliente HTTP
│       └── logger.ts                    # 📝 Logger colorido
│
├── playwright.config.ts                 # ⚙️ Configuração Playwright
├── tsconfig.json                        # 🔧 TypeScript config
├── package.json                         # 📦 Dependências npm
├── package-lock.json                    # 🔒 Versões travadas
├── .env.example                         # 📋 Variáveis de ambiente
├── .gitignore                           # 🚫 Git exclusões
├── .prettier.json                       # 💅 Prettier config
├── .eslintrc.json                       # 🔍 ESLint config
├── PLAYWRIGHT_CONFIG.md                 # 📚 Guia de configuração
├── SCRIPTS.md                           # 📜 Scripts npm
└── README.md                            # 📖 Este arquivo
```

**Resumo de Arquivos Criados:**
- ✅ 4 Page Objects com 90+ métodos
- ✅ 2 arquivos de fixtures com testes e helpers
- ✅ 2 arquivos E2E com 20 cenários
- ✅ Pipeline CI/CD completo
- `⏳` = Em desenvolvimento

---

## 🛠️ Tecnologias Utilizadas

### Core Testing Framework
- **Playwright 1.58+** - Automação cross-browser robusta
- **TypeScript 5.9** - Type safety e DX melhorada
- **Jest/Playwright Test** - Test runner e assertions

### Architecture & Patterns
- **Page Object Model (POM)** - Manutenção facilitada
- **Test Fixtures** - Dados reutilizáveis
- **Helper Functions** - DRY principle
- **Custom Page Base** - Abstração de operações comuns

### Reporters & Analysis
- **HTML Reporter** - Relatórios visuais com screenshots/videos
- **JSON Reporter** - Integração com CI/CD
- **List Reporter** - Output em terminal

### Environment & Tools
- **Node.js 20+** - Runtime
- **npm** - Package manager
- **Git** - Version control
- **GitHub Actions** - CI/CD pipeline

---

## �️ Requisitos & Instalação

### Pré-requisitos

Antes de começar, certifique-se de ter instalado:

| Requisito | Versão Mínima | Status |
|-----------|---------------|--------|
| **Node.js** | 18.x | ✅ Obrigatório |
| **npm** | 9.x | ✅ Obrigatório |
| **Git** | 2.x | ✅ Obrigatório |
| **Navegador** | Qualquer | ✅ Playwright instala |

```bash
# Verificar versões instaladas
node --version    # Esperado: v18.0.0 ou superior
npm --version     # Esperado: v9.0.0 ou superior
git --version     # Esperado: git version 2.x
```

### Instalação Passo a Passo

#### 1️⃣ Clone o Repositório

```bash
# Via HTTPS
git clone https://github.com/FilipeMalta/BlueCoreDesafioTec.git
cd BlueCoreDesafioTec

# Via SSH (se configurado)
git clone git@github.com:FilipeMalta/BlueCoreDesafioTec.git
cd BlueCoreDesafioTec
```

#### 2️⃣ Instale Dependências

```bash
# Instalar todas as dependências (usa package-lock.json)
npm ci --prefer-offline --no-audit

# Ou se quiser usar package.json direto
npm install
```

**Dependências principais instaladas:**
- `@playwright/test` - Framework de testes
- `typescript` - Tipagem estática
- `prettier` - Code formatter
- `eslint` - Code linter

#### 3️⃣ Configure Variáveis de Ambiente

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar com seus valores
nano .env  # ou use seu editor favorito
```

**Variáveis disponíveis (.env):**
```bash
# URL base da aplicação
BASE_URL=http://localhost:3000

# Timeout padrão (ms)
PLAYWRIGHT_TIMEOUT=30000

# Número de retries
PLAYWRIGHT_RETRIES=2

# Log level
LOG_LEVEL=info
```

#### 4️⃣ Instale Browsers do Playwright

```bash
# Instalar browsers (chromium, firefox, webkit)
npx playwright install

# Instalar dependências do SO (Linux apenas)
npx playwright install-deps

# Verificar que tudo foi instalado
npx playwright install-deps && npx playwright test --version
```

**Browsers instalados:**
- ✅ Chromium (base para Chrome/Edge)
- ✅ Firefox
- ✅ WebKit (base para Safari)
- ✅ Mobile Chrome (Pixel 5)
- ✅ Mobile Safari (iPhone 12)

#### 5️⃣ Verifique a Instalação

```bash
# Rodar um teste simples para validar setup
npm run test:e2e -- --project chromium --headed --reporter list

# Output esperado:
# ✓  [chromium] › tests/e2e/tickets/criar-ticket.spec.ts
```

---

## 🚀 Como Executar os Testes

### Execução Básica

```bash
# Rodar TODOS os testes (E2E + API)
npm test

# Apenas E2E no modo headless (recomendado para CI)
npm run test:e2e

# Apenas API
npm run test:api

# Apenas um arquivo específico
npm run test:e2e -- tests/e2e/tickets/criar-ticket.spec.ts
```

### Modo Debug & Desenvolvimento

```bash
# UI Mode (Dashboard interativo - RECOMENDADO para desenvolvimento)
npm run test:ui

# Modo Headed (com navegador visível)
npm run test:headed

# Com Inspector (debug interativo)
npm run test:debug

# Ver relatório HTML dos últimos testes
npm run report
```

### Testes Específicos

```bash
# Rodar um teste pelo nome (grep)
npx playwright test -g "must update status"

# Apenas no Chromium
npx playwright test --project chromium

# Apenas Firefox
npx playwright test --project firefox

# Com trace (gravação de eventos do browser)
npx playwright test --trace on

# Gerar trace zip file
npx playwright test --trace retain-on-failure
```

### Exemplos Práticos

```bash
# 1️⃣ Developing novo teste (vê em tempo real)
npm run test:ui -- tests/e2e/tickets/criar-ticket.spec.ts

# 2️⃣ Debugar por que um teste falhou
npm run test:debug -- -g "should create ticket with valid data"

# 3️⃣ Rodar tudo antes de fazer commit
npm run test:ci

# 4️⃣ Rodar apenas suíte crítica (fast feedback)
npx playwright test tests/e2e/tickets/criar-ticket.spec.ts --reporter list

# 5️⃣ Video + Screenshot em falha (para bug report)
npx playwright test --headed --reporter html
```

---

## 🎯 Todos os Comandos npm

Complete list de scripts disponíveis em `package.json`:

### Testes

| Comando | Descrição | Uso |
|---------|-----------|-----|
| `npm test` | Rodar todos os testes (E2E + API) | CI/CD & pré-commit |
| `npm run test:e2e` | Rodar apenas testes E2E | Desenvolvimento |
| `npm run test:api` | Rodar apenas testes API | Desenvolvimento |
| `npm run test:e2e:create` | Só testes de criação | Iteração rápida |
| `npm run test:e2e:status` | Só testes de status | Iteração rápida |
| `npm run test:ui` | Dashboard interativo | Desenvolvimento |
| `npm run test:headed` | Com navegador visível | Debug |
| `npm run test:debug` | Com Inspector ativo | Deep debugging |
| `npm run test:ci` | Para CI/CD (com retries) | GitHub Actions |

### Linting & Formatação

| Comando | Descrição |
|---------|-----------|
| `npm run lint` | Rodar ESLint em todos .ts |
| `npm run lint:fix` | Corrigir problemas automaticamente |
| `npm run format` | Rodar Prettier (formato) |
| `npm run format:check` | Verificar formatação |
| `npm run format:fix` | Corrigir formatação |

### Relatórios

| Comando | Descrição |
|---------|-----------|
| `npm run report` | Abrir HTML report no browser |
| `npm run report:create` | Gerar relatório de criação |
| `npm run report:status` | Gerar relatório de status |

### Utilidade

| Comando | Descrição |
|---------|-----------|
| `npm run clean` | Limpar resultados de testes |
| `npm run install-browsers` | Instalar navegadores Playwright |

---

## ✅ Automação Implementada

### E2E Tests - Testes End-to-End (Interface)

| Feature | Testes | Status | Cenários |
|---------|--------|--------|----------|
| **Criar Ticket** | ✅ criar-ticket.spec.ts | ✅ Completo | 10 |
| **Atualizar Status** | ✅ atualizar-status.spec.ts | ✅ Completo | 10 |
| **Listar Tickets** | ⏳ ticket-listing.spec.ts | 📋 Em progresso | 27 |
| **Detalhes Ticket** | ⏳ ticket-details.spec.ts | 📋 Em progresso | 20 |

**Detalhes dos Testes:**

**criar-ticket.spec.ts** (10 cenários)
- TC-001: Criar com dados válidos ✅
- TC-002 a TC-004: Diferentes prioridades (Alta, Média, Baixa) ✅
- TC-005 a TC-007: Validações negativas (título vazio, descrição vazia, título longo) ✅
- TC-008: Múltiplas criações sequenciais ✅
- TC-009: Contadores de caracteres em tempo real ✅
- TC-010: Botão cancelar não salva ✅

**atualizar-status.spec.ts** (10 cenários)
- TC-201: Aberto → Em Andamento ✅
- TC-202: Em Andamento → Fechado ✅
- TC-203: Aberto → Fechado (transição direta) ✅
- TC-204: Rejeitar status inválido ✅
- TC-205: Manter histórico de alterações ✅
- TC-206: Validar permissões RBAC ✅
- TC-207: Rejeitar Fechado → Em Andamento ✅
- TC-208: Dropdown com statuses válidos ✅
- TC-209: Motivo obrigatório ao fechar ✅
- TC-210: Gerar auditoria completa ✅

### API Tests

| Endpoint | Testes | Status |
|----------|--------|--------|
| `POST /tickets` | ✅ Criar ticket | Em desenvolvimento |
| `GET /tickets` | ✅ Listar tickets | Em desenvolvimento |
| `GET /tickets/:id` | ✅ Obter detalhes | Em desenvolvimento |
| `PUT /tickets/:id` | ✅ Atualizar ticket | Em desenvolvimento |
| `DELETE /tickets/:id` | ✅ Deletar ticket | Em desenvolvimento |

**Cobertura de Validações:**
- ✅ Payloads válidos e inválidos
- ✅ Tratamento de erros HTTP (400, 401, 403, 404, 500)
- ✅ Autenticação/Autorização
- ✅ Paginação
- ✅ Rate limiting

### Cobertura Cross-Browser

**Browsers Testados:**
- ✅ **Chromium** (Chrome, Edge) - Desktop
- ✅ **Firefox** - Desktop
- ✅ **WebKit** (Safari) - Desktop
- ✅ **Mobile Chrome** (Pixel 5) - Mobile
- ✅ **Mobile Safari** (iPhone 12) - Mobile

**Relatórios Capturados em Falha:**
- 📸 Screenshots automáticos
- 🎬 Videos completos
- 📊 Traces detalhadas (para debug browser)
- 📋 Logs estruturados
- 🗂️ Arquivos JSON (para CI)

---

## 📊 Cobertura de Testes

### Matriz de Cobertura Atual

| Tipo de Teste | Cobertura | Status |
|---------------|-----------|--------|
| **E2E (UI)** | 20 cenários (40% do crítico) | ✅ Ativo |
| **API** | 5 endpoints básicos | ⏳ Em progresso |
| **Unitários** | Validadores | ⏳ Planejado |
| **Integração** | API + DB | ⏳ Planejado |
| **Acessibilidade** | Smoke test | ⏳ Planejado |
| **Performance** | Lighthouse | ⏳ Planejado |

### Histórico de Progresso

```
ETAPA 1-4: Infraestrutura (✅ Completo)
  - 📊 Análise de riscos
  - 📋 Estratégia de QA
  - 🛠️ Configuração Playwright
  
ETAPA 5: Page Object Model (✅ Completo)
  - 🏗️ BasePage (25 métodos)
  - 📋 TicketsPage (20 métodos)
  - ➕ CriarTicketPage (21 métodos)
  - 🔍 DetalhesTicketPage (24 métodos)
  
ETAPA 6: Fixtures & Helpers (✅ Completo)
  - 📊 test-data.ts (9 helpers + datasets)
  - 🛠️ helpers.ts (18 funções)
  
ETAPA 7: E2E Tests (⏳ 20/75 = 27%)
  - ✅ criar-ticket.spec.ts (10 cenários)
  - ✅ atualizar-status.spec.ts (10 cenários)
  - ⏳ ticket-listing.spec.ts (27 cenários)
  - ⏳ ticket-details.spec.ts (20 cenários)
  
ETAPA 8: CI/CD (✅ Completo)
  - ✅ .github/workflows/tests.yml
  
ETAPA 9: Documentação (⏳ Em progresso)
  
ETAPA 10: Documentação Final (⏳ Atual)
```

---

## 📸 Screenshots & Exemplos

### Dashboard de Testes (UI Mode)

```
Ao executar: npm run test:ui

Você verá um dashboard interativo com:
┌─────────────────────────────────────────┐
│ 🎭 Playwright Inspector                 │
├─────────────────────────────────────────┤
│ • Test listing (testes disponíveis)     │
│ • Step-through execution                │
│ • Live page preview                     │
│ • Selectors live inspection             │
│ • Network requests                      │
│ • Console logs                          │
└─────────────────────────────────────────┘
```

### Relatório HTML

```
Ao executar: npm run report

Você verá um relatório web com:
┌─────────────────────────────────────────┐
│ 📊 Playwright Report                    │
├─────────────────────────────────────────┤
│ Total: 20 testes                        │
│ ✅ Passed: 18                           │
│ ❌ Failed: 2                            │
│ ⏭️ Skipped: 0                           │
│                                         │
│ [Filtros] [Search] [Stats]              │
│                                         │
│ Teste 1: criar-ticket.spec.ts ✅        │
│   └─ 📸 Screenshots em falha            │
│   └─ 🎬 Videos da execução              │
│   └─ 📊 Trace para debug                │
│                                         │
│ Teste 2: atualizar-status.spec.ts ✅   │
│   └─ ⏱️ Duration: 1.23s                 │
└─────────────────────────────────────────┘
```

### Exemplo de Teste (Code)

```typescript
// tests/e2e/tickets/criar-ticket.spec.ts

test('TC-001: Deve criar ticket com dados válidos', async ({ page }) => {
  // ARRANGE - Setup
  const criarPage = new CriarTicketPage(page);
  const ticketsPage = new TicketsPage(page);
  
  // ACT - Executar ação
  await criarPage.navigateToCriarTicket();
  await criarPage.criarTicket({
    titulo: 'Login não funciona no Firefox',
    descricao: 'Usuário não consegue fazer login...',
    prioridade: Prioridade.Alta,
  });
  
  // ASSERT - Validar resultado
  await expect(page.locator('[role="alert"]'))
    .toContainText('Ticket criado com sucesso');
  
  const tickets = await ticketsPage.getTicketsList();
  expect(tickets[0].titulo).toBe('Login não funciona no Firefox');
});
```

### Example Test Output

```bash
$ npm run test:e2e

> BlueCoreDesafioTec@1.0.0 test:e2e
> playwright test --reporter=html --reporter=list

Running 20 tests using 3 workers

✅ [chromium] › tests/e2e/tickets/criar-ticket.spec.ts:2 - TC-001
✅ [chromium] › tests/e2e/tickets/criar-ticket.spec.ts:3 - TC-002
✅ [firefox] › tests/e2e/tickets/atualizar-status.spec.ts:1 - TC-201
❌ [webkit] › tests/e2e/tickets/atualizar-status.spec.ts:2 - TC-202
   └─ Error: Status não foi atualizado
   └─ Screenshot: /test-results/webkit-...png
   └─ Video: /test-results/webkit-...webm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test results: 19 passed, 1 failed ⚠️
Duration: 2 min 34s

📊 Reports: /playwright-report/index.html
```

---

## 🔄 Pipeline CI/CD

### GitHub Actions Workflow (`.github/workflows/tests.yml`)

Pipeline automático que executa a cada push/PR para garantir qualidade.

**Triggers:**
- ✅ Push em `main` ou `develop`
- ✅ Pull Requests para `main` ou `develop`
- ✅ Execução manual (workflow_dispatch)

**Jobs Paralelos:**

```
Push/PR ────► Lint (ESLint + Prettier)
              ├─► PASS ──► Test API ────────┐
              │           ├═► Passa? (✅/❌) │
              │           └─► Upload Artifacts
              │                               │
              └─► Test E2E (3 browsers) ──┤
                  ├─► Chromium  ┐          │
                  ├─► Firefox   ├─ Paralelo
                  └─► WebKit    ┘          │
                      ├─► Upload Reports  │
                      └─► Publish Pages   │
                                          λ
                      Report & Notify ◄───┘
```

**Cada Job Inclui:**

| Job | Tempo | Ações |
|-----|-------|-------|
| **Lint** | ~2min | ESLint + Prettier check |
| **Test API** | ~10min | Rodar testes de API |
| **Test E2E** | ~30min (paralelo) | 3 browsers simultâneos |
| **Report** | ~2min | Consolidar + notificar |

**Artifacts Gerados:**

```
✅ ESLint report (JSON)
✅ API test results (JSON + HTML)
✅ Playwright reports (HTML)
✅ Videos de falhas (WebM)
✅ Screenshots (PNG)
✅ Traces (ZIP)
✅ Test summary (Markdown)
```

**Notificações:**

- 📧 Comentário automático em PRs com resultados
- 📢 Slack notification em falhas (opcional)
- 📊 GitHub Pages com histórico de reports

**Como Configurar Secrets:**

```bash
# No GitHub: Settings → Secrets and variables → Actions

SLACK_WEBHOOK_URL    # Para notificações Slack
API_ENDPOINT         # URL da aplicação
AUTH_TOKEN          # Token de teste (se necessário)
```

**Ver Status do Pipeline:**

- Via GitHub: `.github/workflows/tests.yml` → commits
- Via CLI: `gh run list`
- Via Local: `grep -r "workflow_run"` logs

---

---

## 🚀 Próximas Melhorias

### Curto Prazo (Sprint Atual)

- [ ] Completar `ticket-listing.spec.ts` (27 cenários)
  - Filtros por status, prioridade, data
  - Paginação
  - Ordenação de colunas
  - Busca de texto
  
- [ ] Completar `ticket-details.spec.ts` (20 cenários)
  - Visualizar todos os campos
  - Editar ticket
  - Adicionar comentários
  - Download de anexos
  
- [ ] Implementar `LoginPage.ts`
  - Testes de autenticação
  - Testes de autorização (RBAC)

### Médio Prazo (2-3 Sprints)

- [ ] Testes de API completos
- [ ] Aumentar cobertura E2E para 60%
- [ ] Testes de Acessibilidade
- [ ] Testes de Performance

### Longo Prazo (Roadmap)

- [ ] Testes de Carga/Stress
- [ ] Testes Visuais
- [ ] Matriz de Rastreabilidade Automatizada
- [ ] Dashboard de Métricas

---

## 📚 Documentação Complementar

| Documento | Localização | Conteúdo |
|-----------|-------------|----------|
| **Análise de Riscos** | [docs/analise-riscos.md](docs/analise-riscos.md) | Riscos técnicos e mitigações |
| **Estratégia QA** | [docs/estrategia-testes.md](docs/estrategia-testes.md) | Plano de testes detalhado |
| **Config Playwright** | [PLAYWRIGHT_CONFIG.md](PLAYWRIGHT_CONFIG.md) | Opções de configuração |

---

## 👨‍💻 Como Contribuir

### Processo de Contribuição

1. **Fork o Repositório**
   ```bash
   git clone https://github.com/SEU_USERNAME/BlueCoreDesafioTec.git
   cd BlueCoreDesafioTec
   ```

2. **Crie Feature Branch**
   ```bash
   git checkout -b feature/seu-novo-teste
   ```

3. **Implemente e Verifique Qualidade**
   ```bash
   npm run lint:fix
   npm run format:fix
   npm run test:ci
   ```

4. **Commit e Push**
   ```bash
   git commit -m "Add: novo teste para criar ticket"
   git push origin feature/seu-novo-teste
   ```

5. **Abra Pull Request no GitHub**

### Checklist para PR

- [ ] Testes passam (`npm test`)
- [ ] Sem linting errors (`npm run lint`)
- [ ] Código formatado (`npm run format`)
- [ ] JSDoc em funções novas
- [ ] Page Objects usados (não hardcode)
- [ ] Padrão AAA seguido

### Convenções de Código

**✅ Bom - Descreve o que é testado**
```typescript
test('should create ticket with valid data', async () => {})
```

**❌ Ruim - Vago**
```typescript
test('test create', async () => {})
```

---

## 🤝 Dúvidas & Suporte

### Encontrou um Problema?

1. Verifique se já existe uma issue similar
2. Abra uma [GitHub Issue](https://github.com/FilipeMalta/BlueCoreDesafioTec/issues)
3. Inclua:
   - Versão Node/npm
   - Steps para reproduzir
   - Output de erro

### Recursos de Ajuda

- [Playwright Docs](https://playwright.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs)
- [Page Object Pattern](https://playwright.dev/docs/pom)

---

## 📄 Licença

**ISC License** © 2026 - Felipe Malta

Permite uso comercial, modificação e distribuição.
Veja [LICENSE](LICENSE) para detalhes completos.

---

## 📊 Badges & Status

<div align="center">

![Last Commit](https://img.shields.io/github/last-commit/FilipeMalta/BlueCoreDesafioTec?style=flat-square)
![Issues](https://img.shields.io/github/issues/FilipeMalta/BlueCoreDesafioTec?style=flat-square)
![PRs](https://img.shields.io/github/issues-pr/FilipeMalta/BlueCoreDesafioTec?style=flat-square)

**Made with ❤️ by QA Professionals**

*Last Updated: February 8, 2026*

</div>
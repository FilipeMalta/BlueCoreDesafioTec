# Estratégia de QA - Sistema de Gestão de Tickets

## Riscos de Qualidade Identificados

### Críticos
- Perda de dados ao criar/atualizar ticket
- Transições de status inválidas (ex: Fechado → Em andamento)
- Validação inadequada de entrada (SQL injection, XSS)
- Tickets com dados incompletos sendo salvos

### Altos
- Concorrência: dois usuários editando mesmo ticket simultaneamente
- Dados não refletem na listagem após criação
- ID de ticket duplicado ou inválido
- Performance com muitos registros

### Médios
- Mensagens de erro não claras
- Layout quebrado em diferentes resoluções
- Ordenação/filtros na listagem não funcionam

---

## Tipos de Testes Essenciais

### 1. Testes Automatizados (E2E)
Prioritários por ROI alto:
- Criar ticket com dados válidos
- Atualizar status seguindo transições esperadas
- Validações de campo obrigatório
- Listar e filtrar tickets

Por quê: Casos determinísticos, executados 100+ vezes/dia em CI/CD.

### 2. Testes Manuais Exploratórios
Imprescindíveis mas não têm ROI mensurável:
- Usabilidade geral (UX clara?)
- Comportamento com dados extremos
- Edge cases não documentados
- Resposta da app com servidor lento

Quando: Antes de releases, ~2h por sprint.

### 3. Testes de Integração
Validar fluxo completo:
- Criar → Listar → Consultrar → Atualizar → Deletar
- Backend persiste dados corretamente
- API responde com estrutura esperada

---

## Priorização de Automação

### 1º (Maior ROI)
Criar ticket com dados válidos - fluxo crítico, 100x/dia, determinístico.

### 2º
Atualizar status - múltiplas transições, fácil regressão.

### 3º
Validações de input - devem falhar consistentemente.

### 4º
Listar e filtrar - complexidade média.

### Não automatizar (por enquanto)
- Design visual / responsividade
- Testes de carga
- Upload de arquivos

---

## Cenários de Teste Manual

### CRIAR TICKET

#### TC-M01: Criar com dados válidos
```
Pré-requisito: Estar na página de criar ticket
Passos:
1. Preencher título com "Login não funciona no Firefox"
2. Preencher descrição com "Usuário não consegue fazer login"
3. Selecionar prioridade "Alta"
4. Clicar em "Salvar"

Resultado esperado:
- Mensagem de sucesso aparece
- Sistema redireciona para listagem
- Novo ticket aparece com os dados informados
- ID foi atribuído automaticamente
```

#### TC-M02: Criar ticket com prioridade média
```
Pré-requisito: Estar na página de criar ticket
Passos:
1. Preencher título com "Dashboard lento"
2. Preencher descrição com "Carregamento demora 5 segundos"
3. Selecionar prioridade "Média"
4. Clicar em "Salvar"

Resultado esperado:
- Ticket criado com sucesso
- Prioridade exibe como "Média" na listagem
```

#### TC-M03: Criar ticket com prioridade baixa
```
Pré-requisito: Estar na página de criar ticket
Passos:
1. Preencher título com "Typo na página"
2. Preencher descrição com "Palavra errada em parágrafo"
3. Selecionar prioridade "Baixa"
4. Clicar em "Salvar"

Resultado esperado:
- Ticket criado
- Prioridade exibe como "Baixa"
```

#### TC-M04 (NEGATIVO): Tentar criar sem título
```
Pré-requisito: Estar na página de criar ticket
Passos:
1. Deixar título em branco
2. Preencher descrição com "Alguma descrição"
3. Selecionar prioridade "Alta"
4. Clicar em "Salvar"

Resultado esperado:
- Validação impede salvamento
- Mensagem de erro: "Título é obrigatório"
- Permanece na página de criação
- Dados não são perdidos (descrição ainda visível)
```

#### TC-M05 (NEGATIVO): Tentar criar sem descrição
```
Pré-requisito: Estar na página de criar ticket
Passos:
1. Preencher título com "Problem X"
2. Deixar descrição em branco
3. Selecionar prioridade "Alta"
4. Clicar em "Salvar"

Resultado esperado:
- Validação impede salvamento
- Mensagem clara indicando descrição obrigatória
- Ticket não é criado
- Usuário pode corrigir sem perder o título preenchido
```

#### TC-M06: Validação de caracteres especiais
```
Pré-requisito: Estar na página de criar ticket
Passos:
1. Preencher título com "Erro: <script>alert('xss')</script>"
2. Preencher descrição normalmente
3. Selecionar prioridade
4. Clicar em "Salvar"

Resultado esperado:
- Ticket é criado/salvo com segurança
- Conteúdo não executa como código
- Caracteres especiais são escapados
- Ao consultar, exibe o conteúdo literal, não o script
```

#### TC-M07: Cancelar criação de ticket
```
Pré-requisito: Estar na página de criar ticket com dados parcialmente preenchidos
Passos:
1. Preencher título e descrição
2. Clicar no botão "Cancelar"

Resultado esperado:
- Não cria o ticket
- Redireciona para listagem de tickets
- Dados preenchidos são descartados
```

---

### ATUALIZAR STATUS DO TICKET

#### TC-M08: Transição Aberto → Em andamento
```
Pré-requisito: Ticket com status "Aberto" já existe
Passos:
1. Localizar o ticket na listagem
2. Clicar em "Editar" ou abrir detalhes
3. Alterar status para "Em andamento"
4. Clicar em "Salvar"

Resultado esperado:
- Status é atualizado com sucesso
- Mensagem de confirmação aparece
- Listagem reflete a mudança (status exibe "Em andamento")
- Histórico ou timestamp é registrado
```

#### TC-M09: Transição Em andamento → Fechado
```
Pré-requisito: Ticket com status "Em andamento" já existe
Passos:
1. Abrir o ticket
2. Alterar status para "Fechado"
3. Clicar em "Salvar"

Resultado esperado:
- Transição é permitida
- Status muda para "Fechado"
- Data/hora de fechamento é registrada
- Ticket continua visível na listagem (não desaparece)
```

#### TC-M10: Transição Aberto → Fechado (direto)
```
Pré-requisito: Ticket com status "Aberto" já existe
Passos:
1. Abrir o ticket
2. Alterar status para "Fechado" (pulando "Em andamento")
3. Clicar em "Salvar"

Resultado esperado:
- Transição direta é permitida
- Status muda para "Fechado"
- Sistema não força estado intermediário
```

#### TC-M11 (NEGATIVO): Tentar fazer transição inválida
```
Pré-requisito: Ticket com status "Fechado" já existe
Passos:
1. Abrir o ticket
2. Tentar alterar status para "Em andamento"
3. Clicar em "Salvar"

Resultado esperado:
- Validação nega a transição
- Mensagem de erro: "Não é possível reabrir um ticket fechado"
- Status permanece "Fechado"
- Ticket não é alterado
```

#### TC-M12 (NEGATIVO): Tentar alterar para status inválido
```
Pré-requisito: Ticket aberto, página de edição abierta
Passos:
1. Tentar modificar o campo status manualmente (via inspect, se possível)
2. Ou tentar enviar valor inválido
3. Clicar em "Salvar"

Resultado esperado:
- Validação no backend rejeita status inválido
- Mensagem de erro clara
- Ticket mantém status anterior
- Não há corrupção de dados
```

#### TC-M13: Múltiplos usuários atualizando mesmo ticket
```
Pré-requisito: Um ticket existe, dois navegadores/sessões abertos
Passos:
1. Navegador A: Abrir o ticket
2. Navegador B: Abrir o MESMO ticket
3. Navegador A: Alterar status para "Em andamento" e salvar
4. Navegador B: Alterar status para "Fechado" e salvar

Resultado esperado:
- Um dos dois recebe mensagem de conflito
- Última alteração é mantida (ou há merge inteligente)
- Dados não são corrompidos
- Sistema trata concorrência adequadamente
```

#### TC-M14: Atualizar status sem alterar outros dados
```
Pré-requisito: Ticket com título, descrição e status "Aberto"
Passos:
1. Abrir o ticket
2. Mudar APENAS o status para "Em andamento"
3. Não alterar nenhum outro campo
4. Clicar em "Salvar"

Resultado esperado:
- Apenas status é atualizado
- Título continua o mesmo
- Descrição não é modificada
- Prioridade se mantém
- Nenhum campo é perdido
```

---

## Critérios de Aceite Gerais

- Todas as mensagens de erro devem ser claras e em português
- Validações devem ocorrer tanto no frontend quanto no backend
- Dados não podem ser perdidos parcialmente
- UI não deve ficar presa/travada durante operações
- Timestamps devem ser registrados corretamente
- Caracteres especiais/unicode devem ser tratados com segurança

# language: pt
Feature: Criar Novo Ticket no Sistema Helpdesk
  Como um usuário do sistema Helpdesk
  Quero criar um novo ticket de suporte
  Para relatar problemas, solicitações ou feedbacks de forma estruturada

  Contexto (Background):
    Pré-condições que se aplicam a todos os cenários
    - Usuário deve estar autenticado no sistema
    - Usuário deve ter acesso a criar tickets
    - Sistema deve estar em funcionamento normal

  Resumo de Critérios de Aceite:
    ✅ Campo "Título" é obrigatório (mínimo 3, máximo 200 caracteres)
    ✅ Campo "Descrição" é obrigatório (mínimo 10, máximo 5000 caracteres)
    ✅ Campo "Prioridade" deve aceitar: Baixa, Média, Alta, Crítica
    ✅ Campo "Categoria" deve aceitar: Técnico, Pagamento, Relatório, Geral
    ✅ Arquivo anexado é opcional (max 10MB, formatos: PDF, DOC, IMG, ZIP)
    ✅ Ticket criado deve ter status inicial "Aberto"
    ✅ Ticket criado deve ser exibido imediatamente na lista
    ✅ Usuário deve ser redirecionado para página de detalhes do ticket
    ✅ Validações de campo devem exibir mensagens de erro inline
    ✅ Botão "Enviar" deve ser desabilitado se dados obrigatórios faltarem

---

## ✅ CENÁRIOS POSITIVOS (Happy Path)

@smoke @critical
Scenario: Criar ticket com todos os campos obrigatórios preenchidos corretamente
  Given que estou autenticado no sistema como "usuario@exemplo.com"
  And que estou na página de listagem de tickets
  And que a listagem está carregada completamente
  
  When clico no botão "Criar Novo Ticket"
  Then uma modal ou página de criação de ticket é aberta
  And o formulário apresenta os seguintes campos vazios:
    | Campo      | Tipo         | Obrigatório |
    | Título     | Text Input   | Sim         |
    | Descrição  | Text Area    | Sim         |
    | Prioridade | Dropdown     | Sim         |
    | Categoria  | Dropdown     | Sim         |
    | Anexo      | File Upload  | Não         |
  
  When preencho o campo "Título" com "Erro ao processar pagamento no checkout"
  And preencho o campo "Descrição" com "Estou recebendo um erro 502 ao tentar finalizar uma compra. O erro ocorre sempre que tomo uma compra com valor acima de R$100. Já tentei em diferentes navegadores e o problema persiste."
  And seleciono "Alta" no dropdown "Prioridade"
  And seleciono "Pagamento" no dropdown "Categoria"
  
  Then o botão "Enviar" deve estar habilitado (não greyed out)
  And não há mensagens de erro visíveis no formulário
  
  When clico no botão "Enviar"
  Then vejo uma mensagem de sucesso: "Ticket criado com sucesso!"
  And a modal/página fecha
  And sou redirecionado para a página de detalhes do novo ticket
  And o ticket exibe os dados corretos:
    | Campo      | Valor Esperado                      |
    | Título     | Erro ao processar pagamento no checkout |
    | Descrição  | Estou recebendo um erro 502...      |
    | Prioridade | Alta                                |
    | Categoria  | Pagamento                           |
    | Status     | Aberto                              |
  And a URL contém um ID numérico (ex: /tickets/12345)
  And o ticket aparece no topo da lista de tickets com status "Aberto - 0 min"

---

@smoke
Scenario: Criar ticket com prioridade Baixa
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com os dados:
    | Campo      | Valor                           |
    | Título     | Melhorar documentação do sistema |
    | Descrição  | A documentação atual está desatualizada e difícil de seguir |
    | Prioridade | Baixa                           |
    | Categoria  | Geral                           |
  
  And clico em "Enviar"
  Then o ticket é criado com sucesso
  And a prioridade exibe como "Baixa" no detalhe
  And o ícone de prioridade é azul (Baixa)

---

Scenario: Criar ticket com prioridade Média
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com os dados:
    | Campo      | Valor                      |
    | Título     | Funcionalidade de cacha não funciona |
    | Descrição  | O filtro de cacha não está atualizando corretamente |
    | Prioridade | Média                      |
    | Categoria  | Técnico                    |
  
  And clico em "Enviar"
  Then o ticket é criado com sucesso
  And a prioridade exibe como "Média" no detalhe
  And o ícone de prioridade é amarelo (Média)

---

Scenario: Criar ticket com prioridade Alta
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com os dados:
    | Campo      | Valor                           |
    | Título     | Sistema inteiro offline         |
    | Descrição  | O sistema está completamente fora do ar desde 10:30. Usuários não conseguem acessar |
    | Prioridade | Alta                            |
    | Categoria  | Técnico                         |
  
  And clico em "Enviar"
  Then o ticket é criado com sucesso
  And a prioridade exibe como "Alta" no detalhe
  And o ícone de prioridade é laranja (Alta)

---

Scenario: Criar ticket com prioridade Crítica
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com os dados:
    | Campo      | Valor                              |
    | Título     | Perda de dados em produção        |
    | Descrição  | Todos os tickets de fevereiro foram deletados. Impacta 5000+ usuários |
    | Prioridade | Crítica                            |
    | Categoria  | Técnico                            |
  
  And clico em "Enviar"
  Then o ticket é criado com sucesso
  And a prioridade exibe como "Crítica" no detalhe
  And o ícone de prioridade é vermelho (Crítica)

---

@important
Scenario: Criar ticket com descrição extensa (máximo 5000 caracteres)
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o campo "Título" com "Relatório detalhado de bugs encontrados"
  And preencho o campo "Descrição" com um texto de exatamente 4500 caracteres contendo:
    """
    RESUMO EXECUTIVO:
    Durante os últimos 3 dias, conduzimos testes exploratórios abrangentes no módulo de gestão de tickets.
    Identificamos múltiplos bugs críticos que afetam a usabilidade e a integridade dos dados.
    
    CONTEXTO:
    - Ambiente: Staging
    - Navegador: Chrome 131.0 em Windows 11
    - Usuários testados: 5 usuários simultâneos
    - Data de teste: 2026-02-08
    
    PROBLEMAS ENCONTRADOS:
    
    1. PROBLEMA 1: Validação de campo obrigatório não funciona
    Descrição: Ao deixar o campo "Título" vazio e clicar em "Enviar", o sistema não exibe mensagem de erro e permite submissão.
    Impacto: Crítico - Tickets são criados com dados incompletos
    Reprodução: [passos detalhados]
    
    2. PROBLEMA 2: Lentidão ao listar 10k+ tickets
    Descrição: Ao listar tickets com mais de 10.000 registros, a página demora 25 segundos para carregar.
    Impacto: Alto - Afeta produtividade dos usuários
    Requisito: < 5 segundos
    
    3. PROBLEMA 3: Caracteres especiais quebram exibição
    Descrição: Tickets com emojis (😀) ou caracteres unicode aparecem corrompidos.
    Impacto: Médio - Afeta usabilidade visual
    
    RECOMENDAÇÕES:
    [mais detalhes...]
    """
  And seleciono "Média" no dropdown "Prioridade"
  And seleciono "Relatório" no dropdown "Categoria"
  
  Then o botão "Enviar" está habilitado
  And o campo "Descrição" mostra um contador: "4500 / 5000"
  
  When clico em "Enviar"
  Then o ticket é criado com sucesso
  And a descrição completa é exibida no detalhe do ticket
  And não há truncamento ou perda de dados

---

@important
Scenario: Criar ticket com anexo válido (PDF)
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com dados válidos:
    | Campo      | Valor                        |
    | Título     | Orçamento para aprovação     |
    | Descrição  | Segue em anexo o orçamento para o novo projeto |
    | Prioridade | Média                        |
    | Categoria  | Geral                        |
  
  And clico em "Adicionar Anexo"
  Then o diálogo de upload de arquivo é aberto
  
  When seleciono um arquivo PDF com tamanho < 10MB (ex: "orcamento.pdf")
  And confirmo a seleção
  Then o arquivo é carregado com sucesso
  And o nome do arquivo "orcamento.pdf" é exibido no formulário
  And um ícone de remover (X) aparece ao lado do arquivo
  
  When clico em "Enviar"
  Then o ticket é criado com sucesso com anexo
  And na página de detalhes, o anexo é exibido como link downloadável
  And consigo fazer download do arquivo anexado
  And o arquivo baixado é idêntico ao original

---

@important
Scenario: Criar ticket com múltiplos anexos
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com dados válidos
  And clico em "Adicionar Anexo" três vezes
  Then posso selecionar 3 arquivos diferentes:
    | Arquivo               | Tamanho |
    | relatorio.pdf         | 2.5 MB  |
    | evidencia.png         | 1.2 MB  |
    | logs.zip              | 3.1 MB  |
  
  And todos os 3 arquivos são exibidos na lista de anexos
  And o tamanho total exibido é "6.8 MB / 10 MB"
  
  When clico em "Enviar"
  Then o ticket é criado com sucesso com todos os 3 anexos
  And todos os arquivos são downloadáveis no detalhe

---

## ❌ CENÁRIOS NEGATIVOS (Error Cases)

@critical
Scenario: Tentar criar ticket sem preencher o campo "Título"
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  And estou vendo um formulário vazio
  
  When preencho apenas o campo "Descrição" com "Descrição válida com mais de 10 caracteres"
  And seleciono "Alta" no dropdown "Prioridade"
  And seleciono "Técnico" no dropdown "Categoria"
  And deixo o campo "Título" completamente vazio
  
  Then o botão "Enviar" está desabilitado (greyed out)
  And uma mensagem de erro é exibida sob o campo "Título": "Título é obrigatório"
  And o campo "Título" possui uma borda vermelha indicando erro
  And nenhuma solicitação é enviada para o servidor
  
  When clico no botão "Enviar" (mesmo desabilitado)
  Then nada acontece
  And do formulário permanece aberto com todos os dados ainda preenchidos
  And a mensagem de erro continua visível

---

@critical
Scenario: Tentar criar ticket sem preencher o campo "Descrição"
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o campo "Título" com "Um título válido"
  And seleciono "Média" no dropdown "Prioridade"
  And seleciono "Geral" no dropdown "Categoria"
  And deixo o campo "Descrição" vazio
  
  Then o botão "Enviar" está desabilitado
  And uma mensagem de erro é exibida sob o campo "Descrição": "Descrição é obrigatória (mínimo 10 caracteres)"
  And o campo "Descrição" possui uma borda vermelha
  
  When clico para focar no campo "Descrição"
  And digito uma descrição com apenas 5 caracteres: "teste"
  Then a mensagem de erro continua: "Descrição é obrigatória (mínimo 10 caracteres)"
  And o botão "Enviar" permanece desabilitado
  
  When adiciono mais caracteres até totalizar 10: "teste12345"
  Then a mensagem de erro desaparece
  And a borda vermelha é removida
  And o botão "Enviar" fica habilitado

---

@critical
Scenario: Tentar criar ticket com título muito longo (> 200 caracteres)
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o campo "Título" com um texto extremamente longo de 250 caracteres:
    """
    Este é um título extremamente longo que ultrapassa o limite máximo de 200 caracteres permitidos pelo sistema e deve ser rejeitado pela validação de campo de entrada de dados de formulário
    """
  And preencho o campo "Descrição" com "Descrição válida com mais de 10 caracteres"
  
  Then o campo "Título" mostra um contador: "250 / 200"
  And uma mensagem de erro é exibida: "Título não pode ter mais de 200 caracteres"
  And o botão "Enviar" está desabilitado
  
  When removo caracteres até ficar exatamente em 200 caracteres
  Then o contador mostra "200 / 200"
  And a mensagem de erro desaparece
  And o botão "Enviar" fica habilitado
  
  When clico em "Enviar"
  Then o ticket é criado com sucesso

---

@critical
Scenario: Tentar criar ticket com título muito curto (< 3 caracteres)
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o campo "Título" com apenas 2 caracteres: "AB"
  And preencho o campo "Descrição" com "Descrição válida com mais de 10 caracteres"
  
  Then uma mensagem de erro é exibida: "Título deve ter pelo menos 3 caracteres"
  And o botão "Enviar" está desabilitado
  
  When adiciono um caractere no título: "ABC"
  Then a mensagem desaparece
  And o botão "Enviar" fica habilitado

---

@high
Scenario: Tentar criar ticket sem selecionar Prioridade
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho os campos com dados válidos:
    | Campo      | Valor                        |
    | Título     | Um título válido             |
    | Descrição  | Uma descrição com 10+ chars  |
  
  And deixo o campo "Prioridade" sem seleção (placeholder visível)
  And deixo o campo "Categoria" sem seleção
  
  Then o botão "Enviar" está desabilitado
  And mensagens de erro são exibidas:
    | Campo      | Mensagem                    |
    | Prioridade | Prioridade é obrigatória    |
    | Categoria  | Categoria é obrigatória     |
  
  When seleciono "Alta" em "Prioridade"
  Then o erro de prioridade desaparece
  But o erro de categoria continua
  And botão "Enviar" permanece desabilitado
  
  When seleciono "Técnico" em "Categoria"
  Then ambos os erros desaparecem
  And o botão "Enviar" fica habilitado

---

@high
Scenario: Tentar criar ticket com caracteres especiais no título
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o campo "Título" com caracteres especiais: "Bug com <script> e '; DROP--"
  And preencho o campo "Descrição" com "Descrição válida"
  And seleciono "Alta" em "Prioridade"
  And seleciono "Técnico" em "Categoria"
  
  Then não há mensagens de erro
  And o botão "Enviar" está habilitado
  
  When clico em "Enviar"
  Then o ticket é criado com sucesso
  And o título é exibido corretamente no detalhe (caracteres escapados/sanitizados)
  And nenhum código é executado (proteção contra XSS)

---

@high
Scenario: Tentar upload de arquivo acima do tamanho máximo (> 10MB)
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  And preencho os campos obrigatórios com dados válidos
  
  When clico em "Adicionar Anexo"
  And seleciono um arquivo com tamanho 15MB (ex: "video-longo.mp4")
  
  Then uma mensagem de erro é exibida: "Arquivo não pode ultrapassar 10MB. Tamanho atual: 15MB"
  And o arquivo não é carregado
  And o formulário não é modificado
  And o botão "Enviar" continua habilitado (pois anexo é opcional)

---

@high
Scenario: Tentar upload de arquivo com extensão não permitida
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  And preencho os campos obrigatórios com dados válidos
  
  When clico em "Adicionar Anexo"
  And seleciono um arquivo executável (ex: "virus.exe" ou "script.bat")
  
  Then uma mensagem de erro é exibida: "Formato de arquivo não permitido. Formatos aceitos: PDF, DOC, DOCX, IMG (JPG, PNG), ZIP"
  And o arquivo não é carregado
  And o formulário não é modificado

---

Scenario: Cancelar criação de ticket após preencher dados
  Given que estou autenticado no sistema
  And que estou na página de criação de tickets
  
  When preencho o formulário com dados:
    | Campo      | Valor        |
    | Título     | Meu problema |
    | Descrição  | Uma descrição longa com 10+ caracteres |
  
  And clico no botão "Cancelar" ou fecha a modal
  Then a modal/página fecha
  And nenhum ticket é criado
  And sou redirecionado para a listagem de tickets
  And a listagem mostra o mesmo estado anterior (sem o novo ticket)

---

Scenario: Criação de ticket em segundo plano enquanto outra aba continua navegando
  Given que tenho 2 abas do navegador abertas
  And ambas estão logadas no sistema
  And a Aba 1 está na página de criação de tickets
  And a Aba 2 está na listagem de tickets
  
  When na Aba 1, preencho e envio um novo ticket
  Then na Aba 1, vejo mensagem de sucesso
  And sou redirecionado para detalhe do novo ticket
  
  When navego para a Aba 2
  And atualizo a página (F5)
  Then o novo ticket criado na Aba 1 aparece no topo da listagem
  And o ticket mostra status "Aberto - 0 min"

---

## 🏷️ TAGS DE PRIORIDADE

Usar tags para executar subconjuntos de testes:

@smoke       → Testes essenciais (5 min, executar sempre)
@critical    → Bugs bloqueadores (15 min, executar antes de release)
@important   → Funcionalidades chave (30 min, executar antes de staging)
@high        → Casos diversos (executar 1x por semana)

---

## 📋 CHECKLIST DE EXECUÇÃO

Salvar em `testes-manuais/execution-logs/TC001-YYYY-MM-DD-executor.md`:

```markdown
# TC001 - Criar Ticket - Execution Log

**Data**: 2026-02-08
**Executor**: [Seu nome]
**Navegador**: [Chrome/Firefox/Safari] - [versão]
**Ambiente**: [dev/staging/prod]
**Tempo Total**: [X min]

## Resumo
- [x] Scenario 1: ✅ PASSOU
- [x] Scenario 2: ✅ PASSOU
- [x] Scenario 3: ❌ FALHOU
  - Bug: [descrição]
  - Evidência: [screenshot]

## Bugs Encontrados: 1
- BUG-001-criar-ticket-validacao-titulo

## Status Final
✅ 90% PASSOU (9/10 cenários)
```

---

**Documento criado**: Fevereiro 2026
**Última atualização**: 2026-02-08
**Status**: 📋 Pronto para execução manual

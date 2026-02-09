# language: pt
Feature: Consultar Ticket por ID no Sistema Helpdesk
  Como um usuário/support agent
  Quero consultar os detalhes de um ticket específico
  Para visualizar todas as informações e histórico relacionado ao ticket

  Contexto (Background):
    Pré-condições que se aplicam a todos os cenários
    - Usuário deve estar autenticado no sistema
    - Deve existir um ticket válido com ID numérico
    - Sistema deve estar funcionando normalmente

  Resumo de Critérios de Aceite:
    ✅ Consultar ticket por ID válido retorna todos os dados
    ✅ Todos os campos devem ser exibidos: ID, Título, Descrição, Status, Prioridade, Categoria, Criador, Data de Criação, Responsável, Data da última modificação
    ✅ Tickets podem ter campos opcionais (Responsável, Anexos) que podem estar vazios
    ✅ Histórico de status deve ser exibido como timeline
    ✅ Comentários devem ser listados com autor, data e texto
    ✅ Anexos devem ser downloadáveis
    ✅ ID inválido (não numérico) retorna mensagem clara
    ✅ ID inexistente retorna erro 404
    ✅ Usuários sem permissão recebem erro 403
    ✅ Página de detalhe é responsiva em mobile

---

## ✅ CENÁRIOS POSITIVOS (Happy Path)

@smoke @critical
Scenario: Consultar ticket existente por ID válido
  Given que estou autenticado no sistema como "user@exemplo.com"
  And que existe um ticket com ID "12345" no banco de dados
  And que estou na página de listagem de tickets
  
  When clico no ticket com ID "12345"
  Or digito manualmente a URL: /tickets/12345
  Then a página carrega com sucesso
  And sou redirecionado para: /tickets/12345
  And a página mostra o cabeçalho: "Detalhes do Ticket #12345"
  And exibe um indicador visual mostrando: "🔴 Aberto" (badge de status)

---

@smoke @critical
Scenario: Validar que todos os campos requeridos são retornados
  Given que estou consultando o ticket ID "12345"
  And a página de detalhes foi carregada completamente
  
  When visualizo a página de detalhe
  Then vejo todos os seguintes campos preenchidos:
    | Campo                | Tipo           | Obrigatório | Valor Esperado      |
    | ID                   | Identificador  | Sim         | 12345               |
    | Título               | Texto          | Sim         | Erro ao fazer login |
    | Descrição            | Texto longo    | Sim         | Não consigo acessar... |
    | Status               | Badge          | Sim         | 🔴 Aberto           |
    | Prioridade           | Badge          | Sim         | 🔴 Crítica          |
    | Categoria            | Tag            | Sim         | Pagamento           |
    | Data de Criação      | DateTime       | Sim         | 2026-02-08 14:35    |
    | Responsável          | Avatar+Nome    | Não         | João Silva          |
    | Data de Modificação  | DateTime       | Sim         | 2026-02-08 16:20    |
    | Criador              | Avatar+Nome    | Sim         | user@exemplo.com    |
  
  And cada campo mostra um ícone indicativo:
    | Ícone | Campo              |
    | #     | ID                 |
    | 📝    | Título             |
    | 📄    | Descrição          |
    | 🔴    | Status             |
    | ⚡    | Prioridade         |
    | 📂    | Categoria          |
    | 📅    | Data               |
    | 👤    | Responsável        |

---

@important
Scenario: Validar campos opcionais vazios são tratados corretamente
  Given que estou consultando um ticket onde:
    | Campo        | Valor  |
    | Responsável  | vazio  |
    | Anexos       | 0      |
    | Comentários  | 0      |
  
  When visualizo a página de detalhe
  Then campos opcionais vazios exibem:
    | Campo        | Exibição                           |
    | Responsável  | "Sem atribuição" ou "-"           |
    | Anexos       | "Nenhum anexo" ou seção oculta    |
    | Comentários  | "Nenhum comentário ainda"         |
  
  And não há erros visuais ou quebra de layout
  And a página não exibe valores "null", "undefined" ou "N/A"

---

@important
Scenario: Consultar histórico completo de alterações do ticket
  Given que estou consultando o ticket ID "12345"
  And que este ticket passou por 5 mudanças de status
  And que este ticket tem 3 comentários
  
  When rolo para a seção "Histórico e Comentários"
  Then vejo uma timeline vertical (ou lista) mostrando:
    | Timestamp       | Tipo      | Descrição                    |
    | 2026-02-08 10:00 | Criação   | Ticket criado por user@ex... |
    | 2026-02-08 10:15 | Status    | user1 alterou: Aberto → Em Andamento |
    | 2026-02-08 11:30 | Comentário| user2 adicionou: "Investigando..." |
    | 2026-02-08 11:45 | Status    | user1 alterou: Em Andamento → Fechado |
    | 2026-02-08 14:45 | Status    | admin alterou: Fechado → Reaberto |
  
  And cada evento mostra:
    - Avatar do usuário
    - Nome do usuário
    - Timestamp exato
    - Ícone indicando tipo (status: ↔️, comentário: 💬, etc)
  
  And eventos mais recentes aparecem ACIMA (topo = mais recente)

---

@important
Scenario: Consultar comentários do ticket
  Given que estou consultando um ticket com 3 comentários
  
  When rolo para a seção "Comentários"
  Then vejo uma lista/thread com cada comentário exibindo:
    | Campo      | Tipo     | Valor Esperado                |
    | Avatar     | Image    | Foto do usuário que comentou  |
    | Autor      | Texto    | "João Silva"                  |
    | Email      | Texto    | "joao@empresa.com"            |
    | Timestamp  | DateTime | "2026-02-08 11:30"            |
    | Texto      | Texto    | "Já validei o servidor X"     |
    | Ações      | Buttons  | [Editar] [Deletar] (se autor) |
  
  And se há muitos comentários (> 10):
    - Exibir apenas os primeiros 5 comentários
    - Botão "Mostrar Mais" permite carregar mais
    - Or infinita scroll carrega automaticamente

---

@important
Scenario: Consultar anexos do ticket e fazer download
  Given que estou consultando um ticket com 2 anexos:
    | Arquivo        | Tamanho | Tipo |
    | relatorio.pdf  | 2.5 MB  | PDF  |
    | screenshot.png | 1.2 MB  | PNG  |
  
  When rolo para a seção "Anexos"
  Then vejo uma listagem com cada arquivo mostrando:
    | Campo        | Exemplo                    |
    | Ícone tipo   | 📄 (PDF)                   |
    | Nome arquivo | "relatorio.pdf"            |
    | Tamanho      | "2.5 MB"                   |
    | Data upload  | "Há 2 horas" (2026-02-08)  |
    | Botão download| "⬇️ Download" ou link      |
  
  When clico em "⬇️ Download" no primeiro anexo
  Then o arquivo "relatorio.pdf" (2.5 MB) é baixado com sucesso
  And o arquivo baixado é idêntico ao original
  And a requisição mostra: Content-Disposition: attachment; filename="relatorio.pdf"

---

@important
Scenario: Validar dados formatados e estruturados corretamente
  Given que estou consultando um ticket
  
  When visualizo os dados
  Then os campos exibem formato correto:
    | Campo            | Formato Esperado         | Exemplo          |
    | ID               | Numérico (5 dígitos)     | 12345            |
    | Data Criação     | ISO 8601 ou DDMMYYYY     | 2026-02-08 14:35 |
    | Status           | Enum validado            | Aberto           |
    | Prioridade       | Enum validado            | Crítica          |
    | Email            | RFC 5322                 | user@example.com |
    | Descrição        | Markdown ou HTML safe    | Sem XSS          |
  
  And datas mostram timezone consistente
  And números são formatados com separador decimal correto (pt-BR: vírgula? ou ponto?)

---

@important
Scenario: Relatórios lógicos entre campos do ticket
  Given que estou consultando um ticket
  
  When visualizo o ticket
  Then valido as relações lógicas:
    | Validação                                    | Esperado |
    | Data Criação <= Data Modificação             | Sim      |
    | Status está entre valores permitidos         | Sim      |
    | Prioridade está entre (Baixa, Média, Alta, Crítica) | Sim |
    | Responsável OU está vazio OU é usuário válido | Sim     |
    | Se Status = "Fechado", há um motivo no histórico | Sim |

---

@mobile
Scenario: Visualizar detalhes do ticket em mobile (responsividade)
  Given que estou em um dispositivo mobile (375px)
  And que acesso /tickets/12345 em mobile
  
  When a página de detalhes carrega
  Then o layout se adapta para mobile:
    - Headers empilhados em coluna
    - Badges (Status, Prioridade) ocupam largura total
    - Tabs ou accordion para organizar seções (Detalhes, Histórico, Anexos)
    - Botões de ação são stacked verticalmente
    - Fonte é legível sem zoom (mínimo 12pt)
  
  And rolagem é suave
  And toque em elementos é responsivo (44px mínimo)

---

Scenario: Compartilhar link do ticket
  Given que estou consultando o ticket ID "12345"
  And que vejo um botão "Copiar Link" ou ícone de compartilhamento
  
  When clico em "Copiar Link"
  Then o link é copiado para clipboard:
    https://helpdesk.com/tickets/12345
  And vejo notificação: "Link copiado!"
  
  When clico em "Compartilhar" (se em mobile/social)
  Then opções de compartilhamento aparecem:
    - WhatsApp
    - Email
    - Copiar link
    - Outros

---

Scenario: Imprimir detalhes do ticket
  Given que estou consultando o ticket ID "12345"
  And que vejo um botão "Imprimir" ou ícone de printer
  
  When clico em "Imprimir"
  Then a página se renderiza em formato de impressão
  And inclui:
    - Cabeçalho com logo da empresa
    - Todos os detalhes do ticket
    - Histórico de status (resumido)
    - Comentários (resumido)
    - Rodapé com timestamp de impressão
  
  When abro o diálogo de impressão (Ctrl+P)
  And clico em "Imprimir"
  Then o documento é impresso com formatação correta
  And não há elementos quebrados ou overlapping

---

## ❌ CENÁRIOS NEGATIVOS (Error Cases)

@critical
Scenario: Consultar ticket com ID inexistente (404)
  Given que estou autenticado no sistema
  And que não existe um ticket com ID "99999"
  
  When vou para a URL: /tickets/99999
  Or clico em um link para um ticket deletado
  
  Then a página carrega com status HTTP 404
  And vejo uma mensagem de erro centralizada:
    "Ticket não encontrado"
  And um ícone de "404 - Not Found" é exibido
  And dois botões são oferecidos:
    - "Voltar para Listagem"
    - "Criar Novo Ticket"
  
  When clico em "Voltar para Listagem"
  Then sou redirecionado para: /tickets
  And a listagem é exibida normalmente

---

@critical
Scenario: Consultar ticket com ID em formato inválido (não numérico)
  Given que estou autenticado no sistema
  
  When vou para URLs com ID inválido:
    | URL Inválida         | Tipo                |
    | /tickets/abc         | Texto não numérico  |
    | /tickets/123abc      | Misto               |
    | /tickets/-123        | Negativo            |
    | /tickets/12.5        | Decimal             |
    | /tickets/<script>xyz | XSS attempt         |
  
  Then a página mostra mensagem de erro:
    "ID do ticket deve ser um número válido"
  Or redireciona para /tickets com mensagem de erro: "Formato de ID inválido"
  
  And nenhum código malicioso é executado (XSS protection)
  And a URL é limpa (sanitizada)

---

@critical
Scenario: Consultar ticket sem autenticação (401)
  Given que NÃO estou autenticado no sistema
  And que vou manualmente para: /tickets/12345
  
  When a página tenta carregar
  Then recebo redirecionamento para: /login
  And vejo mensagem: "Faça login para acessar este ticket"
  And nenhum detalhe do ticket é exibido
  And a URL anterior (/tickets/12345) é salva para redirect após login

---

@critical
Scenario: Consultar ticket sem permissão (403 Forbidden)
  Given que estou autenticado como um usuário comum
  And que existe um ticket "12345" que pertence a outro usuário/empresa
  And que a política de permissão NÃO permite ver tickets de outros
  
  When vou para: /tickets/12345
  Then recebo erro HTTP 403 (Forbidden)
  And vejo mensagem: "Você não tem permissão para visualizar este ticket"
  And um botão "Voltar" leva para a listagem
  And nenhum detalhe do ticket é revelado

---

@high
Scenario: Timeout ao carregar detalhes do ticket
  Given que estou em uma conexão lenta (2G simulado)
  And que clico em um ticket para ver detalhes
  
  When a requisição demora mais de 10 segundos
  Then vejo um indicador de carregamento: "Carregando ticket..."
  
  When o timeout de 30 segundos é atingido
  Then vejo mensagem de erro:
    "Falha ao carregar o ticket. Verifique sua conexão"
  And um botão "Tentar Novamente" permite retry

---

@high
Scenario: Ticket foi deletado enquanto visualizávamos
  Given que estou visualizando o ticket ID "12345"
  And que estou há 5 minutos nesta página
  
  When em outra sessão/usuário, o ticket é deletado
  And eu clico em "Atualizar Histórico" ou a página faz auto-refresh
  
  Then a página mostra mensagem:
    "O ticket não existe mais. Pode ter sido deletado."
  And ofereço botão "Voltar para Listagem"

---

Scenario: Erro ao carregar anexos do ticket
  Given que estou consultando um ticket com anexos
  
  When o servidor retorna erro ao listar anexos
  Then a seção "Anexos" mostra:
    "Erro ao carregar anexos. Tente recarregar a página"
  And a seção de comentários e histórico continuam carregados normalmente
  And um botão "Recarregar" permite retry apenas dos anexos

---

Scenario: Arquivo anexado foi deletado do servidor
  Given que um ticket tinha um arquivo anexado
  And que agora o arquivo foi deletado do armazenamento
  
  When visualizo os detalhes do ticket
  And o anexo aparece na lista mas:
  When clico em "Download"
  Then recebo erro 404: "Arquivo não encontrado"
  And a seção mostra: "⚠️ Este arquivo não está mais disponível"

---

Scenario: Histórico com muitos registros (performance)
  Given que estou consultando um ticket com 500+ eventos no histórico
  
  When a página carrega
  Then apenas os 20 primeiros eventos são carregados imediatamente
  And vejo um botão: "Mostrar 20 eventos antigos"
  Or a página usa infinita scroll para carregar dinamicamente
  
  And a página permanece responsiva (não congela)
  And scrolear não causa lag

---

Scenario: Dados sensíveis não são expostos na resposta
  Given que estou consultando um ticket
  
  When analiso a resposta HTTP (DevTools → Network)
  Then a resposta NÃO contém:
    - Senhas
    - Tokens de API
    - Informações de cartão de crédito
    - SSN, CPF, documentos sensíveis (não deviam estar lá mesmo)
  
  And apenas dados públicos/autorizados para este usuário são retornados

---

Scenario: Tentar acessar ticket de outro usuário (isolamento multi-tenant)
  Given que estou autenticado como empresa "EMPRESA A"
  And que existe ticket ID "12345" que pertence a "EMPRESA B"
  
  When vou para: /tickets/12345
  Then recebo erro 403 (Forbidden)
  And nenhum detalhe é revelado
  And logs registram tentativa de acesso não autorizado

---

## 📊 ESTRUTURA DOS DADOS RETORNADOS

Exemplo de resposta JSON completa:

```json
{
  "id": 12345,
  "titulo": "Erro ao fazer login",
  "descricao": "Não consigo acessar o sistema...",
  "status": "aberto",
  "prioridade": "critica",
  "categoria": "pagamento",
  "criador": {
    "id": "user-1",
    "nome": "João Silva",
    "email": "joao@exemplo.com",
    "avatar": "https://..."
  },
  "responsavel": {
    "id": "user-2",
    "nome": "Maria Santos",
    "email": "maria@empresa.com"
  },
  "data_criacao": "2026-02-08T14:35:00Z",
  "data_modificacao": "2026-02-08T16:20:00Z",
  "anexos": [
    {
      "id": "file-1",
      "nome": "relatorio.pdf",
      "tamanho": 2621440,
      "tipo": "application/pdf",
      "url_download": "/api/tickets/12345/attachments/file-1",
      "data_upload": "2026-02-08T14:40:00Z"
    }
  ],
  "comentarios": [
    {
      "id": "comment-1",
      "autor": {...},
      "texto": "Já validei...",
      "data_criacao": "2026-02-08T11:30:00Z"
    }
  ],
  "historico": [
    {
      "id": "event-1",
      "tipo": "status_change",
      "status_anterior": "aberto",
      "status_novo": "em_andamento",
      "data": "2026-02-08T10:15:00Z",
      "usuario": {...}
    }
  ]
}
```

---

## 🔐 VALIDAÇÕES DE SEGURANÇA

Ao consultar um ticket, o sistema deve:

- ✅ Validar token/sessão do usuário
- ✅ Verificar permissões (RBAC: Admin, Manager, Support, User)
- ✅ Sanitizar inputs (ID do ticket)
- ✅ Prevenir SQL Injection
- ✅ Prevenir XSS (especialmente em comentários/descrição)
- ✅ Não expor dados sensíveis
- ✅ Logar acessos (audit trail)
- ✅ Rate limit (impedir enumeration de IDs)

---

## 🏷️ TAGS DE PRIORIDADE

@smoke       → Testes essenciais (5 min)
@critical    → Bugs bloqueadores (15 min)
@important   → Funcionalidades chave (30 min)
@mobile      → Responsividade mobile

---

## 📋 CHECKLIST DE EXECUÇÃO

Salvar em `testes-manuais/execution-logs/TC004-YYYY-MM-DD-executor.md`:

```markdown
# TC004 - Consultar Ticket - Execution Log

**Data**: 2026-02-08
**Executor**: [Seu nome]
**Navegador**: [Chrome] - [131.0]
**Ambiente**: [staging]
**Tempo Total**: [30 min]

## Resumo
- [ ] Scenario 1 (Consultar por ID válido): ✅ PASSOU
- [ ] Scenario 2 (Todos os campos): ✅ PASSOU
- [ ] Scenario 3 (Histórico): ✅ PASSOU
- [ ] Scenario 4 (ID inexistente): ✅ PASSOU
- [ ] Scenario 5 (ID inválido): ✅ PASSOU
- [ ] Scenario 6 (Sem autenticação): ✅ PASSOU

## Bugs Encontrados
Nenhum

## Status Final
✅ 100% PASSOU (6/6 cenários críticos)
```

---

**Documento criado**: Fevereiro 2026
**Última atualização**: 2026-02-08
**Status**: 📋 Pronto para execução manual

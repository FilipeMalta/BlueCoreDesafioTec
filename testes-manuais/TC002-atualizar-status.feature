# language: pt
Feature: Atualizar Status de Ticket no Sistema Helpdesk
  Como um support agent ou usuário
  Quero atualizar o status de um ticket
  Para refletir o progresso na resolução do problema

  Contexto (Background):
    Pré-condições que se aplicam a todos os cenários
    - Usuário deve estar autenticado no sistema
    - Deve existir um ticket válido para ser atualizado
    - Sistema deve estar funcionando normalmente

  Resumo de Critérios de Aceite:
    ✅ Status válidos: Aberto, Em Andamento, Fechado, Reaberto
    ✅ Transições permitidas:
        Aberto → Em Andamento
        Aberto → Fechado
        Em Andamento → Fechado
        Em Andamento → Aberto
        Fechado → Reaberto (se houver motivo)
    ✅ Transições NÃO permitidas:
        Fechado → Em Andamento (deve reabrir primeiro)
        Aberto → Aberto (sem mudança)
    ✅ Ao alterar status, deve exibir mensagem de sucesso
    ✅ Cada mudança de status deve ser registrada no histórico
    ✅ Histórico deve conter: Data/Hora, Status Anterior, Status Novo, Usuário, Motivo (se houver)
    ✅ Status anterior não deve desaparecer dos registros
    ✅ Ticket deve ser atualizado imediatamente na lista após mudança
    ✅ Apenas usuários com permissão devem conseguir alterar status
    ✅ Não deve haver race condition se múltiplos usuários alterarem simultaneamente

---

## ✅ CENÁRIOS POSITIVOS (Happy Path)

@smoke @critical
Scenario: Atualizar status de Aberto para Em Andamento
  Given que estou autenticado no sistema como "support@empresa.com"
  And que existe um ticket com ID "12345" no status "Aberto"
  And que o ticket foi criado há 5 minutos
  And que estou na página de detalhes do ticket "12345"
  And que vejo o campo "Status" exibindo "🔴 Aberto"
  
  When clico no campo "Status" ou no botão "Atualizar Status"
  Then um dropdown com opções de status é exibido:
    | Status       | Descrição                    | Disponível |
    | Em Andamento | Começar a trabalhar no caso | Sim        |
    | Fechado      | Resolver e fechar o caso    | Sim        |
  
  When seleciono "Em Andamento"
  Then uma caixa de diálogo opcional aparece:
    | Campo      | Tipo     | Obrigatório |
    | Motivo     | Text     | Não         |
    | Comentário | Text     | Não         |
  
  When clico em "Confirmar" (sem preencher motivo, pois é opcional)
  Then vejo uma mensagem de sucesso: "Status atualizado com sucesso!"
  And o campo "Status" muda para "🟡 Em Andamento"
  And o ticket é movido na lista para a seção "Em Andamento"
  And um novo registro aparece na seção "Histórico de Status":
    | Campo         | Valor                              |
    | Data/Hora     | 2026-02-08 14:35 (timestamp atual) |
    | Status Anterior | Aberto                           |
    | Status Novo   | Em Andamento                       |
    | Alterado por  | support@empresa.com                |
    | Motivo        | (vazio)                            |

---

@smoke @critical
Scenario: Atualizar status de Em Andamento para Fechado
  Given que estou na página de detalhes de um ticket
  And que o ticket está no status "Em Andamento"
  And que o ticket foi criado há 1 hora
  
  When clico em "Atualizar Status"
  Then o dropdown exibe as opções disponíveis:
    | Status       | Disponível |
    | Aberto       | Sim        |
    | Fechado      | Sim        |
  
  When seleciono "Fechado"
  Then uma caixa de diálogo aparece com campos:
    | Campo      | Obrigatório | Tipo     |
    | Motivo     | Sim         | Dropdown |
    | Comentário | Não         | Text     |
  
  And o dropdown "Motivo" contém as opções:
    | Motivo              |
    | Resolvido           |
    | Duplicado           |
    | Sem mais informações |
    | Não é um problema   |
    | Cancelado pelo usuário |
  
  When seleciono "Resolvido" no campo "Motivo"
  And preencho comentário com "Problema resolvido com sucesso aplicando patch v1.2.3"
  And clico em "Confirmar"
  
  Then vejo mensagem de sucesso: "Ticket fechado com sucesso!"
  And o campo "Status" muda para "🟢 Fechado"
  And a cor do ícone muda para verde
  And um novo registro é adicionado ao "Histórico de Status":
    | Campo         | Valor                |
    | Data/Hora     | 2026-02-08 15:35     |
    | Status Anterior | Em Andamento       |
    | Status Novo   | Fechado              |
    | Alterado por  | support@empresa.com  |
    | Motivo        | Resolvido            |
    | Comentário    | Problema resolvido... |

---

@smoke @critical
Scenario: Atualizar status de Aberto para Fechado (sem passar por Em Andamento)
  Given que estou na página de detalhes de um ticket
  And que o ticket está no status "Aberto"
  And que a descrição do ticket é clara e o problema parece simples de resolver
  
  When clico em "Atualizar Status"
  Then o dropdown exibe:
    | Status       | Disponível |
    | Em Andamento | Sim        |
    | Fechado      | Sim        |
  
  When seleciono "Fechado" (sem passar por Em Andamento)
  Then a caixa de diálogo exige o campo "Motivo"
  
  When preencho "Motivo" com "Não é um problema"
  And preencho "Comentário" com "Parece ser comportamento esperado do sistema"
  And clico em "Confirmar"
  
  Then o ticket muda diretamente de "Aberto" para "Fechado"
  And ambas as mudanças são registradas no histórico:
    | Status Anterior | Status Novo | Motivo              |
    | Aberto          | Fechado     | Não é um problema   |

---

@important
Scenario: Reabrir um ticket já fechado
  Given que estou na página de detalhes de um ticket
  And que o ticket está no status "Fechado"
  And que foi fechado há 2 horas com motivo "Resolvido"
  
  When clico em "Atualizar Status"
  Then o dropdown exibe opções limitadas:
    | Status      | Disponível |
    | Reaberto    | Sim        |
    | Aberto      | Sim        |
  
  When seleciono "Reaberto"
  Then uma caixa de diálogo aparece com:
    | Campo      | Obrigatório |
    | Motivo     | Sim         |
    | Comentário | Não         |
  
  And o dropdown "Motivo" contém:
    | Motivo              |
    | Problema persistiu  |
    | Solução não funciona|
    | Contexto mudou      |
    | Erro na resolução   |
  
  When seleciono "Problema persistiu"
  And preencho comentário: "O patch não resolveu. Ainda vejo o erro X"
  And clico em "Confirmar"
  
  Then o ticket muda de "Fechado" para "Reaberto"
  And o histórico registra:
    | Campo         | Valor                      |
    | Status Anterior | Fechado                  |
    | Status Novo   | Reaberto                   |
    | Motivo        | Problema persistiu         |
    | Comentário    | O patch não resolveu...    |
    | Timestamp     | 2026-02-08 16:35           |

---

@important
Scenario: Visualizar histórico completo de mudanças de status
  Given que estou na página de detalhes de um ticket
  And que o ticket passou por múltiplas mudanças de status:
    | Timestamp            | Status Anterior | Status Novo  | Motivo                |
    | 2026-02-08 10:00 | -               | Aberto       | Criação inicial       |
    | 2026-02-08 10:15 | Aberto          | Em Andamento | -                     |
    | 2026-02-08 11:30 | Em Andamento    | Fechado      | Resolvido             |
    | 2026-02-08 14:45 | Fechado         | Reaberto     | Problema persistiu    |
    | 2026-02-08 15:20 | Reaberto        | Em Andamento | -                     |
  
  When rolo para baixo até a seção "Histórico de Status"
  Then vejo uma tabela com todas as mudanças em ordem cronológica inversa (mais recente primeiro):
    | Timestamp            | De              | Para         | Por                  | Motivo                |
    | 2026-02-08 15:20 | Reaberto        | Em Andamento | support@empresa.com  | -                     |
    | 2026-02-08 14:45 | Fechado         | Reaberto     | admin@empresa.com    | Problema persistiu    |
    | 2026-02-08 11:30 | Em Andamento    | Fechado      | support@empresa.com  | Resolvido             |
    | 2026-02-08 10:15 | Aberto          | Em Andamento | support@empresa.com  | -                     |
    | 2026-02-08 10:00 | -               | Aberto       | user@empresa.com     | Criação inicial       |
  
  And cada linha do histórico é clicável
  And ao clicar em uma linha, vejo detalhes completos da mudança:
    - Data/Hora exata com milissegundos
    - IP do usuário que fez a mudança
    - Comentário/Motivo completo
    - Campos afetados (se houver mais que status)

---

@important
Scenario: Status é atualizado em tempo real na lista de tickets
  Given que tenho 2 janelas do navegador abertas:
    - Janela 1: Detalhes do ticket "12345" (Status: Aberto)
    - Janela 2: Listagem de tickets
  And ambas estão em https://helpdesk.com
  
  When na Janela 1, atualizo o status para "Em Andamento"
  And clico em "Confirmar"
  
  Then na Janela 1:
    - Vejo mensagem de sucesso
    - O status muda para "🟡 Em Andamento"
  
  When navegando para a Janela 2
  And sem recarregar a página (F5)
  Then o ticket "12345" na listagem ainda mostra status "Aberto"
  
  When atualizo a página (F5)
  Then o ticket "12345" agora mostra status "🟡 Em Andamento"
  And aparece em uma seção diferente da lista (se filtrada por status)

---

## ❌ CENÁRIOS NEGATIVOS (Error Cases)

@critical
Scenario: Tentar atualizar status de um ticket que não existe
  Given que estou autenticado no sistema
  And que vou manualmente para a URL: /tickets/99999 (ID inexistente)
  
  When a página carrega
  Then vejo uma mensagem de erro: "Ticket não encontrado"
  And a página mostra um botão "Voltar para Listagem"
  And o campo "Atualizar Status" não está disponível
  
  When clico no botão "Voltar para Listagem"
  Then sou redirecionado para a listagem de tickets
  And nenhuma alteração foi feita

---

@critical
Scenario: Tentar alterar para um status inválido
  Given que estou autenticado no sistema
  And que estou na página de detalhes de um ticket válido
  And o status atual é "Aberto"
  
  When tento manipular a URL ou a requisição para enviar um status inválido:
    POST /api/tickets/12345/status
    {"status": "NãoExiste"}
  
  Then o servidor responde com erro HTTP 400 (Bad Request)
  And a resposta contém: {"error": "Status inválido. Valores permitidos: Aberto, Em Andamento, Fechado, Reaberto"}
  And o status do ticket permanece "Aberto" (sem mudança)
  And na página exibida, vejo mensagem de erro: "Status inválido"

---

@critical
Scenario: Tentar atualizar status sem permissão (Usuário comum)
  Given que estou autenticado como um usuário comum (não support/admin)
  And que estou na página de detalhes de um ticket "12345"
  And que o ticket está no status "Aberto"
  
  When procuro pelo campo "Atualizar Status" ou "Alterar Status"
  Then o campo NÃO está disponível
  And vejo mensagem: "Apenas agents de support podem alterar o status"
  And o status é exibido apenas como texto, sem opção de clique/dropdown
  
  When tento fazer uma requisição direta POST /api/tickets/12345/status
  Then o servidor responde com erro HTTP 403 (Forbidden)
  And a resposta contém: {"error": "Você não tem permissão para alterar este ticket"}

---

@critical
Scenario: Tentar transição de status inválida (Fechado → Em Andamento direto)
  Given que estou autenticado como support
  And que estou na página de detalhes de um ticket
  And que o ticket está no status "Fechado"
  
  When clico em "Atualizar Status"
  Then o dropdown NÃO exibe "Em Andamento" como opção
  And o dropdown apenas exibe:
    | Status     |
    | Reaberto   |
    | Aberto     |
  
  And há uma mensagem explicativa: "Tickets fechados devem ser reabertos antes de ir para Em Andamento"

---

@high
Scenario: Tentar fechar ticket sem informar motivo (quando obrigatório)
  Given que estou na página de detalhes de um ticket
  And que o ticket está no status "Em Andamento"
  
  When clico em "Atualizar Status"
  And seleciono "Fechado"
  Then a caixa de diálogo aparece com campo "Motivo" obrigatório
  
  When deixo o campo "Motivo" vazio
  And clico em "Confirmar"
  Then vejo mensagem de erro: "Motivo é obrigatório para fechar um ticket"
  And o botão "Confirmar" está desabilitado
  And nenhuma requisição é enviada para o servidor
  And o diálogo permanece aberto com os dados preenchidos

---

@high
Scenario: Atualizar para o mesmo status (idempotência)
  Given que estou na página de detalhes de um ticket
  And que o ticket está no status "Em Andamento"
  
  When clico em "Atualizar Status"
  And seleciono "Em Andamento" (mesmo status atual)
  
  Then uma de duas coisas acontece:
    Opção A: Mensagem informativa "Ticket já está neste status"
    Opção B: Deixa atualizar, mas não registra no histórico
  
  And o botão "Confirmar" fica desabilitado ou a ação é ignorada

---

@high
Scenario: Race condition: Dois usuários atualizando status simultaneamente
  Given que dois support agents estão visualizando o mesmo ticket "12345"
  And ambos veem status atual "Aberto"
  And ambos clicam em "Atualizar Status" ao mesmo tempo
  And Agent 1 seleciona "Em Andamento"
  And Agent 2 seleciona "Fechado"
  
  When Agent 1 clica em "Confirmar" primeiro
  Then o status muda para "Em Andamento"
  And o histórico registra: Agent 1 → Em Andamento (14:35)
  
  When Agent 2 clica em "Confirmar" (segundos depois)
  Then Agent 2 recebe um erro de conflito HTTP 409 (Conflict)
  And a mensagem de erro é: "Este ticket foi atualizado por outro usuário. Status atual é: Em Andamento"
  And é oferecida a opção de:
    - Cancelar a mudança
    - Recarregar e visualizar o novo status
    - Forçar a mudança (com override - apenas admin)

---

@high
Scenario: Validar integridade do histórico (não pode ser deletado/editado)
  Given que estou na página de detalhes de um ticket
  And que visualizo o histórico de status com 5 registros
  
  When tento clicar em "Editar" ou "Deletar" em um registro histórico
  Then essas opções NÃO estão disponíveis (nenhum botão mostrado)
  
  And quando vejo o histórico novamente sempre exibe todos os registros
  And a ordem cronológica nunca muda
  And os timestamps nunca mudam

---

Scenario: Desconexão durante atualização de status
  Given que estou na página de detalhes de um ticket
  And que clico em "Atualizar Status" → "Fechado"
  And que estou preenchendo o motivo
  
  When a conexão de internet é perdida (simular com DevTools)
  And clico em "Confirmar"
  
  Then vejo uma mensagem de erro: "Falha na conexão. Verifique sua internet"
  And o diálogo permanece aberto com dados intactos
  And o ticket no servidor mantém status anterior (Aberto)
  
  When a conexão é restaurada
  And clico em "Confirmar" novamente
  Then o status é atualizado com sucesso
  And o histórico registra apenas uma mudança (não duplicada)

---

Scenario: Atualizar status com timestamp correto mesmo com relógio do cliente errado
  Given que a máquina local tem relógio desincronizado (5 horas atrasado)
  And estou na página de detalhes de um ticket
  
  When atualizo o status
  And clico em "Confirmar"
  
  Then o ticket é atualizado
  And o histórico registra o timestamp correto do servidor (não do cliente)
  And o timestamp é: 2026-02-08 15:35 (hora real do servidor, não 10:35)

---

## 🔄 FLUXO DE TRANSIÇÃO DE ESTADOS

```
┌──────────┐
│  Aberto  │◄─────────────────────────┐
└────┬─────┘                          │
     │                                │
     ├──→ Em Andamento ──→ Fechado   │
     │                        │       │
     └──→ Fechado (direto)    │       │
                              │       │
                          Reaberto ──┘
```

**Transições válidas**:
- Aberto → Em Andamento ✅
- Aberto → Fechado ✅
- Em Andamento → Fechado ✅
- Em Andamento → Aberto ✅
- Fechado → Reaberto ✅
- Fechado → Aberto ✅
- Reaberto → Em Andamento ✅
- Reaberto → Fechado ✅

**Transições inválidas**:
- Fechado → Em Andamento ❌ (deve reabrir primeiro)

---

## 📋 CAMPOS DO HISTÓRICO

Cada registro no histórico deve conter:

```
{
  "id": "hist-001",
  "timestamp": "2026-02-08T15:35:42Z",
  "status_anterior": "Aberto",
  "status_novo": "Em Andamento",
  "usuario_id": "user-123",
  "usuario_nome": "João da Silva",
  "usuario_email": "joao@empresa.com",
  "motivo": null,
  "comentario": null,
  "ip_origem": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "ticket_id": "12345"
}
```

**Nunca deve incluir**:
- Dados sensíveis (senha, token)
- Informações de outro usuário sem permissão

---

## 🏷️ TAGS DE PRIORIDADE

@smoke       → Testes essenciais (5 min)
@critical    → Bugs bloqueadores (15 min)
@important   → Funcionalidades chave (30 min)
@high        → Casos diversos (1x/semana)

---

## 📋 CHECKLIST DE EXECUÇÃO

Salvar em `testes-manuais/execution-logs/TC002-YYYY-MM-DD-executor.md`:

```markdown
# TC002 - Atualizar Status - Execution Log

**Data**: 2026-02-08
**Executor**: [Seu nome]
**Navegador**: [Chrome/Firefox] - [versão]
**Ambiente**: [staging/prod]
**Tempo Total**: [X min]

## Resumo
- [ ] Scenario 1 (Aberto → Em Andamento): ✅ PASSOU
- [ ] Scenario 2 (Em Andamento → Fechado): ✅ PASSOU
- [ ] Scenario 3 (Aberto → Fechado): ✅ PASSOU
- [ ] Scenario 4 (Transição inválida): ✅ PASSOU
- [ ] Scenario 5 (Histórico): ❌ FALHOU - Bug: [descrição]

## Bugs Encontrados
- BUG-002-status-race-condition

## Status Final
✅ 80% PASSOU (8/10 cenários)
```

---

**Documento criado**: Fevereiro 2026
**Última atualização**: 2026-02-08
**Status**: 📋 Pronto para execução manual

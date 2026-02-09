# Testes Manuais

## Criar Ticket

| Cenário | Passos | Resultado Esperado |
|---------|--------|-------------------|
| TC-01: Dados válidos | Preencher título, descrição, prioridade Alta. Clicar Salvar | Ticket criado, mensagem sucesso, aparece na listagem |
| TC-02: Prioridade Média | Preencher dados com prioridade Média e salvar | Ticket criado com prioridade Média exibida |
| TC-03: Prioridade Baixa | Preencher dados com prioridade Baixa e salvar | Ticket criado com prioridade Baixa exibida |
| TC-04: Sem título | Deixar título em branco, preencher descrição e tentar salvar | Validação impede, erro "Título obrigatório" |
| TC-05: Sem descrição | Deixar descrição em branco, preencher título e tentar salvar | Validação impede, erro "Descrição obrigatória" |
| TC-06: XSS no título | Preencher título com `<script>alert('xss')</script>` e salvar | Salva, mas conteúdo é escapado (não executa) |
| TC-07: Cancelar | Preencher dados e clicar Cancelar | Não cria ticket, volta para listagem, dados descartados |

## Atualizar Status

| Cenário | Passos | Resultado Esperado |
|---------|--------|-------------------|
| TC-08: Aberto → Em andamento | Abrir ticket com status Aberto, mudar para Em andamento, salvar | Status atualizado, mensagem sucesso |
| TC-09: Em andamento → Fechado | Abrir ticket, mudar de Em andamento para Fechado, salvar | Status atualizado para Fechado |
| TC-10: Aberto → Fechado direto | Abrir ticket Aberto, mudar direto para Fechado, salvar | Status atualizado sem forçar estados intermediários |
| TC-11: Transição inválida | Abrir ticket Fechado, tentar mudar para Em andamento | Sistema nega, erro "Transição inválida" |
| TC-12: Status inválido | Tentar mandar status inválido via inspect (backend) | Backend rejeita, ticket mantém status anterior |
| TC-13: Concorrência | Duas abas: Tab A muda status para Em andamento (salva). Tab B muda para Fechado (salva) | Um recebe erro de conflito, nenhum dado é corrompido |
| TC-14: Apenas status | Abrir ticket, mudar APENAS status (não tocar outros campos), salvar | Apenas status muda, título/descrição/prioridade se mantêm |

## Riscos Principais

- Perda de dados ao criar/atualizar
- Transições de status inválidas
- Validação inadequada (SQL injection, XSS)
- Concorrência (dois usuários mesmo ticket)

## Priorização

Automatizar primeiro: Criar ticket + Atualizar status (maior ROI)

Depois: Validações, listar/filtrar

Manuais: Casos de XSS, concorrência, edge cases

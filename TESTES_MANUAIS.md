# Testes Manuais

## Criar Ticket

**TC-01: Dados válidos**
- Preencher: título, descrição, prioridade Alta
- Clicar: Salvar
- Resultado: Ticket criado com sucesso, aparece na listagem

**TC-02: Prioridade Média**
- Preencher: dados com prioridade Média
- Resultado: Ticket criado, prioridade exibe como Média

**TC-03: Prioridade Baixa**
- Preencher: dados com prioridade Baixa
- Resultado: Ticket criado, prioridade exibe como Baixa

**TC-04: Sem título (negativo)**
- Deixar: título em branco
- Clicar: Salvar
- Resultado: Validação nega criação, erro "Título obrigatório"

**TC-05: Sem descrição (negativo)**
- Deixar: descrição em branco
- Clicar: Salvar
- Resultado: Validação nega criação, erro "Descrição obrigatória"

**TC-06: XSS (segurança)**
- Preencher título: `<script>alert('xss')</script>`
- Clicar: Salvar
- Resultado: Ticket criado, conteúdo é escapado (não executa)

**TC-07: Cancelar**
- Preencher: título e descrição
- Clicar: Cancelar
- Resultado: Ticket não é criado, volta para listagem

## Atualizar Status

**TC-08: Aberto → Em andamento**
- Abrir: ticket com status Aberto
- Mudar: status para Em andamento
- Resultado: Status atualizado com sucesso

**TC-09: Em andamento → Fechado**
- Abrir: ticket com status Em andamento
- Mudar: status para Fechado
- Resultado: Status atualizado para Fechado

**TC-10: Aberto → Fechado direto**
- Abrir: ticket com status Aberto
- Mudar: direto para Fechado (pulando intermediários)
- Resultado: Transição permitida, sem forçar estados

**TC-11: Transição inválida (negativo)**
- Abrir: ticket com status Fechado
- Tentar: mudar para Em andamento
- Resultado: Sistema nega, erro "Transição inválida"

**TC-12: Status inválido (backend)**
- Tentar: enviar status inválido
- Resultado: Backend rejeita, ticket mantém status anterior

**TC-13: Concorrência**
- Abrir: mesmo ticket em duas abas
- Tab A: muda para Em andamento (salva)
- Tab B: muda para Fechado (salva)
- Resultado: Um recebe erro de conflito, dados não são corrompidos

**TC-14: Atualizar apenas status**
- Abrir: ticket
- Mudar: APENAS status (não tocar outros campos)
- Resultado: Apenas status é alterado, outros dados se mantêm

## Riscos

- Perda de dados ao criar/atualizar
- Transições de status inválidas
- Validação inadequada (SQL injection, XSS)
- Concorrência (dois usuários mesmo ticket)

## Priorização

Automatizar primeiro: Criar + Atualizar status (ROI alto)

Depois: Validações, listar/filtrar

Manuais: XSS, concorrência, edge cases

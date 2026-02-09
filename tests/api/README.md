# API Tests

Testes de endpoint usando JSONPlaceholder (serviço de mock para testes).

## Como Rodar

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /users | Listar todos |
| GET | /users/:id | Buscar um |
| POST | /users | Criar novo |
| PUT | /users/:id | Atualizar |
| DELETE | /users/:id | Deletar |

## Como Executar

```bash
# Todos os testes
npm test

# Apenas testes de API
npx playwright test tests/api

# Com interface interativa
npm run test:ui tests/api

# Com navegador visível
npm run test:headed tests/api

# Teste específico
npx playwright test -g "Deve retornar lista de usuários"
```

## Validações em Cada Teste

Status code, Content-Type, estrutura de resposta, tipos de dados.

Exemplo:
```typescript
const response = await request.get(`${BASE_URL}/users/1`);
expect(response.status()).toBe(200);                              // Status
expect(response.headers()['content-type']).toContain('application/json'); // Header
const user = await response.json();
expect(user).toHaveProperty('id');                              // Estrutura
expect(typeof user.id).toBe('number');                          // Tipo
expect(user.id).toBe(1);                                        // Conteúdo
```

## Cenários

26 testes cobrindo:
- GET /users (lista, array, estrutura, tipos)
- GET /users/:id (específico, 404, email válido)
- POST /users (criar, resposta, JSON, dados mínimos)
- PUT /users/:id (atualizar, resposta, atualização parcial)
- DELETE /users/:id (deletar, resposta, Content-Type)
- Validação (404, range, email regex, username, timeout)
- Performance (GET /users < 2s, GET /users/:id < 1s)

## Interpretar Resultados

## Quando Falha

Status code errado, property faltando, tipo incorreto, timeout.

Ações: verificar API, conferir estrutura, ver logs.

## Debug

Se falhar: `npm run test:headed tests/api` ou `npm run test:debug tests/api`

Ver relatório: `npm run report`

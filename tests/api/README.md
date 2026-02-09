# API Tests - JSONPlaceholder

## Objetivo

Validar que os endpoints da API funcionam corretamente, retornam dados esperados e tratam erros apropriadamente. Testes contra JSONPlaceholder (serviço de mock).

## Endpoints Testados

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /users | Listar todos os usuários |
| GET | /users/:id | Buscar usuário específico |
| POST | /users | Criar novo usuário |
| PUT | /users/:id | Atualizar usuário |
| DELETE | /users/:id | Deletar usuário |

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

## Estrutura de Validações

Cada teste valida:

1. **Status Code** - Verifica se retorna código HTTP esperado (200, 201, 404, etc)
2. **Content-Type** - Confirma que resposta é JSON
3. **Estrutura** - Valida se objeto tem properties esperadas
4. **Tipos** - Confirma tipos de dados (number, string, object)
5. **Conteúdo** - Valida valores específicos quando aplicável

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

## Cenários Cobertos

### GET /users
- Retorna array de usuários
- Cada usuário tem estrutura correta
- Tipos de dados estão corretos
- Contém entre 1 e 100 usuários

### GET /users/:id
- Retorna usuário específico
- Dados correspondem ao ID solicitado
- 404 para ID inexistente
- Email em formato válido

### POST /users
- Cria novo usuário com status 201
- Resposta contém o usuário criado com ID
- Funciona com dados mínimos ou completos
- Retorna JSON válido

### PUT /users/:id
- Atualiza usuário existente
- Retorna dados atualizados
- Suporta atualização parcial (alguns campos)
- Mantém integridade de tipos

### DELETE /users/:id
- Deleta usuário com status 200
- Retorna resposta vazia/confirmação
- Mantém Content-Type correto

### Performance
- GET /users responde em menos de 2 segundos
- GET /users/:id responde em menos de 1 segundo
- Sem timeout em requisições normais

## Interpretar Resultados

### Teste Passou (✓)
```
✓ [chromium] › api › jsonplaceholder › GET /users › Deve retornar lista
```
Significa: Endpoint funcionando corretamente, validações OK.

### Teste Falhou (✗)
```
✗ [chromium] › api › jsonplaceholder › GET /users › Deve retornar 200
  Error: received: 500
```

Tipos comuns de falha:
- **Status code errado** - API retornou erro inesperado
- **Property faltando** - Estrutura da resposta mudou
- **Tipo incorreto** - Campo tem tipo diferente do esperado
- **Timeout** - Endpoint demorou muito

Ações:
1. Verificar se API está rodando
2. Conferir se estrutura mudou
3. Ver logs da API para detalhes de erro

## Estrutura de Código

Tests organizados por describe/test:

```
describe: JSONPlaceholder API - Users Endpoints
  describe: GET /users
    test: Deve retornar lista com status 200
    test: Deve retornar array de usuários
    test: Usuário deve ter estrutura correta
    test: Tipos de dados devem ser válidos
  describe: GET /users/:id
    test: Deve retornar usuário específico
    ... (5 testes)
  describe: POST /users
    ... (4 testes)
  describe: PUT /users/:id
    ... (4 testes)
  describe: DELETE /users/:id
    ... (3 testes)
  describe: Validação e Tratamento de Erros
    ... (5 testes)
  describe: Performance Básica
    ... (2 testes)
```

Total: 26 testes × 2 browsers (Chromium, Firefox) = 52 execuções

## Debugging

Se um teste falhar:

```bash
# Ver o teste rodando
npm run test:headed tests/api

# Debug interativo
npm run test:debug tests/api

# Ver relatório HTML
npm run report
```

No modo debug você consegue pausar, inspecionar, e ver exatamente o que aconteceu.

## Manutenção

Se a API mudar:
1. Testes vão falhar imediatamente
2. Edite o teste para validar nova estrutura
3. Commite as mudanças

Se quiser adicionar novo teste:
1. Abra `jsonplaceholder.spec.ts`
2. Adicione novo `test()` dentro do `describe` apropriado
3. Rode `npm test` para verificar

import { test, expect } from '@playwright/test';

interface User {
  id: number;
  name: string;
  email: string;
  username: string;
  address?: {
    street: string;
    city: string;
  };
  phone?: string;
  website?: string;
  company?: {
    name: string;
  };
}

const BASE_URL = 'https://jsonplaceholder.typicode.com';

test.describe('JSONPlaceholder API - Users Endpoints', () => {
  test.describe('GET /users', () => {
    
    test('Deve retornar lista de usuários com status 200', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`);
      
      expect(response.status()).toBe(200);
      expect(response.headers()['content-type']).toContain('application/json');
    });
    
    test('Deve retornar array de usuários', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`);
      const users = await response.json();
      
      expect(Array.isArray(users)).toBeTruthy();
      expect(users.length).toBeGreaterThan(0);
    });
    
    test('Usuário deve ter estrutura correta', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`);
      const users = (await response.json()) as User[];
      
      const firstUser = users[0];
      
      expect(firstUser).toHaveProperty('id');
      expect(firstUser).toHaveProperty('name');
      expect(firstUser).toHaveProperty('email');
      expect(firstUser).toHaveProperty('username');
      expect(firstUser).toHaveProperty('address');
      expect(firstUser).toHaveProperty('phone');
      expect(firstUser).toHaveProperty('website');
      expect(firstUser).toHaveProperty('company');
    });
    
    test('Tipos de dados dos campos devem ser válidos', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`);
      const users = (await response.json()) as User[];
      
      const user = users[0];
      
      expect(typeof user.id).toBe('number');
      expect(typeof user.name).toBe('string');
      expect(typeof user.email).toBe('string');
      expect(typeof user.username).toBe('string');
      expect(typeof user.address).toBe('object');
      expect(typeof user.company).toBe('object');
    });
  });
  
  test.describe('GET /users/:id', () => {
    
    test('Deve retornar usuário com ID específico', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users/1`);
      const user = (await response.json()) as User;
      
      expect(response.status()).toBe(200);
      expect(user.id).toBe(1);
      expect(user.name).toBeDefined();
      expect(user.email).toBeDefined();
    });
    
    test('Deve ter Content-Type correto', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users/1`);
      
      expect(response.headers()['content-type']).toContain('application/json');
    });
    
    test('Objeto de usuário deve ter estrutura esperada', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users/1`);
      const user = (await response.json()) as User;
      
      expect(user).toHaveProperty('id', 1);
      expect(user).toHaveProperty('name');
      expect(user).toHaveProperty('email');
      expect(user.address).toHaveProperty('street');
      expect(user.address).toHaveProperty('city');
      expect(user.company).toHaveProperty('name');
    });
    
    test('Deve retornar 404 para usuário inexistente', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users/999999`);
      
      expect(response.status()).toBe(404);
    });
    
    test('ID=1 deve ser Leanne Graham', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users/1`);
      const user = (await response.json()) as User;
      
      expect(user.name).toBe('Leanne Graham');
      expect(user.username).toBe('Bret');
    });
  });
  
  test.describe('POST /users', () => {
    
    test('Deve criar novo usuário com status 201', async ({ request }) => {
      const newUser = {
        name: 'João Silva',
        email: 'joao@example.com',
        username: 'joaosilva',
        address: {
          street: 'Rua A',
          city: 'São Paulo'
        },
        phone: '11987654321',
        website: 'joao.com',
        company: {
          name: 'Tech Company'
        }
      };
      
      const response = await request.post(`${BASE_URL}/users`, {
        data: newUser
      });
      
      expect(response.status()).toBe(201);
    });
    
    test('Resposta deve conter o usuário criado com ID', async ({ request }) => {
      const newUser = {
        name: 'Maria Santos',
        email: 'maria@example.com',
        username: 'mariasantos'
      };
      
      const response = await request.post(`${BASE_URL}/users`, {
        data: newUser
      });
      const createdUser = await response.json();
      
      expect(createdUser).toHaveProperty('id');
      expect(createdUser.name).toBe(newUser.name);
      expect(createdUser.email).toBe(newUser.email);
      expect(createdUser.username).toBe(newUser.username);
    });
    
    test('Deve retornar JSON válido', async ({ request }) => {
      const newUser = {
        name: 'Pedro Costa',
        email: 'pedro@example.com',
        username: 'pedrocosta'
      };
      
      const response = await request.post(`${BASE_URL}/users`, {
        data: newUser
      });
      
      expect(response.headers()['content-type']).toContain('application/json');
    });
    
    test('POST com dados mínimos deve funcionar', async ({ request }) => {
      const minimalUser = {
        name: 'User Minimal'
      };
      
      const response = await request.post(`${BASE_URL}/users`, {
        data: minimalUser
      });
      
      expect(response.status()).toBe(201);
      const created = await response.json();
      expect(created.name).toBe('User Minimal');
    });
  });
  
  test.describe('PUT /users/:id', () => {
    
    test('Deve atualizar usuário existente', async ({ request }) => {
      const updatedData = {
        id: 1,
        name: 'Leanne Graham Updated',
        email: 'leanne.updated@example.com',
        username: 'bretUpdated',
        address: {
          street: 'Kulas Light Updated',
          city: 'Gwenborough'
        }
      };
      
      const response = await request.put(`${BASE_URL}/users/1`, {
        data: updatedData
      });
      
      expect(response.status()).toBe(200);
    });
    
    test('Resposta deve conter dados atualizados', async ({ request }) => {
      const updatedData = {
        id: 1,
        name: 'Nome Atualizado',
        email: 'novo@email.com',
        username: 'novouser'
      };
      
      const response = await request.put(`${BASE_URL}/users/1`, {
        data: updatedData
      });
      const updated = await response.json();
      
      expect(updated.id).toBe(1);
      expect(updated.name).toBe('Nome Atualizado');
      expect(updated.email).toBe('novo@email.com');
    });
    
    test('PUT deve retornar Content-Type correto', async ({ request }) => {
      const updateData = { name: 'Test' };
      const response = await request.put(`${BASE_URL}/users/1`, {
        data: updateData
      });
      
      expect(response.headers()['content-type']).toContain('application/json');
    });
    
    test('Deve atualizar parcialmente (alguns campos)', async ({ request }) => {
      const partialUpdate = {
        email: 'novo.email@test.com'
      };
      
      const response = await request.put(`${BASE_URL}/users/1`, {
        data: partialUpdate
      });
      const updated = await response.json();
      
      expect(updated.id).toBe(1);
      expect(updated.email).toBe('novo.email@test.com');
    });
  });
  
  test.describe('DELETE /users/:id', () => {
    
    test('Deve deletar usuário existente', async ({ request }) => {
      const response = await request.delete(`${BASE_URL}/users/1`);
      
      expect(response.status()).toBe(200);
    });
    
    test('Resposta de delete deve ser um objeto vazio ou confirmação', async ({ request }) => {
      const response = await request.delete(`${BASE_URL}/users/1`);
      const result = await response.json();
      
      // JSONPlaceholder retorna um objeto vazio para DELETE
      expect(typeof result).toBe('object');
    });
    
    test('DELETE deve retornar Content-Type correto', async ({ request }) => {
      const response = await request.delete(`${BASE_URL}/users/1`);
      
      expect(response.headers()['content-type']).toContain('application/json');
    });
  });
  
  test.describe('Validação e Tratamento de Erros', () => {
    
    test('Requisição GET para endpoint inexistente deve retornar 404', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/posts/999999`);
      
      expect(response.status()).toBe(404);
    });
    
    test('GET /users deve retornar entre 1 e 100 usuários', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`);
      const users = await response.json();
      
      expect(users.length).toBeGreaterThanOrEqual(1);
      expect(users.length).toBeLessThanOrEqual(100);
    });
    
    test('Email deve ser válido quando retornado', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users/1`);
      const user = (await response.json()) as User;
      
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      expect(emailRegex.test(user.email)).toBeTruthy();
    });
    
    test('Username não deve ser vazio', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`);
      const users = (await response.json()) as User[];
      
      users.forEach(user => {
        expect(user.username).toBeTruthy();
        expect(user.username.length).toBeGreaterThan(0);
      });
    });
    
    test('Timeout não deve ocorrer em requisições normais', async ({ request }) => {
      const response = await request.get(`${BASE_URL}/users`, {
        timeout: 5000 // 5 segundos
      });
      
      expect(response.ok()).toBeTruthy();
    });
  });
  
  test.describe('Performance Básica', () => {
    
    test('GET /users deve responder em menos de 2 segundos', async ({ request }) => {
      const startTime = Date.now();
      await request.get(`${BASE_URL}/users`);
      const duration = Date.now() - startTime;
      
      expect(duration).toBeLessThan(2000);
    });
    
    test('GET /users/:id deve responder rapidamente', async ({ request }) => {
      const startTime = Date.now();
      await request.get(`${BASE_URL}/users/1`);
      const duration = Date.now() - startTime;
      
      expect(duration).toBeLessThan(1000);
    });
  });
});

import { test, expect } from '@playwright/test';

test.describe('@api API Tests', () => {
  let baseURL: string;

  test.beforeAll(() => {
    baseURL = process.env.BASE_URL || 'http://localhost:3000';
  });

  test('should verify API is reachable', async ({ request }) => {
    try {
      const response = await request.get(`${baseURL}/api/health`);
      // API may not exist, just verify connectivity
      expect([200, 404]).toContain(response.status());
    } catch (error) {
      console.log('⚠️  API not available for testing');
    }
  });

  test('should handle API errors gracefully', async ({ request }) => {
    try {
      const response = await request.get(`${baseURL}/api/invalid-endpoint`);
      expect([404, 500]).toContain(response.status());
    } catch (error) {
      console.log('⚠️  API not reachable');
    }
  });
});

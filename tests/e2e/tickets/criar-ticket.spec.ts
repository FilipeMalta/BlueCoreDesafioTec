import { test, expect } from '@playwright/test';
import { CriarTicketPage } from '../../pages/CriarTicketPage';
import { ticketsData } from '../../fixtures/test-data';

test.describe('Criar Tickets', () => {
  let criarPage: CriarTicketPage;

  test.beforeEach(async ({ page }) => {
    criarPage = new CriarTicketPage(page);
    await criarPage.navigateToCriarTicket();
  });

  test('TC-01: Criar ticket com dados válidos', async () => {
    const ticket = ticketsData[0];
    await criarPage.fillForm(ticket);
    await criarPage.clickSalvar();
    const msg = await criarPage.getSuccessMessage();
    expect(msg).toBeTruthy();
  });

  test('TC-02: Criar ticket com prioridade Alta', async () => {
    await criarPage.fillForm({ ...ticketsData[0], prioridade: 'Alta' });
    await criarPage.clickSalvar();
    const msg = await criarPage.getSuccessMessage();
    expect(msg).toBeTruthy();
  });

  test('TC-03: Criar ticket com prioridade Média', async () => {
    await criarPage.fillForm({ ...ticketsData[1], prioridade: 'Média' });
    await criarPage.clickSalvar();
    const msg = await criarPage.getSuccessMessage();
    expect(msg).toBeTruthy();
  });

  test('TC-04: Não criar sem título', async () => {
    await criarPage.fillForm({
      titulo: '',
      descricao: ticketsData[0].descricao,
      prioridade: 'Alta',
    });
    await criarPage.clickSalvar();
    const error = await criarPage.getErrorMessage();
    expect(error).toBeTruthy();
  });

  test('TC-05: Não criar sem descrição', async () => {
    await criarPage.fillForm({
      titulo: ticketsData[0].titulo,
      descricao: '',
      prioridade: 'Alta',
    });
    await criarPage.clickSalvar();
    const error = await criarPage.getErrorMessage();
    expect(error).toBeTruthy();
  });

  test('TC-06: Cancelar deve retornar', async ({ page }) => {
    await criarPage.clickCancelar();
    const url = page.url();
    expect(url).not.toContain('/tickets/criar');
  });
});


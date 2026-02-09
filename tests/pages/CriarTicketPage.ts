import { Page } from '@playwright/test';
import { BasePage } from './BasePage';

export class CriarTicketPage extends BasePage {
  async navigateToCriarTicket() {
    await this.navigate('/tickets/criar');
  }

  async fillForm(data) {
    await this.fill('[data-testid="input-titulo"]', data.titulo);
    await this.fill('[data-testid="textarea-descricao"]', data.descricao);
    await this.selectOption('[data-testid="select-prioridade"]', data.prioridade);
  }

  async clickSalvar() {
    await this.click('[data-testid="btn-salvar"]');
  }

  async clickCancelar() {
    await this.click('[data-testid="btn-cancelar"]');
  }

  async getSuccessMessage() {
    return await this.getText('[data-testid="msg-sucesso"]');
  }

  async getErrorMessage() {
    return await this.getText('[data-testid="error-message"]');
  }
}


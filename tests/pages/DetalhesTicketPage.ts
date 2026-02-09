import { Page } from '@playwright/test';
import { BasePage } from './BasePage';

// Representa uma entrada no histórico de alterações do ticket
export interface HistoricoItem {
  timestamp: string;
  usuario: string;
  acao: string;
  statusAnterior?: string;
  statusNovo?: string;
  motivo?: string;
}

// Page Object para a página de detalhes de um ticket
export class DetalhesTicketPage extends BasePage {
  // Seletores principais
  private readonly TICKET_ID = '[data-testid="ticket-id"]';
  private readonly STATUS = '[data-testid="ticket-status"]';
  private readonly STATUS_BADGE = '[data-testid="status-badge"]';

  // Modal de atualização de status
  private readonly BTN_ATUALIZAR_STATUS = '[data-testid="btn-atualizar-status"]';
  private readonly MODAL_ATUALIZAR_STATUS = '[data-testid="modal-atualizar-status"]';
  private readonly SELECT_NOVO_STATUS = '[data-testid="select-novo-status"]';
  private readonly TEXTAREA_MOTIVO = '[data-testid="textarea-motivo"]';
  private readonly BTN_CONFIRMAR_STATUS = '[data-testid="btn-confirmar-status"]';

  // Histórico de alterações
  private readonly HISTORICO_CONTAINER = '[data-testid="historico-container"]';
  private readonly HISTORICO_ITEMS = '[data-testid="historico-item"]';
  private readonly HISTORICO_TIMESTAMP = '[data-testid="historico-timestamp"]';
  private readonly HISTORICO_USUARIO = '[data-testid="historico-usuario"]';
  private readonly HISTORICO_ACAO = '[data-testid="historico-acao"]';

  // Container e loading
  private readonly CONTAINER_DETALHES = '[data-testid="ticket-detalhes-container"]';
  private readonly LOADING_SPINNER = '[data-testid="loading-spinner"]';

  constructor(page: Page) {
    super(page);
  }

  // Navega para a página de detalhes do ticket
  async navigate(ticketId: string): Promise<void> {
    const path = ticketId.includes('tickets') ? ticketId : `/tickets/${ticketId}`;
    await super.navigate(path);
    await this.waitForPageLoad();
    await this.aguardarCarregamento();
  }

  // Aguarda o carregamento completo dos detalhes
  private async aguardarCarregamento(): Promise<void> {
    await this.waitForElement(this.CONTAINER_DETALHES);

    const temSpinner = await this.isElementVisible(this.LOADING_SPINNER);
    if (temSpinner) {
      await this.waitForElementToDisappear(this.LOADING_SPINNER);
    }
  }

  // Retorna o ID do ticket exibido na página
  async getId(): Promise<string> {
    return await this.getText(this.TICKET_ID);
  }

  // Retorna o status atual do ticket
  async getStatus(): Promise<string> {
    const temBadge = await this.isElementVisible(this.STATUS_BADGE);
    const selector = temBadge ? this.STATUS_BADGE : this.STATUS;
    return await this.getText(selector);
  }

  // Abre o modal, seleciona o novo status, preenche motivo e confirma
  async atualizarStatus(novoStatus: string, motivo?: string): Promise<void> {
    await this.clickElement(this.BTN_ATUALIZAR_STATUS);
    await this.waitForElement(this.MODAL_ATUALIZAR_STATUS);

    await this.selectOption(this.SELECT_NOVO_STATUS, novoStatus);

    if (motivo) {
      const temCampoMotivo = await this.isElementVisible(this.TEXTAREA_MOTIVO);
      if (temCampoMotivo) {
        await this.fillInput(this.TEXTAREA_MOTIVO, motivo);
      }
    }

    await this.clickElement(this.BTN_CONFIRMAR_STATUS);
    await this.waitForElementToDisappear(this.MODAL_ATUALIZAR_STATUS);

    // Aguarda o status atualizar na tela
    await this.waitForCondition(async () => {
      const statusAtual = await this.getStatus();
      return statusAtual === novoStatus;
    }, 8000);
  }

  // Retorna todas as entradas do histórico de alterações
  async getHistoricoAlteracoes(): Promise<HistoricoItem[]> {
    const temHistorico = await this.isElementVisible(this.HISTORICO_CONTAINER);
    if (!temHistorico) return [];

    const items = this.page.locator(this.HISTORICO_ITEMS);
    const total = await items.count();
    if (total === 0) return [];

    const historico: HistoricoItem[] = [];

    for (let i = 0; i < total; i++) {
      const item = items.nth(i);

      historico.push({
        timestamp: ((await item.locator(this.HISTORICO_TIMESTAMP).textContent()) || '').trim(),
        usuario: ((await item.locator(this.HISTORICO_USUARIO).textContent()) || '').trim(),
        acao: ((await item.locator(this.HISTORICO_ACAO).textContent()) || '').trim(),
        statusAnterior: (await item.locator('[data-testid="status-anterior"]').textContent())?.trim(),
        statusNovo: (await item.locator('[data-testid="status-novo"]').textContent())?.trim(),
        motivo: (await item.locator('[data-testid="motivo"]').textContent())?.trim(),
      });
    }

    return historico;
  }
}

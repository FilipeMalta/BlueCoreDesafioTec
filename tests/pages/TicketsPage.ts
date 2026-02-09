import { Page } from '@playwright/test';
import { BasePage } from './BasePage';

// Dados de um ticket na listagem
export interface TicketData {
  id: string;
  title: string;
  status: string;
  priority: string;
  createdAt: string;
  assignee?: string;
  category?: string;
}

// Opções de filtro disponíveis
export interface FilterOptions {
  status?: string;
  priority?: string;
  searchTerm?: string;
}

// Page Object da listagem de tickets
export class TicketsPage extends BasePage {
  // Seletores da tabela
  private readonly TABLE = '[data-testid="tickets-table"]';
  private readonly ROWS = '[data-testid="ticket-row"]';
  private readonly SPINNER = '[data-testid="loading-spinner"]';

  // Células de cada linha
  private readonly CELL_ID = '[data-testid="cell-id"]';
  private readonly CELL_TITLE = '[data-testid="cell-title"]';
  private readonly CELL_STATUS = '[data-testid="cell-status"]';
  private readonly CELL_PRIORITY = '[data-testid="cell-priority"]';
  private readonly CELL_CREATED_AT = '[data-testid="cell-created-at"]';
  private readonly CELL_ASSIGNEE = '[data-testid="cell-assignee"]';
  private readonly CELL_CATEGORY = '[data-testid="cell-category"]';

  constructor(page: Page) {
    super(page);
  }

  // Aguarda o spinner sumir e a tabela aparecer
  private async waitForTable(): Promise<void> {
    const hasSpinner = await this.isElementVisible(this.SPINNER);
    if (hasSpinner) {
      await this.waitForElementToDisappear(this.SPINNER);
    }
    await this.waitForElement(this.TABLE);
  }

  // Navega para /tickets e aguarda carregamento
  async navigateToTickets(): Promise<void> {
    await this.navigate('/tickets');
    await this.waitForPageLoad();
    await this.waitForTable();
  }

  // Retorna todos os tickets visíveis na tabela
  async getTicketsList(): Promise<TicketData[]> {
    await this.waitForTable();

    const rows = this.page.locator(this.ROWS);
    const count = await rows.count();

    if (count === 0) return [];

    const tickets: TicketData[] = [];

    for (let i = 0; i < count; i++) {
      const row = rows.nth(i);
      await row.waitFor({ state: 'visible' });

      const id = (await row.locator(this.CELL_ID).textContent()) || '';
      const title = (await row.locator(this.CELL_TITLE).textContent()) || '';
      const status = (await row.locator(this.CELL_STATUS).textContent()) || '';
      const priority = (await row.locator(this.CELL_PRIORITY).textContent()) || '';
      const createdAt = (await row.locator(this.CELL_CREATED_AT).textContent()) || '';
      const assignee = (await row.locator(this.CELL_ASSIGNEE).textContent()) || undefined;
      const category = (await row.locator(this.CELL_CATEGORY).textContent()) || undefined;

      tickets.push({
        id: id.trim(),
        title: title.trim(),
        status: status.trim(),
        priority: priority.trim(),
        createdAt: createdAt.trim(),
        assignee: assignee?.trim(),
        category: category?.trim(),
      });
    }

    return tickets;
  }
}

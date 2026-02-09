import { Page } from '@playwright/test';

export class BasePage {
  constructor(protected page: Page) {}

  async navigate(url: string) {
    await this.page.goto(`http://localhost:3000${url}`);
  }

  async click(selector: string) {
    await this.page.click(selector);
  }

  async fill(selector: string, text: string) {
    await this.page.fill(selector, text);
  }

  async getText(selector: string) {
    return await this.page.textContent(selector);
  }

  async isVisible(selector: string) {
    return await this.page.isVisible(selector);
  }

  async selectOption(selector: string, value: string) {
    await this.page.selectOption(selector, value);
  }

  async waitFor(selector: string) {
    await this.page.waitForSelector(selector);
  }
}


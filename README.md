# BlueCoreDesafioTec

QA automation tests for Helpdesk ticket management system using Playwright + TypeScript.

## Setup

```bash
# Install dependencies
npm install
npm ci

# Install Playwright browsers
npx playwright install
```

## Running Tests

```bash
# Run all tests
npm test

# Run with UI mode (interactive)
npm run test:ui

# Run with visible browser (headed mode)
npm run test:headed

# View HTML report
npm run report

# Run specific test file
npx playwright test tests/e2e/tickets/criar-ticket.spec.ts

# List available tests
npx playwright test --list
```

## Configuration

- **Base URL**: `http://localhost:3000`
- **Browsers**: Chromium, Firefox
- **Timeout**: 30 seconds (per test)

## Project Structure

```
tests/
├── e2e/tickets/
│   └── criar-ticket.spec.ts       # Create ticket tests
├── pages/
│   ├── BasePage.ts                # Base page class
│   ├── CriarTicketPage.ts         # Create ticket page
│   └── TicketsPage.ts             # Tickets list page
└── fixtures/
    └── test-data.ts               # Test data
```

## Page Object Model

Tests follow POM pattern with `BasePage` providing common operations:
- `navigate(url)`
- `click(selector)`
- `fill(selector, text)`
- `getText(selector)`
- `isVisible(selector)`
- `selectOption(selector, value)`
- `waitFor(selector)`

## Test Files

- **criar-ticket.spec.ts**: Create ticket scenarios (TC-01 to TC-06)
  - Valid data, priority variations, validation failures, cancel flow

Total: 6 tests × 2 browsers = 12 tests

## Requirements

- Node.js 18+
- npm 10+
- Git

## Notes

- Tests expect server running on `http://localhost:3000`
- TypeScript in non-strict mode
- No CI/CD pipeline - runs locally only

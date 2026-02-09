# BlueCoreDesafioTec

QA automation tests with Playwright for ticket management system.

## Setup

```bash
npm install
npx playwright install
```

## Running Tests

```bash
npm test              # All tests
npm run test:ui       # Interactive UI
npm run test:headed   # Browser visible
npm run report        # View report
```

## Project Structure

```
tests/
├── e2e/tickets/
│   └── criar-ticket.spec.ts
├── api/
│   └── jsonplaceholder.spec.ts
└── pages/
    ├── BasePage.ts
    ├── CriarTicketPage.ts
    └── TicketsPage.ts
```

## Tests

- **E2E (UI)**: 6 tests (create ticket, priority, validation, cancel)
- **API**: 26 tests (GET, POST, PUT, DELETE, validation, performance)

Total: 66 tests (32 tests × 2 browsers)

## Requirements

- Node.js 18+
- npm 10+

## Notes

- Runs against `http://localhost:3000` (E2E) and JSONPlaceholder API
- TypeScript non-strict mode

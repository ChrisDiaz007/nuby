# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start development server (Rails only)
bin/rails server

# Start with Tailwind CSS watcher (recommended for UI work)
bin/dev

# Database setup
rails db:create db:migrate

# Run tests
rails test

# Run a single test file
rails test test/models/food_test.rb

# Run a single test by line number
rails test test/models/food_test.rb:10
```

## Architecture

**Nuby** is a Rails 7.1 mobile-first food tracking app. Users scan barcodes, get nutrition data from OpenFoodFacts, log meals, and track daily calories against a personal goal.

### Data Flow: Barcode Scan

1. `FoodsController#scan` renders the scan page with QuaggaJS (via `barcode_scanner_controller.js`)
2. Barcode is submitted to `FoodsController#lookup`
3. Lookup checks `Food` table first (cache); if missing, calls `OpenFoodFactsService.find(barcode)` which wraps the `openfoodfacts` gem
4. Food record is created and user is redirected to `foods#show`

### Styling

Two parallel CSS systems coexist — use **Tailwind** for new work:
- **Tailwind CSS** (`app/assets/tailwind/application.css`) — primary utility classes
- **SCSS** (`app/assets/stylesheets/`) — component files under `components/` imported via `application.scss`

### Key Models

- `User` — Devise auth; has one `CalorieProfile`, many `UserFood`s and `FoodLog`s
- `Food` — Cached OpenFoodFacts data; `additives_tags` stored as JSON-serialized array; unique by `barcode`
- `UserFood` — Join table for a user's saved foods list
- `FoodLog` — A meal diary entry (meal type + serving size + date)
- `CalorieProfile` — Daily calorie goal, set manually or calculated via Mifflin-St Jeor (`CalorieCalculatorService`)

### Services

- `OpenFoodFactsService` — Wraps the `openfoodfacts` gem; returns a flat hash of nutritional attributes or `nil` on failure
- `CalorieCalculatorService` — Mifflin-St Jeor BMR formula with activity multiplier and goal adjustment (+/-500 kcal)

### JavaScript (Stimulus Controllers)

- `barcode_scanner_controller.js` — Controls QuaggaJS camera scanning lifecycle
- `nutrition_row_controller.js` — Handles interactive nutrition row display

### Hotwire Native

The app targets Hotwire Native iOS as a shell. Keep navigation Turbo-compatible; avoid full-page JS redirects.

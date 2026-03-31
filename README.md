# Nuvy

A mobile-first Rails web app that helps users understand the nutritional quality of food by scanning barcodes and tracking daily calorie intake against a personal goal.

## Features

- **Barcode Scanning** — Scan food barcodes with your camera (QuaggaJS) or enter manually
- **Food Lookup** — Fetches nutritional data from the OpenFoodFacts API and caches results
- **Nutrition Breakdown** — Detailed food card with Nutri-Score, negative/positive nutrients, additives, and gradient scale bars
- **Additives Detail** — View all additives in a product with links to Wikipedia descriptions
- **Saved Foods List** — Save foods to your personal list for quick meal logging
- **Meal Logging** — Log breakfast, lunch, and dinner with serving sizes
- **Home Dashboard** — Week selector showing daily meals, calorie progress bar, and meal totals
- **Activity Dashboard** — 7-day calorie bar chart with daily goal line
- **Calorie Goal Setup** — Set goal manually or via Mifflin-St Jeor survey calculator
- **User Profile** — Edit name, update calorie goal, retake survey
- **Hotwire Native iOS** — Runs as a native iOS app via Hotwire Native

## Tech Stack

| Technology | Purpose |
|---|---|
| Ruby 3.3.5 | Language |
| Rails 7.1 | Framework |
| PostgreSQL | Database |
| Devise | Authentication |
| Tailwind CSS | Styling |
| Stimulus JS | Interactive components |
| Turbo | SPA-like navigation |
| OpenFoodFacts gem | Food data API |
| QuaggaJS | In-browser barcode scanning |
| Chart.js | Weekly calorie chart |
| Hotwire Native iOS | iOS app shell |

## Data Models

- **User** — Authentication via Devise
- **Food** — Cached product data from OpenFoodFacts
- **UserFood** — Join table (user's saved foods list)
- **FoodLog** — Daily meal diary entries
- **CalorieProfile** — User's daily calorie goal

## Getting Started

### Requirements

- Ruby 3.3.5
- PostgreSQL
- Bundler

### Setup

```bash
git clone https://github.com/ChrisDiaz007/nuby.git
cd nuby
bundle install
rails db:create db:migrate
rails server
```

Visit `http://localhost:3000`

## Screenshots

_Coming soon_

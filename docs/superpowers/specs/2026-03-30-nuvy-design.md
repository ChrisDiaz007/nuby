# Nuby — App Design Spec
**Date:** 2026-03-30
**Status:** Approved

---

## Overview

Nuby is a mobile-first Rails web app that helps users understand the nutritional quality of food by scanning barcodes, and tracks their daily calorie intake against a personal goal. The long-term vision is a Hotwire Native iOS app; the initial target is a mobile web app.

---

## Core User Flow

1. User scans a food barcode (camera on mobile, manual input on desktop)
2. Nuby looks up the food via the OpenFoodFacts API
3. A food info card is shown — user can add the food to their list or dismiss it
4. From their saved foods list, the user logs meals (breakfast, lunch, dinner)
5. A dashboard shows today's meal table, daily progress, and a 7-day calorie chart

---

## Data Models

### `User` (existing — Devise)
- `first_name`, `last_name`, `email`, `encrypted_password`
- `has_one :calorie_profile`
- `has_many :user_foods`
- `has_many :foods, through: :user_foods`
- `has_many :food_logs`

### `Food`
Acts as a local cache of OpenFoodFacts data. Avoids repeated API calls for the same product.

| Field | Type | Notes |
|---|---|---|
| `barcode` | string | unique, indexed |
| `name` | string | product name |
| `brand` | string | |
| `calories_per_serving` | decimal | kcal |
| `fat` | decimal | grams |
| `carbohydrates` | decimal | grams |
| `protein` | decimal | grams |
| `nutri_score` | string | A–E grade, nullable |
| `serving_size` | string | e.g. "30g" |

- `has_many :user_foods`
- `has_many :users, through: :user_foods`
- `has_many :food_logs`

### `UserFood` (saved foods list)
Created when a user approves a food from the scan card.

| Field | Type | Notes |
|---|---|---|
| `user_id` | integer | FK |
| `food_id` | integer | FK |

- `belongs_to :user`
- `belongs_to :food`
- Unique index on `[user_id, food_id]`

### `FoodLog` (daily diary)
One record per eating event. Drives the daily meal table and weekly chart.

| Field | Type | Notes |
|---|---|---|
| `user_id` | integer | FK |
| `food_id` | integer | FK |
| `servings` | decimal | e.g. 1.5 |
| `meal_type` | string | breakfast / lunch / dinner |
| `logged_on` | date | the day this was eaten |

- `belongs_to :user`
- `belongs_to :food`

### `CalorieProfile`
Stores the user's calorie goal — either manually entered or calculated via survey.

| Field | Type | Notes |
|---|---|---|
| `user_id` | integer | FK, unique |
| `daily_target` | integer | calculated or manual kcal goal |
| `age` | integer | nullable (survey) |
| `sex` | string | nullable (survey) |
| `weight_kg` | decimal | nullable (survey) |
| `height_cm` | decimal | nullable (survey) |
| `activity_level` | string | sedentary / lightly_active / moderately_active / very_active |
| `goal_type` | string | lose / maintain / gain |
| `entry_method` | string | manual / survey |

- `belongs_to :user`

---

## Features

### 1. Barcode Scan & Food Lookup

**Mobile:** ZXing JavaScript library accesses the device camera, reads the barcode, and submits it to Rails.

**Desktop:** A text input for manual barcode entry.

**Rails lookup flow:**
1. Check `foods` table for existing barcode — return cached result if found
2. If not found, call OpenFoodFacts API via the `openfoodfacts` gem
3. Save result to `foods` table
4. Return food info to the user

**Food card shows:**
- Name, brand, serving size
- Calories per serving
- Macros: fat, carbs, protein
- Nutri-Score grade (if available)
- "Add to my list" button (creates `UserFood`) and ✕ to dismiss

**Not found fallback:** "We couldn't find that product. Try scanning again or enter the barcode manually."

---

### 2. Saved Foods List

A page showing all foods the user has added. From here, the user can log a food to a meal. Each item shows name, brand, calories, and a "Log this" button.

---

### 3. Daily Meal Table & Progress

The user's dashboard (home after login) shows:

- **Progress bar** — today's total calories vs. daily target (lime green = under, orange/red = over)
- **Meal table** — broken into Breakfast, Lunch, Dinner sections with food rows, serving counts, calories, and section totals
- **Daily total** — sum of all logged calories for today

Logging a food:
1. Select from saved foods list
2. Choose meal type (Breakfast / Lunch / Dinner)
3. Enter servings
4. Submit → creates `FoodLog` record

---

### 4. Calorie Goal Setup

Two paths:

**Manual:** User enters their daily calorie target directly.

**Survey (Mifflin-St Jeor formula):**
Collects: age, sex, weight, height, activity level, goal type.

Formula:
- Men: BMR = (10 × weight_kg) + (6.25 × height_cm) − (5 × age) + 5
- Women: BMR = (10 × weight_kg) + (6.25 × height_cm) − (5 × age) − 161

Activity multipliers: sedentary 1.2 / lightly active 1.375 / moderately active 1.55 / very active 1.725

Goal adjustment: lose −500 kcal / maintain ±0 / gain +500 kcal

Result saved to `CalorieProfile`. User can update anytime.

Unit input: weight in lbs or kg (converted server-side), height in ft/in or cm (converted server-side).

---

### 5. Weekly Stats Chart

Displayed on the dashboard above the meal table.

- 7 bars representing the last 7 days
- Bar height = total calories logged that day
- Horizontal line at daily goal
- Bar color: lime green if ≤ goal, orange/red if > goal
- Empty bar (0) for days with no logs
- Rendered via **Chart.js** (loaded via importmap, no gem needed)
- Data passed as JSON from Rails to the view

---

## Tech Stack Additions

| Addition | Purpose |
|---|---|
| `openfoodfacts` gem | OpenFoodFacts API wrapper |
| ZXing JS | In-browser barcode scanning via camera |
| Chart.js | Weekly calorie bar chart |

---

## Build Order

1. Data models & migrations (Option C — foundation first)
2. Barcode scan + food lookup + food card
3. Saved foods list
4. Log a meal + daily meal table
5. Calorie goal setup (manual + survey)
6. Weekly stats chart

Each step will be explained as it is built — this app is being built as a Rails learning project.

---

## Out of Scope (for now)
- iOS / Hotwire Native
- Manual food name search
- Custom food entry
- Social / sharing features

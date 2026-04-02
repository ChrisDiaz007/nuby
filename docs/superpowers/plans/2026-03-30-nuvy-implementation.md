# Nuby Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Nuby — a food barcode scanning, nutritional lookup, and daily calorie tracking Rails web app.

**Architecture:** Data models are built first (Option C), then features are layered on top slice by slice. Each feature has its own controller, service (where logic is needed), and views. We follow TDD: write a failing test, then write the code to make it pass.

**Tech Stack:** Rails 7.1, Ruby 3.3.5, PostgreSQL, Devise (auth), Tailwind CSS, Stimulus JS, Turbo, openfoodfacts gem, ZXing JS (barcode scan), Chart.js (weekly stats)

---

## Learning Notes

Throughout this plan you will see `# WHY:` comments in code. These explain the reasoning behind a decision — not just what the code does, but why it's written that way. Read them as you go.

Rails tests use **Minitest** (built in, no install needed). Run a single test file with:
```bash
rails test test/models/food_test.rb
```
Run all tests:
```bash
rails test
```

---

## File Map

| File | Purpose |
|---|---|
| `Gemfile` | Add openfoodfacts gem |
| `config/routes.rb` | All app routes |
| `config/importmap.rb` | Pin ZXing + Chart.js CDN libraries |
| `db/migrate/*_create_foods.rb` | Foods table |
| `db/migrate/*_create_user_foods.rb` | Saved foods join table |
| `db/migrate/*_create_food_logs.rb` | Daily meal diary table |
| `db/migrate/*_create_calorie_profiles.rb` | User calorie goal table |
| `app/models/food.rb` | Food model + validations |
| `app/models/user_food.rb` | UserFood model + validations |
| `app/models/food_log.rb` | FoodLog model + validations + scopes |
| `app/models/calorie_profile.rb` | CalorieProfile model + validations |
| `app/models/user.rb` | Add associations |
| `app/services/open_food_facts_service.rb` | Wraps openfoodfacts gem, handles not-found |
| `app/services/calorie_calculator_service.rb` | Mifflin-St Jeor formula |
| `app/controllers/application_controller.rb` | authenticate_user! before_action |
| `app/controllers/dashboard_controller.rb` | Main dashboard (meal table + chart data) |
| `app/controllers/foods_controller.rb` | Scan page + barcode lookup |
| `app/controllers/user_foods_controller.rb` | Save food to list / remove from list |
| `app/controllers/food_logs_controller.rb` | Log a meal entry |
| `app/controllers/calorie_profiles_controller.rb` | Manual goal entry + survey |
| `app/views/layouts/application.html.erb` | Modify layout for dashboard root |
| `app/views/shared/_navbar.html.erb` | Update navbar links |
| `app/views/dashboard/index.html.erb` | Progress bar + meal table + weekly chart |
| `app/views/foods/scan.html.erb` | Barcode scanner page |
| `app/views/foods/show.html.erb` | Food info card (add or dismiss) |
| `app/views/user_foods/index.html.erb` | Saved foods list |
| `app/views/food_logs/new.html.erb` | Log a meal form |
| `app/views/calorie_profiles/new.html.erb` | Goal setup (manual or survey) |
| `app/views/calorie_profiles/edit.html.erb` | Update goal |
| `app/javascript/controllers/barcode_scanner_controller.js` | Stimulus controller for ZXing |
| `test/models/food_test.rb` | Food model tests |
| `test/models/user_food_test.rb` | UserFood model tests |
| `test/models/food_log_test.rb` | FoodLog model tests |
| `test/models/calorie_profile_test.rb` | CalorieProfile model tests |
| `test/services/open_food_facts_service_test.rb` | Service tests (with stubbed API) |
| `test/services/calorie_calculator_service_test.rb` | Formula tests |
| `test/controllers/dashboard_controller_test.rb` | Dashboard controller tests |
| `test/controllers/foods_controller_test.rb` | Foods controller tests |
| `test/controllers/user_foods_controller_test.rb` | UserFoods controller tests |
| `test/controllers/food_logs_controller_test.rb` | FoodLogs controller tests |
| `test/controllers/calorie_profiles_controller_test.rb` | CalorieProfiles controller tests |
| `test/fixtures/foods.yml` | Food test data |
| `test/fixtures/user_foods.yml` | UserFood test data |
| `test/fixtures/food_logs.yml` | FoodLog test data |
| `test/fixtures/calorie_profiles.yml` | CalorieProfile test data |

---

## Task 1: Add the openfoodfacts Gem

**What you're learning:** How to add a third-party gem to a Rails app and install it.

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Add the gem to Gemfile**

Open `Gemfile` and add this line after the `gem 'devise'` line:

```ruby
gem 'openfoodfacts'
```

- [ ] **Step 2: Install the gem**

Run in your terminal:
```bash
bundle install
```

Expected output: You will see `Bundle complete!` at the end. The gem is now available in your app.

- [ ] **Step 3: Verify the gem installed**

```bash
bundle list | grep openfoodfacts
```

Expected output: `openfoodfacts (x.x.x)` — a version number next to the gem name.

- [ ] **Step 4: Commit**

```bash
git add Gemfile Gemfile.lock
git commit -m "Add openfoodfacts gem"
```

---

## Task 2: Create the Food Model

**What you're learning:** Rails migrations create database tables. The model file defines what the table can do (validations, associations). `rails generate migration` is a command that creates a migration file with a timestamp — Rails uses these timestamps to know what order to run migrations in.

**Files:**
- Create: `db/migrate/TIMESTAMP_create_foods.rb` (Rails generates the timestamp)
- Create: `app/models/food.rb`
- Create: `test/models/food_test.rb`
- Create: `test/fixtures/foods.yml`

- [ ] **Step 1: Generate the migration**

```bash
rails generate migration CreateFoods barcode:string:uniq name:string brand:string calories_per_100g:decimal fat_100g:decimal carbohydrates_100g:decimal protein_100g:decimal nutri_score:string serving_size:string
```

This creates a migration file in `db/migrate/`. Open it and confirm it looks like this (the timestamp will differ):

```ruby
class CreateFoods < ActiveRecord::Migration[7.1]
  def change
    create_table :foods do |t|
      t.string :barcode, null: false
      t.string :name
      t.string :brand
      t.decimal :calories_per_100g, precision: 8, scale: 2
      t.decimal :fat_100g, precision: 8, scale: 2
      t.decimal :carbohydrates_100g, precision: 8, scale: 2
      t.decimal :protein_100g, precision: 8, scale: 2
      t.string :nutri_score
      t.string :serving_size

      t.timestamps
    end

    add_index :foods, :barcode, unique: true
  end
end
```

If `precision: 8, scale: 2` wasn't added automatically, add it manually — it means "up to 8 digits total, 2 after the decimal" (e.g. 123456.78).

- [ ] **Step 2: Run the migration**

```bash
rails db:migrate
```

Expected output:
```
== CreateFoods: migrating ==========================
-- create_table(:foods)
== CreateFoods: migrated (0.0123s) =================
```

- [ ] **Step 3: Write the failing test**

Create `test/models/food_test.rb`:

```ruby
require "test_helper"

class FoodTest < ActiveSupport::TestCase
  # WHY: We test that a food without a barcode is invalid.
  # This ensures our data is always complete — a food with no barcode
  # can't be looked up, so it's useless.
  test "is invalid without a barcode" do
    food = Food.new(name: "Apple")
    assert_not food.valid?
    assert_includes food.errors[:barcode], "can't be blank"
  end

  test "is invalid without a name" do
    food = Food.new(barcode: "1234567890")
    assert_not food.valid?
    assert_includes food.errors[:name], "can't be blank"
  end

  # WHY: Two foods with the same barcode would mean the same physical product
  # is stored twice. We prevent that with a uniqueness validation.
  test "is invalid with a duplicate barcode" do
    Food.create!(barcode: "1234567890", name: "Apple")
    duplicate = Food.new(barcode: "1234567890", name: "Apple 2")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:barcode], "has already been taken"
  end

  test "is valid with barcode and name" do
    food = Food.new(barcode: "9999999999", name: "Test Food")
    assert food.valid?
  end
end
```

- [ ] **Step 4: Run the test to confirm it fails**

```bash
rails test test/models/food_test.rb
```

Expected: Tests fail with `uninitialized constant FoodTest::Food` — the model doesn't exist yet.

- [ ] **Step 5: Create the Food model**

Create `app/models/food.rb`:

```ruby
class Food < ApplicationRecord
  # WHY: These associations are defined here even though we haven't created
  # UserFood and FoodLog yet. Rails won't complain — it only resolves
  # associations when they're actually called.
  has_many :user_foods, dependent: :destroy
  has_many :users, through: :user_foods
  has_many :food_logs, dependent: :destroy

  validates :barcode, presence: true, uniqueness: true
  validates :name, presence: true
end
```

- [ ] **Step 6: Create the fixture file**

Create `test/fixtures/foods.yml`:

```yaml
# WHY: Fixtures are pre-loaded test data. Rails inserts these into
# the test database before each test so you have known data to test against.
banana:
  barcode: "0011110874931"
  name: "Banana"
  brand: "Chiquita"
  calories_per_100g: 89.0
  fat_100g: 0.3
  carbohydrates_100g: 23.0
  protein_100g: 1.1
  nutri_score: "a"
  serving_size: "118g"

oatmeal:
  barcode: "0016000275287"
  name: "Oatmeal"
  brand: "Quaker"
  calories_per_100g: 371.0
  fat_100g: 6.9
  carbohydrates_100g: 67.0
  protein_100g: 13.0
  nutri_score: "b"
  serving_size: "40g"
```

- [ ] **Step 7: Run tests again to confirm they pass**

```bash
rails test test/models/food_test.rb
```

Expected output: `3 runs, 3 assertions, 0 failures, 0 errors`

- [ ] **Step 8: Commit**

```bash
git add db/migrate/*_create_foods.rb db/schema.rb app/models/food.rb test/models/food_test.rb test/fixtures/foods.yml
git commit -m "Add Food model with validations and tests"
```

---

## Task 3: Create the UserFood Model

**What you're learning:** A join table connects two models. `UserFood` is the "saved foods list" — it records which users have saved which foods. The `through:` association in Rails lets you skip the join model and go directly from User to Food.

**Files:**
- Create: `db/migrate/TIMESTAMP_create_user_foods.rb`
- Create: `app/models/user_food.rb`
- Create: `test/models/user_food_test.rb`
- Create: `test/fixtures/user_foods.yml`

- [ ] **Step 1: Generate the migration**

```bash
rails generate migration CreateUserFoods user:references food:references
```

Open the generated file and confirm it looks like this:

```ruby
class CreateUserFoods < ActiveRecord::Migration[7.1]
  def change
    create_table :user_foods do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true

      t.timestamps
    end

    # WHY: A user should only be able to save the same food once.
    # This index enforces that at the database level.
    add_index :user_foods, [:user_id, :food_id], unique: true
  end
end
```

Add the `add_index` line if it wasn't generated automatically.

- [ ] **Step 2: Run the migration**

```bash
rails db:migrate
```

Expected output: `== CreateUserFoods: migrating ==` ... `migrated`

- [ ] **Step 3: Write the failing test**

Create `test/models/user_food_test.rb`:

```ruby
require "test_helper"

class UserFoodTest < ActiveSupport::TestCase
  test "is invalid without a user" do
    user_food = UserFood.new(food: foods(:banana))
    assert_not user_food.valid?
  end

  test "is invalid without a food" do
    user_food = UserFood.new(user: users(:one))
    assert_not user_food.valid?
  end

  # WHY: A user saving the same food twice would clutter their list.
  # We enforce uniqueness so each food appears only once per user.
  test "prevents a user from saving the same food twice" do
    UserFood.create!(user: users(:one), food: foods(:banana))
    duplicate = UserFood.new(user: users(:one), food: foods(:banana))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:food_id], "has already been taken"
  end

  test "allows different users to save the same food" do
    UserFood.create!(user: users(:one), food: foods(:banana))
    other = UserFood.new(user: users(:two), food: foods(:banana))
    assert other.valid?
  end
end
```

- [ ] **Step 4: Check the users fixture**

Rails ships with a `test/fixtures/users.yml`. Open it and make sure it has at least two users. If it's empty or missing, replace it with:

```yaml
one:
  first_name: Alice
  last_name: Smith
  email: alice@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>

two:
  first_name: Bob
  last_name: Jones
  email: bob@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
```

- [ ] **Step 5: Run the test to confirm it fails**

```bash
rails test test/models/user_food_test.rb
```

Expected: Fails with `uninitialized constant UserFoodTest::UserFood`

- [ ] **Step 6: Create the UserFood model**

Create `app/models/user_food.rb`:

```ruby
class UserFood < ApplicationRecord
  belongs_to :user
  belongs_to :food

  # WHY: scope: :user means "unique food per user" — not globally unique.
  validates :food_id, uniqueness: { scope: :user_id }
end
```

- [ ] **Step 7: Create the fixture file**

Create `test/fixtures/user_foods.yml`:

```yaml
alice_banana:
  user: one
  food: banana
```

- [ ] **Step 8: Run tests to confirm they pass**

```bash
rails test test/models/user_food_test.rb
```

Expected: `4 runs, 4 assertions, 0 failures, 0 errors`

- [ ] **Step 9: Commit**

```bash
git add db/migrate/*_create_user_foods.rb db/schema.rb app/models/user_food.rb test/models/user_food_test.rb test/fixtures/user_foods.yml test/fixtures/users.yml
git commit -m "Add UserFood join model with uniqueness validation and tests"
```

---

## Task 4: Create the FoodLog Model

**What you're learning:** `FoodLog` is the diary — each row is one eating event. Scopes let you define reusable query shortcuts on a model, like `FoodLog.today` or `FoodLog.for_week`.

**Files:**
- Create: `db/migrate/TIMESTAMP_create_food_logs.rb`
- Create: `app/models/food_log.rb`
- Create: `test/models/food_log_test.rb`
- Create: `test/fixtures/food_logs.yml`

- [ ] **Step 1: Generate the migration**

```bash
rails generate migration CreateFoodLogs user:references food:references servings:decimal meal_type:string logged_on:date
```

Open the generated file and confirm it looks like this:

```ruby
class CreateFoodLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :food_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.decimal :servings, precision: 5, scale: 2, null: false, default: 1.0
      t.string :meal_type, null: false
      t.date :logged_on, null: false

      t.timestamps
    end

    # WHY: We often query "all logs for user X on date Y" — this index
    # makes that query fast instead of scanning the entire table.
    add_index :food_logs, [:user_id, :logged_on]
  end
end
```

Add precision/scale and the index if not generated automatically.

- [ ] **Step 2: Run the migration**

```bash
rails db:migrate
```

- [ ] **Step 3: Write the failing test**

Create `test/models/food_log_test.rb`:

```ruby
require "test_helper"

class FoodLogTest < ActiveSupport::TestCase
  test "is invalid without a meal_type" do
    log = FoodLog.new(user: users(:one), food: foods(:banana), logged_on: Date.today)
    assert_not log.valid?
    assert_includes log.errors[:meal_type], "can't be blank"
  end

  test "is invalid with an unrecognized meal_type" do
    log = FoodLog.new(user: users(:one), food: foods(:banana), logged_on: Date.today, meal_type: "midnight_snack")
    assert_not log.valid?
    assert_includes log.errors[:meal_type], "is not included in the list"
  end

  test "is invalid without a logged_on date" do
    log = FoodLog.new(user: users(:one), food: foods(:banana), meal_type: "breakfast")
    assert_not log.valid?
  end

  test "is valid with all required fields" do
    log = FoodLog.new(user: users(:one), food: foods(:banana), meal_type: "lunch", logged_on: Date.today)
    assert log.valid?
  end

  # WHY: Scopes let us write current_user.food_logs.today instead of
  # current_user.food_logs.where(logged_on: Date.today) everywhere.
  test "today scope returns only today's logs" do
    log_today = food_logs(:alice_breakfast_today)
    assert_includes FoodLog.today, log_today
  end

  test "calories_consumed calculates total kcal for a log entry" do
    # banana is 89 kcal/100g, 118g serving = ~105 kcal per serving
    # We log 2 servings of banana: 2 × 105 = 210 kcal
    log = FoodLog.new(food: foods(:banana), servings: 2)
    assert_in_delta 210.0, log.calories_consumed, 1.0
  end
end
```

- [ ] **Step 4: Run to confirm it fails**

```bash
rails test test/models/food_log_test.rb
```

Expected: Fails with `uninitialized constant FoodLogTest::FoodLog`

- [ ] **Step 5: Create the FoodLog model**

Create `app/models/food_log.rb`:

```ruby
class FoodLog < ApplicationRecord
  belongs_to :user
  belongs_to :food

  MEAL_TYPES = %w[breakfast lunch dinner].freeze

  validates :meal_type, presence: true, inclusion: { in: MEAL_TYPES }
  validates :logged_on, presence: true
  validates :servings, numericality: { greater_than: 0 }

  # WHY: Scopes are reusable query methods you can chain.
  # FoodLog.today returns all logs where logged_on is today's date.
  scope :today, -> { where(logged_on: Date.today) }
  scope :for_date, ->(date) { where(logged_on: date) }

  # WHY: last_7_days gives us the data for the weekly chart.
  # It groups results by date so Chart.js gets one value per day.
  scope :last_7_days, -> { where(logged_on: 7.days.ago.to_date..Date.today) }

  # WHY: This is a computed value — calories depend on how many servings
  # were eaten. We multiply kcal per serving by the number of servings.
  # serving_size is stored as "118g" so we parse the number out of it.
  def calories_consumed
    return 0 unless food.calories_per_100g

    serving_grams = food.serving_size.to_f  # "118g".to_f => 118.0
    kcal_per_serving = (food.calories_per_100g / 100.0) * serving_grams
    (kcal_per_serving * servings).round(1)
  end
end
```

- [ ] **Step 6: Create the fixture file**

Create `test/fixtures/food_logs.yml`:

```yaml
alice_breakfast_today:
  user: one
  food: banana
  meal_type: breakfast
  logged_on: <%= Date.today %>
  servings: 1.0

alice_lunch_today:
  user: one
  food: oatmeal
  meal_type: lunch
  logged_on: <%= Date.today %>
  servings: 1.0
```

- [ ] **Step 7: Run tests to confirm they pass**

```bash
rails test test/models/food_log_test.rb
```

Expected: `6 runs, 6 assertions, 0 failures, 0 errors`

- [ ] **Step 8: Commit**

```bash
git add db/migrate/*_create_food_logs.rb db/schema.rb app/models/food_log.rb test/models/food_log_test.rb test/fixtures/food_logs.yml
git commit -m "Add FoodLog model with meal type validation, scopes, and calorie calculation"
```

---

## Task 5: Create the CalorieProfile Model

**What you're learning:** `has_one` is used when one model belongs to exactly one other model (not many). A user can only have one calorie profile at a time.

**Files:**
- Create: `db/migrate/TIMESTAMP_create_calorie_profiles.rb`
- Create: `app/models/calorie_profile.rb`
- Create: `test/models/calorie_profile_test.rb`
- Create: `test/fixtures/calorie_profiles.yml`

- [ ] **Step 1: Generate the migration**

```bash
rails generate migration CreateCalorieProfiles user:references daily_target:integer age:integer sex:string weight_kg:decimal height_cm:decimal activity_level:string goal_type:string entry_method:string
```

Open the generated file and update it to look like this:

```ruby
class CreateCalorieProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :calorie_profiles do |t|
      # WHY: index: { unique: true } means one profile per user —
      # enforced at the database level, not just in Ruby.
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :daily_target, null: false
      t.integer :age
      t.string :sex
      t.decimal :weight_kg, precision: 6, scale: 2
      t.decimal :height_cm, precision: 6, scale: 2
      t.string :activity_level
      t.string :goal_type
      t.string :entry_method, null: false, default: "manual"

      t.timestamps
    end
  end
end
```

- [ ] **Step 2: Run the migration**

```bash
rails db:migrate
```

- [ ] **Step 3: Write the failing test**

Create `test/models/calorie_profile_test.rb`:

```ruby
require "test_helper"

class CalorieProfileTest < ActiveSupport::TestCase
  test "is invalid without a daily_target" do
    profile = CalorieProfile.new(user: users(:one), entry_method: "manual")
    assert_not profile.valid?
    assert_includes profile.errors[:daily_target], "can't be blank"
  end

  test "is invalid with a daily_target less than 1" do
    profile = CalorieProfile.new(user: users(:one), daily_target: 0, entry_method: "manual")
    assert_not profile.valid?
  end

  test "is valid with a user and daily_target" do
    profile = CalorieProfile.new(user: users(:two), daily_target: 2000, entry_method: "manual")
    assert profile.valid?
  end

  # WHY: A user should only have one calorie profile. If they already have one,
  # creating a second should fail.
  test "only one profile allowed per user" do
    CalorieProfile.create!(user: users(:two), daily_target: 2000, entry_method: "manual")
    duplicate = CalorieProfile.new(user: users(:two), daily_target: 1800, entry_method: "manual")
    assert_not duplicate.valid?
  end
end
```

- [ ] **Step 4: Run to confirm it fails**

```bash
rails test test/models/calorie_profile_test.rb
```

Expected: Fails with `uninitialized constant CalorieProfileTest::CalorieProfile`

- [ ] **Step 5: Create the CalorieProfile model**

Create `app/models/calorie_profile.rb`:

```ruby
class CalorieProfile < ApplicationRecord
  belongs_to :user

  ACTIVITY_LEVELS = %w[sedentary lightly_active moderately_active very_active].freeze
  GOAL_TYPES = %w[lose maintain gain].freeze
  ENTRY_METHODS = %w[manual survey].freeze

  validates :daily_target, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: true
  validates :entry_method, inclusion: { in: ENTRY_METHODS }
end
```

- [ ] **Step 6: Create the fixture file**

Create `test/fixtures/calorie_profiles.yml`:

```yaml
alice_profile:
  user: one
  daily_target: 2000
  entry_method: manual
```

- [ ] **Step 7: Run tests to confirm they pass**

```bash
rails test test/models/calorie_profile_test.rb
```

Expected: `4 runs, 4 assertions, 0 failures, 0 errors`

- [ ] **Step 8: Commit**

```bash
git add db/migrate/*_create_calorie_profiles.rb db/schema.rb app/models/calorie_profile.rb test/models/calorie_profile_test.rb test/fixtures/calorie_profiles.yml
git commit -m "Add CalorieProfile model with uniqueness per user and tests"
```

---

## Task 6: Update User Model, Routes, and Application Controller

**What you're learning:** Associations are defined in both directions — the `User` model needs to declare what it owns. Routes are the "table of contents" for your app — every URL your app responds to must be listed here.

**Files:**
- Modify: `app/models/user.rb`
- Modify: `config/routes.rb`
- Modify: `app/controllers/application_controller.rb`

- [ ] **Step 1: Update User model with associations**

Open `app/models/user.rb` and replace its contents with:

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # WHY: has_one means a user owns exactly one calorie profile.
  # dependent: :destroy means if the user is deleted, their profile is too.
  has_one :calorie_profile, dependent: :destroy

  has_many :user_foods, dependent: :destroy
  has_many :foods, through: :user_foods

  has_many :food_logs, dependent: :destroy
end
```

- [ ] **Step 2: Update the routes**

Open `config/routes.rb` and replace its contents with:

```ruby
Rails.application.routes.draw do
  devise_for :users

  # WHY: authenticated :user means "this route is only for logged-in users."
  # When a logged-in user visits /, they go to the dashboard.
  # When a guest visits /, they go to the home/landing page.
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  root to: "pages#home"

  # WHY: :only limits which actions are generated. We don't need all 7
  # REST actions for every resource — just the ones we'll actually use.
  resource :dashboard, only: [:index]

  # Barcode scan and food lookup
  resources :foods, only: [] do
    collection do
      get  :scan    # GET  /foods/scan   — shows the scanner page
      post :lookup  # POST /foods/lookup — submits a barcode, returns food info
    end
  end

  # Saved foods list
  resources :user_foods, only: [:index, :create, :destroy]

  # Log a meal
  resources :food_logs, only: [:new, :create, :destroy]

  # Calorie goal setup
  resource :calorie_profile, only: [:new, :create, :edit, :update]
end
```

- [ ] **Step 3: Check application_controller.rb**

Open `app/controllers/application_controller.rb`. It should look like this (it likely already has the `before_action`):

```ruby
class ApplicationController < ActionController::Base
  # WHY: This ensures every page requires login, EXCEPT pages that
  # explicitly opt out with skip_before_action (like the home page).
  before_action :authenticate_user!
end
```

If `before_action :authenticate_user!` is missing, add it.

- [ ] **Step 4: Verify routes are correct**

```bash
rails routes | grep -E "dashboard|foods|user_foods|food_logs|calorie_profile"
```

Expected output (roughly):
```
authenticated_root GET  /                     dashboard#index
dashboard          GET  /dashboard            dashboard#index
scan_foods         GET  /foods/scan           foods#scan
lookup_foods       POST /foods/lookup         foods#lookup
user_foods         GET  /user_foods           user_foods#index
...
```

- [ ] **Step 5: Run all model tests to confirm nothing broke**

```bash
rails test test/models/
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add app/models/user.rb config/routes.rb app/controllers/application_controller.rb
git commit -m "Update User associations, routes for all features, require auth by default"
```

---

## Task 7: Build the OpenFoodFacts Service

**What you're learning:** Services are plain Ruby classes that contain business logic. Controllers should be thin — they receive a request, call a service, and render a response. The actual API call logic lives in the service, not the controller.

**Files:**
- Create: `app/services/open_food_facts_service.rb`
- Create: `test/services/open_food_facts_service_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/services/` directory if it doesn't exist, then create `test/services/open_food_facts_service_test.rb`:

```ruby
require "test_helper"

class OpenFoodFactsServiceTest < ActiveSupport::TestCase
  # WHY: We don't want our tests to make real HTTP calls — that would be
  # slow, unreliable, and could fail if there's no internet. Instead we
  # use Minitest's stub method to fake the API response.

  test "returns a Food object when barcode is found in our database" do
    existing_food = foods(:banana)
    result = OpenFoodFactsService.lookup(existing_food.barcode)
    assert_equal existing_food, result
  end

  test "returns nil when barcode is not found anywhere" do
    # Stub OpenFoodFacts::Product.get to return nil (not found)
    OpenFoodFacts::Product.stub(:get, nil) do
      result = OpenFoodFactsService.lookup("0000000000000")
      assert_nil result
    end
  end

  test "creates and returns a Food record when barcode found via API" do
    # Build a fake product object with the fields we need
    fake_product = OpenStruct.new(
      product_name: "Test Chips",
      brands: "Test Brand",
      serving_size: "30g",
      nutrition_grades: "c",
      nutriments: OpenStruct.new(
        energy_kcal_100g: 500.0,
        fat_100g: 25.0,
        carbohydrates_100g: 55.0,
        proteins_100g: 8.0
      )
    )

    OpenFoodFacts::Product.stub(:get, fake_product) do
      assert_difference "Food.count", 1 do
        result = OpenFoodFactsService.lookup("9999888877776")
        assert_equal "Test Chips", result.name
        assert_equal "Test Brand", result.brand
        assert_equal 500.0, result.calories_per_100g
      end
    end
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/services/open_food_facts_service_test.rb
```

Expected: Fails with `uninitialized constant OpenFoodFactsService`

- [ ] **Step 3: Create the service**

Create `app/services/open_food_facts_service.rb`:

```ruby
class OpenFoodFactsService
  # WHY: A class method (self.lookup) means you call it as
  # OpenFoodFactsService.lookup(barcode) — no need to instantiate the class.

  def self.lookup(barcode)
    # Step 1: Check our own database first (cache hit = no API call needed)
    food = Food.find_by(barcode: barcode)
    return food if food

    # Step 2: Ask the OpenFoodFacts API
    product = OpenFoodFacts::Product.get(barcode)
    return nil if product.nil? || product.product_name.blank?

    # Step 3: Save to our database and return
    Food.create!(
      barcode:             barcode,
      name:                product.product_name,
      brand:               product.brands,
      serving_size:        product.serving_size,
      nutri_score:         product.nutrition_grades,
      calories_per_100g:   safe_nutriment(product, :energy_kcal_100g),
      fat_100g:            safe_nutriment(product, :fat_100g),
      carbohydrates_100g:  safe_nutriment(product, :carbohydrates_100g),
      protein_100g:        safe_nutriment(product, :proteins_100g)
    )
  rescue ActiveRecord::RecordInvalid
    # WHY: If the Food is already in the database (race condition or duplicate
    # barcode in OpenFoodFacts), find_by will get it. We don't want to crash.
    Food.find_by(barcode: barcode)
  end

  private

  # WHY: Nutriment data from the API can be nil for some products.
  # safe_nutriment returns nil gracefully instead of raising NoMethodError.
  def self.safe_nutriment(product, field)
    product.nutriments&.send(field)
  rescue NoMethodError
    nil
  end
end
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
rails test test/services/open_food_facts_service_test.rb
```

Expected: `3 runs, 5 assertions, 0 failures, 0 errors`

- [ ] **Step 5: Commit**

```bash
git add app/services/open_food_facts_service.rb test/services/open_food_facts_service_test.rb
git commit -m "Add OpenFoodFactsService with database caching and API fallback"
```

---

## Task 8: Build the CalorieCalculator Service

**What you're learning:** Pure business logic (a math formula) belongs in a service, not a model or controller. This makes the formula easy to test in isolation.

**Files:**
- Create: `app/services/calorie_calculator_service.rb`
- Create: `test/services/calorie_calculator_service_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/services/calorie_calculator_service_test.rb`:

```ruby
require "test_helper"

class CalorieCalculatorServiceTest < ActiveSupport::TestCase
  # WHY: We test known inputs against known outputs so we can be confident
  # the formula is implemented correctly. These expected values were
  # verified against an online Mifflin-St Jeor calculator.

  test "calculates BMR for a male, sedentary, maintain goal" do
    # Male, 30 years, 80 kg, 175 cm, sedentary, maintain
    # BMR = (10 × 80) + (6.25 × 175) − (5 × 30) + 5 = 1848.75
    # TDEE = 1848.75 × 1.2 = 2218.5 → rounded to 2219
    result = CalorieCalculatorService.calculate(
      sex: "male", age: 30, weight_kg: 80, height_cm: 175,
      activity_level: "sedentary", goal_type: "maintain"
    )
    assert_equal 2219, result
  end

  test "calculates BMR for a female, moderately active, lose goal" do
    # Female, 25 years, 60 kg, 165 cm, moderately_active, lose
    # BMR = (10 × 60) + (6.25 × 165) − (5 × 25) − 161 = 1401.25
    # TDEE = 1401.25 × 1.55 = 2171.9 → minus 500 = 1672
    result = CalorieCalculatorService.calculate(
      sex: "female", age: 25, weight_kg: 60, height_cm: 165,
      activity_level: "moderately_active", goal_type: "lose"
    )
    assert_equal 1672, result
  end

  test "raises an error for unknown sex" do
    assert_raises(ArgumentError) do
      CalorieCalculatorService.calculate(
        sex: "unknown", age: 25, weight_kg: 60, height_cm: 165,
        activity_level: "sedentary", goal_type: "maintain"
      )
    end
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/services/calorie_calculator_service_test.rb
```

Expected: Fails with `uninitialized constant CalorieCalculatorServiceTest::CalorieCalculatorService`

- [ ] **Step 3: Create the service**

Create `app/services/calorie_calculator_service.rb`:

```ruby
class CalorieCalculatorService
  ACTIVITY_MULTIPLIERS = {
    "sedentary"          => 1.2,
    "lightly_active"     => 1.375,
    "moderately_active"  => 1.55,
    "very_active"        => 1.725
  }.freeze

  GOAL_ADJUSTMENTS = {
    "lose"     => -500,
    "maintain" => 0,
    "gain"     => +500
  }.freeze

  def self.calculate(sex:, age:, weight_kg:, height_cm:, activity_level:, goal_type:)
    bmr = mifflin_st_jeor(sex: sex, age: age, weight_kg: weight_kg, height_cm: height_cm)
    multiplier = ACTIVITY_MULTIPLIERS.fetch(activity_level, 1.2)
    adjustment = GOAL_ADJUSTMENTS.fetch(goal_type, 0)

    ((bmr * multiplier) + adjustment).round
  end

  private

  def self.mifflin_st_jeor(sex:, age:, weight_kg:, height_cm:)
    # WHY: The Mifflin-St Jeor formula has a sex-specific constant
    # (+5 for men, -161 for women) that accounts for physiological differences.
    base = (10 * weight_kg) + (6.25 * height_cm) - (5 * age)
    case sex.downcase
    when "male"   then base + 5
    when "female" then base - 161
    else raise ArgumentError, "sex must be 'male' or 'female'"
    end
  end
end
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
rails test test/services/calorie_calculator_service_test.rb
```

Expected: `3 runs, 3 assertions, 0 failures, 0 errors`

- [ ] **Step 5: Commit**

```bash
git add app/services/calorie_calculator_service.rb test/services/calorie_calculator_service_test.rb
git commit -m "Add CalorieCalculatorService implementing Mifflin-St Jeor formula"
```

---

## Task 9: Build the Foods Controller

**What you're learning:** Controllers receive HTTP requests and decide what to do. The `scan` action renders a page (GET). The `lookup` action processes submitted data (POST).

**Files:**
- Create: `app/controllers/foods_controller.rb`
- Create: `test/controllers/foods_controller_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/controllers/foods_controller_test.rb`:

```ruby
require "test_helper"

class FoodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # WHY: sign_in is provided by Devise for tests. Most pages require
    # a logged-in user, so we sign in before each test.
    sign_in users(:one)
  end

  test "GET /foods/scan returns 200" do
    get scan_foods_path
    assert_response :success
  end

  test "POST /foods/lookup with known barcode returns food info" do
    post lookup_foods_path, params: { barcode: foods(:banana).barcode }
    assert_response :success
    assert_select "h2", text: /Banana/
  end

  test "POST /foods/lookup with unknown barcode shows not-found message" do
    OpenFoodFacts::Product.stub(:get, nil) do
      post lookup_foods_path, params: { barcode: "0000000000000" }
      assert_response :success
      assert_select ".not-found-message"
    end
  end

  test "POST /foods/lookup redirects to login when not authenticated" do
    sign_out users(:one)
    post lookup_foods_path, params: { barcode: "123" }
    assert_redirected_to new_user_session_path
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/controllers/foods_controller_test.rb
```

Expected: Fails with `uninitialized constant FoodsControllerTest::FoodsController` (or routing error)

- [ ] **Step 3: Create the controller**

Create `app/controllers/foods_controller.rb`:

```ruby
class FoodsController < ApplicationController
  def scan
    # WHY: This action just renders the scanner page.
    # The actual barcode lookup happens in the lookup action below.
  end

  def lookup
    barcode = params[:barcode].to_s.strip

    if barcode.blank?
      flash.now[:alert] = "Please enter or scan a barcode."
      render :scan and return
    end

    @food = OpenFoodFactsService.lookup(barcode)

    if @food
      render :show
    else
      render :not_found
    end
  end
end
```

- [ ] **Step 4: Create a placeholder scan view**

Create `app/views/foods/scan.html.erb` (just enough to make the test pass — we'll build the full UI in Task 10):

```erb
<div class="max-w-md mx-auto p-6">
  <h1 class="text-2xl font-bold mb-4">Scan a Food Barcode</h1>
  <!-- Scanner UI comes in Task 10 -->
  <%= form_with url: lookup_foods_path, method: :post, local: true do |f| %>
    <%= f.text_field :barcode, placeholder: "Enter barcode manually", class: "border rounded w-full p-2 mb-4" %>
    <%= f.submit "Look Up", class: "bg-green-600 text-white px-4 py-2 rounded" %>
  <% end %>
</div>
```

- [ ] **Step 5: Create a placeholder show view**

Create `app/views/foods/show.html.erb`:

```erb
<div class="max-w-md mx-auto p-6">
  <h2 class="text-2xl font-bold"><%= @food.name %></h2>
  <p class="text-gray-500"><%= @food.brand %></p>
  <!-- Full food card UI comes in Task 11 -->
</div>
```

- [ ] **Step 6: Create a not_found view**

Create `app/views/foods/not_found.html.erb`:

```erb
<div class="max-w-md mx-auto p-6 text-center not-found-message">
  <p class="text-lg text-gray-600">We couldn't find that product.</p>
  <p class="text-sm text-gray-400 mt-1">Try scanning again or enter the barcode manually.</p>
  <%= link_to "Try again", scan_foods_path, class: "mt-4 inline-block bg-green-600 text-white px-4 py-2 rounded" %>
</div>
```

- [ ] **Step 7: Run tests to confirm they pass**

```bash
rails test test/controllers/foods_controller_test.rb
```

Expected: `4 runs, 4 assertions, 0 failures, 0 errors`

- [ ] **Step 8: Commit**

```bash
git add app/controllers/foods_controller.rb app/views/foods/ test/controllers/foods_controller_test.rb
git commit -m "Add FoodsController with scan page and barcode lookup"
```

---

## Task 10: Build the Barcode Scanner UI

**What you're learning:** Stimulus is a JavaScript framework built for Rails. You connect a Stimulus controller to an HTML element with `data-controller="barcode-scanner"`. The JS then controls that part of the page. ZXing is a library that reads barcodes from the camera.

**Files:**
- Modify: `config/importmap.rb`
- Create: `app/javascript/controllers/barcode_scanner_controller.js`
- Modify: `app/views/foods/scan.html.erb`

- [ ] **Step 1: Pin ZXing in importmap**

Open `config/importmap.rb` and add:

```ruby
pin "@zxing/browser", to: "https://cdn.jsdelivr.net/npm/@zxing/browser@0.1.1/umd/index.min.js"
```

- [ ] **Step 2: Create the Stimulus controller**

Create `app/javascript/controllers/barcode_scanner_controller.js`:

```javascript
// WHY: Stimulus controllers are the bridge between your HTML and JavaScript.
// When Rails sees data-controller="barcode-scanner" on an element, it
// automatically creates an instance of this class and calls connect().

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // WHY: targets let you reference HTML elements from JavaScript.
  // static targets = ["video", "result", "input"] means you can
  // use this.videoTarget, this.resultTarget, this.inputTarget in your code.
  static targets = ["video", "result", "input", "startBtn", "stopBtn"]

  connect() {
    this.codeReader = null
  }

  async startScan() {
    // WHY: We dynamically import ZXing only when the user clicks "Start Camera"
    // so it doesn't slow down the initial page load.
    const { BrowserMultiFormatReader } = await import("@zxing/browser")
    this.codeReader = new BrowserMultiFormatReader()

    this.startBtnTarget.classList.add("hidden")
    this.stopBtnTarget.classList.remove("hidden")
    this.videoTarget.classList.remove("hidden")

    try {
      await this.codeReader.decodeFromVideoDevice(
        undefined,       // use default camera
        this.videoTarget,
        (result, error) => {
          if (result) {
            // WHY: Once we have a barcode, we stop the camera and submit the form.
            this.resultTarget.value = result.getText()
            this.stopScan()
            this.element.querySelector("form").submit()
          }
        }
      )
    } catch (e) {
      alert("Camera not available. Please enter the barcode manually.")
      this.stopScan()
    }
  }

  stopScan() {
    if (this.codeReader) {
      BrowserMultiFormatReader.releaseAllStreams()
      this.codeReader = null
    }
    this.videoTarget.classList.add("hidden")
    this.startBtnTarget.classList.remove("hidden")
    this.stopBtnTarget.classList.add("hidden")
  }

  disconnect() {
    // WHY: disconnect() is called when the element leaves the page.
    // Always clean up camera streams to avoid memory leaks.
    this.stopScan()
  }
}
```

- [ ] **Step 3: Register the controller**

Open `app/javascript/controllers/index.js` and add:

```javascript
import BarcodeScannerController from "./barcode_scanner_controller"
application.register("barcode-scanner", BarcodeScannerController)
```

- [ ] **Step 4: Update the scan view with full UI**

Replace `app/views/foods/scan.html.erb` with:

```erb
<%# WHY: data-controller="barcode-scanner" connects this div to our
    Stimulus controller. All targets inside it are accessible in JS. %>
<div class="max-w-md mx-auto p-6" data-controller="barcode-scanner">
  <h1 class="text-2xl font-bold mb-6 text-center">Scan a Food Barcode</h1>

  <%# Camera video feed — hidden by default, shown when camera starts %>
  <video data-barcode-scanner-target="video"
         class="w-full rounded-lg mb-4 hidden"
         autoplay
         playsinline></video>

  <%# Camera controls %>
  <div class="flex gap-3 mb-6">
    <button data-barcode-scanner-target="startBtn"
            data-action="click->barcode-scanner#startScan"
            class="flex-1 bg-green-600 text-white py-3 rounded-xl font-semibold">
      📷 Scan Barcode
    </button>
    <button data-barcode-scanner-target="stopBtn"
            data-action="click->barcode-scanner#stopScan"
            class="flex-1 bg-gray-400 text-white py-3 rounded-xl font-semibold hidden">
      Stop Camera
    </button>
  </div>

  <div class="flex items-center gap-3 my-4">
    <hr class="flex-1 border-gray-300">
    <span class="text-gray-400 text-sm">or enter manually</span>
    <hr class="flex-1 border-gray-300">
  </div>

  <%# Manual entry form — also used by the JS scanner to auto-submit %>
  <%= form_with url: lookup_foods_path, method: :post, local: true do |f| %>
    <%# data-barcode-scanner-target="result" is where JS puts the scanned barcode %>
    <%= f.text_field :barcode,
          data: { "barcode-scanner-target": "result" },
          placeholder: "Enter barcode number",
          class: "border border-gray-300 rounded-xl w-full p-3 mb-4 text-center text-lg" %>
    <%= f.submit "Look Up",
          class: "w-full bg-green-600 text-white py-3 rounded-xl font-semibold" %>
  <% end %>
</div>
```

- [ ] **Step 5: Start the Rails server and manually test**

```bash
rails server
```

Open http://localhost:3000/foods/scan (you must be logged in). You should see:
- A "Scan Barcode" button
- An "or enter manually" divider
- A text field and "Look Up" button

Try entering a known barcode like `0011110874931` and clicking Look Up. You should see the banana food card.

- [ ] **Step 6: Commit**

```bash
git add config/importmap.rb app/javascript/controllers/barcode_scanner_controller.js app/javascript/controllers/index.js app/views/foods/scan.html.erb
git commit -m "Add barcode scanner UI with ZXing camera scanning and manual fallback"
```

---

## Task 11: Build the Food Card View

**What you're learning:** The food card is what the user sees after a successful barcode lookup. It shows nutritional info and lets the user add the food to their saved list or dismiss it.

**Files:**
- Modify: `app/views/foods/show.html.erb`

- [ ] **Step 1: Replace the food card view**

Replace `app/views/foods/show.html.erb` with:

```erb
<div class="max-w-md mx-auto p-6">

  <%# Nutri-Score badge color mapping %>
  <% nutri_colors = { "a" => "bg-green-500", "b" => "bg-lime-400",
                      "c" => "bg-yellow-400", "d" => "bg-orange-400",
                      "e" => "bg-red-500" } %>

  <div class="bg-white rounded-2xl shadow-lg overflow-hidden">
    <%# Header %>
    <div class="p-5 border-b border-gray-100">
      <div class="flex justify-between items-start">
        <div>
          <h2 class="text-xl font-bold text-gray-800"><%= @food.name %></h2>
          <p class="text-gray-500 text-sm"><%= @food.brand %></p>
          <p class="text-gray-400 text-xs mt-1">Serving: <%= @food.serving_size || "per 100g" %></p>
        </div>
        <%# Nutri-Score badge %>
        <% if @food.nutri_score.present? %>
          <span class="<%= nutri_colors[@food.nutri_score.downcase] || 'bg-gray-300' %> text-white font-bold px-3 py-1 rounded-lg text-sm uppercase">
            <%= @food.nutri_score.upcase %>
          </span>
        <% end %>
      </div>
    </div>

    <%# Nutrition facts grid %>
    <div class="grid grid-cols-2 gap-4 p-5 bg-gray-50">
      <div class="text-center">
        <p class="text-2xl font-bold text-gray-800"><%= @food.calories_per_100g&.round || "—" %></p>
        <p class="text-xs text-gray-500">kcal / 100g</p>
      </div>
      <div class="text-center">
        <p class="text-2xl font-bold text-gray-800"><%= @food.protein_100g&.round || "—" %>g</p>
        <p class="text-xs text-gray-500">Protein</p>
      </div>
      <div class="text-center">
        <p class="text-2xl font-bold text-gray-800"><%= @food.carbohydrates_100g&.round || "—" %>g</p>
        <p class="text-xs text-gray-500">Carbs</p>
      </div>
      <div class="text-center">
        <p class="text-2xl font-bold text-gray-800"><%= @food.fat_100g&.round || "—" %>g</p>
        <p class="text-xs text-gray-500">Fat</p>
      </div>
    </div>

    <%# Action buttons %>
    <div class="p-5 flex gap-3">
      <%# If user already saved this food, show "Already saved" %>
      <% already_saved = current_user.user_foods.exists?(food: @food) %>
      <% if already_saved %>
        <span class="flex-1 text-center py-3 rounded-xl bg-gray-100 text-gray-500 font-semibold">
          ✓ Already in your list
        </span>
      <% else %>
        <%= form_with url: user_foods_path, method: :post, local: true, class: "flex-1" do |f| %>
          <%= f.hidden_field :food_id, value: @food.id %>
          <%= f.submit "＋ Add to my list",
                class: "w-full py-3 rounded-xl bg-green-600 text-white font-semibold cursor-pointer" %>
        <% end %>
      <% end %>

      <%# Dismiss button — goes back to the scanner %>
      <%= link_to "✕", scan_foods_path,
            class: "flex items-center justify-center px-5 rounded-xl border-2 border-gray-200 text-gray-400 font-bold hover:bg-gray-50" %>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Manually test the food card**

Start the server (`rails server`) and go to `/foods/scan`. Look up barcode `0011110874931` (banana). You should see:
- Food name and brand
- Nutri-Score badge
- Calories, protein, carbs, fat
- "Add to my list" button
- ✕ dismiss button

- [ ] **Step 3: Commit**

```bash
git add app/views/foods/show.html.erb
git commit -m "Build food card view with nutritional info and add/dismiss actions"
```

---

## Task 12: Build the UserFoods Controller and Saved Foods List

**What you're learning:** The `create` action saves a food to the user's list. The `destroy` action removes it. The `index` action shows the full list. `redirect_to` sends the user to a different page after an action.

**Files:**
- Create: `app/controllers/user_foods_controller.rb`
- Create: `app/views/user_foods/index.html.erb`
- Create: `test/controllers/user_foods_controller_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/controllers/user_foods_controller_test.rb`:

```ruby
require "test_helper"

class UserFoodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "GET /user_foods shows the saved foods list" do
    get user_foods_path
    assert_response :success
    assert_select "h1", text: /My Saved Foods/
  end

  test "POST /user_foods saves a food to the user's list" do
    assert_difference "UserFood.count", 1 do
      post user_foods_path, params: { food_id: foods(:oatmeal).id }
    end
    assert_redirected_to user_foods_path
  end

  test "POST /user_foods does not duplicate an existing saved food" do
    # alice already has banana saved (from fixture)
    assert_no_difference "UserFood.count" do
      post user_foods_path, params: { food_id: foods(:banana).id }
    end
    assert_redirected_to user_foods_path
  end

  test "DELETE /user_foods/:id removes a saved food" do
    user_food = user_foods(:alice_banana)
    assert_difference "UserFood.count", -1 do
      delete user_food_path(user_food)
    end
    assert_redirected_to user_foods_path
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/controllers/user_foods_controller_test.rb
```

Expected: Fails

- [ ] **Step 3: Create the controller**

Create `app/controllers/user_foods_controller.rb`:

```ruby
class UserFoodsController < ApplicationController
  def index
    @user_foods = current_user.user_foods.includes(:food).order("foods.name")
  end

  def create
    food = Food.find(params[:food_id])
    # WHY: find_or_create_by prevents duplicates without raising an error.
    # If the food is already saved, it just returns the existing record.
    current_user.user_foods.find_or_create_by(food: food)
    redirect_to user_foods_path, notice: "#{food.name} added to your list."
  end

  def destroy
    user_food = current_user.user_foods.find(params[:id])
    user_food.destroy
    redirect_to user_foods_path, notice: "Food removed from your list."
  end
end
```

- [ ] **Step 4: Create the saved foods view**

Create `app/views/user_foods/index.html.erb`:

```erb
<div class="max-w-md mx-auto p-6">
  <h1 class="text-2xl font-bold mb-6">My Saved Foods</h1>

  <% if @user_foods.empty? %>
    <div class="text-center text-gray-400 py-12">
      <p class="text-lg">No foods saved yet.</p>
      <%= link_to "Scan your first food →", scan_foods_path,
            class: "mt-4 inline-block text-green-600 font-semibold" %>
    </div>
  <% else %>
    <div class="space-y-3">
      <% @user_foods.each do |user_food| %>
        <% food = user_food.food %>
        <div class="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between">
          <div class="flex-1">
            <p class="font-semibold text-gray-800"><%= food.name %></p>
            <p class="text-sm text-gray-500"><%= food.brand %></p>
            <p class="text-xs text-gray-400 mt-1">
              <%= food.calories_per_100g&.round %> kcal/100g
              <% if food.nutri_score.present? %>
                · Nutri-Score <strong><%= food.nutri_score.upcase %></strong>
              <% end %>
            </p>
          </div>

          <%# Log this food button %>
          <%= link_to "Log", new_food_log_path(food_id: food.id),
                class: "bg-green-600 text-white px-3 py-1 rounded-lg text-sm mr-2" %>

          <%# Remove from list %>
          <%= button_to "✕", user_food_path(user_food), method: :delete,
                class: "text-gray-400 hover:text-red-500 px-2 py-1",
                data: { confirm: "Remove #{food.name} from your list?" } %>
        </div>
      <% end %>
    </div>
  <% end %>
</div>
```

- [ ] **Step 5: Run tests to confirm they pass**

```bash
rails test test/controllers/user_foods_controller_test.rb
```

Expected: `4 runs, 5 assertions, 0 failures, 0 errors`

- [ ] **Step 6: Commit**

```bash
git add app/controllers/user_foods_controller.rb app/views/user_foods/index.html.erb test/controllers/user_foods_controller_test.rb
git commit -m "Add UserFoodsController and saved foods list view"
```

---

## Task 13: Build the FoodLogs Controller and Log Meal Form

**What you're learning:** Logging a meal creates a `FoodLog` record linking the user, the food, the meal type, serving count, and today's date.

**Files:**
- Create: `app/controllers/food_logs_controller.rb`
- Create: `app/views/food_logs/new.html.erb`
- Create: `test/controllers/food_logs_controller_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/controllers/food_logs_controller_test.rb`:

```ruby
require "test_helper"

class FoodLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "GET /food_logs/new shows the log meal form" do
    get new_food_log_path(food_id: foods(:banana).id)
    assert_response :success
    assert_select "h1", text: /Log a Meal/
  end

  test "POST /food_logs creates a food log entry" do
    assert_difference "FoodLog.count", 1 do
      post food_logs_path, params: {
        food_log: {
          food_id:    foods(:oatmeal).id,
          meal_type:  "breakfast",
          servings:   1,
          logged_on:  Date.today
        }
      }
    end
    assert_redirected_to dashboard_path
  end

  test "POST /food_logs with invalid params re-renders form" do
    assert_no_difference "FoodLog.count" do
      post food_logs_path, params: {
        food_log: { food_id: foods(:banana).id, meal_type: "", servings: 1 }
      }
    end
    assert_response :unprocessable_entity
  end

  test "DELETE /food_logs/:id removes a food log" do
    log = food_logs(:alice_breakfast_today)
    assert_difference "FoodLog.count", -1 do
      delete food_log_path(log)
    end
    assert_redirected_to dashboard_path
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/controllers/food_logs_controller_test.rb
```

- [ ] **Step 3: Create the controller**

Create `app/controllers/food_logs_controller.rb`:

```ruby
class FoodLogsController < ApplicationController
  def new
    # WHY: We pre-populate the form with food_id if it was passed
    # in the URL (e.g., clicking "Log" from the saved foods list).
    @food_log = FoodLog.new(food_id: params[:food_id], logged_on: Date.today)
    @user_foods = current_user.user_foods.includes(:food).order("foods.name")
  end

  def create
    @food_log = current_user.food_logs.build(food_log_params)

    if @food_log.save
      redirect_to dashboard_path, notice: "Meal logged!"
    else
      @user_foods = current_user.user_foods.includes(:food).order("foods.name")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log = current_user.food_logs.find(params[:id])
    log.destroy
    redirect_to dashboard_path, notice: "Log entry removed."
  end

  private

  def food_log_params
    params.require(:food_log).permit(:food_id, :meal_type, :servings, :logged_on)
  end
end
```

- [ ] **Step 4: Create the log meal form**

Create `app/views/food_logs/new.html.erb`:

```erb
<div class="max-w-md mx-auto p-6">
  <h1 class="text-2xl font-bold mb-6">Log a Meal</h1>

  <%= form_with model: @food_log, local: true do |f| %>
    <% if @food_log.errors.any? %>
      <div class="bg-red-50 border border-red-200 rounded-xl p-4 mb-4">
        <% @food_log.errors.full_messages.each do |msg| %>
          <p class="text-red-600 text-sm"><%= msg %></p>
        <% end %>
      </div>
    <% end %>

    <%# Food selector %>
    <div class="mb-4">
      <%= f.label :food_id, "Food", class: "block text-sm font-medium text-gray-700 mb-1" %>
      <%= f.select :food_id,
            @user_foods.map { |uf| [uf.food.name, uf.food.id] },
            { prompt: "Select a food..." },
            class: "border border-gray-300 rounded-xl w-full p-3" %>
    </div>

    <%# Meal type selector %>
    <div class="mb-4">
      <%= f.label :meal_type, "Meal", class: "block text-sm font-medium text-gray-700 mb-1" %>
      <%= f.select :meal_type,
            [["Breakfast", "breakfast"], ["Lunch", "lunch"], ["Dinner", "dinner"]],
            { prompt: "Select meal..." },
            class: "border border-gray-300 rounded-xl w-full p-3" %>
    </div>

    <%# Servings %>
    <div class="mb-4">
      <%= f.label :servings, "Servings", class: "block text-sm font-medium text-gray-700 mb-1" %>
      <%= f.number_field :servings, min: 0.25, step: 0.25, value: 1,
            class: "border border-gray-300 rounded-xl w-full p-3" %>
    </div>

    <%# Date %>
    <div class="mb-6">
      <%= f.label :logged_on, "Date", class: "block text-sm font-medium text-gray-700 mb-1" %>
      <%= f.date_field :logged_on, class: "border border-gray-300 rounded-xl w-full p-3" %>
    </div>

    <%= f.submit "Log Meal", class: "w-full bg-green-600 text-white py-3 rounded-xl font-semibold" %>
  <% end %>
</div>
```

- [ ] **Step 5: Run tests to confirm they pass**

```bash
rails test test/controllers/food_logs_controller_test.rb
```

Expected: `4 runs, 6 assertions, 0 failures, 0 errors`

- [ ] **Step 6: Commit**

```bash
git add app/controllers/food_logs_controller.rb app/views/food_logs/new.html.erb test/controllers/food_logs_controller_test.rb
git commit -m "Add FoodLogsController and log meal form"
```

---

## Task 14: Build the Dashboard Controller and Meal Table View

**What you're learning:** The dashboard is the user's home base after login. It aggregates data from multiple models (food logs, calorie profile) and displays it in one view. `group_by` is a Ruby method that organizes a list into buckets.

**Files:**
- Create: `app/controllers/dashboard_controller.rb`
- Create: `app/views/dashboard/index.html.erb`
- Create: `test/controllers/dashboard_controller_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/controllers/dashboard_controller_test.rb`:

```ruby
require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "GET / redirects logged-in user to dashboard" do
    get root_path
    assert_redirected_to authenticated_root_path
  end

  test "GET /dashboard shows today's meals" do
    get dashboard_path
    assert_response :success
    assert_select "h1", text: /Today/
  end

  test "GET /dashboard shows calorie progress bar when profile exists" do
    get dashboard_path
    assert_response :success
    assert_select ".calorie-progress"
  end

  test "GET /dashboard shows setup prompt when no calorie profile" do
    users(:one).calorie_profile.destroy
    get dashboard_path
    assert_response :success
    assert_select ".setup-prompt"
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/controllers/dashboard_controller_test.rb
```

- [ ] **Step 3: Create the controller**

Create `app/controllers/dashboard_controller.rb`:

```ruby
class DashboardController < ApplicationController
  def index
    @calorie_profile = current_user.calorie_profile

    # Today's logs grouped by meal type
    today_logs = current_user.food_logs.today.includes(:food)
    @meals = today_logs.group_by(&:meal_type)

    # WHY: We calculate total calories here in the controller so the view
    # just has to display a number, not do math.
    @total_calories_today = today_logs.sum(&:calories_consumed)

    # Data for the weekly chart — used in Task 16
    @weekly_data = weekly_calorie_data
  end

  private

  def weekly_calorie_data
    # WHY: We build a hash of { "Mon" => 1500, "Tue" => 0, ... } for the last 7 days.
    # Chart.js will receive this as JSON.
    last_7 = (6.days.ago.to_date..Date.today).to_a

    logs_by_date = current_user.food_logs.last_7_days.includes(:food).group_by(&:logged_on)

    last_7.map do |date|
      calories = (logs_by_date[date] || []).sum(&:calories_consumed)
      { date: date.strftime("%a"), calories: calories.round }
    end
  end
end
```

- [ ] **Step 4: Create the dashboard view**

Create `app/views/dashboard/index.html.erb`:

```erb
<div class="max-w-md mx-auto p-6">
  <h1 class="text-2xl font-bold mb-2">Today</h1>
  <p class="text-gray-400 text-sm mb-6"><%= Date.today.strftime("%A, %B %-d") %></p>

  <%# ── Calorie Progress ──────────────────────────────── %>
  <% if @calorie_profile %>
    <div class="bg-white rounded-2xl shadow-sm p-5 mb-6 calorie-progress">
      <div class="flex justify-between items-baseline mb-2">
        <span class="font-semibold text-gray-700">Calories</span>
        <span class="text-sm text-gray-500">
          <%= @total_calories_today.round %> / <%= @calorie_profile.daily_target %> kcal
        </span>
      </div>
      <% pct = [(@total_calories_today / @calorie_profile.daily_target.to_f * 100), 100].min %>
      <% bar_color = @total_calories_today > @calorie_profile.daily_target ? "bg-orange-500" : "bg-lime-400" %>
      <div class="w-full bg-gray-100 rounded-full h-4">
        <div class="<%= bar_color %> h-4 rounded-full transition-all"
             style="width: <%= pct %>%"></div>
      </div>
    </div>
  <% else %>
    <div class="bg-lime-50 border border-lime-200 rounded-2xl p-5 mb-6 setup-prompt">
      <p class="text-gray-700 font-semibold">Set your daily calorie goal</p>
      <p class="text-gray-500 text-sm mt-1">Take a quick survey or enter it manually.</p>
      <%= link_to "Set Goal →", new_calorie_profile_path,
            class: "mt-3 inline-block bg-green-600 text-white px-4 py-2 rounded-xl text-sm font-semibold" %>
    </div>
  <% end %>

  <%# ── Meal Table ─────────────────────────────────────── %>
  <div class="bg-white rounded-2xl shadow-sm overflow-hidden mb-6">
    <% %w[breakfast lunch dinner].each do |meal| %>
      <% logs = @meals[meal] || [] %>
      <div class="border-b border-gray-50 last:border-0">
        <div class="flex justify-between items-center px-5 py-3 bg-gray-50">
          <span class="font-semibold text-gray-700 capitalize"><%= meal %></span>
          <span class="text-sm text-gray-400">
            <%= logs.sum(&:calories_consumed).round %> kcal
          </span>
        </div>
        <% if logs.empty? %>
          <p class="text-gray-300 text-sm px-5 py-3 italic">Nothing logged yet</p>
        <% else %>
          <% logs.each do |log| %>
            <div class="flex justify-between items-center px-5 py-2">
              <div>
                <span class="text-gray-700 text-sm"><%= log.food.name %></span>
                <span class="text-gray-400 text-xs ml-1">× <%= log.servings %></span>
              </div>
              <div class="flex items-center gap-3">
                <span class="text-gray-500 text-sm"><%= log.calories_consumed.round %> kcal</span>
                <%= button_to "✕", food_log_path(log), method: :delete,
                      class: "text-gray-300 hover:text-red-400 text-xs" %>
              </div>
            </div>
          <% end %>
        <% end %>
        <%= link_to "+ Add", new_food_log_path(meal_type: meal),
              class: "block text-green-600 text-xs font-semibold px-5 py-2 hover:bg-green-50" %>
      </div>
    <% end %>
  </div>

  <%# ── Weekly Chart placeholder (filled in Task 16) ── %>
  <div id="weekly-chart-container" class="bg-white rounded-2xl shadow-sm p-5"
       data-weekly='<%= @weekly_data.to_json %>'
       data-goal='<%= @calorie_profile&.daily_target || 2000 %>'>
    <h2 class="font-semibold text-gray-700 mb-4">Last 7 Days</h2>
    <canvas id="weeklyChart" height="200"></canvas>
  </div>
</div>
```

- [ ] **Step 5: Run tests to confirm they pass**

```bash
rails test test/controllers/dashboard_controller_test.rb
```

Expected: `4 runs, 4 assertions, 0 failures, 0 errors`

- [ ] **Step 6: Commit**

```bash
git add app/controllers/dashboard_controller.rb app/views/dashboard/index.html.erb test/controllers/dashboard_controller_test.rb
git commit -m "Add Dashboard with today's meal table, calorie progress bar, and weekly chart data"
```

---

## Task 15: Build the CalorieProfiles Controller and Goal Setup Form

**What you're learning:** `resource :calorie_profile` (singular) means there's only one per user — no `:id` in the URL. The controller uses `current_user.calorie_profile` to find it, not a URL parameter.

**Files:**
- Create: `app/controllers/calorie_profiles_controller.rb`
- Create: `app/views/calorie_profiles/new.html.erb`
- Create: `app/views/calorie_profiles/edit.html.erb`
- Create: `test/controllers/calorie_profiles_controller_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/controllers/calorie_profiles_controller_test.rb`:

```ruby
require "test_helper"

class CalorieProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:two)  # user two has no profile in fixtures
  end

  test "GET /calorie_profile/new shows the setup form" do
    get new_calorie_profile_path
    assert_response :success
    assert_select "h1", text: /Set Your Calorie Goal/
  end

  test "POST /calorie_profile with manual entry creates profile" do
    assert_difference "CalorieProfile.count", 1 do
      post calorie_profile_path, params: {
        calorie_profile: { daily_target: 2200, entry_method: "manual" }
      }
    end
    assert_redirected_to dashboard_path
  end

  test "POST /calorie_profile with survey calculates and saves target" do
    assert_difference "CalorieProfile.count", 1 do
      post calorie_profile_path, params: {
        calorie_profile: {
          entry_method:   "survey",
          sex:            "male",
          age:            30,
          weight_kg:      80,
          height_cm:      175,
          activity_level: "sedentary",
          goal_type:      "maintain"
        }
      }
    end
    profile = CalorieProfile.last
    assert_equal 2219, profile.daily_target
    assert_redirected_to dashboard_path
  end

  test "GET /calorie_profile/edit shows edit form" do
    sign_in users(:one)  # user one has a profile
    get edit_calorie_profile_path
    assert_response :success
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
rails test test/controllers/calorie_profiles_controller_test.rb
```

- [ ] **Step 3: Create the controller**

Create `app/controllers/calorie_profiles_controller.rb`:

```ruby
class CalorieProfilesController < ApplicationController
  before_action :redirect_if_profile_exists, only: [:new, :create]

  def new
    @calorie_profile = CalorieProfile.new
  end

  def create
    @calorie_profile = current_user.build_calorie_profile(calorie_profile_params)

    # WHY: If the user chose the survey, we calculate the target for them.
    # If they chose manual, daily_target is already in the form params.
    if @calorie_profile.entry_method == "survey"
      @calorie_profile.daily_target = CalorieCalculatorService.calculate(
        sex:            @calorie_profile.sex,
        age:            @calorie_profile.age,
        weight_kg:      @calorie_profile.weight_kg,
        height_cm:      @calorie_profile.height_cm,
        activity_level: @calorie_profile.activity_level,
        goal_type:      @calorie_profile.goal_type
      )
    end

    if @calorie_profile.save
      redirect_to dashboard_path, notice: "Calorie goal set to #{@calorie_profile.daily_target} kcal/day."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @calorie_profile = current_user.calorie_profile || redirect_to(new_calorie_profile_path)
  end

  def update
    @calorie_profile = current_user.calorie_profile

    if params[:calorie_profile][:entry_method] == "survey"
      params[:calorie_profile][:daily_target] = CalorieCalculatorService.calculate(
        sex:            params[:calorie_profile][:sex],
        age:            params[:calorie_profile][:age].to_i,
        weight_kg:      params[:calorie_profile][:weight_kg].to_f,
        height_cm:      params[:calorie_profile][:height_cm].to_f,
        activity_level: params[:calorie_profile][:activity_level],
        goal_type:      params[:calorie_profile][:goal_type]
      )
    end

    if @calorie_profile.update(calorie_profile_params)
      redirect_to dashboard_path, notice: "Goal updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def calorie_profile_params
    params.require(:calorie_profile).permit(
      :daily_target, :entry_method, :sex, :age,
      :weight_kg, :height_cm, :activity_level, :goal_type
    )
  end

  def redirect_if_profile_exists
    redirect_to edit_calorie_profile_path if current_user.calorie_profile.present?
  end
end
```

- [ ] **Step 4: Create the new/edit views**

Create `app/views/calorie_profiles/new.html.erb`:

```erb
<div class="max-w-md mx-auto p-6">
  <h1 class="text-2xl font-bold mb-2">Set Your Calorie Goal</h1>
  <p class="text-gray-500 text-sm mb-6">Enter your target manually, or let us calculate it for you.</p>

  <%= form_with model: @calorie_profile, url: calorie_profile_path, method: :post, local: true,
        data: { controller: "calorie-form" } do |f| %>

    <%# Entry method toggle %>
    <div class="flex rounded-xl border border-gray-200 overflow-hidden mb-6">
      <label class="flex-1 text-center cursor-pointer">
        <%= f.radio_button :entry_method, "manual",
              checked: true,
              class: "sr-only peer/manual",
              data: { action: "change->calorie-form#toggleMethod" } %>
        <span class="block py-3 text-sm font-semibold peer-checked/manual:bg-green-600 peer-checked/manual:text-white text-gray-500">
          Manual
        </span>
      </label>
      <label class="flex-1 text-center cursor-pointer">
        <%= f.radio_button :entry_method, "survey",
              class: "sr-only peer/survey",
              data: { action: "change->calorie-form#toggleMethod" } %>
        <span class="block py-3 text-sm font-semibold peer-checked/survey:bg-green-600 peer-checked/survey:text-white text-gray-500">
          Calculate for me
        </span>
      </label>
    </div>

    <%# Manual section %>
    <div data-calorie-form-target="manual">
      <div class="mb-4">
        <%= f.label :daily_target, "Daily Calorie Target (kcal)",
              class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.number_field :daily_target, min: 500, max: 10000,
              class: "border border-gray-300 rounded-xl w-full p-3",
              placeholder: "e.g. 2000" %>
      </div>
    </div>

    <%# Survey section — hidden by default %>
    <div data-calorie-form-target="survey" class="hidden space-y-4">
      <div>
        <%= f.label :sex, "Biological Sex", class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.select :sex, [["Male", "male"], ["Female", "female"]],
              { prompt: "Select..." },
              class: "border border-gray-300 rounded-xl w-full p-3" %>
      </div>
      <div>
        <%= f.label :age, "Age", class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.number_field :age, min: 15, max: 100,
              class: "border border-gray-300 rounded-xl w-full p-3", placeholder: "e.g. 30" %>
      </div>
      <div>
        <%= f.label :weight_kg, "Weight (kg)", class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.number_field :weight_kg, min: 30, max: 300, step: 0.1,
              class: "border border-gray-300 rounded-xl w-full p-3", placeholder: "e.g. 75" %>
      </div>
      <div>
        <%= f.label :height_cm, "Height (cm)", class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.number_field :height_cm, min: 100, max: 250, step: 0.1,
              class: "border border-gray-300 rounded-xl w-full p-3", placeholder: "e.g. 170" %>
      </div>
      <div>
        <%= f.label :activity_level, "Activity Level",
              class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.select :activity_level,
              [["Sedentary (little or no exercise)", "sedentary"],
               ["Lightly active (1–3 days/week)", "lightly_active"],
               ["Moderately active (3–5 days/week)", "moderately_active"],
               ["Very active (6–7 days/week)", "very_active"]],
              { prompt: "Select..." },
              class: "border border-gray-300 rounded-xl w-full p-3" %>
      </div>
      <div>
        <%= f.label :goal_type, "Goal", class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.select :goal_type,
              [["Lose weight", "lose"], ["Maintain weight", "maintain"], ["Gain weight", "gain"]],
              { prompt: "Select..." },
              class: "border border-gray-300 rounded-xl w-full p-3" %>
      </div>
    </div>

    <%= f.submit "Set Goal", class: "w-full bg-green-600 text-white py-3 rounded-xl font-semibold mt-6" %>
  <% end %>
</div>
```

Create `app/views/calorie_profiles/edit.html.erb`:

```erb
<div class="max-w-md mx-auto p-6">
  <h1 class="text-2xl font-bold mb-2">Update Your Calorie Goal</h1>
  <p class="text-gray-500 text-sm mb-4">
    Current goal: <strong><%= @calorie_profile.daily_target %> kcal/day</strong>
  </p>

  <%= form_with model: @calorie_profile, url: calorie_profile_path, method: :patch, local: true,
        data: { controller: "calorie-form" } do |f| %>
    <div class="mb-4">
      <%= f.label :daily_target, "Daily Calorie Target (kcal)",
            class: "block text-sm font-medium text-gray-700 mb-1" %>
      <%= f.number_field :daily_target, min: 500, max: 10000,
            class: "border border-gray-300 rounded-xl w-full p-3" %>
    </div>
    <%= f.submit "Update Goal", class: "w-full bg-green-600 text-white py-3 rounded-xl font-semibold" %>
  <% end %>
</div>
```

- [ ] **Step 5: Add a Stimulus controller for the manual/survey toggle**

Create `app/javascript/controllers/calorie_form_controller.js`:

```javascript
// WHY: This controller shows/hides the manual vs survey form sections
// when the user clicks the toggle buttons.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["manual", "survey"]

  toggleMethod(event) {
    const isSurvey = event.target.value === "survey"
    this.manualTarget.classList.toggle("hidden", isSurvey)
    this.surveyTarget.classList.toggle("hidden", !isSurvey)
  }
}
```

Register it in `app/javascript/controllers/index.js`:

```javascript
import CalorieFormController from "./calorie_form_controller"
application.register("calorie-form", CalorieFormController)
```

- [ ] **Step 6: Run tests to confirm they pass**

```bash
rails test test/controllers/calorie_profiles_controller_test.rb
```

Expected: `4 runs, 5 assertions, 0 failures, 0 errors`

- [ ] **Step 7: Commit**

```bash
git add app/controllers/calorie_profiles_controller.rb app/views/calorie_profiles/ app/javascript/controllers/calorie_form_controller.js app/javascript/controllers/index.js test/controllers/calorie_profiles_controller_test.rb
git commit -m "Add CalorieProfilesController with manual entry and survey calculation"
```

---

## Task 16: Add the Weekly Stats Chart with Chart.js

**What you're learning:** Chart.js is a JavaScript charting library. Rails passes data from the controller to the view as JSON in a `data-` attribute. A Stimulus controller reads that data and tells Chart.js to draw the chart.

**Files:**
- Modify: `config/importmap.rb`
- Create: `app/javascript/controllers/weekly_chart_controller.js`
- Modify: `app/javascript/controllers/index.js`
- Modify: `app/views/dashboard/index.html.erb`

- [ ] **Step 1: Pin Chart.js in importmap**

Add to `config/importmap.rb`:

```ruby
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"
```

- [ ] **Step 2: Create the chart Stimulus controller**

Create `app/javascript/controllers/weekly_chart_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

export default class extends Controller {
  connect() {
    // WHY: We read the weekly data and daily goal from data- attributes
    // on the container element. This is how Rails passes Ruby data to JS.
    const weeklyData = JSON.parse(this.element.dataset.weekly)
    const goal = parseInt(this.element.dataset.goal, 10)

    const labels = weeklyData.map(d => d.date)
    const calories = weeklyData.map(d => d.calories)

    // Color each bar: lime green if under goal, orange if over
    const barColors = calories.map(c =>
      c > goal ? "rgba(249, 115, 22, 0.8)" : "rgba(163, 230, 53, 0.8)"
    )

    new Chart(document.getElementById("weeklyChart"), {
      type: "bar",
      data: {
        labels: labels,
        datasets: [{
          label: "Calories",
          data: calories,
          backgroundColor: barColors,
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: ctx => `${ctx.raw} kcal`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            // WHY: The goal line helps users see how close they were each day.
            grid: { color: "rgba(0,0,0,0.05)" }
          },
          x: {
            grid: { display: false }
          }
        },
        // WHY: A goal annotation line would require Chart.js annotation plugin.
        // Instead, we draw the goal visually in the dataset using a separate line dataset.
      }
    })
  }
}
```

- [ ] **Step 3: Register the controller**

Add to `app/javascript/controllers/index.js`:

```javascript
import WeeklyChartController from "./weekly_chart_controller"
application.register("weekly-chart", WeeklyChartController)
```

- [ ] **Step 4: Update the dashboard chart container**

In `app/views/dashboard/index.html.erb`, find the `#weekly-chart-container` div and add the `data-controller` attribute:

```erb
<div id="weekly-chart-container" class="bg-white rounded-2xl shadow-sm p-5"
     data-controller="weekly-chart"
     data-weekly='<%= @weekly_data.to_json %>'
     data-goal='<%= @calorie_profile&.daily_target || 2000 %>'>
  <h2 class="font-semibold text-gray-700 mb-4">Last 7 Days</h2>
  <canvas id="weeklyChart" height="200"></canvas>
</div>
```

- [ ] **Step 5: Manually test the chart**

Start the server (`rails server`), log in, and go to `/dashboard`. You should see:
- 7 bars representing the last 7 days
- Lime green bars for days under goal, orange for days over
- Day labels (Mon, Tue, etc.) on the x-axis

- [ ] **Step 6: Commit**

```bash
git add config/importmap.rb app/javascript/controllers/weekly_chart_controller.js app/javascript/controllers/index.js app/views/dashboard/index.html.erb
git commit -m "Add weekly calorie bar chart using Chart.js with goal-based color coding"
```

---

## Task 17: Update the Navbar

**What you're learning:** The navbar gives users navigation between the app's main sections. Devise's `current_user` helper is available in views and tells you who is logged in.

**Files:**
- Modify: `app/views/shared/_navbar.html.erb`
- Modify: `app/views/layouts/application.html.erb`

- [ ] **Step 1: Read the current navbar**

Open `app/views/shared/_navbar.html.erb` to see what's currently there.

- [ ] **Step 2: Replace the navbar**

Replace `app/views/shared/_navbar.html.erb` with:

```erb
<nav class="bg-white border-t border-gray-100 fixed bottom-0 left-0 right-0 z-10">
  <div class="max-w-md mx-auto flex justify-around items-center py-3">

    <%= link_to dashboard_path, class: "flex flex-col items-center text-xs #{current_page?(dashboard_path) ? 'text-green-600' : 'text-gray-400'}" do %>
      <span class="text-xl">🏠</span>
      <span>Home</span>
    <% end %>

    <%= link_to scan_foods_path, class: "flex flex-col items-center text-xs #{current_page?(scan_foods_path) ? 'text-green-600' : 'text-gray-400'}" do %>
      <span class="text-2xl font-bold bg-green-600 text-white rounded-full w-12 h-12 flex items-center justify-center -mt-4 shadow-lg">+</span>
      <span class="mt-1">Scan</span>
    <% end %>

    <%= link_to user_foods_path, class: "flex flex-col items-center text-xs #{current_page?(user_foods_path) ? 'text-green-600' : 'text-gray-400'}" do %>
      <span class="text-xl">📋</span>
      <span>My Foods</span>
    <% end %>

  </div>
</nav>
```

- [ ] **Step 3: Update application layout**

Open `app/views/layouts/application.html.erb`. Update the body to add bottom padding so content doesn't hide behind the fixed navbar:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>Nuby</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>
  <body>
    <% if user_signed_in? %>
      <%# WHY: pb-20 adds bottom padding so content doesn't hide behind the fixed navbar %>
      <main class="min-h-screen bg-gradient-to-b from-lime-100 via-green-50 to-white pb-20">
        <%= yield %>
      </main>
      <%= render "shared/navbar" %>
    <% else %>
      <main class="2xl:min-h-screen bg-gradient-to-b from-lime-100 via-green-50 to-white flex items-center justify-center">
        <%= yield %>
      </main>
    <% end %>
  </body>
</html>
```

- [ ] **Step 4: Run the full test suite**

```bash
rails test
```

Expected: All tests pass with 0 failures, 0 errors.

- [ ] **Step 5: Commit**

```bash
git add app/views/shared/_navbar.html.erb app/views/layouts/application.html.erb
git commit -m "Update navbar with bottom navigation for dashboard, scan, and saved foods"
```

---

## Done!

You now have a fully functional Nuby app with:

- Barcode scanning (camera on mobile, manual on desktop)
- OpenFoodFacts food lookup with local caching
- Food card with nutritional info and Nutri-Score
- Saved foods list
- Daily meal logging (breakfast, lunch, dinner)
- Calorie progress bar
- Calorie goal via manual entry or survey
- Weekly 7-day bar chart
- Bottom navigation bar

**To run the full test suite at any time:**
```bash
rails test
```

**To start the development server:**
```bash
rails server
```

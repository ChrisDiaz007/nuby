class CreateFoodLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :food_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.decimal :servings
      t.string :meal_type
      t.date :logged_on

      t.timestamps
    end
  end
end

class CreateCalorieProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :calorie_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :daily_target
      t.integer :age
      t.string :sex
      t.decimal :weight_lbs
      t.decimal :height_cm
      t.string :activity_level
      t.string :goal_type
      t.string :entry_method

      t.timestamps
    end
  end
end

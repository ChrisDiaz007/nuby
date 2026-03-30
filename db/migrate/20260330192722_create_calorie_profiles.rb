class CreateCalorieProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :calorie_profiles do |t|
      t.references :user, null: false, foreign_key: true
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

    add_index :calorie_profiles, :user_id, unique: true
  end
end

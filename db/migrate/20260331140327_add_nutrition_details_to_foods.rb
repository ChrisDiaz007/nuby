class AddNutritionDetailsToFoods < ActiveRecord::Migration[7.1]
  def change
    add_column :foods, :image_url, :string
    add_column :foods, :additives_count, :integer
    add_column :foods, :sugars_100g, :decimal
    add_column :foods, :saturated_fat_100g, :decimal
    add_column :foods, :salt_100g, :decimal
    add_column :foods, :fiber_100g, :decimal
    add_column :foods, :fruits_veg_100g, :decimal
    add_column :foods, :nutriscore_score, :integer
  end
end

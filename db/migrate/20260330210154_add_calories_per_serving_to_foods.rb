class AddCaloriesPerServingToFoods < ActiveRecord::Migration[7.1]
  def change
    add_column :foods, :calories_per_serving, :decimal
  end
end

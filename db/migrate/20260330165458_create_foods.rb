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

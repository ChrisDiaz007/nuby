class AddAdditivesTagsToFoods < ActiveRecord::Migration[7.1]
  def change
    add_column :foods, :additives_tags, :text
  end
end

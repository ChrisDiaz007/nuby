class FoodLog < ApplicationRecord
  belongs_to :user
  belongs_to :food

  validates :servings, presence: true, numericality: { greater_than: 0 }
  validates :meal_type, presence: true, inclusion: { in: %w[breakfast lunch dinner] }
  validates :logged_on, presence: true
end

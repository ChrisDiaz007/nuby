class Food < ApplicationRecord
  has_many :user_foods, dependent: :destroy
  has_many :users, through: :user_foods
  has_many :food_logs, dependent: :destroy

  serialize :additives_tags, coder: JSON

  validates :barcode, presence: true, uniqueness: true
  validates :name, presence: true
end

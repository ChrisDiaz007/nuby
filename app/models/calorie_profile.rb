class CalorieProfile < ApplicationRecord
  belongs_to :user

  validates :daily_target, presence: true, numericality: { greater_than: 0 }
  validates :entry_method, presence: true, inclusion: { in: %w[manual survey] }
end

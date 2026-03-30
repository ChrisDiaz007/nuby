class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :calorie_profile, dependent: :destroy
  has_many :user_foods, dependent: :destroy
  has_many :foods, through: :user_foods
  has_many :food_logs, dependent: :destroy
end

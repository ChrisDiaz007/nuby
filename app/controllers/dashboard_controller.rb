class DashboardController < ApplicationController

  def show
    @today_logs = current_user.food_logs.includes(:food).where(logged_on: Date.today).order(:meal_type)

    @meals = @today_logs.group_by(&:meal_type)
    @total_calories = @today_logs.sum { |log| (log.food.calories_per_100g || 0) * log.servings / 100 }
  end
end

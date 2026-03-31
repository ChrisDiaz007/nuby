class DashboardController < ApplicationController
  def show
    @selected_date = params[:date] ? Date.parse(params[:date]) : Date.today

    @today_logs = current_user.food_logs
                              .includes(:food)
                              .where(logged_on: @selected_date)
                              .order(:meal_type)

    @meals = @today_logs.group_by(&:meal_type)
    @total_calories = @today_logs.sum { |log| (log.food.calories_per_serving || 0) * log.servings }

    @calorie_profile = current_user.calorie_profile
    @daily_target = @calorie_profile&.daily_target || 2000

    @weekly_data = (6.downto(0)).map do |days_ago|
      date = Date.today - days_ago
      logs = current_user.food_logs.includes(:food).where(logged_on: date)
      total = logs.sum { |log| (log.food.calories_per_serving || 0) * log.servings }
      { date: date.strftime("%a"), full_date: date.to_s, calories: total.round }
    end
  end
end

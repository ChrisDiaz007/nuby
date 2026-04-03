class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :about]

  def about
  end

  def home
    if user_signed_in?
      @selected_date = params[:date] ? Date.parse(params[:date]) : Date.today

      @today_logs = current_user.food_logs
                                .includes(:food)
                                .where(logged_on: @selected_date)
                                .order(:meal_type)

      @meals = @today_logs.group_by(&:meal_type)
      @total_calories = @today_logs.sum { |log| (log.food.calories_per_serving || 0) * log.servings }

      @calorie_profile = current_user.calorie_profile
      @daily_target = @calorie_profile&.daily_target || 2000

      # Current week Sun-Sat
      @week_dates = (0..6).map { |i| Date.today.beginning_of_week(:sunday) + i }
    end
  end
end

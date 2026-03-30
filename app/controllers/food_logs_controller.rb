class FoodLogsController < ApplicationController

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @meal_type = params[:meal_type]
    @logs = current_user.food_logs
                        .includes(:food)
                        .where(logged_on: @date, meal_type: @meal_type)
  end

  def new
    @meal_type = params[:meal_type]
    @date = params[:date] || Date.today.to_s
    @user_foods = current_user.user_foods.includes(:food)
  end
  def create
    @food_log = current_user.food_logs.new(food_log_params)
    @food_log.logged_on = params[:food_log][:logged_on].present? ? Date.parse(params[:food_log][:logged_on]) : Date.today

    if @food_log.save
      redirect_to root_path(date: @food_log.logged_on), notice: "Meal logged."
    else
      redirect_to user_foods_path, alert: "Could not log meal: #{@food_log.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    food_log = current_user.food_logs.find(params[:id])
    food_log.destroy
    redirect_to root_path, notice: "Meal Removed."
  end

  private

  def food_log_params
    params.require(:food_log).permit(:food_id, :servings, :meal_type, :logged_on)
  end
end

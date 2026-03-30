class FoodLogsController < ApplicationController

  def create
    @food_log = current_user.food_logs.new(food_log_params)
    @food_log.logged_on = Date.today

    if @food_log.save
      redirect_to dashboard_path, notice: "Meal Logged."
    else
      redirect_to user_foods_path, alert: "Could not log meal: #{@food_log.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    food_log = current_user.food_logs.find(params[:id])
    food_log.destroy
    redirect_to dashboard_path, notice: "Meal Removed."
  end

  private

  def food_log_params
    params.require(:food_log).permit(:food_id, :servings, :meal_type)
  end
end

class UserFoodsController < ApplicationController
  def create
    food = Food.find(params[:user_food][:food_id])
    current_user.user_foods.find_or_create_by(food: food)
    redirect_to scan_foods_path, notice: "#{food.name} added to your list."
  end

  def destroy
    user_food = current_user.user_foods.find(params[:id])
    user_food.destroy
    redirect_to user_foods_path, notice: "Removed from your list."
  end
end

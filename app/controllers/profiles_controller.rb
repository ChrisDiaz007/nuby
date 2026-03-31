class ProfilesController < ApplicationController
  def show
    @calorie_profile = current_user.calorie_profile
  end

  def edit
    @calorie_profile = current_user.calorie_profile || CalorieProfile.new
  end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end

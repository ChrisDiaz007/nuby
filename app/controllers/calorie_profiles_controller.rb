class CalorieProfilesController < ApplicationController
  def new
    @calorie_profile = current_user.calorie_profile || CalorieProfile.new
  end

  def create
    @calorie_profile = current_user.build_calorie_profile(calorie_profile_params)

    if params[:entry_method] == "survey"
      @calorie_profile.daily_target = CalorieCalculatorService.calculate(
        age: @calorie_profile.age,
        sex: @calorie_profile.sex,
        weight_lbs: @calorie_profile.weight_lbs,
        height_cm: @calorie_profile.height_cm,
        activity_level: @calorie_profile.activity_level,
        goal_type: @calorie_profile.goal_type
      )
    end

    if @calorie_profile.save
      redirect_to dashboard_path, notice: "Calorie goal saved!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @calorie_profile = current_user.calorie_profile || redirect_to(new_calorie_profile_path)
  end

  def update
    @calorie_profile = current_user.calorie_profile

    if params[:entry_method] == "survey"
      @calorie_profile.assign_attributes(calorie_profile_params)
      @calorie_profile.daily_target = CalorieCalculatorService.calculate(
        age: @calorie_profile.age,
        sex: @calorie_profile.sex,
        weight_lbs: @calorie_profile.weight_lbs,
        height_cm: @calorie_profile.height_cm,
        activity_level: @calorie_profile.activity_level,
        goal_type: @calorie_profile.goal_type
      )
    end

    if @calorie_profile.update(calorie_profile_params)
      redirect_to dashboard_path, notice: "Calorie goal updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def calorie_profile_params
    params.require(:calorie_profile).permit(:daily_target, :entry_method, :age, :sex, :weight_lbs, :height_cm, :activity_level,
    :goal_type)
  end
end

  class CalorieCalculatorService
    ACTIVITY_MULTIPLIERS = {
      "sedentary"          => 1.2,
      "lightly_active"     => 1.375,
      "moderately_active"  => 1.55,
      "very_active"        => 1.725
    }

    GOAL_ADJUSTMENTS = {
      "lose"     => -500,
      "maintain" => 0,
      "gain"     => +500
    }

    def self.calculate(age:, sex:, weight_lbs:, height_cm:, activity_level:, goal_type:)
      weight_kg = weight_lbs * 0.453592

      bmr = if sex == "male"
        (10 * weight_kg) + (6.25 * height_cm) - (5 * age) + 5
      else
        (10 * weight_kg) + (6.25 * height_cm) - (5 * age) - 161
      end

      multiplier = ACTIVITY_MULTIPLIERS[activity_level] || 1.2
      adjustment = GOAL_ADJUSTMENTS[goal_type] || 0

      (bmr * multiplier + adjustment).round
    end
  end

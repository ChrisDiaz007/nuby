module ApplicationHelper
  def nutri_score_color(score)
    case score&.downcase
    when "a" then "bg-green-500 text-white"
    when "b" then "bg-lime-400 text-white"
    when "c" then "bg-yellow-400 text-black"
    when "d" then "bg-orange-400 text-white"
    when "e" then "bg-red-500 text-white"
    else "bg-gray-300 text-gray-600"
    end
  end
end

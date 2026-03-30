class FoodsController < ApplicationController

  def scan
  end

  def lookup
    barcode = params[:barcode].strip

    food = Food.find_by(barcode: barcode)

    if food.nil?
      data = OpenFoodFactsService.find(barcode)

      if data.nil?
        redirect_to scan_foods_path, alert: "We couldn't find that product. Try scanning again or enter the barcode manually"
        return
      end

      food = Food.create!(data)
    end

    redirect_to food_path(food)
  end

  def show
    @food = Food.find(params[:id])
  end
end

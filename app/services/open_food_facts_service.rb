class OpenFoodFactsService
  def self.find(barcode)
    product = Openfoodfacts::Product.get(barcode)
    return nil if product.nil?

    {
      barcode: barcode,
      name: product.product_name,
      brand: product.brands,
      calories_per_100g: product.nutriments&.[]("energy-kcal_100g"),
      calories_per_serving: product.nutriments&.[]("energy-kcal_serving"),
      fat_100g: product.nutriments&.fat_100g,
      carbohydrates_100g: product.nutriments&.carbohydrates_100g,
      protein_100g: product.nutriments&.proteins_100g,
      nutri_score: product.nutrition_grades,
      serving_size: product.serving_size
    }
  rescue StandardError
    nil
  end
end

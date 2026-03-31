class OpenFoodFactsService
  def self.find(barcode)
    product = Openfoodfacts::Product.get(barcode)
    return nil if product.nil?

    nutriments = product.nutriments

    {
      barcode: barcode,
      name: product.product_name,
      brand: product.brands,
      image_url: product.image_url,
      calories_per_100g: nutriments&.[]("energy-kcal_100g"),
      calories_per_serving: nutriments&.[]("energy-kcal_serving"),
      fat_100g: nutriments&.fat_100g,
      carbohydrates_100g: nutriments&.carbohydrates_100g,
      protein_100g: nutriments&.proteins_100g,
      sugars_100g: nutriments&.[]("sugars_100g"),
      saturated_fat_100g: nutriments&.[]("saturated-fat_100g"),
      salt_100g: nutriments&.[]("salt_100g"),
      fiber_100g: nutriments&.[]("fiber_100g"),
      fruits_veg_100g: nutriments&.[]("fruits-vegetables-legumes-estimate-from-ingredients_100g"),
      nutri_score: product.nutrition_grades,
      nutriscore_score: product.nutriscore_score,
      additives_count: product.additives_n,
      additives_tags: product.additives_tags,
      serving_size: product.serving_size
    }
  rescue StandardError
    nil
  end
end

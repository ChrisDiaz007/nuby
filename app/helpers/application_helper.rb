module ApplicationHelper
  ADDITIVE_NAMES = {
    "e100" => "Curcumin",
    "e101" => "Riboflavin",
    "e102" => "Tartrazine",
    "e104" => "Quinoline Yellow",
    "e110" => "Sunset Yellow",
    "e120" => "Cochineal",
    "e122" => "Carmoisine",
    "e123" => "Amaranth",
    "e124" => "Ponceau 4R",
    "e129" => "Allura Red",
    "e131" => "Patent Blue",
    "e132" => "Indigo Carmine",
    "e133" => "Brilliant Blue",
    "e150a" => "Caramel",
    "e160a" => "Beta-carotene",
    "e200" => "Sorbic Acid",
    "e202" => "Potassium Sorbate",
    "e210" => "Benzoic Acid",
    "e211" => "Sodium Benzoate",
    "e220" => "Sulphur Dioxide",
    "e250" => "Sodium Nitrite",
    "e251" => "Sodium Nitrate",
    "e260" => "Acetic Acid",
    "e270" => "Lactic Acid",
    "e300" => "Ascorbic Acid",
    "e301" => "Sodium Ascorbate",
    "e306" => "Tocopherols",
    "e307" => "Alpha-tocopherol",
    "e322" => "Lecithins",
    "e330" => "Citric Acid",
    "e331" => "Sodium Citrates",
    "e332" => "Potassium Citrates",
    "e333" => "Calcium Citrates",
    "e334" => "Tartaric Acid",
    "e338" => "Phosphoric Acid",
    "e339" => "Sodium Phosphates",
    "e340" => "Potassium Phosphates",
    "e341" => "Calcium Phosphates",
    "e400" => "Alginic Acid",
    "e401" => "Sodium Alginate",
    "e402" => "Potassium Alginate",
    "e404" => "Calcium Alginate",
    "e406" => "Agar",
    "e407" => "Carrageenan",
    "e410" => "Locust Bean Gum",
    "e412" => "Guar Gum",
    "e414" => "Acacia Gum",
    "e415" => "Xanthan Gum",
    "e420" => "Sorbitol",
    "e421" => "Mannitol",
    "e422" => "Glycerol",
    "e440" => "Pectins",
    "e450" => "Diphosphates",
    "e451" => "Triphosphates",
    "e452" => "Polyphosphates",
    "e460" => "Cellulose",
    "e471" => "Mono and Diglycerides",
    "e472e" => "Mono and Diacetyltartaric Esters",
    "e481" => "Sodium Stearoyl Lactylate",
    "e500" => "Sodium Carbonates",
    "e501" => "Potassium Carbonates",
    "e503" => "Ammonium Carbonates",
    "e504" => "Magnesium Carbonates",
    "e507" => "Hydrochloric Acid",
    "e516" => "Calcium Sulphate",
    "e524" => "Sodium Hydroxide",
    "e551" => "Silicon Dioxide",
    "e552" => "Calcium Silicate",
    "e621" => "Monosodium Glutamate",
    "e627" => "Disodium Guanylate",
    "e631" => "Disodium Inosinate",
    "e635" => "Disodium Ribonucleotides",
    "e901" => "Beeswax",
    "e903" => "Carnauba Wax",
    "e950" => "Acesulfame K",
    "e951" => "Aspartame",
    "e952" => "Cyclamate",
    "e954" => "Saccharin",
    "e955" => "Sucralose",
    "e960" => "Steviol Glycosides",
    "e965" => "Maltitol",
    "e966" => "Lactitol",
    "e967" => "Xylitol"
  }.freeze

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

  def additive_name(code)
    ADDITIVE_NAMES[code.downcase] || code.upcase
  end
end

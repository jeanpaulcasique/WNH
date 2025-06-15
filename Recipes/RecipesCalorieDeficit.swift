import Foundation

struct RecipesDeficit {
    static func getWeeklyRecipes() -> [Recipe] {
        return [
            // DÍA 1
            Recipe(title: "Oatmeal with Berries", mealType: .Breakfast, imageName: "deficit_oatmeal_berries",
                   ingredients: [
                    Ingredient(name: "avena", quantity: "40g"),
                    Ingredient(name: "leche descremada", quantity: "200ml"),
                    Ingredient(name: "fresas", quantity: "50g"),
                    Ingredient(name: "arándanos", quantity: "30g"),
                    Ingredient(name: "semillas de chía", quantity: "5g")
                   ],
                   instructions: "Cook oats in milk over medium heat. Top with sliced strawberries, blueberries, and chia seeds.",
                   calories: 300),

            Recipe(title: "Grilled Chicken Salad", mealType: .Lunch, imageName: "deficit_chicken_salad",
                   ingredients: [
                    Ingredient(name: "pechuga de pollo", quantity: "100g"),
                    Ingredient(name: "lechuga", quantity: "80g"),
                    Ingredient(name: "tomate cherry", quantity: "50g"),
                    Ingredient(name: "pepino", quantity: "50g"),
                    Ingredient(name: "aguacate", quantity: "30g"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml"),
                    Ingredient(name: "jugo de limón", quantity: "10ml")
                   ],
                   instructions: "Slice all veggies and chicken. Toss everything in a bowl and dress with olive oil and lemon juice.",
                   calories: 400),

            Recipe(title: "Baked Salmon with Broccoli", mealType: .Dinner, imageName: "deficit_salmon_broccoli",
                   ingredients: [
                    Ingredient(name: "filete de salmón", quantity: "120g"),
                    Ingredient(name: "brócoli", quantity: "100g"),
                    Ingredient(name: "ajo", quantity: "2 cloves"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml"),
                    Ingredient(name: "limón", quantity: "1/2 unit")
                   ],
                   instructions: "Preheat oven to 180°C. Place salmon and broccoli on baking sheet, drizzle olive oil and crushed garlic, bake for 15–20 minutes. Squeeze lemon on top before serving.",
                   calories: 420),

            // DÍA 2
            Recipe(title: "Greek Yogurt with Nuts & Honey", mealType: .Breakfast, imageName: "deficit_yogurt_nuts",
                   ingredients: [
                    Ingredient(name: "yogur griego (bajo en grasa)", quantity: "150g"),
                    Ingredient(name: "nuez", quantity: "15g"),
                    Ingredient(name: "almendra", quantity: "10g"),
                    Ingredient(name: "miel", quantity: "5g")
                   ],
                   instructions: "Serve yogurt in a bowl. Top with chopped nuts and drizzle with honey.",
                   calories: 320),

            Recipe(title: "Tuna Lettuce Wraps", mealType: .Lunch, imageName: "deficit_tuna_wraps",
                   ingredients: [
                    Ingredient(name: "atún en agua", quantity: "100g"),
                    Ingredient(name: "hojas de lechuga", quantity: "4 large leaves"),
                    Ingredient(name: "yogur griego", quantity: "20g"),
                    Ingredient(name: "apio", quantity: "20g"),
                    Ingredient(name: "mostaza", quantity: "5g"),
                    Ingredient(name: "pimienta negra", quantity: "To taste")
                   ],
                   instructions: "Mix tuna, yogurt, mustard, diced celery and pepper. Fill lettuce leaves with mixture and roll.",
                   calories: 330),

            Recipe(title: "Zucchini Noodles with Turkey", mealType: .Dinner, imageName: "deficit_zoodles_turkey",
                   ingredients: [
                    Ingredient(name: "carne molida de pavo", quantity: "120g"),
                    Ingredient(name: "calabacita", quantity: "150g"),
                    Ingredient(name: "salsa de tomate (sin azúcar)", quantity: "50g"),
                    Ingredient(name: "cebolla", quantity: "40g"),
                    Ingredient(name: "ajo", quantity: "1 clove"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml")
                   ],
                   instructions: "Spiralize zucchini. Cook onion, garlic, and turkey in olive oil. Add tomato sauce and serve over zucchini noodles.",
                   calories: 390),

            // DÍA 3
            Recipe(title: "Boiled Eggs and Whole Wheat Toast", mealType: .Breakfast, imageName: "deficit_eggs_toast",
                   ingredients: [
                    Ingredient(name: "huevo", quantity: "2 units"),
                    Ingredient(name: "pan integral", quantity: "1 slice"),
                    Ingredient(name: "aguacate", quantity: "30g"),
                    Ingredient(name: "sal y pimienta", quantity: "To taste")
                   ],
                   instructions: "Boil eggs to desired doneness. Toast bread and spread avocado on top. Serve eggs on side.",
                   calories: 340),

            Recipe(title: "Quinoa Veggie Bowl", mealType: .Lunch, imageName: "deficit_quinoa_veggies",
                   ingredients: [
                    Ingredient(name: "quinoa (cocida)", quantity: "100g"),
                    Ingredient(name: "pimiento", quantity: "50g"),
                    Ingredient(name: "zanahoria", quantity: "40g"),
                    Ingredient(name: "calabacita", quantity: "40g"),
                    Ingredient(name: "garbanzo", quantity: "60g"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml")
                   ],
                   instructions: "Sauté vegetables in olive oil. Combine with cooked quinoa and chickpeas.",
                   calories: 410),

            Recipe(title: "Eggplant Lasagna", mealType: .Dinner, imageName: "deficit_eggplant_lasagna",
                   ingredients: [
                    Ingredient(name: "berenjena", quantity: "150g"),
                    Ingredient(name: "carne molida de res (magro)", quantity: "100g"),
                    Ingredient(name: "salsa de tomate", quantity: "50g"),
                    Ingredient(name: "queso mozzarella (light)", quantity: "30g"),
                    Ingredient(name: "albahaca", quantity: "To taste")
                   ],
                   instructions: "Slice and bake eggplant. Cook beef with tomato sauce. Layer eggplant, meat, and cheese. Bake at 180°C for 15 minutes.",
                   calories: 400),

            // DÍA 4
            Recipe(title: "Smoothie Bowl", mealType: .Breakfast, imageName: "deficit_smoothie_bowl",
                   ingredients: [
                    Ingredient(name: "frutos rojos congelados", quantity: "100g"),
                    Ingredient(name: "plátano", quantity: "1 unit"),
                    Ingredient(name: "leche de almendra", quantity: "150ml"),
                    Ingredient(name: "proteína en polvo", quantity: "15g"),
                    Ingredient(name: "semillas de chía", quantity: "5g")
                   ],
                   instructions: "Blend berries, banana, milk and protein. Pour in bowl and top with chia seeds.",
                   calories: 330),

            Recipe(title: "Turkey Wrap", mealType: .Lunch, imageName: "deficit_turkey_wrap",
                   ingredients: [
                    Ingredient(name: "tortilla integral", quantity: "1 unit"),
                    Ingredient(name: "pechuga de pavo", quantity: "100g"),
                    Ingredient(name: "espinaca", quantity: "30g"),
                    Ingredient(name: "jitomate", quantity: "30g"),
                    Ingredient(name: "yogur griego", quantity: "20g")
                   ],
                   instructions: "Fill tortilla with turkey, spinach, tomato, and yogurt. Wrap and slice in half.",
                   calories: 360),

            Recipe(title: "Shrimp Stir-Fry", mealType: .Dinner, imageName: "deficit_shrimp_stirfry",
                   ingredients: [
                    Ingredient(name: "camarón", quantity: "120g"),
                    Ingredient(name: "pimiento", quantity: "50g"),
                    Ingredient(name: "brócoli", quantity: "50g"),
                    Ingredient(name: "zanahoria", quantity: "40g"),
                    Ingredient(name: "salsa de soya", quantity: "10ml"),
                    Ingredient(name: "aceite de sésamo", quantity: "5ml")
                   ],
                   instructions: "Stir-fry shrimp and vegetables in sesame oil. Add soy sauce before serving.",
                   calories: 380),

            // DÍA 5
            Recipe(title: "Avocado Toast with Egg", mealType: .Breakfast, imageName: "deficit_avocado_toast",
                   ingredients: [
                    Ingredient(name: "pan integral", quantity: "1 slice"),
                    Ingredient(name: "aguacate", quantity: "40g"),
                    Ingredient(name: "huevo", quantity: "1 unit"),
                    Ingredient(name: "hojuelas de chile", quantity: "To taste")
                   ],
                   instructions: "Toast bread, spread avocado, top with fried or poached egg and sprinkle chili flakes.",
                   calories: 330),

            Recipe(title: "Lentil Soup", mealType: .Lunch, imageName: "deficit_lentil_soup",
                   ingredients: [
                    Ingredient(name: "lentejas", quantity: "100g"),
                    Ingredient(name: "zanahoria", quantity: "50g"),
                    Ingredient(name: "apio", quantity: "40g"),
                    Ingredient(name: "cebolla", quantity: "40g"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml")
                   ],
                   instructions: "Cook all ingredients in water until tender. Blend partially for creamy texture.",
                   calories: 390),

            Recipe(title: "Chicken & Veggie Skewers", mealType: .Dinner, imageName: "deficit_chicken_skewers",
                   ingredients: [
                    Ingredient(name: "pechuga de pollo", quantity: "100g"),
                    Ingredient(name: "calabacita", quantity: "50g"),
                    Ingredient(name: "pimiento", quantity: "50g"),
                    Ingredient(name: "cebolla", quantity: "40g"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml")
                   ],
                   instructions: "Cube and skewer all ingredients. Grill or bake with olive oil until cooked.",
                   calories: 400),

            // DÍA 6
            Recipe(title: "Cottage Cheese & Pineapple", mealType: .Breakfast, imageName: "deficit_cottage_pineapple",
                   ingredients: [
                    Ingredient(name: "queso cottage", quantity: "150g"),
                    Ingredient(name: "piña", quantity: "60g")
                   ],
                   instructions: "Serve cottage cheese in a bowl and top with diced pineapple.",
                   calories: 280),

            Recipe(title: "Chicken Veggie Bowl", mealType: .Lunch, imageName: "deficit_chicken_veggie_bowl",
                   ingredients: [
                    Ingredient(name: "pechuga de pollo a la plancha", quantity: "100g"),
                    Ingredient(name: "arroz integral", quantity: "100g"),
                    Ingredient(name: "brócoli", quantity: "50g"),
                    Ingredient(name: "zanahoria", quantity: "50g"),
                    Ingredient(name: "semillas de sésamo", quantity: "5g")
                   ],
                   instructions: "Assemble all ingredients in a bowl. Sprinkle sesame seeds on top.",
                   calories: 420),

            Recipe(title: "Stuffed Bell Peppers", mealType: .Dinner, imageName: "deficit_stuffed_peppers",
                   ingredients: [
                    Ingredient(name: "pimiento", quantity: "2 units"),
                    Ingredient(name: "carne molida de pollo", quantity: "120g"),
                    Ingredient(name: "arroz integral (cocido)", quantity: "80g"),
                    Ingredient(name: "salsa de tomate", quantity: "60g"),
                    Ingredient(name: "cebolla", quantity: "40g"),
                    Ingredient(name: "ajo", quantity: "2 cloves"),
                    Ingredient(name: "queso (light)", quantity: "30g")
                   ],
                   instructions: "Cut tops off bell peppers and remove seeds. Sauté onion and garlic, then add chicken. Stir in rice and sauce. Stuff peppers, top with cheese and bake.",
                   calories: 390),

            // DÍA 7
            Recipe(title: "Protein Pancakes", mealType: .Breakfast, imageName: "deficit_protein_pancakes",
                   ingredients: [
                    Ingredient(name: "avena", quantity: "40g"),
                    Ingredient(name: "plátano", quantity: "1 small"),
                    Ingredient(name: "huevo", quantity: "1 unit"),
                    Ingredient(name: "claras de huevo", quantity: "2 units"),
                    Ingredient(name: "proteína en polvo", quantity: "15g"),
                    Ingredient(name: "polvo para hornear", quantity: "2g"),
                    Ingredient(name: "canela", quantity: "1g")
                   ],
                   instructions: "Blend all ingredients. Cook pancakes on a non-stick pan until golden.",
                   calories: 350),

            Recipe(title: "Grilled Veggie & Hummus Plate", mealType: .Lunch, imageName: "deficit_veggie_plate",
                   ingredients: [
                    Ingredient(name: "calabacita", quantity: "100g"),
                    Ingredient(name: "berenjena", quantity: "100g"),
                    Ingredient(name: "pimiento", quantity: "80g"),
                    Ingredient(name: "hummus", quantity: "50g"),
                    Ingredient(name: "pan pita integral", quantity: "1/2 unit"),
                    Ingredient(name: "aceite de oliva", quantity: "10ml"),
                    Ingredient(name: "jugo de limón", quantity: "10ml")
                   ],
                   instructions: "Grill veggies. Serve with hummus and half pita. Drizzle with olive oil and lemon juice.",
                   calories: 380),

            Recipe(title: "Beef Stir-Fry with Cauliflower Rice", mealType: .Dinner, imageName: "deficit_beef_stirfry",
                   ingredients: [
                    Ingredient(name: "tirita de res magra", quantity: "120g"),
                    Ingredient(name: "arroz de coliflor", quantity: "150g"),
                    Ingredient(name: "brócoli", quantity: "80g"),
                    Ingredient(name: "zanahoria", quantity: "60g"),
                    Ingredient(name: "ajo", quantity: "2 cloves"),
                    Ingredient(name: "salsa de soya baja en sodio", quantity: "15ml"),
                    Ingredient(name: "aceite de sésamo", quantity: "5ml")
                   ],
                   instructions: "Sauté garlic in oil. Add beef, then vegetables. Stir-fry and finish with soy sauce.",
                   calories: 400)
        ]
    }
}

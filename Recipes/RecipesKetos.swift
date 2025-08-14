import Foundation

// MARK: - Recetas Keto (21 recetas: 7 días x 3 comidas)

struct RecipesKeto {
    static func getWeeklyRecipes() -> [Recipe] {
        return [
        // DÍA 1
            //"RecipeK1"
        Recipe(title: "Keto Breakfast Bowl", mealType: .Breakfast, imageName: "RecipeK1",
               ingredients: [
                Ingredient(name: "huevos revueltos", quantity: "120g"),
                Ingredient(name: "rodajas de aguacate", quantity: "50g"),
                Ingredient(name: "queso cheddar", quantity: "30g"),
                Ingredient(name: "tocino", quantity: "2 slices")
               ],
               instructions: "Whisk eggs and cook in a pan until fluffy. Transfer to a bowl and top with sliced avocado, grated cheddar cheese, and crumbled bacon.",
               calories: 500),
        //"RecipeK2"
        Recipe(title: "Zucchini Noodle Chicken", mealType: .Lunch, imageName: "RecipeK2",
               ingredients: [
                Ingredient(name: "calabacitas en tiras", quantity: "100g"),
                Ingredient(name: "pechuga de pollo a la plancha", quantity: "150g"),
                Ingredient(name: "aceite de oliva", quantity: "15ml"),
                Ingredient(name: "tomate cherry", quantity: "50g"),
                Ingredient(name: "queso parmesano", quantity: "20g")
               ],
               instructions: "Sauté zucchini noodles in olive oil until al dente. Add grilled chicken and halved cherry tomatoes. Cook for 2 more minutes. Serve with freshly grated parmesan on top.",
               calories: 600),
        //"RecipeK3"
        Recipe(title: "Salmon with Creamed Spinach", mealType: .Dinner, imageName: "RecipeK3",
               ingredients: [
                Ingredient(name: "filete de salmón", quantity: "160g"),
                Ingredient(name: "espinacas", quantity: "100g"),
                Ingredient(name: "crema espesa", quantity: "30ml"),
                Ingredient(name: "ajo", quantity: "2 cloves"),
                Ingredient(name: "mantequilla", quantity: "10g")
               ],
               instructions: "Season salmon with salt and pepper. Bake at 180°C for 15 minutes. In a pan, melt butter, sauté minced garlic, add spinach until wilted. Pour in cream and cook until thickened. Serve salmon over creamed spinach.",
               calories: 650),

        // DÍA 2
        //"RecipeK4"
        Recipe(title: "Keto Omelette", mealType: .Breakfast, imageName: "RecipeK4",
               ingredients: [
                Ingredient(name: "huevos", quantity: "3 units"),
                Ingredient(name: "espinacas", quantity: "40g"),
                Ingredient(name: "queso feta", quantity: "25g"),
                Ingredient(name: "pimiento rojo", quantity: "30g"),
                Ingredient(name: "aceite de oliva", quantity: "5ml")
               ],
               instructions: "Beat eggs with salt and pepper. Heat olive oil in a pan. Pour eggs and cook until edges set. Add spinach, diced red pepper, and crumbled feta. Fold omelette and cook until eggs are set but still moist.",
               calories: 450),
        //"RecipeK5"
        Recipe(title: "Cauliflower Rice Bowl", mealType: .Lunch, imageName: "RecipeK5",
               ingredients: [
                Ingredient(name: "arroz de coliflor", quantity: "120g"),
                Ingredient(name: "carne molida de res", quantity: "150g"),
                Ingredient(name: "aceite de aguacate", quantity: "10ml"),
                Ingredient(name: "condimento para tacos", quantity: "5g"),
                Ingredient(name: "aguacate", quantity: "50g"),
                Ingredient(name: "crema agria", quantity: "15g")
               ],
               instructions: "Sauté cauliflower rice in avocado oil until tender. In another pan, cook ground beef with taco seasoning. Serve beef over cauliflower rice, topped with sliced avocado and a dollop of sour cream.",
               calories: 700),
        //"RecipeK6"
        Recipe(title: "Grilled Pork Chops", mealType: .Dinner, imageName: "RecipeK6",
               ingredients: [
                Ingredient(name: "chuletas de cerdo", quantity: "180g"),
                Ingredient(name: "brócoli", quantity: "100g"),
                Ingredient(name: "mantequilla", quantity: "20g"),
                Ingredient(name: "ajo en polvo", quantity: "2g"),
                Ingredient(name: "romero", quantity: "2g")
               ],
               instructions: "Season pork chops with salt, pepper, garlic powder, and rosemary. Grill for about 4-5 minutes per side until internal temperature reaches 145°F. Steam broccoli and toss with melted butter. Serve together.",
               calories: 600),

        // DÍA 3
        //"RecipeK7"
        Recipe(title: "Avocado Baked Eggs", mealType: .Breakfast, imageName: "RecipeK7",
               ingredients: [
                Ingredient(name: "aguacate", quantity: "1 unit"),
                Ingredient(name: "huevos", quantity: "2 units"),
                Ingredient(name: "tocino", quantity: "2 slices"),
                Ingredient(name: "cebollín", quantity: "5g"),
                Ingredient(name: "queso cheddar", quantity: "15g")
               ],
               instructions: "Halve avocado and remove pit. Scoop out some flesh to make room for eggs. Crack an egg into each half, sprinkle with cheese. Bake at 200°C for 15 minutes until whites are set. Top with crumbled bacon and chives.",
               calories: 520),
        //"RecipeK8"
        Recipe(title: "Keto Cobb Salad", mealType: .Lunch, imageName: "RecipeK8",
               ingredients: [
                Ingredient(name: "lechuga romana", quantity: "100g"),
                Ingredient(name: "pechuga de pollo a la plancha", quantity: "120g"),
                Ingredient(name: "tocino", quantity: "30g"),
                Ingredient(name: "huevos duros", quantity: "2 units"),
                Ingredient(name: "aguacate", quantity: "50g"),
                Ingredient(name: "queso azul", quantity: "30g"),
                Ingredient(name: "aceite de oliva", quantity: "15ml"),
                Ingredient(name: "jugo de limón", quantity: "5ml")
               ],
               instructions: "Arrange chopped lettuce on a plate. Top with sliced grilled chicken, crumbled bacon, quartered hard-boiled eggs, diced avocado, and crumbled blue cheese. Drizzle with olive oil and lemon juice.",
               calories: 680),
        //"RecipeK9" - IMAGEN FALTANTE: Necesitas agregar RecipeK9.png al proyecto
        Recipe(title: "Butter Garlic Shrimp", mealType: .Dinner, imageName: "RecipeK9",
               ingredients: [
                Ingredient(name: "camarón", quantity: "200g"),
                Ingredient(name: "mantequilla", quantity: "30g"),
                Ingredient(name: "ajo", quantity: "3 cloves"),
                Ingredient(name: "jugo de limón", quantity: "10ml"),
                Ingredient(name: "perejil", quantity: "5g"),
                Ingredient(name: "calabacita", quantity: "100g")
               ],
               instructions: "Melt butter in a large skillet. Add minced garlic and cook until fragrant. Add shrimp and cook until pink, about 2-3 minutes per side. Stir in lemon juice and chopped parsley. Serve with sautéed zucchini slices.",
               calories: 580),

        // DÍA 4
            //"RecipeK10" - IMAGEN FALTANTE: Necesitas agregar RecipeK10.png al proyecto
        Recipe(title: "Coconut Chia Pudding", mealType: .Breakfast, imageName: "RecipeK10",
               ingredients: [
                Ingredient(name: "semillas de chía", quantity: "30g"),
                Ingredient(name: "leche de coco", quantity: "200ml"),
                Ingredient(name: "extracto de vainilla", quantity: "2ml"),
                Ingredient(name: "frutos rojos", quantity: "30g"),
                Ingredient(name: "coco rallado", quantity: "10g")
               ],
               instructions: "Mix chia seeds, coconut milk, and vanilla extract. Refrigerate overnight. In the morning, top with berries and shredded coconut.",
               calories: 420),

            //"RecipeK11" - IMAGEN FALTANTE: Necesitas agregar RecipeK11.png al proyecto
        Recipe(title: "Keto Cheeseburger Wrap", mealType: .Lunch, imageName: "RecipeK11",
               ingredients: [
                Ingredient(name: "carne molida de res", quantity: "150g"),
                Ingredient(name: "queso cheddar", quantity: "30g"),
                Ingredient(name: "hojas de lechuga", quantity: "100g"),
                Ingredient(name: "jitomate", quantity: "30g"),
                Ingredient(name: "cebolla", quantity: "20g"),
                Ingredient(name: "pepinillo", quantity: "20g"),
                Ingredient(name: "mayonesa", quantity: "15g"),
                Ingredient(name: "mostaza", quantity: "5g")
               ],
               instructions: "Cook ground beef until browned. Season with salt and pepper. Melt cheese on top. Use large lettuce leaves as wraps, fill with meat and cheese. Add sliced tomato, onion, pickle, and condiments.",
               calories: 620),

            //"RecipeK12" - IMAGEN FALTANTE: Necesitas agregar RecipeK12.png al proyecto
        Recipe(title: "Baked Cod with Herb Butter", mealType: .Dinner, imageName: "RecipeK12",
               ingredients: [
                Ingredient(name: "filetes de bacalao", quantity: "180g"),
                Ingredient(name: "mantequilla", quantity: "25g"),
                Ingredient(name: "ajo", quantity: "2 cloves"),
                Ingredient(name: "hierbas mixtas", quantity: "5g"),
                Ingredient(name: "limón", quantity: "1/2 unit"),
                Ingredient(name: "espárragos", quantity: "100g")
               ],
               instructions: "Mix softened butter with minced garlic and herbs. Season cod fillets and top with herb butter. Bake at 190°C for 15 minutes until flaky. Roast asparagus on the side and serve with lemon wedges.",
               calories: 550),

        // DÍA 5
            //"RecipeK13" - IMAGEN FALTANTE: Necesitas agregar RecipeK13.png al proyecto
        Recipe(title: "Greek Yogurt with Berries", mealType: .Breakfast, imageName: "RecipeK13",
               ingredients: [
                Ingredient(name: "yogur griego (entero)", quantity: "150g"),
                Ingredient(name: "frutos rojos", quantity: "50g"),
                Ingredient(name: "almendras", quantity: "15g"),
                Ingredient(name: "canela", quantity: "1g"),
                Ingredient(name: "semillas de chía", quantity: "5g")
               ],
               instructions: "Place yogurt in a bowl. Top with berries, chopped almonds, a sprinkle of cinnamon, and chia seeds. Mix gently before eating.",
               calories: 380),

            //"RecipeK14" - IMAGEN FALTANTE: Necesitas agregar RecipeK14.png al proyecto
        Recipe(title: "Tuna Salad Stuffed Avocado", mealType: .Lunch, imageName: "RecipeK14",
               ingredients: [
                Ingredient(name: "atún en lata", quantity: "120g"),
                Ingredient(name: "aguacate", quantity: "1 unit"),
                Ingredient(name: "mayonesa", quantity: "20g"),
                Ingredient(name: "apio", quantity: "20g"),
                Ingredient(name: "cebolla morada", quantity: "15g"),
                Ingredient(name: "jugo de limón", quantity: "5ml"),
                Ingredient(name: "eneldo", quantity: "2g")
               ],
               instructions: "Mix tuna with mayonnaise, diced celery, minced red onion, lemon juice, and dill. Cut avocado in half, remove pit. Fill avocado halves with tuna salad mixture.",
               calories: 550),

            //"RecipeK15"
        Recipe(title: "Garlic Butter Steak", mealType: .Dinner, imageName: "RecipeK15",
               ingredients: [
                Ingredient(name: "bistec ribeye", quantity: "200g"),
                Ingredient(name: "mantequilla", quantity: "30g"),
                Ingredient(name: "ajo", quantity: "3 cloves"),
                Ingredient(name: "romero", quantity: "3g"),
                Ingredient(name: "tomillo", quantity: "3g"),
                Ingredient(name: "puré de coliflor", quantity: "120g")
               ],
               instructions: "Season steak with salt and pepper. Sear in hot pan to desired doneness. Add butter, crushed garlic, rosemary, and thyme to pan. Baste steak with herb butter. Let rest before slicing. Serve with cauliflower mash.",
               calories: 700),

        // DÍA 6
            //"RecipeK16"
        Recipe(title: "Ham and Cheese Egg Cups", mealType: .Breakfast, imageName: "RecipeK16",
               ingredients: [
                Ingredient(name: "huevos", quantity: "4 units"),
                Ingredient(name: "rebanadas de jamón", quantity: "60g"),
                Ingredient(name: "queso cheddar", quantity: "40g"),
                Ingredient(name: "espinacas", quantity: "30g"),
                Ingredient(name: "crema espesa", quantity: "30ml"),
                Ingredient(name: "pimiento morrón", quantity: "20g")
               ],
               instructions: "Line muffin tin cups with ham slices. Mix eggs with cream, salt, and pepper. Add chopped spinach and diced bell pepper. Pour mixture into ham cups, top with cheese. Bake at 180°C for 15 minutes until set.",
               calories: 480),

            //"RecipeK17"
        Recipe(title: "Chicken Caesar Salad", mealType: .Lunch, imageName: "RecipeK17",
               ingredients: [
                Ingredient(name: "lechuga romana", quantity: "100g"),
                Ingredient(name: "pechuga de pollo a la plancha", quantity: "150g"),
                Ingredient(name: "queso parmesano", quantity: "30g"),
                Ingredient(name: "tocino", quantity: "20g"),
                Ingredient(name: "aderezo césar", quantity: "30ml"),
                Ingredient(name: "aguacate", quantity: "50g")
               ],
               instructions: "Tear lettuce into bite-sized pieces. Top with sliced grilled chicken, crumbled bacon, shaved parmesan, and diced avocado. Drizzle with keto-friendly Caesar dressing.",
               calories: 650),

            //"RecipeK18"
        Recipe(title: "Beef and Broccoli Stir-Fry", mealType: .Dinner, imageName: "RecipeK18",
               ingredients: [
                Ingredient(name: "tiras de res", quantity: "180g"),
                Ingredient(name: "ramilletes de brócoli", quantity: "120g"),
                Ingredient(name: "pimiento morrón", quantity: "50g"),
                Ingredient(name: "aceite de coco", quantity: "15ml"),
                Ingredient(name: "salsa de soya", quantity: "15ml"),
                Ingredient(name: "jengibre", quantity: "5g"),
                Ingredient(name: "ajo", quantity: "2 cloves")
               ],
               instructions: "Heat coconut oil in a wok. Add minced ginger and garlic, stir for 30 seconds. Add beef strips and cook until browned. Add broccoli and bell pepper, stir-fry until tender-crisp. Season with soy sauce and serve.",
               calories: 580),

        // DÍA 7
            //"RecipeK19"
        Recipe(title: "Keto Pancakes", mealType: .Breakfast, imageName: "RecipeK19",
               ingredients: [
                Ingredient(name: "harina de almendra", quantity: "60g"),
                Ingredient(name: "queso crema", quantity: "60g"),
                Ingredient(name: "huevos", quantity: "3 units"),
                Ingredient(name: "extracto de vainilla", quantity: "2ml"),
                Ingredient(name: "mantequilla", quantity: "15g"),
                Ingredient(name: "frutos rojos", quantity: "30g")
               ],
               instructions: "Blend almond flour, cream cheese, eggs, and vanilla until smooth. Heat butter in a pan. Pour small portions of batter to make pancakes. Cook until bubbles form, then flip. Serve with a few berries on top.",
               calories: 520),

            //"RecipeK20"
        Recipe(title: "Keto Italian Sub Roll-Ups", mealType: .Lunch, imageName: "RecipeK20",
               ingredients: [
                Ingredient(name: "embutidos italianos", quantity: "100g"),
                Ingredient(name: "queso provolone", quantity: "40g"),
                Ingredient(name: "lechuga", quantity: "30g"),
                Ingredient(name: "jitomate", quantity: "30g"),
                Ingredient(name: "cebolla morada", quantity: "20g"),
                Ingredient(name: "aderezo italiano", quantity: "15ml"),
                Ingredient(name: "aceitunas negras", quantity: "20g")
               ],
               instructions: "Layer deli meats on a plate. Top with slices of provolone. Add lettuce, sliced tomato, red onion rings, and olives. Drizzle with Italian dressing. Roll up tightly and slice into pinwheels.",
               calories: 560),

            //"RecipeK21"
        Recipe(title: "Lemon Butter Chicken Thighs", mealType: .Dinner, imageName: "RecipeK21",
               ingredients: [
                Ingredient(name: "muslos de pollo", quantity: "200g"),
                Ingredient(name: "mantequilla", quantity: "30g"),
                Ingredient(name: "limón", quantity: "1 unit"),
                Ingredient(name: "ajo", quantity: "3 cloves"),
                Ingredient(name: "tomillo", quantity: "3g"),
                Ingredient(name: "ejotes", quantity: "100g")
               ],
               instructions: "Season chicken thighs with salt and pepper. Sear skin-side down until crispy. Flip and add butter, crushed garlic, thyme, and lemon slices to pan. Baste chicken with the sauce. Finish in oven at 190°C for 15 minutes. Serve with buttered green beans.",
               calories: 650)
        ]
    }
}

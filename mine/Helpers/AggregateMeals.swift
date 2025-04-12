//
//  AggregateMeals.swift
//  mine
//
//  Created by christopher on 4/9/25.
//

import Foundation

struct NutrientTotals { //struct, better for type safety.
    let totalCalories: Int
    let totalProtein: Int
    let totalCarbs: Int
    let totalFat: Int
}

func aggregateMeals(meals: [MealEstimate]) -> NutrientTotals {
    
    var totalCalories = 0
    var totalProtein = 0
    var totalCarbs = 0
    var totalFat = 0

    for meal in meals {
        totalCalories += meal.calories
        totalProtein += meal.protein
        totalCarbs += meal.carbs
        totalFat += meal.fat
    }
    
    return NutrientTotals(
           totalCalories: totalCalories,
           totalProtein: totalProtein,
           totalCarbs: totalCarbs,
           totalFat: totalFat
       )
}


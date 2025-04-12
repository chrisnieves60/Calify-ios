import Foundation
struct MealEstimate: Codable, Hashable { //codable protocol enables ability to decode json received from openai. 
    let id: Int? //optional, id of meal.
    let user_id: UUID? // optional bc, dont need it for openai
    let protein: Int
    let carbs: Int
    let fat: Int
    let calories: Int
    let description: String
    let accuracyScore: Int
}

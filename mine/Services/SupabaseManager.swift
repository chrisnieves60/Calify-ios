import Supabase
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager() //Singleton instance of SupabaseManager for global access
    
    let client: SupabaseClient
    

    private init() {
        
        let url = URL(string: "https://ypzdjlfgckfyqqhyhgjc.supabase.co")!
        let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }
    
    func getUserId()async throws -> UUID {
        let auth = client.auth //user signed in. grab it
        
        do {
                if let currentSession = try? await auth.session {
                    print("We are anonymously logged in")
                    return currentSession.user.id
                } else {
                    let newSession = try await auth.signInAnonymously()
                    print("For some reason, we arent signed in.... signing in now.")
                    return newSession.user.id
                }
            } catch {
                print("Failed to get session: \(error)")
                throw error //Re-throw error for proper upstream handling.
            }
    }
    func insertMeal(description: String, calories: Int, protein: Int, carbs: Int, fat: Int, accuracyScore: Int) async { //This will insert a new meal into the database.
        do {
            let userId = try await self.getUserId()
            
            let meal = MealEstimate(
                id: nil,
                user_id: userId,
                protein: protein,
                carbs: carbs,
                fat: fat,
                calories: calories,
                description: description,
                accuracyScore: accuracyScore
            )
            
            try await client.from("Meals").insert(meal).execute()
            print("insertion successful")
        } catch {
            print("Error inserting meals into database: ", error)
        }
            
    }
        
    
    
    func fetchTodaysMeals() async throws -> [MealEstimate] {
        do {
                let userId = try await self.getUserId()
                
                // Use the userId to fetch meals
                let today = Calendar.current.startOfDay(for: Date())
                
            let meals: [MealEstimate] = try await client
                    .from("Meals")
                    .select()
                    .eq("user_id", value: userId)
                    .gte("created_at", value: today.ISO8601Format()) // You'll need to format this properly
                    .execute()
                    .value //generic property returning decoded type that was declared (here, its meal estimate.)
            return meals
            
            } catch {
                print("Error fetching today's meals: \(error)")
                throw error
            }

    }
    
    func deleteMeal(id: Int) async { //This will delete a meal from the database.
        do {
            
            try await client.from("Meals").delete().eq("id", value: id).execute()
                
            print("deletion successful")
        } catch {
            print("Error deleting meal from database: ", error)
        }
            
    }
    
    
    
    
    
}

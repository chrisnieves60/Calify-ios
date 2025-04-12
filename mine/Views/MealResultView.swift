import SwiftUI

struct MealResultView: View {
    let result: MealEstimate
    
    var body: some View {
        VStack(spacing: 24) {
            Text("\(result.calories) Calories")
                .font(.system(size: 36, weight: .bold))
            
            HStack(spacing: 8) {
                Text("Protein: \(result.protein)g")
                Text("Carbs: \(result.carbs)g")
                Text("Fat: \(result.fat)g")
            }
            .font(.title3)
            
            // Add accuracy gauge
            HStack(spacing: 16) {
                ScoreGaugeView(
                    score: result.accuracyScore,
                    title: "accuracy",
                    description: "How certain we are about these values"
                )
            }
            .padding(.top, 10)
            
            // Optional tip for improving results
            if result.accuracyScore < 70 {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.blue)
                    Text("Adding more meal details improves accuracy!")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            Button("Save Meal") {
                Task {
                    await SupabaseManager.shared.insertMeal(
                        description: result.description,
                        calories: result.calories,
                        protein: result.protein,
                        carbs: result.carbs,
                        fat: result.fat,
                        accuracyScore: result.accuracyScore
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Meal Breakdown")
    }
}


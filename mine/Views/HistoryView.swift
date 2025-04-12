import SwiftUI

struct HistoryView: View {
    @State private var todaysMeals: [MealEstimate] = []
    @State private var todaysTotal: NutrientTotals? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading your meals...")
                } else if let error = errorMessage {
                    ContentUnavailableView("Couldn't Load Meals", systemImage: "exclamationmark.triangle", description: Text(error))
                        .padding()
                } else if todaysMeals.isEmpty {
                    ContentUnavailableView("No Meals Today", systemImage: "fork.knife", description: Text("Meals you add will appear here"))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Daily Summary Card
                            if let summary = todaysTotal {
                                DailySummaryCard(summary: summary)
                            }
                            
                            // List of individual meals
                            VStack(spacing: 8) {
                                Text("Today's Meals")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                ForEach(todaysMeals, id: \.description) { meal in
                                    MealCard(meal: meal, onDelete: {
                                        refreshData()
                                    })
                                }
                            }
                            .padding(.bottom)
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Today's Nutrition")
            .toolbar {
                Button {
                    refreshData()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }
    
    func refreshData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let meals = try await SupabaseManager.shared.fetchTodaysMeals()
                await MainActor.run {
                    todaysMeals = meals
                    todaysTotal = aggregateMeals(meals: meals)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error loading meals: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct DailySummaryCard: View {
    var summary: NutrientTotals
    
    var body: some View {
        VStack(spacing: 16) {
            // Calories
            VStack(spacing: 4) {
                Text("\(summary.totalCalories)")
                    .font(.system(size: 36, weight: .bold))
                Text("CALORIES")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Divider
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5))
                .padding(.horizontal)
            
            // Macros
            HStack(spacing: 24) {
                MacroItem(value: summary.totalProtein, label: "Protein", color: .blue)
                MacroItem(value: summary.totalCarbs, label: "Carbs", color: .green)
                MacroItem(value: summary.totalFat, label: "Fat", color: .orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct MacroItem: View {
    var value: Int
    var label: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)g")
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
    }
}

struct MealCard: View {
    var meal: MealEstimate
    var onDelete: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Meal description
            Text(meal.description)
                .font(.headline)
                .lineLimit(1)
            
            // Nutrition info
            HStack {
                NutritionPill(value: meal.calories, unit: "cal", color: .red)
                NutritionPill(value: meal.protein, unit: "p", color: .blue)
                NutritionPill(value: meal.carbs, unit: "c", color: .green)
                NutritionPill(value: meal.fat, unit: "f", color: .orange)
//                NutritionPill(value: meal.accuracyScore, unit: "f", color: .orange)
                ScoreGaugeView(
                    score: meal.accuracyScore,
                    title: "accuracy",
                    description: "How certain we are about these values"
                )
                Spacer()
                
                // Trash Icon Button
                Button(action: {
                    
                    Task {
                        if let mealId = meal.id {
                            // Proceed with deletion
                                await SupabaseManager.shared.deleteMeal(id: mealId)
                                onDelete()

                        } else {
                            // Handle the case where meal.id is nil
                            print("Error: Meal ID is nil and cannot be deleted.")
                            // Optionally, you could show an alert to the user or log this error in analytics
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red) // Red color for trash icon
                        .font(.title2)
                        .padding(8)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
    }
}


struct NutritionPill: View {
    var value: Int
    var unit: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(unit)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
        .foregroundColor(color)
    }
}

#Preview {
    HistoryView()
}

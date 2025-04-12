//
//  HomeView.swift
//  Calify
//
//  Created by christopher on 3/29/25.
//

import SwiftUI
import AVFoundation
struct HomeView: View {
    @State private var userMeal: String = ""
    @State private var isLoading = false
    @State private var toggleRecord = false
    @State private var result: MealEstimate? = nil
    @State private var showResult = false
    
    // Speech recognizer
    private let speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("What did you eat?")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Recording button in the middle
                Button {
                    if toggleRecord {
                        toggleRecord = false
                    }
                    else {
                        toggleRecord = true
                    }
                    handleRecordingToggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(toggleRecord ? Color.red.opacity(0.8) : Color.blue) 
                            .frame(width: 120, height: 120)
                            .shadow(radius: 5)
                        
                        if toggleRecord {
                            // Pulsating animation when recording
                            Circle()
                                .stroke(Color.red, lineWidth: 3)
                                .frame(width: 140, height: 140)
                                .scaleEffect(toggleRecord ? 1.2 : 1.0)
                                .opacity(toggleRecord ? 0.0 : 1.0)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: toggleRecord)
                            
                            Text("Stop")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Text showing what was recorded or hints
                Text(userMeal.isEmpty ? "Tap the mic button to start logging your meal..." : "\"" + userMeal + "\"")
                    .foregroundColor(userMeal.isEmpty ? .gray : .primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Text input option below
                HStack {
                    TextField("Or type your meal here...", text: $userMeal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button {
                        submitMeal()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                    .disabled(userMeal.isEmpty)
                }
                
                if isLoading {
                    LoadingView()
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showResult) {
                if let result = result {
                    MealResultView(result: result)
                } else {
                    MealResultView(result: MealEstimate(id: nil, user_id: nil, protein: 0, carbs: 0, fat: 0, calories: 0, description: "", accuracyScore: 0))
                }
            }
        }
    }
    
    //toggle record is initially set to false.
    
    //onclick of handleRecordingToggle, it gets set to... TRUE!
    private func handleRecordingToggle() {
        // Start recording
        if toggleRecord {
            userMeal = ""
            speechRecognizer.startRecognition { recognizedText in
                DispatchQueue.main.async {
                    self.userMeal = recognizedText
                }
            }
        }
        
        if toggleRecord == false {
            // Stop recording
            speechRecognizer.stopRecognition()
            if !userMeal.isEmpty {
                submitMeal()
            }
        }
    }
    
    
    //this function is essentially, taking the response from chatgpt(raw json string), parsing it, and storing cals/macros in result which is of type MealEstimate struct
    private func submitMeal() {
        guard !userMeal.isEmpty else { return }
        
        isLoading = true
        Task {
            let jsonString = await OpenAIManager.shared.rawResponse(meal: userMeal)
            
            if let data = jsonString.data(using: .utf8) {
                do {
                    let decoded = try JSONDecoder().decode(MealEstimate.self, from: data)
                    result = decoded
                    showResult = true
                    print(decoded) //print the json received from chatgpt
                } catch {
                    print("Decoding failed: \(error)")
                }
            }
            userMeal = ""
            isLoading = false
        }
    }
}


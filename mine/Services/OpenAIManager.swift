import Foundation
import SwiftOpenAI

class OpenAIManager {
    static let shared = OpenAIManager()
    private let service: OpenAIService

    private init() {
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        self.service = OpenAIServiceFactory.service(apiKey: apiKey)
    }

    //so no matter what, we want this function to return, the json containing cals and macros.
    func rawResponse(meal: String) async -> String {
        //so if this is our raw prompt, it needs to send this response to the second chatgpt call.
        let rawPrompt = """
 You are a calorie tracking expert. Estimate total calories and macros (protein, carbs, fat in grams) for any food input. Be accurate and include specific numbers. Assume standard portion sizes if needed. Never skip any items mentioned. Output should be clear, factual, and not overly polite or vague.
 
 If a user uses vague measurements like 'a cup,' 'a serving,' or 'an ounce,' standardize them to precise values like '1 cup,' '1 serving,' or '1 ounce.' Scale appropriately if the context implies more or less.
 """
        
        //make call to chatgpt. text is rawprompt + meal. specify model.
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text(meal + " " + rawPrompt))],
            model: .gpt4o,
            temperature: 0.0
        )
        //print(parameters) //TODO: Im just curious wtf this looks like, how it structures messages and model, and what chatcompletparameters is even for.
        do {
            let response = try await service.startChat(parameters: parameters)  //response will be what chatgpt sends back, we wanna give this to the chained model.
            
            // 👉 INSERTED MID-CHAIN PROMPT
                    let accuracyPrompt = """
            Based on this meal: "\(meal)"

            Evaluate the level of detail provided by the user input:

            Assign a confidence score (accuracyScore) from 0-100 based on how precise the estimate likely is, considering food type, cooking method, portion clarity, etc.

            Return only this in JSON Format, with NO BACKTICKS:
            - accuracyScore: (int)
            """
//TODO: Do something with accuracy explanation in Phase 2. - explanation: (string)
                    let accuracyParameters = ChatCompletionParameters(
                        messages: [.init(role: .user, content: .text(accuracyPrompt))],
                        model: .gpt4o,
                        temperature: 0.0
                    )

                    let accuracyResponse = try await service.startChat(parameters: accuracyParameters)
                    guard let accuracyMessage = accuracyResponse.choices.first?.message.content else {
                        return "Error: Empty response from GPT-CHAIN 2 (accuracy)"
                    }

            guard let firstMessage = response.choices.first?.message.content else { return "Error: Empty response from GPT-CHAIN 1"  }
            
            let structurePrompt = 
"""
            Convert this text into JSON with keys: calories(int), protein(int), carbs(int), fat(int), accuracyScore(int), and description(string).
            Only return JSON. Do not include backticks. Use average values of calorie/macro estimates.
"""
            let structureParameters = ChatCompletionParameters(
                messages: [.init(role: .user, content: .text((structurePrompt + String(firstMessage) + String(accuracyMessage))))],
                model: .gpt4o,
                temperature: 0.0
            )
            
            let structureResponse = try await service.startChat(parameters: structureParameters)
            
            
            
            
            if let finalMessage = structureResponse.choices.first?.message.content {
                return finalMessage
            }
        } catch {
            print("OpenAI error:", error)
            return "1 Error: \(error.localizedDescription)"
            
        }
        return "2 error unknown"
    }

}

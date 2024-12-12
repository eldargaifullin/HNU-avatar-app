import Foundation

final class ChatManager: ObservableObject {
    @Published var responseText: String = ""
    
    // Singleton instance
    static let shared = ChatManager()
    
    // Use the key from OpenAIAPIKey enum
    private let apiKey = OpenAIAPIKey.key
    private let customModelID = "ft:gpt-4o-2024-08-06:hnu:politics-religion-filter:AJQK71Bv" // Replace with your desired model
    
    private init() {} // Private initializer to ensure the singleton pattern
    
    func sendText(_ text: String) async -> String {
        guard !text.isEmpty else { return "Hey, the text box is lonely! Fill it up." }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")! // Correct endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Update the body for the chat/completions endpoint
        let body: [String: Any] = [
            "model": customModelID,
            "messages": [
                ["role": "user", "content": text]
            ],
            "max_tokens": 300
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Perform the API call
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Debug: Log raw response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(rawResponse)")
            }
            
            // Decode the response
            let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            
            // Safely access the first choice text
            if let choices = response.choices, let firstChoice = choices.first?.message.content {
                return firstChoice
            } else {
                return "No response available"
            }
        } catch {
            // Log and handle errors
            print("Error occurred during API call: \(error.localizedDescription)")
            return "Error: \(error.localizedDescription)"
        }
    }
}

// Response structures for decoding
struct ChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]?
}


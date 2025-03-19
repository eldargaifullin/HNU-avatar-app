//
//  ChatOpenAI.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 20.01.25.
//
import Foundation

class ChatOpenAI {
    private let apiKey: String
    private let model: String

    init(apiKey: String) {
        self.apiKey = apiKey
        self.model = "gpt-4o"
    }

    func generateResponse(prompt: String) async -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 500
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let text = choices.first?["message"] as? [String: Any],
               let content = text["content"] as? String {
                return content
            } else {
                return "No response"
            }
        } catch {
            print("Error calling OpenAI API: \(error)")
            return "Error generating response"
        }
    }
}

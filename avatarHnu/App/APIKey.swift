// APIKey.swift
import Foundation

enum OpenAIAPIKey {
    static let key: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OpenAI API Key is missing in Info.plist")
        }
        return apiKey
    }()
}

//
//  EmbeddingFunction.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 20.01.25.
//


class EmbeddingFunction {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func embedText(_ text: String) -> [Double] {
        // Simulate embedding using a placeholder (replace with real API integration)
        return Array(repeating: Double.random(in: 0...1), count: 512) // Example embedding size
    }
}

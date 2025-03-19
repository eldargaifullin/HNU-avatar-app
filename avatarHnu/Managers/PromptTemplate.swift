//
//  class.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 20.01.25.
//


// Define the PromptTemplate class
class PromptTemplate {
    private let template: String

    init(template: String) {
        self.template = template
    }

    func format(with context: [String: String]) -> String {
        var formattedPrompt = template
        for (key, value) in context {
            formattedPrompt = formattedPrompt.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return formattedPrompt
    }
}
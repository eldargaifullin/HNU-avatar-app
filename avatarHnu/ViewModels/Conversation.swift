//
//  Conversation.swift
//
//  Created by Gaifullin, Eldar on 20.11.24.
//
import Foundation

@MainActor
final class Conversation: ObservableObject {
    struct Dialog: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
    }
    enum State { case idle, listening, asking }
    static let initPrompt = "(listening...)"
    static let initAnswer = "(thinking...)"
    @Published var prompt = ""      // input text
    @Published var question = ""
    @Published var answer = ""
    @Published var talkLogs = [Dialog]()
    @Published var state: State = .idle

    func startListening() {
        Synthesizer.shared.stopSpeaking()
        state = .listening
        prompt = Self.initPrompt
        SpeechRecognizer.shared.startRecording(progressHandler: { text in
            self.prompt = text
        })
    }

    func stopListening() {
        state = .idle
        SpeechRecognizer.shared.stopRecording()
    }

    func ask(usingTextInput input: String? = nil) async {
        state = .asking
        SpeechRecognizer.shared.stopRecording()

        // Use text input if provided; otherwise, use the voice input
        if let input = input, !input.isEmpty {
            question = input
        } else if prompt != Self.initPrompt {
            question = prompt
        } else {
            return // Exit if neither text nor voice input is available
        }

        answer = Self.initAnswer
        prompt = Self.initPrompt

        // Make the API call
        answer = await ChatManager.shared.sendText(question)
        talkLogs.append(Dialog(question: question, answer: answer))

        state = .idle
    }

    func speak() {
        guard answer != Self.initAnswer else { return }

        if Synthesizer.shared.isSpeaking {
            Synthesizer.shared.stopSpeaking()
        } else {
            Synthesizer.shared.speak(answer)
        }
    }
}

import Foundation

@MainActor
final class Conversation: ObservableObject {
    struct Dialog: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
    }

    @Published var prompt = ""
    @Published private(set) var question = ""
    @Published private(set) var answer = ""
    @Published private(set) var talkLogs = [Dialog]()
    private let chatManager = ChatManager.shared
    func ask(usingTextInput input: String? = nil) async {
        guard let input = input, !input.isEmpty else { return }
            question = input
            
            let context = chatManager.ragHandler.retrieveContext(for: question)
            let finalPrompt = """
            \(chatManager.systemPrompt)
            Use the following context:
            \(context)
            Question: \(question)
            """
            
            // Вызов реального API ChatGPT
            answer = await chatManager.chatOpenAI.generateResponse(prompt: finalPrompt)
            
            talkLogs.append(Dialog(question: question, answer: answer))
    }

    func startListening() {
        SpeechRecognizer.shared.requestAuthorization()

        SpeechRecognizer.shared.startRecording { recognizedText in
            DispatchQueue.main.async {
                self.prompt = recognizedText
            }
        }
        print("Listening started")
    }


    func stopListening() {
        SpeechRecognizer.shared.stopRecording()
        print("Listening stopped")
    }

}


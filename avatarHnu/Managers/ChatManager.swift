import Foundation

final class ChatManager: ObservableObject {
    @Published var responseText: String = ""

    // Singleton instance
    static let shared = ChatManager()

    // Use the key from OpenAIAPIKey enum
    private let apiKey = OpenAIAPIKey.key
    private let customModelID = "ft:gpt-4o-2024-08-06:hnu:politics-religion-filter:AJQK71Bv" // Replace with your desired model

    // RAG configuration parameters
    private let ragEnabled = true
    private let ragHandler = RAGHandler()  // Instance of RAGHandler
    private let systemPrompt = """
    You are a student advisor bot for Hochschule Neu-Ulm (HNU).
    Always respond only in English, regardless of the content or language of the documents. If documents contain German text, translate or paraphrase them into English.
    """

    private init() {
        if ragEnabled {
            ragHandler.loadAndProcessPDFs()  // Load and process PDFs when RAG is enabled
        }
    } // Private initializer to ensure the singleton pattern

    // Function to retrieve relevant content from the RAGHandler
    private func retrieveRelevantContent(for query: String) async -> String {
        guard ragEnabled else { return "" }

        // Use RAGHandler to retrieve relevant documents
        return await ragHandler.retrieveRelevantContent(for: query)
    }

    func sendText(_ text: String) async -> String {
        guard !text.isEmpty else { return "Hey, the text box is lonely! Fill it up." }

        // Retrieve relevant content from the documents using RAGHandler
        let relevantContent = await retrieveRelevantContent(for: text)

        let url = URL(string: "https://api.openai.com/v1/chat/completions")! // Correct endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Decide context to send to the model
        let context: String
        if relevantContent.isEmpty {
            context = systemPrompt + "\n\nNo relevant documents were found. Please answer based on your knowledge base."
        } else {
            context = systemPrompt + "\n\n" + relevantContent
        }

        // Update the body for the chat/completions endpoint
        let body: [String: Any] = [
            "model": customModelID,
            "messages": [
                ["role": "system", "content": context],
                ["role": "user", "content": text]
            ],
            "max_tokens": 300
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            // Perform the API call
            let (data, _) = try await URLSession.shared.data(for: request)

            // Decode the response
            let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

            // Safely access the first choice text
            if let choices = response.choices, let firstChoice = choices.first?.message.content {
                return firstChoice
            } else {
                return "No response available."
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


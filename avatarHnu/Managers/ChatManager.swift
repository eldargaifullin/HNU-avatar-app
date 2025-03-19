import Foundation
import PDFKit  // Если речь идет о PDF-документе


// ChatManager: Handles the chatbot loop and RAG-based responses
final class ChatManager {
    @Published var responseText: String = ""
    static let shared = ChatManager()
    
    // Конфигурация модели GPT
    let temperature = 0.8
    let max_tokens = 4000
    
    // Размер чанков и перекрытия для разбиения текста
    private let chunkSize: Int = 4000
    private let chunkOverlap: Int = 1600

    private let ragEnabled = true
    
    let systemPrompt: String = """
    You are a student advisor at the HNU (Hochschule Neu-Ulm) and want to help new students with orientation at the university.
    Always respond only in English, regardless of the content or language of the documents.
    If you don't know the answer, or don't have relevant information, say shortly, avoid long explanations in such cases.
    """
    
    var ragHandler: RAGHandler
    var chatOpenAI: ChatOpenAI
    private var lastResponse: String = ""
    

    init() {
        self.ragHandler = RAGHandler(chunkSize: chunkSize, chunkOverlap: chunkOverlap)
        self.chatOpenAI = ChatOpenAI(apiKey: OpenAIAPIKey.key)

        if ragEnabled {
            let pdfDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first!.appendingPathComponent("hnu_documents").path
            ragHandler.loadPdfsFromDirectory(directoryPath: pdfDirectory)
        }
    }

    
    func chatbotLoop() {
        print("Welcome to the HNU Expert Bot! Type 'exit' to quit.")
        
        while true {
            print("Your question: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else { continue }
            
            if userInput.lowercased() == "exit" {
                print("Goodbye!")
                break
            }
            
            if userInput.lowercased() == "repeat" {
                print("HNU bot: \(lastResponse)")
                continue
            }
            
            let contextText = ragHandler.retrieveContext(for: userInput)
            let finalPrompt = """
            \(systemPrompt)
            Use the following context: \(contextText)
            Question: \(userInput)
            """
            
            Task {
                let response = await chatOpenAI.generateResponse(prompt: finalPrompt)
                print("HNU bot: \(response)")
                lastResponse = response
            }
        }
    }
    
    // Функция для загрузки PDF документов
    func loadPdfsFromDirectory(directoryPath: String) -> [String] {
        var textChunks = [String]()
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
            for filename in files {
                if filename.hasSuffix(".pdf") {
                    let filePath = directoryPath + "/" + filename
                    if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath)) {
                        for pageIndex in 0..<pdfDocument.pageCount {
                            if let page = pdfDocument.page(at: pageIndex) {
                                if let text = page.string {
                                    textChunks.append(text)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error reading contents of directory: \(error)")
        }
        
        return textChunks
    }
}


import PDFKit
import NaturalLanguage

class RAGHandler {
    private let chunkSize: Int
    private let chunkOverlap: Int
    private var textSplitter: TextSplitter
    private var vectorStore = VectorStore()
    private let embeddingModel = NLEmbedding.wordEmbedding(for: .english) // Встроенная модель
    
    init(chunkSize: Int, chunkOverlap: Int) {
        self.chunkSize = chunkSize
        self.chunkOverlap = chunkOverlap
        self.textSplitter = TextSplitter(chunkSize: chunkSize, chunkOverlap: chunkOverlap)
    }
    
    // Загрузка PDF и обработка текста
    func loadPdfsFromDirectory(directoryPath: String) {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
            for filename in files where filename.hasSuffix(".pdf") {
                let filePath = directoryPath + "/" + filename
                if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath)) {
                    for pageIndex in 0..<pdfDocument.pageCount {
                        if let page = pdfDocument.page(at: pageIndex), let text = page.string {
                            print("Processing page \(pageIndex + 1) of \(pdfDocument.pageCount)")
                            let chunks = textSplitter.createDocuments(from: [text])
                            
                            for chunk in chunks {
                                if let vector = generateVector(for: chunk) {
                                    vectorStore.addDocument(text: chunk, vector: vector)
                                } else {
                                    print("Ошибка: не удалось сгенерировать вектор для текста")
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Ошибка чтения директории: \(error)")
        }
    }
    // Поиск контекста
    func retrieveContext(for query: String) -> String {
        guard let queryVector = generateVector(for: query) else {
            return "Ошибка векторизации запроса"
        }
        let results = vectorStore.searchSimilar(queryVector: queryVector)
        return results.map { $0.text }.joined(separator: "\n\n")
    }
    // Векторизация текста с `NLEmbedding`
    private func generateVector(for text: String) -> [Float]? {
        guard let embeddingModel = embeddingModel else {
            print("Ошибка: Встроенная модель векторизации не найдена")
            return nil
        }
        
        let words = text.split(separator: " ").map { String($0) }
        var vector = [Double](repeating: 0, count: embeddingModel.dimension) // Используем Double сначала
        var validWordCount = 0
        for word in words {
            if let wordVector = embeddingModel.vector(for: word) {
                for i in 0..<vector.count {
                    vector[i] += wordVector[i]
                }
                validWordCount += 1
            }
        }
        if validWordCount > 0 {
            for i in 0..<vector.count {
                vector[i] /= Double(validWordCount) // Усреднение
            }
            return vector.map { Float($0) } // Конвертируем в [Float]
        } else {
            return nil
        }
    }
    // Обновленный код для добавления документа в векторное хранилище
    func addDocumentToStore(text: String) {
      // Векторизация текста
      if let vector = generateVector(for: text) {
          // Добавляем в хранилище только если вектор был успешно сгенерирован
          vectorStore.addDocument(text: text, vector: vector)
      } else {
          print("Ошибка: не удалось сгенерировать вектор для текста")
      }
    }
}


//  Document.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 10.03.25.
//


import Foundation
import Accelerate

// Структура для хранения документа с вектором
struct Document: Codable {
    let id: String
    let text: String
    let vector: [Float]
}

// Менеджер для хранения векторов
class VectorStore {
    private var documents: [Document] = []
    private let filePath: URL
    
    init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.filePath = directory.appendingPathComponent("vector_store.json")
        ensureFileExists()
        loadFromFile()
    }
    
    // Сохранение в JSON
    private func saveToFile() {
        do {
            let data = try JSONEncoder().encode(documents)
            try data.write(to: filePath, options: .atomic)
            print("Данные успешно сохранены в \(filePath.path)")
        } catch {
            print("Ошибка сохранения JSON: \(error)")
        }
    }
    
    // Загрузка данных из JSON
    private func loadFromFile() {
        do {
            let data = try Data(contentsOf: filePath)
            
            guard !data.isEmpty else {
                print("JSON-файл пуст. Создаём новую базу.")
                return
            }

            documents = try JSONDecoder().decode([Document].self, from: data)
        } catch {
            print("Ошибка загрузки JSON: \(error). Файл будет пересоздан.")
            documents = [] // Обнуляем базу
        }
    }


    
    // Добавление документа
    func addDocument(text: String, vector: [Float]) {
        let document = Document(id: UUID().uuidString, text: text, vector: vector)
        documents.append(document)
        print("Добавлен новый документ: \(document)")
        saveToFile()
    }
    
    // Поиск ближайших документов по вектору
    func searchSimilar(queryVector: [Float], topK: Int = 3) -> [Document] {
        return documents
            .map { ($0, cosineSimilarity($0.vector, queryVector)) }
            .sorted { $0.1 > $1.1 }
            .prefix(topK)
            .map { $0.0 }
    }
    
    // Косинусное сходство
    private func cosineSimilarity(_ v1: [Float], _ v2: [Float]) -> Float {
        guard v1.count == v2.count else { return -1 }
        
        var dotProduct: Float = 0
        var normV1: Float = 0
        var normV2: Float = 0
        
        for i in 0..<v1.count {
            dotProduct += v1[i] * v2[i]
            normV1 += v1[i] * v1[i]
            normV2 += v2[i] * v2[i]
        }
        
        let denominator = (sqrt(normV1) * sqrt(normV2))
        return denominator == 0 ? 0 : dotProduct / denominator
    }
    
    // проверка инициализации файла при старте:
    private func ensureFileExists() {
        if !FileManager.default.fileExists(atPath: filePath.path) {
            print("Файл не найден, создаем пустой JSON-файл.")
            saveToFile()
        }
    }

}

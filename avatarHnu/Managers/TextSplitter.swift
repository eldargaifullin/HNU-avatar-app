//
//  TextSplitter.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 09.03.25.
// Класс для разбиения текста на фрагменты

import Foundation

class TextSplitter {
    let chunkSize: Int
    let chunkOverlap: Int
    
    init(chunkSize: Int, chunkOverlap: Int) {
        self.chunkSize = chunkSize
        self.chunkOverlap = chunkOverlap
    }
    
    func createDocuments(from textChunks: [String]) -> [String] {
        var documents: [String] = []
        
        for text in textChunks {
            let chunkedText = splitText(text)
            documents.append(contentsOf: chunkedText)
        }
        
        return documents
    }
    
    private func splitText(_ text: String) -> [String] {
        var chunks: [String] = []
        var startIndex = text.startIndex

        while startIndex < text.endIndex {
            guard let chunkEnd = text.index(startIndex, offsetBy: chunkSize, limitedBy: text.endIndex) else {
                chunks.append(String(text[startIndex..<text.endIndex]))
                break
            }

            chunks.append(String(text[startIndex..<chunkEnd]))

            guard let nextStart = text.index(startIndex, offsetBy: chunkSize - chunkOverlap, limitedBy: text.endIndex) else {
                break
            }

            startIndex = nextStart
        }

        return chunks
    }
}


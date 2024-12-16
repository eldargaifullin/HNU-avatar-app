//
//  RAGHandler.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 15.12.24.
//
import CryptoKit
import Foundation

final class RAGHandler {
    private let pdfDirectory: String = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("hnu_documents").path
    }()  // Path to the directory with PDF files
    private let chunkSize = 500            // Chunk size when splitting documents
    private let chunkOverlap = 100         // Overlap size for continuity
    private let vectorStore = ChromaDB()   // Placeholder for your vector store
    
    init() {
        createDirectoryIfNeeded()
        copySamplePDFToDirectory() // Optional: Copy a sample PDF for testing
    }

    // Ensure the hnu_documents directory exists
    private func createDirectoryIfNeeded() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: pdfDirectory) {
            do {
                try fileManager.createDirectory(atPath: pdfDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at: \(pdfDirectory)")
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }

    // Copy a sample PDF to the directory for testing purposes
    private func copySamplePDFToDirectory() {
        let fileManager = FileManager.default
        guard let samplePDFPath = Bundle.main.path(forResource: "sample", ofType: "pdf") else {
            print("Sample PDF not found in bundle.")
            return
        }
        let destinationPath = pdfDirectory + "/sample.pdf"
        if !fileManager.fileExists(atPath: destinationPath) {
            do {
                try fileManager.copyItem(atPath: samplePDFPath, toPath: destinationPath)
                print("Sample PDF copied to: \(destinationPath)")
            } catch {
                print("Error copying sample PDF: \(error.localizedDescription)")
            }
        }
    }

    // Function to load and process PDFs
    func loadAndProcessPDFs() {
        do {
            let fileManager = FileManager.default
            let pdfFiles = try fileManager.contentsOfDirectory(atPath: pdfDirectory).filter { $0.hasSuffix(".pdf") }
            
            for pdfFile in pdfFiles {
                let filePath = "\(pdfDirectory)/\(pdfFile)"
                let pdfText = try extractTextFromPDF(at: filePath)
                
                // Split PDF text into chunks
                let chunks = splitTextIntoChunks(pdfText, chunkSize: chunkSize, overlap: chunkOverlap)
                for chunk in chunks {
                    let chunkHash = hashText(chunk)
                    if !vectorStore.contains(hash: chunkHash) {
                        vectorStore.addDocument(chunk, metadata: ["source": pdfFile])
                    }
                }
            }
        } catch {
            print("Error loading PDFs: \(error.localizedDescription)")
        }
    }

    // Function to retrieve relevant content for a user query
    func retrieveRelevantContent(for query: String) async -> String {
        let relevantDocs = vectorStore.similaritySearch(query: query, topK: 3)
        return relevantDocs.isEmpty ? "No relevant information found." : relevantDocs.joined(separator: "\n")
    }

    // Helper function to hash text content
    private func hashText(_ text: String) -> String {
        let hash = Insecure.MD5.hash(data: text.data(using: .utf8) ?? Data())
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }

    // Helper function to split text into chunks
    private func splitTextIntoChunks(_ text: String, chunkSize: Int, overlap: Int) -> [String] {
        var chunks = [String]()
        var startIndex = text.startIndex
        
        while startIndex < text.endIndex {
            let endIndex = text.index(startIndex, offsetBy: chunkSize, limitedBy: text.endIndex) ?? text.endIndex
            let chunk = String(text[startIndex..<endIndex])
            chunks.append(chunk)
            startIndex = text.index(startIndex, offsetBy: chunkSize - overlap, limitedBy: text.endIndex) ?? text.endIndex
        }
        
        return chunks
    }

    // Simulated PDF text extraction (replace with actual implementation)
    private func extractTextFromPDF(at path: String) throws -> String {
        // Placeholder: Implement actual PDF text extraction logic
        return "" // Dummy return value
    }
}


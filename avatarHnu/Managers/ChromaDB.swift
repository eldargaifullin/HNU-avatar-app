import Foundation
import CryptoKit

class ChromaDB {
    private var documents: [String: String] = [:] // Store document hash and content
    private var documentHashes: [String] = []    // Store document hashes for quick lookup
    
    // Simulated similarity search based on query (you can improve this logic)
    func similaritySearch(query: String, topK: Int) -> [String] {
        let relevantDocs = documents.filter { $0.value.localizedCaseInsensitiveContains(query) }
        return Array(relevantDocs.prefix(topK).map { $0.value })
    }
    
    // Add document to the store
    func addDocument(_ document: String, metadata: [String: Any]) {
        let hash = hashText(document)
        documents[hash] = document
        documentHashes.append(hash)
    }
    
    // Check if the document is already in the store based on hash
    func contains(hash: String) -> Bool {
        return documentHashes.contains(hash)
    }
    
    // Helper function to hash the document (MD5 hash)
    private func hashText(_ text: String) -> String {
        // Ensure CryptoKit is imported for Insecure.MD5
        let hash = Insecure.MD5.hash(data: text.data(using: .utf8) ?? Data())
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}


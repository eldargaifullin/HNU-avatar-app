//
//  class.swift
//  avatarHnu
//
//  Created by Gaifullin, Eldar on 20.01.25.
//


// Define the RetrievalQA class
class RetrievalQA {
    private let llm: ChatOpenAI
    private let retriever: (String) -> String
    private let promptTemplate: PromptTemplate
    private let returnSourceDocuments: Bool

    init(llm: ChatOpenAI, retriever: @escaping (String) -> String, promptTemplate: PromptTemplate, returnSourceDocuments: Bool = true) {
        self.llm = llm
        self.retriever = retriever
        self.promptTemplate = promptTemplate
        self.returnSourceDocuments = returnSourceDocuments
    }

    // Marked the function as 'async' to support concurrency
    func runChain(for query: String) async -> (response: String, sourceDocuments: [String]?) {
        let context = retriever(query)
        let formattedPrompt = promptTemplate.format(with: ["context": context, "question": query])
        
        // Use 'await' for the async call
        let response = await llm.generateResponse(prompt: formattedPrompt)
        let sourceDocs = returnSourceDocuments ? [context] : nil
        return (response, sourceDocs)
    }
}


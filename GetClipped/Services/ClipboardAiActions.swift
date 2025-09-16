//
//  ClipboardAiActions.swift
//  GetClipped
//
//  Created by Ishan Misra on 9/13/25.
//

import FoundationModels
import SwiftUI

@available(macOS 26.0, *)
class ClipboardAiActions {
    static let shared = ClipboardAiActions()
    let taggingModel = SystemLanguageModel(useCase: .contentTagging)
    let generalModel = SystemLanguageModel.default
    
    @Generable struct ContentTags: Codable {
        var tags: [String]
    }
    
    private init() {}
    
    func summarizeText(_ text: String) async throws -> String {
        let session = LanguageModelSession(model: generalModel)
        let prompt = "Summarize the following text in a concise manner:\n\n\(text)"
        let response = try await session.respond(to: prompt)
        
        return response.content
    }
    
    func createTags(_ text: String) async throws -> [String] {
        let session = LanguageModelSession(model: taggingModel)
        let options = GenerationOptions(
            sampling: .greedy,
            temperature: 0.8,
            maximumResponseTokens: 200
        )
        
        let prompt = "Generate 5-10 relevant tags for the following text:\n\n\(text)"
        
        let response = try await session.respond(to: prompt, generating: ContentTags.self, includeSchemaInPrompt: false, options: options)
        return response.content.tags
     }
}

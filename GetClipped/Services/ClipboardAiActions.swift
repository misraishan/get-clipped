//
//  ClipboardAiActions.swift
//  GetClipped
//
//  Created by Ishan Misra on 9/13/25.
//

import FoundationModels
import SwiftUI

class ClipboardAiActions: @unchecked Sendable {
    static let shared = ClipboardAiActions()
    let taggingModel = SystemLanguageModel(useCase: .contentTagging)
    let generalModel = SystemLanguageModel.default
    
    @Generable struct ContentTags: Codable {
        var tags: [String]
    }
    
    @Generable struct CodeLanguageDetection: Codable {
        var language: String? = nil
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
    
    func detectCodingLanguage(_ codeSnippet: String) async throws -> String? {
        let session = LanguageModelSession(model: taggingModel)
        let options = GenerationOptions(
            sampling: .greedy,
            temperature: 0.8,
            maximumResponseTokens: 200
        )
        
        let prompt = "Determine if the following text is a coding language. If it is, specify which language it is written in (such as Swift, JavaScript, C#, etc.):\n\n\(codeSnippet)"
        
        let response = try await session.respond(to: prompt, generating: CodeLanguageDetection.self, includeSchemaInPrompt: false, options: options)
        return response.content.language ?? nil
    }
}

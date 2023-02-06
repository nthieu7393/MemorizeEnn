//
//  CardProtocol.swift
//  Quizzie
//
//  Created by hieu nguyen on 03/01/2023.
//

import Foundation

protocol Card: Codable {
    var idOfCard: String { set get }
    var termDisplay: String { get set }
    var listOfDefinition: [String] { get }
    var listOfLexicalCategory: [PartOfSpeech]? { get }
    var listOfExamples: [String]? { get }
    var phoneticDisplay: String? { get set }
    
    var selectedDefinition: String? { get set }
    var selectedLexicalCategory: PartOfSpeech? { get set }
    var selectedExample: String? { get set }
}

extension Card {
    
    var toJson: [String: Any] {
        return [
            "definition": selectedDefinition ?? "",
            "lexicawl_category": selectedLexicalCategory?.rawValue ?? PartOfSpeech.none.rawValue,
            "phrases": selectedExample ?? "",
            "term": termDisplay
        ]
    }
    
    var isEmpty: Bool {
        return termDisplay.isEmpty
        && (selectedDefinition?.isEmpty ?? true)
//        && (selectedExample?.isEmpty ?? true)
    }
}

extension Array<Card> {

    var toJson: [[String: Any]] {
        return self.compactMap {
            $0.toJson
        }
    }
}

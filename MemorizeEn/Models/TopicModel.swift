//
//  TopicModel.swift
//  Quizzie
//
//  Created by hieu nguyen on 16/11/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct TopicModel: Codable {
    
    @DocumentID var id: String?
    let topicId: String?
    var name: String
    var numberOfTerms: Int
    var createdDate: Date
    var terms: [TermModel]?

    enum CodingKeys: String, CodingKey {
        case topicId = "id"
        case name = "topic_name"
        case numberOfTerms = "number_of_terms"
        case createdDate = "created_date"
        case terms = "terms"
    }

    var toJson: [String: Any] {
        var dictionary: [String: Any] = [
            "topic_name": name,
            "number_of_terms": numberOfTerms,
            "created_date": createdDate
        ]
        if let topicId = topicId {
            dictionary["id"] = topicId
        }
        if let terms = terms {
            dictionary["terms"] = terms.compactMap({
                $0.toJson
            })
        }
        return dictionary
    }

    init(id: String? = nil, name: String) {
        self.topicId = id
        self.name = name
        self.numberOfTerms = 0
        self.createdDate = Date()
        self.terms = nil
    }
}

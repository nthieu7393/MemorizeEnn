//
//  SetModel.swift
//  Quizzie
//
//  Created by hieu nguyen on 15/11/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestoreSwift

struct SetTopicModel: Codable {

    @DocumentID var id: String?
    var name: String?
    var topics: [TopicModel] = []

    enum CodingKeys: String, CodingKey {
        case id
        case name = "set_name"
        case topics
    }
}

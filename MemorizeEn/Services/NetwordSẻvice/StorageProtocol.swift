//
//  StorageProtocol.swift
//  Quizzie
//
//  Created by hieu nguyen on 15/11/2022.
//

import Foundation

protocol StorageProtocol {
    
    func editSetName(_ set: SetTopicModel, name: String) async throws -> SetTopicModel?
    func createNewSet(name: String) async throws -> SetTopicModel?
    func getAllSets() async throws -> [SetTopicModel]?
    func getTopicDetails<T: Decodable>(
        set: SetTopicModel,
        topic: TopicModel) async throws -> T?
    func saveCards(
        cards: [Card],
        setId: String,
        topicId: String
    ) async throws
    func createNewTopic(_ topicName: String, set: SetTopicModel) async throws
    func deleteFolder(_ folder: SetTopicModel, completion: @escaping ((Error?) -> Void))
    func deleteTopic(
        _ topic: TopicModel,
        in folder: SetTopicModel,
        completion: @escaping ((Error?) -> Void))
}

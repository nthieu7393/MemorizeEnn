//
//  FirebaseVocabularyService.swift
//  Quizzie
//
//  Created by hieu nguyen on 15/11/2022.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseStorageService<T: Card>: StorageProtocol {
    
    private var authService: Authentication?
    private let db: Firestore!
    private let database = Firestore.firestore().collection("users")
    private var rootDocumentReference: DocumentReference? {
        guard let authUid = authService?.authUid else {
            debugPrint("‼️ not signin yet")
            return nil
        }
        return database.document(authUid)
    }
    
    private var folderCollectionRef: CollectionReference? {
        guard let reference = rootDocumentReference else { return nil }
        return reference.collection("folders")
    }

    private var deletedTopicCollection: CollectionReference? {
        guard let ref = rootDocumentReference else { return nil }
        return ref.collection("deleted_topics")
    }
    
    private func topicReference(setId: String, topicId: String) -> DocumentReference? {
        guard let reference = folderCollectionRef else { return nil }
        return reference.document(setId).collection("topics").document(topicId)
    }
    
    init(authService: Authentication?) {
        if let uwr = authService {
            self.authService = uwr
        }
        db = Firestore.firestore()
    }
    
    func getAllSets() async throws -> [SetTopicModel]? {
        do {
            guard let result = try await folderCollectionRef?.getDocuments() else { return nil }
            return result.documents.compactMap({
                return try? $0.data(as: SetTopicModel.self)
            })
        } catch {
            throw error
        }
    }
    
    func createNewSet(name: String) async throws -> SetTopicModel? {
        do {
            let data = ["set_name": name]
            let ref = try await folderCollectionRef?.addDocument(data: data)
            return SetTopicModel(id: ref?.documentID, name: name)
        } catch {
            throw error
        }
    }
    
    func editSetName(_ set: SetTopicModel, name: String) async throws -> SetTopicModel? {
        guard let documentId = set.id,
              set.name != name else { return nil }
        do {
            var mutatingSet = set
            let data = ["set_name": name]
            try await folderCollectionRef?.document(documentId).setData(data)
            mutatingSet.name = name
            return mutatingSet
        } catch {
            throw error
        }
    }
    
    func getTopicDetails<T: Decodable>(set: SetTopicModel, topic: TopicModel) async throws -> T? {
        guard let setId = set.id, let topicId = topic.topicId else { return nil }
        let result = topicReference(
            setId: setId,
            topicId: topicId
        )
        do {
            let topic = try await result!.getDocument(as: T.self)
            return topic
        } catch {
            throw error
        }
    }

    func saveCards(
        cards: [Card],
        setId: String,
        topicId: String
    ) async throws {
        do {
            try await topicReference(
                setId: setId,
                topicId: topicId)?.setData(
                    ["terms": cards.toJson],
                    merge: true
                )
        } catch {
            throw error
        }
    }
    
    func createNewTopic(_ topicName: String, set: SetTopicModel) {
        let documentRefOfSet = folderCollectionRef?.document(set.id ?? "")
        let topic = TopicModel(name: topicName)
        let documentRef = documentRefOfSet?
            .collection("topics")
            .addDocument(data: topic.toJson)

        let topicId = documentRef?.documentID
        var mutatingSet = set
        mutatingSet.topics.append(TopicModel(id: topicId, name: topicName))
        var dicData: [String: Any] = ["set_name": set.name ?? ""]
        dicData["topics"] = mutatingSet.topics.compactMap({
            $0.toJson
        })
        documentRefOfSet?.setData(dicData, merge: true)
    }

    func deleteFolder(_ folder: SetTopicModel, completion: @escaping ((Error?) -> Void)) {
        guard let folderId = folder.id else { return }
        folderCollectionRef?.document(folderId).delete(completion: { error in
            completion(error)
        })
    }

    func deleteTopic(
        _ topic: TopicModel,
        in folder: SetTopicModel,
        completion: @escaping ((Error?) -> Void)) {
        moveTopicToDeletedCollection(topic: topic) { [weak self] error in
            guard error == nil,
                  let uwrSelf = self else { return }
            uwrSelf.deleteTopicFromFolder(topic, in: folder, completion: completion)
        }
    }

    private func moveTopicToDeletedCollection(
        topic: TopicModel,
        completion: @escaping ((Error?) -> Void)) {
        deletedTopicCollection?.addDocument(data: topic.toJson, completion: completion)
    }

    private func deleteTopicFromFolder(
        _ topic: TopicModel,
        in folder: SetTopicModel,
        completion: @escaping ((Error?) -> Void)) {
        let batch = db.batch()
        var mutatingTopics = folder.topics
        let deletedTopicIndex = mutatingTopics.firstIndex {
            $0.topicId == topic.topicId
        }
        guard let folderId = folder.id,
              let uwrIndex = deletedTopicIndex,
              let folderRef = folderCollectionRef?.document(folderId) else {
            debugPrint("🥵 folder id not found")
            completion(PathError.notFound)
            return
        }

        // field topics
        mutatingTopics.remove(at: uwrIndex)
        batch.updateData(["topics": mutatingTopics.map({
            $0.toJson
        })], forDocument: folderRef)

        // collection topics
        let folderTopicRef = folderRef.collection("topics").document(topic.topicId ?? "")
        batch.deleteDocument(folderTopicRef)

        batch.commit { error in
            completion(error)
        }
    }
}

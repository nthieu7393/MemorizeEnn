//
//  SetViewController.swift
//  Quizzie
//
//  Created by hieu nguyen on 03/11/2022.
//

import Foundation

class SetsPresenter: BasePresenter {

    private let storageService: StorageProtocol
    private let view: SetsView
    private var sets: [SetTopicModel]?

    init(view: SetsView, storageService: StorageProtocol) {
        self.view = view
        self.storageService = storageService
    }

    func loadAllSets() {
        view.showLoadingIndicator()
        Task {
            do {
                sets = try await storageService.getAllSets()
                DispatchQueue.main.async {
                    self.view.displayDataOfSets(sets: self.sets ?? [])
                    self.view.dismissLoadingIndicator()
                }
            } catch {
                self.view.dismissLoadingIndicator()
                self.view.showErrorAlert(msg: error.localizedDescription)
            }
        }
    }

    func createNewSet() {
        view.startInputNameOfSet(initialString: "") { [weak self] string in
            guard let self = self,
                  let string = string else { return }
            Task {
                do {
                    let set = try await self.storageService.createNewSet(name: string)
                    if let set = set {
                        DispatchQueue.main.async {
                            self.sets?.insert(set, at: 0)
                            self.view.displayNewSet(set: set)
                        }
                    }
                } catch {
                    self.view.showErrorAlert(msg: error.localizedDescription)
                }
            }
        }
    }

    func createNewTopicToSet(set: SetTopicModel) {
        view.startInputNameOfSet(initialString: "") { [weak self] topicName in
            guard let self = self else { return }
            self.addNewTopicToSet(topicName ?? "", set: set)
        }
    }

    func editNameOfSet(_ set: SetTopicModel) {
        view.startInputNameOfSet(initialString: set.name ?? "") { [weak self] string in
            guard let self = self,
                  let string = string,
                  let indexOfMutatingSet = self.sets?.firstIndex(where: { $0.id == set.id })
            else { return }
            Task {
                do {
                    let set = try await self.storageService.editSetName(set, name: string)
                    if let set = set {
                        DispatchQueue.main.async {
                            self.sets?[indexOfMutatingSet] = set
                            self.view.displayDataOfSets(sets: self.sets ?? [])
                        }
                    }
                } catch {

                }
            }
        }
    }
    
    func addNewTopicToSet(_ topicName: String, set: SetTopicModel) {
        Task {
            do {
                try await self.storageService.createNewTopic(topicName, set: set)
            } catch {
                view.showErrorAlert(msg: error.localizedDescription)
            }
        }
    }

    func deleteFolder(_ folder: SetTopicModel) {
        storageService.deleteFolder(folder) { [weak self] error in
            self?.view.showResultAlert(error: error, message: nil)
        }
    }

    func deleteTopic(_ topic: TopicModel, from folder: SetTopicModel) {
        storageService.deleteTopic(topic, in: folder) { [weak self] error in
            self?.view.showResultAlert(error: error, message: nil)
        }
    }
}

//
//  TermsPresenter.swift
//  Quizzie
//
//  Created by hieu nguyen on 19/11/2022.
//

import Foundation
import RealmSwift

class TermsPresenter: BasePresenter {
    private let storageService: StorageProtocol
    private let networkVocabularySerivce: NetworkVocabularyProtocol
    private let realmVocabularyService: RealmVocabularyService<PhrasalVerbEntity>
    private var phrasalVerbsFileProvider: (any FileDataProvider)?
    private var dispathQueue = DispatchQueue(
        label: "concurrentQueue",
        attributes: .concurrent)
    var searchDataOfCardDispatchWork: DispatchWorkItem!

    private let topic: TopicModel
    private let set: SetTopicModel
    private var terms: [Card]? = []
    private let view: TermsView

    init(
        view: TermsView,
        set: SetTopicModel,
        topic: TopicModel,
        storageService: StorageProtocol,
        networkVocabularyService: NetworkVocabularyProtocol
//        realmVocabularyService: LocalProtocol
    ) {
        self.view = view
        self.topic = topic
        self.set = set
        self.storageService = storageService
        self.networkVocabularySerivce = networkVocabularyService

        view.showLoadingIndicator()

        phrasalVerbsFileProvider = BundleFileDataProvider<PhrasalVerbList>(
            fileName: "phrasal-verbs",
            extension: "json")
        self.realmVocabularyService = RealmVocabularyService(realm: RealmProvider.phrasalVerbs.realm!)
        
        let verbs: [PhrasalVerbWordItem]? = ((try? phrasalVerbsFileProvider?.loadData()) as? PhrasalVerbList)?.list
        let verbEntities = verbs?.compactMap({
            return PhrasalVerbEntity(
                term: $0.word,
                derivatives: $0.derivatives ?? [],
                descriptions: $0.descriptions ?? [],
                examples: $0.examples ?? []
            )
        })
        self.realmVocabularyService.saveMany(items: verbEntities ?? []) { _, _ in
        }
        terms = []
        view.dismissLoadingIndicator()
    }

    func getAllTerms() {
        Task {
            do {
                let topic: TopicModel? = try await storageService.getTopicDetails(
                    set: set,
                    topic: topic
                )
                let terms = topic?.terms ?? []
                self.terms = terms
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.view.displayTerms(terms: terms)
                }
            } catch {

            }
        }
    }
    
    func autoFillDataOfTerm(card: Card, at cell: TermTableCell, display: Bool) {
        searchDataOfCardDispatchWork?.cancel()
        searchDataOfCardDispatchWork = DispatchWorkItem(block: {
            if card.termDisplay.components(separatedBy: " ").count == 1 {
                self.getDataOfWord(card: card, cell: cell, display: display)
            } else {
                self.getDataOfPhrasalVerbs(card: card, cell: cell, display: display)
            }
        })
        dispathQueue.asyncAfter(deadline: .now()+0.6, execute: searchDataOfCardDispatchWork)
    }
    
    func getDataOfPhrasalVerbs(card: Card, cell: TermTableCell, display: Bool) {
        DispatchQueue.main.async {
            let result = self.realmVocabularyService.object(
                type: PhrasalVerbEntity.self,
                predicateFormat: "term == %@",
                args: card.termDisplay
            )
            guard let uwrTerm = result?.first else { return }
            let phrasalVerb = TermModel(
                id: card.idOfCard,
                term: uwrTerm.termDisplay,
                definition: uwrTerm.selectedDefinition,
                phrases: uwrTerm.selectedExample)
            self.view.displayCard(card: phrasalVerb, at: cell, display: display)
            self.updateListOfCards(term: phrasalVerb)
        }
    }
    
    func getDataOfWord(card: Card, cell: TermTableCell, display: Bool) {
        self.networkVocabularySerivce.getDefination(
            term: card.termDisplay) { [weak self] (wordItem: WordsApiWordItem?, error: Error?) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.view.displayCard(card: nil, at: cell, display: display)
                    self.view.showErrorAlert(msg: error.localizedDescription)
                } else if var wordItem = wordItem {
                    wordItem.idOfCard = card.idOfCard
                    self.view.displayCard(card: wordItem, at: cell, display: display)
                    self.updateListOfCards(term: wordItem)
                }
            }
        }
    }
    
    func insertTermToList(term: Card) {
        terms?.insert(term, at: 0)
    }
    
    func updateListOfCards(term: Card) {
        if (terms?.count ?? 0) == 1 && terms?.first?.isEmpty == true || terms == nil {
            terms = [term]
            return
        }
        guard let oldTerm = terms?.firstIndex(where: {
            $0.idOfCard == term.idOfCard
        }) else {
            debugPrint("‼️ not found term")
            return
        }
        terms?[oldTerm].termDisplay = term.termDisplay
        terms?[oldTerm].selectedDefinition = term.selectedDefinition
        terms?[oldTerm].selectedExample = term.selectedExample
    }
    
    func saveTopic() {
        Task {
            do {
                try await storageService.saveCards(
                    cards: terms ?? [],
                    setId: set.id ?? "",
                    topicId: topic.topicId ?? ""
                )
            } catch {
                view.showErrorAlert(msg: error.localizedDescription)
            }
        }
    }
}

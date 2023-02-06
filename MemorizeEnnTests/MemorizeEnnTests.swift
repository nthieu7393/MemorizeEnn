//
//  MemorizeEnTests.swift
//  MemorizeEnTests
//
//  Created by hieu nguyen on 02/02/2023.
//

import XCTest
@testable import MemorizeEnn

final class MemorizeEnnTests: XCTestCase {

    var phrasalVerbsFile: BundleFileDataProvider<PhrasalVerbList>!
    var realmVocabularyService: RealmVocabularyService<PhrasalVerbEntity>?
    var verbEntities: [PhrasalVerbEntity]?

    override func setUp() {
        phrasalVerbsFile = BundleFileDataProvider<PhrasalVerbList>(
            fileName: "phrasal-verbs",
            extension: "json")
        let phrasalVerbsRealm = RealmProvider.phrasalVerbs.copyForTesting().realm
        realmVocabularyService = RealmVocabularyService(realm: phrasalVerbsRealm!)

        let verbs = try? phrasalVerbsFile.loadData()?.list
        verbEntities = verbs?.compactMap({
            return PhrasalVerbEntity(
                term: $0.word,
                derivatives: $0.derivatives ?? [],
                descriptions: $0.descriptions ?? [],
                examples: $0.examples ?? []
            )
        })
        try? phrasalVerbsRealm?.write({
            verbEntities?.forEach({
                phrasalVerbsRealm?.add($0)
            })
        })
    }

    override func tearDown() {}

    func test_fileNameAndExtensionNotNil_whenInit() {
        XCTAssertEqual(phrasalVerbsFile.fileName, "phrasal-verbs")
        XCTAssertEqual(phrasalVerbsFile.extension, "json")
    }

    func test_phrasalVerbsNotEmpty_whenLoadBundleFile() {
        do {
            let verbs = try phrasalVerbsFile.loadData()
            XCTAssertNotNil(verbs?.list)
        } catch {
            fatalError("‼️ Load phrasal verbs failed")
        }
    }

    func test_dataNotNil_savePhrasalVerbsLocalStorage() {
        do {
            var totalNewlyAdded = 0
            let expectation = XCTestExpectation(description: "test_dataNotNil_savePhrasalVerbsLocalStorage")
            expectation.expectedFulfillmentCount = 1
            let verbs = try phrasalVerbsFile.loadData()?.list
            let verbEntities = verbs?.compactMap({
                return PhrasalVerbEntity(
                    term: $0.word,
                    derivatives: $0.derivatives ?? [],
                    descriptions: $0.descriptions ?? [],
                    examples: $0.examples ?? []
                )
            })
            realmVocabularyService?.saveMany(
                items: verbEntities ?? [],
                onComplete: { totalAdded, error in
                    totalNewlyAdded = totalAdded
                    expectation.fulfill()
                })
            let waitResult = XCTWaiter().wait(for: [expectation], timeout: 3.0)
            XCTAssertEqual(waitResult, .completed, "result not completed. Its timeout")
            XCTAssertEqual(totalNewlyAdded, 3350)
        } catch {
            fatalError("‼️ Load phrasal verbs failed")
        }
    }

    func test_deleteObject_givenObjectId() {
        do {
            try realmVocabularyService?.saveManySync(items: verbEntities ?? [])
            let firstItem = realmVocabularyService?.objects(type: PhrasalVerbEntity.self)?.first?.idOfCard
            try? realmVocabularyService?.delete(id: firstItem ?? "")
            XCTAssertEqual(realmVocabularyService?.objects(type: PhrasalVerbEntity.self)?.count, 3349)
        } catch {
            fatalError("‼️ realmVocabularyService?.delete")
        }
    }

    func test_phrasalVerbNotNil() {
        let objects = realmVocabularyService?.object(type: PhrasalVerbEntity.self, predicateFormat: "term == %@", args: "account for")
        do {
            let values = try XCTUnwrap(objects)
            XCTAssertTrue(values.count > 0)
            XCTAssertEqual(Array(values.first!.derivatives), [ "accounts for", "accounting for", "accounted for" ])
        } catch {
            fatalError("‼️ objects is nil")
        }
    }
}

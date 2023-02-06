//
//  TestingRealm+.swift
//  QuizzieTests
//
//  Created by hieu nguyen on 07/01/2023.
//

import Foundation
import RealmSwift

@testable import MemorizeEnn

extension RealmProvider {
    
    func copyForTesting() -> RealmProvider {
        var conf = self.config
        conf.inMemoryIdentifier = UUID().uuidString
        conf.readOnly = false
        return RealmProvider(config: conf)
    }
}

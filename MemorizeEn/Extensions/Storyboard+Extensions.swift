//
//  Coordinator.swift
//  Quizzie
//
//  Created by hieu nguyen on 02/11/2022.
//

import UIKit

protocol Storyboarded {
    
    static func instantiate() -> Self?
}

extension Storyboarded where Self: UIViewController {

    static func instantiate() -> Self? {
        let name = NSStringFromClass(self).components(separatedBy: ".").last!
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name) as? Self
    }
}

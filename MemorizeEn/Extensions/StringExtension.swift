//
//  StringExtension.swift
//  Quizzie
//
//  Created by hieu nguyen on 01/02/2023.
//

import Foundation

extension String {

    var isEmail: Bool {
        let emailPattern = #"^\S+@\S+\.\S+$"#
        let result = range(of: emailPattern, options: .regularExpression)
        return result != nil
    }

    var isValidPassword: Bool {
        let pattern = #"(?=.{8,})"#
        let result = range(of: pattern, options: .regularExpression)
        return result != nil
    }
}

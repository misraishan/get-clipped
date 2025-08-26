//
//  StringExtensions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import Foundation

extension String {
    var isValidURL: Bool {
        guard !contains("..") || !contains(" ") else { return false }

        let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head + "+(.)+" + tail

        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)

        return urlTest.evaluate(with: trimmingCharacters(in: .whitespaces))
    }

    var getLinkPreview: String {
        if isValidURL {
            return components(separatedBy: ".")[1].capitalized
        }
        return self
    }
}

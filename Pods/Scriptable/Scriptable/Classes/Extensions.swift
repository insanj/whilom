//
//  Extensions.swift
//  Pods-Scriptable_Example
//
//  Created by Abdullah Alhaider on 13/07/2019.
//

import Foundation

public extension String {
    
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var asLog: String {
        var string = "\(self.trimmed)\n"
        string = string.replacingOccurrences(of: "\n", with: "\n | ")
        return "\(string.dropLast(6))"
    }
    
    var replaceSpaces: String {
        return self.replacingOccurrences(of: " ", with: #"\ "#)
    }
}

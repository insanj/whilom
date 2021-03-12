//
//  App+Task.swift
//  Pods-Scriptable_Example
//
//  Created by Abdullah Alhaider on 13/07/2019.
//

import Foundation

public extension Task {
    
    enum Apps: Scriptable {
        
        case slack
        case terminal
        case outlookEmail
        case figma
        case sourceTree
        case skypeForBusiness
        case custom(String)
        
        public var command: String {
            switch self {
            case .slack:
                return "open -a Slack"
            case .terminal:
                return "open -a Terminal"
            case .outlookEmail:
                return "open -a \("Microsoft Outlook".replaceSpaces)"
            case .figma:
                return "open -a Figma"
            case .sourceTree:
                return "open -a Sourcetree"
            case .skypeForBusiness:
                return "open -a \("Skype for Business".replaceSpaces)"
            case .custom(let appName):
                return "open -a \(appName.replaceSpaces)"
            }
        }
        
        public static var allApps: [Apps] {
            return [.slack, .terminal, .skypeForBusiness]
        }
    }
}

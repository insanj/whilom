//
//  Directory+Task.swift
//  Scriptable
//
//  Created by Abdullah Alhaider on 13/07/2019.
//

import Foundation

public extension Task {
    
    enum Directory: Scriptable {
        
        case desktop
        case documents
        case downloads
        case custom(String)
        
        public var command: String {
            switch self {
            case .desktop:
                return "cd ~ && cd Desktop/ && open ."
            case .documents:
                return "cd ~ && cd Documents/ && open ."
            case .downloads:
                return "cd ~ && cd Downloads/ && open ."
            case .custom(let directory):
                return "cd ~ && cd \(directory) && open ."
            }
        }
        
        public static var all: [Directory] {
            return [.desktop, .documents, .downloads]
        }
    }
}

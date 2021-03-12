//
//  Custom+Task.swift
//  Scriptable
//
//  Created by Abdullah Alhaider on 13/07/2019.
//

import Foundation

public extension Task {
    
    enum Custom: Scriptable {
        
        case command(String)
        
        public var command: String {
            switch self {
            case .command(let cmd):
                return cmd
            }
        }
    }
}

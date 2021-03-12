//
//  Kill+Task.swift
//  Scriptable
//
//  Created by Abdullah Alhaider on 26/07/2019.
//

import Foundation

public extension Task {
    
    /// Force quit any app (process)
    enum Kill: Scriptable {
        
        /// Quitting the process using the app name with provided kill options
        case appName(String, option: KillOptions)
        /// Quitting the prosses by PID number using `Kill` command
        case usingPID(Int)
        
        public var command: String {
            switch self {
            case .appName(let app, let option):
                return "\(option.cmd) \(app.replaceSpaces)"
            case .usingPID(let pID):
                return "Kill \(pID)"
            }
        }
    }
}

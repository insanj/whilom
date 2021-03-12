//
//  KillOptions.swift
//  Scriptable
//
//  Created by Abdullah Alhaider on 27/07/2019.
//

import Foundation

public enum KillOptions {
    case pkill
    case killall
    
    public var cmd: String {
        switch self {
        case .pkill:
            return "pkill"
        case .killall:
            return "killall"
        }
    }
}

//
//  WhilomCommands.swift
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//

import Scriptable

enum WhilomCommandType {
    case disableSleep
    case enableSleep
}

struct WhilomCommand: Scriptable {
    let password: String
    let type: WhilomCommandType
    init(password: String, type: WhilomCommandType){
        self.password = password
        self.type = type
    }
    
//    func command(_ whilomCommand: WhilomCommand, _ password: String) -> String {
//        let string = "sudo -S pmset -a disablesleep 1"whilomCommand == .disableSleep ? "sudo -S pmset -a disablesleep 1" : "sudo -S pmset -a disablesleep 0"
//        return "echo \(password) | \(w)"
//    }

    var command: String {
        switch type {
        case .disableSleep:
            let commandString = "echo \(password) | sudo -S pmset -a disablesleep 1"
            return commandString
        case .enableSleep:
            let commandString = "echo \(password) | sudo -S pmset -a disablesleep 0"
            return commandString
        }
    }
}

//
//  InterfaceStyle.swift
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//
// https://stackoverflow.com/questions/25207077/how-to-detect-if-os-x-is-in-dark-mode
//

import Foundation

enum InterfaceStyle : String {
   case Dark, Light

   init() {
      let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
      self = InterfaceStyle(rawValue: type)!
    }
}

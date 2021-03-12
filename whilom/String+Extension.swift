//
//  String+Extension.swift
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//

import Foundation

extension String {
  // https://stackoverflow.com/questions/52007286/show-random-emoji-inside-a-label-in-tableviewcell
  static var randomEmoji: String? {
      guard let randomElement = Array(0x1F300...0x1F3F0).randomElement() else {
          return nil
      }
      
      guard let unicodeScalar = UnicodeScalar(randomElement) else {
          return nil
      }
    
      let randomString = String(unicodeScalar)
      return randomString
  }
}

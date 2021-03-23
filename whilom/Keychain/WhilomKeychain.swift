//
//  WhilomKeychain.swift
//  whilom
//
//  Created by Julian Weiss on 3/23/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//

import Foundation

class WhilomKeychain {
  
  public class func getCurrentUsername() -> String {
    return NSUserName()
  }
  
  private class func key(forUsername username: String) -> String {
    return "WhilomKeychainLocalUser-\(username)"
  }
  
  public class func saveCurrentPassword(_ password: String) -> Bool {
    let username = getCurrentUsername()
    let key = WhilomKeychain.key(forUsername: username)
    
    do {
      return try Keychain.save(str: password, forKey: key)
    } catch let e {
      print(e)
      return false
    }
  }
  
  public class func getSavedPassword(_ username: String?=nil) -> String? {
    let username = username ?? getCurrentUsername()
    let key = WhilomKeychain.key(forUsername: username)
    return Keychain.load(key: key)
  }
  
  public class func deletePasswords() -> Bool {
    return Keychain.clear()
  }
  
}

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
    return KeychainWrapper.standard.set(password, forKey: key)
  }
  
  public class func getSavedPassword(_ username: String?=nil) -> String? {
    let username = username ?? getCurrentUsername()
    let key = WhilomKeychain.key(forUsername: username)
    return KeychainWrapper.standard.string(forKey: key)
  }
  
  public class func deletePassword(_ username: String?=nil) -> Bool {
    let username = username ?? getCurrentUsername()
    let key = WhilomKeychain.key(forUsername: username)
    return KeychainWrapper.standard.removeObject(forKey: key)
  }
  
}

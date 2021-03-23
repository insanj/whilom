//
//  Keychain.swift
//  whilom
//
//  Created by Julian Weiss on 3/23/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//
// derived from
// https://gist.github.com/nafu/c22fc9bd7535f779f0f2
// https://developer.apple.com/documentation/security/keychain_services/keychain_items/searching_for_keychain_items

import Foundation
import Security

public class Keychain {
  
  public class func save(str: String, forKey: String) throws -> Bool {
    let dataFromString: Data = str.data(using: .utf8, allowLossyConversion: false)!
    let query: [String : Any] = [
      kSecClass as String: kSecClassGenericPassword as String,
      kSecAttrAccount as String: forKey,
      kSecValueData as String: dataFromString
    ]

    SecItemDelete(query as CFDictionary)

    let status: OSStatus = SecItemAdd(query as CFDictionary, nil)

    return status == noErr
  }

  public class func load(key: String) -> String? {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ] as [String : Any]

    var item: CFTypeRef?
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item)
    
    guard status == noErr else {
      return nil
    }
    
    guard let existingItem = item as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let value = String(data: passwordData, encoding: String.Encoding.utf8) else {
      return nil
    }
    
    return value
  }

  public class func delete(key: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key
    ]

    let status: OSStatus = SecItemDelete(query as CFDictionary)

    return status == noErr
  }

  public class func clear() -> Bool {
    let query = [
      kSecClass as String: kSecClassGenericPassword
    ]

    let status: OSStatus = SecItemDelete(query as CFDictionary)

    return status == noErr
  }
}

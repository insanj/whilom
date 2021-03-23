//
//  WhilomKeychain.swift
//  whilom
//
//  Created by Julian Weiss on 3/23/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//
//  See: https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
//

import Foundation

class WhilomKeychain {
  struct Credentials {
      var username: String
      var password: String
  }
  
  enum KeychainError: Error {
      case noPassword
      case unexpectedPasswordData
      case unhandledError(status: OSStatus)
  }
  
  static let shared = WhilomKeychain()
  
  private static let QUERY_DICTIONARY_TAG = "com.insanj.whilom.keychain"
  private static var QUERY_DICTIONARY_TAG_DATA: Data {
    return QUERY_DICTIONARY_TAG.data(using: .utf8)!
  }
  
  private func createQueryDictionary(_ credentials: Credentials) -> [String: Any] {
    let tag = WhilomKeychain.QUERY_DICTIONARY_TAG_DATA
    let account = credentials.username
    let password = credentials.password.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrApplicationTag as String: tag,
                                kSecAttrAccount as String: account,
                                kSecValueData as String: password]
    return query
  }
  
  private func saveQueryDictionary(_ credentials: Credentials) throws -> OSStatus {
    let addquery = createQueryDictionary(credentials)

    let status = SecItemAdd(addquery as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeychainError.unhandledError(status: status)
    }
    
    return status
  }
  
  private func getQueryDictionary() -> String? {
    let tag = WhilomKeychain.QUERY_DICTIONARY_TAG_DATA
    let getquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrApplicationTag as String: tag,
                                   kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                   kSecReturnRef as String: true]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(getquery as CFDictionary, &item)
    guard status == errSecSuccess else {
      return nil
    }
    
    let key = item as! SecKey
    return key
  }
  
  func store(item: Any) {
    
  }
  
}

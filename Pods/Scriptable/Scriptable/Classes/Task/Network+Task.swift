//
//  Network+Task.swift
//  Pods-Scriptable_Example
//
//  Created by Abdullah Alhaider on 13/07/2019.
//

import Foundation

public enum Switch: String {
    case on, off
}

public extension Task {
    
    /// Network related tasks
    enum Network: Scriptable {
        
        /// Switching the wifi
        case wifi(_ switch: Switch)
        /// Getting your public ip address
        case getIpAddress
        
        /// Getting your current WiFi SSID name
        case getWiFiName
        /// Getting PassiveFTP status
        case getPassiveFTP
        /// Getting WebProxy Info
        case getWebProxyInfo
        /// Getting SecureWebProxy Info
        case getSecureWebProxyInfo
        
        /// Setting PassiveFTP to either On or Off
        case setPassiveFTP(_ switch: Switch)
        /// Setting WebProxy state to either On or Off
        case setWebProxyState(_ switch: Switch)
        /// Setting SecureWebProxy state to either On or Off
        case setSecureWebProxyState(_ switch: Switch)
        
        case showMoreCommands
        
        public var command: String {
            switch self {
            case .wifi(let `switch`):
                return #"/usr/sbin/networksetup -setairportpower $airport \#(`switch`)"#
            case .getIpAddress:
                return "curl ipecho.net/plain ; echo"
                
            case .getWiFiName:
                return #"networksetup -getairportnetwork en0"#
            case .getPassiveFTP:
                return #"networksetup -getpassiveftp "Wi-fi""#
            case .getWebProxyInfo:
                return #"networksetup -getwebproxy "Wi-fi""#
            case .getSecureWebProxyInfo:
                return #"networksetup -getsecurewebproxy "Wi-fi""#
                
            case .setPassiveFTP(let `switch`):
                return #"networksetup -setpassiveftp "Wi-fi" \#(`switch`)"#
            case .setWebProxyState(let `switch`):
                return #"networksetup -setwebproxystate "Wi-fi" \#(`switch`)"#
            case .setSecureWebProxyState(let `switch`):
                return #"networksetup -setsecurewebproxystate "Wi-fi" \#(`switch`)"#
                
            case .showMoreCommands:
                return "open https://github.com/cs4alhaider/NetworkCommands/blob/master/README.md"
            }
        }
        
        public static var allGetInfoCommands: [Network] {
            return [.getWiFiName, .getPassiveFTP, .getWebProxyInfo, .getSecureWebProxyInfo]
        }
        
        public static var allSetOnCommands: [Network] {
            return [.setPassiveFTP(.on), .setWebProxyState(.on), .setSecureWebProxyState(.on)]
        }
        
        public static var allSetOffCommands: [Network] {
            return [.setPassiveFTP(.off), .setWebProxyState(.off), .setSecureWebProxyState(.off)]
        }
    }
}

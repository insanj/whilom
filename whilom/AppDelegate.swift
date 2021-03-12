//
//  AppDelegate.swift
//  whilom
//
//  Created by Julian Weiss on 8/28/20.
//  Copyright © 2020 Julian Weiss. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - properties
    // MARK: menu, list items
    let menu: NSMenu = {
      return NSMenu()
    }()
    
    let whilomStatusItem: NSStatusItem = {
      var statusItem = NSStatusItem()
      statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
      statusItem.button?.title = "🪄"
      return statusItem
    }()
  
    let titleMenuItem: NSMenuItem = {
      let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
      return NSMenuItem(title: "🪄 whilom \(versionString)", action: nil, keyEquivalent: "")
    }()
  
    let openMenuItem: NSMenuItem = {
      let item = NSMenuItem()
      item.title = "🎩 Turn Sleep Off"
      return item
    }()
  
    let quitMenuItem: NSMenuItem = {
      let quitMenuItem = NSMenuItem()
      quitMenuItem.title = "Quit"
      return quitMenuItem
    }()
  
    // MARK: scripts
    let enableSleepScript: NSAppleScript? = {
        let myAppleScript = """
        do shell script "sudo pmset -a disablesleep 0" with administrator privileges
        """
        
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: myAppleScript) else {
            return nil
        }
        
        return scriptObject
    }()
  
    let disableSleepScript: NSAppleScript? = {
        let myAppleScript = """
        do shell script "sudo pmset -a disablesleep 1" with administrator privileges
        """
        
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: myAppleScript) else {
            return nil
        }
        
        return scriptObject
    }()
  
    // MARK: - runtime
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menu.delegate = self
        whilomStatusItem.menu = menu
        
        titleMenuItem.isEnabled = false
        menu.addItem(titleMenuItem)
        
        menu.addItem(NSMenuItem.separator())

        openMenuItem.action = #selector(disableSleep)
        openMenuItem.target = self
        menu.addItem(openMenuItem)
        
        menu.addItem(NSMenuItem.separator())

        quitMenuItem.action = #selector(quitWhilom(_:))
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc func quitWhilom(_ sender: Any) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
  
    @objc func disableSleep() -> Bool {
        var error: NSDictionary?
        disableSleepScript?.executeAndReturnError(&error)
      
        if let error = error {
          let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
          alert.runModal()
          return false
        }
      
        openMenuItem.title = "😴 Turn Sleep On"
        openMenuItem.action = #selector(enableSleep)
        return true
    }
    
    @objc func enableSleep() -> Bool {
        var error: NSDictionary?
        enableSleepScript?.executeAndReturnError(&error)
    
        if let error = error {
          let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
          alert.runModal()
          return false
        }
      
        openMenuItem.title = "🎩 Turn Sleep Off"
        openMenuItem.action = #selector(disableSleep)
        return true
    }
  
}

extension AppDelegate: NSMenuDelegate, NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}

//
//  AppDelegate.swift
//  whilom
//
//  Created by Julian Weiss on 8/28/20, 3/11/21.
//  Copyright © 2021 Snowcode, LLC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - properties
    // MARK: left click menu item
    let whilomStatusItem: NSStatusItem = {
        var statusItem = NSStatusItem()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🪄"
        return statusItem
    }()
    
    // MARK: right click menu items
    let menu: NSMenu = {
        return NSMenu()
    }()
  
    let titleMenuItem: NSMenuItem = {
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        return NSMenuItem(title: "💝 whilom \(versionString)", action: nil, keyEquivalent: "")
    }()
  
    let quitMenuItem: NSMenuItem = {
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        return quitMenuItem
    }()
  
    // MARK: scripts, states
    var isSleepEnabled = false
  
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
          whilomStatusItem.button?.action = #selector(whilomClicked(_:))
          whilomStatusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
          // bye bye!
    }
    
    // MARK: - left or right click handler
    @objc func whilomClicked(_ sender: NSStatusBarButton)  {
        guard let event = NSApp.currentEvent else {
            return
        }
      
        if event.type == .rightMouseUp {
            createWhilomMenu()
        } else {
            toggleSleep()
        }
    }
    
    // MARK: - right click handlers
    func createWhilomMenu() {
        titleMenuItem.isEnabled = false
        menu.addItem(titleMenuItem)

        menu.addItem(NSMenuItem.separator())

        quitMenuItem.action = #selector(quitWhilom(_:))
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
      
        whilomStatusItem.menu = menu
        
        let point = NSApp.currentEvent?.window?.frame.origin ?? .zero
        menu.popUp(positioning: titleMenuItem, at: point, in: nil)
    }
  
    @objc func quitWhilom(_ sender: Any) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
    
    // MARK: - left click handler
    private func toggleSleep() {
        if isSleepEnabled {
            let _ = disableSleep()
        } else {
            let _ = enableSleep()
        }
    }
    
    // MARK: execute scripts based on state
    @objc private func disableSleep() -> Bool {
        var error: NSDictionary?
        disableSleepScript?.executeAndReturnError(&error)
      
        if let error = error {
            let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
            alert.runModal()
            return false
        }
        
        whilomStatusItem.button?.title = "😴"
        isSleepEnabled = false
        return true
    }
    
    @objc private func enableSleep() -> Bool {
        var error: NSDictionary?
        enableSleepScript?.executeAndReturnError(&error)
    
        if let error = error {
            let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
            alert.runModal()
            return false
        }
      
        whilomStatusItem.button?.title = "🪄"
        isSleepEnabled = true
        return true
    }
}

extension AppDelegate: NSMenuDelegate, NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}

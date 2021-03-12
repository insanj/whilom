//
//  AppDelegate.swift
//  keysmith
//
//  Created by Julian Weiss on 8/28/20.
//  Copyright © 2020 Julian Weiss. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var keysmithStatusItem: NSStatusItem?
    var menu: NSMenu?
    var hasEnabled: Bool = false
        
    let openMenuItem = NSMenuItem()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        keysmithStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        keysmithStatusItem?.button?.title = "🪄"
        
        menu = NSMenu()
        menu?.delegate = self
        keysmithStatusItem?.menu = menu
        
        let titleMenuItem = NSMenuItem(title: "🪄 whilom 0.1.0", action: nil, keyEquivalent: "")
        titleMenuItem.isEnabled = false
        menu?.addItem(titleMenuItem)
        
        menu?.addItem(NSMenuItem.separator())

        openMenuItem.title = "🎩 Turn Sleep Off"
        openMenuItem.action = #selector(disableSleep)
        openMenuItem.target = self
        menu?.addItem(openMenuItem)
        
        menu?.addItem(NSMenuItem.separator())

        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        quitMenuItem.action = #selector(quitWhilom(_:))
        quitMenuItem.target = self
        menu?.addItem(quitMenuItem)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc func quitWhilom(_ sender: Any) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
  
    @objc func disableSleep() -> Bool {
        let myAppleScript = """
        do shell script "sudo pmset -a disablesleep 1" with administrator privileges
        """
        
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: myAppleScript) else {
            return false
        }

        let _: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
        
        openMenuItem.title = "😴 Turn Sleep On"
        openMenuItem.action = #selector(enableSleep)
        return true
    }
    
    @objc func enableSleep() -> Bool {
        let myAppleScript = """
        do shell script "sudo pmset -a disablesleep 0" with administrator privileges
        """
        
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: myAppleScript) else {
            return false
        }

        let _: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
      
        
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

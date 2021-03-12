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
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
      
        let hattieOffImage = NSImage(named: NSImage.Name("hattie off"))
        hattieOffImage?.isTemplate = false // in the future, this will be handled by the instance var instead
      
        statusItem.button?.imageScaling = .scaleProportionallyUpOrDown
        statusItem.button?.imageHugsTitle = true
//        statusItem.button?.alternateImage =
        statusItem.button?.image = hattieOffImage

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
    var isSleepEnabled = true
  
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
  
    // MARK: - anim props
    let animDuration: CFTimeInterval = 0.15
    let imageHattieOff: NSImage = {
        let image = NSImage(named: NSImage.Name("hattie off"))!
        image.isTemplate = false
        return image
    }()
  
    let imageHattieOn1: NSImage = {
        let image = NSImage(named: NSImage.Name("hattie on 1"))!
        image.isTemplate = false
        return image
    }()

    let imageHattieOn2: NSImage = {
        let image = NSImage(named: NSImage.Name("hattie on 2"))!
        image.isTemplate = false
        return image
    }()

    let imageHattieOn3: NSImage = {
        let image = NSImage(named: NSImage.Name("hattie on 3"))!
        image.isTemplate = false
        return image
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
//        var error: NSDictionary?
//        disableSleepScript?.executeAndReturnError(&error)
//
//        if let error = error {
//            let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
//            alert.runModal()
//            return false
//        }
      
        performSleepAnimation(forwards: true)
        isSleepEnabled = false
        return true
    }
    
    @objc private func enableSleep() -> Bool {
//        var error: NSDictionary?
//        enableSleepScript?.executeAndReturnError(&error)
//
//        if let error = error {
//            let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
//            alert.runModal()
//            return false
//        }
//
        performSleepAnimation(forwards: false)
        isSleepEnabled = true
        return true
    }
  
    // MARK: - animations
    private func performSleepAnimation(forwards: Bool) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = animDuration
        whilomStatusItem.button?.image = forwards ? imageHattieOn1 : imageHattieOn2
        NSAnimationContext.endGrouping()
      
        DispatchQueue.main.asyncAfter(deadline: .now() + (animDuration * 1)) { [unowned self] in
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = self.animDuration
            self.whilomStatusItem.button?.image = forwards ? imageHattieOn2 : imageHattieOn1
            NSAnimationContext.endGrouping()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (animDuration * 2)) { [unowned self] in
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = self.animDuration
            self.whilomStatusItem.button?.image = forwards ? imageHattieOn3 : imageHattieOff
            NSAnimationContext.endGrouping()
        }
      
//        let crossFade1 = CABasicAnimation(keyPath: "image")
//        crossFade1.duration = duration
//        crossFade1.fromValue = whilomStatusItem.button?.image
//        crossFade1.toValue = hattieOn1
//
//        let crossFade2 = CABasicAnimation(keyPath: "image")
//        crossFade2.duration = duration
//        crossFade2.fromValue = hattieOn1
//        crossFade2.toValue = hattieOn2
//
//        let crossFade3 = CABasicAnimation(keyPath: "image")
//        crossFade3.duration = duration
//        crossFade3.fromValue = hattieOn2
//        crossFade3.toValue = hattieOn3
//
//
//
//        whilomStatusItem.button?.layer?.add(crossFade1, forKey: "stepOne")


    }
  
    private func performEnableSleepAnimation() {
  //      let hattieOffImage = NSImage(named: NSImage.Name("hattie off"))
  //      hattieOffImage?.isTemplate = true
  //      statusItem.button?.imageScaling = .scaleProportionallyUpOrDown
  //      statusItem.button?.imageHugsTitle = true
  //  //        statusItem.button?.alternateImage =
  //      statusItem.button?.image = hattieOffImage

    }
}

extension AppDelegate: NSMenuDelegate, NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}

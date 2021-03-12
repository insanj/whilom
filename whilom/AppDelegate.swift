//
//  AppDelegate.swift
//  whilom
//
//  Created by Julian Weiss on 8/28/20, 3/11/21.
//  Copyright © 2021 Snowcode, LLC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: AuthorizedAppDelegate {
    // MARK: - properties
    // MARK: left click menu item
    let whilomStatusItem: NSStatusItem = {
        var statusItem = NSStatusItem()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        var hattieOffImage = NSImage(named: NSImage.Name("hattie off"))!
        hattieOffImage.isTemplate = false
              
        if AppDelegate.isDarkMode(statusItem) {
            hattieOffImage = imageWithInverseColor(hattieOffImage)
        }
      
//        statusItem.button?.alternateImage = hattieOffImage
        statusItem.button?.imageScaling = .scaleProportionallyUpOrDown
        statusItem.button?.imageHugsTitle = true
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
  
    let aboutMenuItem: NSMenuItem = {
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "About"
        return quitMenuItem
    }()

    let quitMenuItem: NSMenuItem = {
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        return quitMenuItem
    }()
  
    // MARK: scripts, states
    var isSleepEnabled = true
    private var isJustMessingAround = false
  
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
    let animDuration: CFTimeInterval = 0.125
    var imageHattieOff: NSImage?
    var imageHattieOn1: NSImage?
    var imageHattieOn2: NSImage?
    var imageHattieOn3: NSImage?
  
    // MARK: - runtime
    override func applicationDidFinishLaunching(_ aNotification: Notification) {
          whilomStatusItem.button?.action = #selector(whilomClicked(_:))
          whilomStatusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
      
          whilomStatusItem.button?.addObserver(self, forKeyPath: "effectiveAppearance", options: .new, context: nil)
          themeifyMenuItems()
      
          setupRightClickMenu()
    }

    override func applicationWillTerminate(_ aNotification: Notification) {
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
  private func setupRightClickMenu() {
        titleMenuItem.isEnabled = false
        menu.addItem(titleMenuItem)
        menu.delegate = self

        menu.addItem(NSMenuItem.separator())

        aboutMenuItem.action = #selector(aboutWhilom(_:))
        aboutMenuItem.target = self
        menu.addItem(aboutMenuItem)
      
        quitMenuItem.action = #selector(quitWhilom(_:))
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
    }
  
    private func createWhilomMenu() {
        whilomStatusItem.menu = menu
        let point = NSApp.currentEvent?.window?.frame.origin ?? .zero
        menu.popUp(positioning: titleMenuItem, at: point, in: nil)
    }
  
    private func destroyWhilomMenu() {
        whilomStatusItem.menu = nil
    }
  
    @objc func aboutWhilom(_ sender: Any) {
        let aboutAlert = NSAlert()
        aboutAlert.icon = NSImage(named: NSImage.Name("whilom"))
        aboutAlert.messageText = "whilom"
        aboutAlert.informativeText = "🪄 keep your mac awake even when the lid is closed\n\n💭 whi·lom, meaning \"at times,\" having once been\n\n🎉 thanks for checking out our app! follow us @SnowcodeDesign\n\n© 2021 Snowcode, LLC"
        aboutAlert.addButton(withTitle: "👋 Sweet dreams!")
        aboutAlert.runModal()
    }
  
    @objc func quitWhilom(_ sender: Any) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
    
    // MARK: - left click handler
    func toggleSleep() {
        if isSleepEnabled {
            let _ = disableSleep()
        } else {
            let _ = enableSleep()
        }
    }
    
    // MARK: execute scripts based on state
    @objc func disableSleep() -> Bool {
        if !isJustMessingAround {
//            var error: NSDictionary?
//            disableSleepScript?.executeAndReturnError(&error)
//
//            if let error = error {
//                let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
//                alert.runModal()
//                return false
//            }
          
//          let command = "sudo pmset -a disablesleep 1"
//          Authorize.runCommand(asRoot: command)
        }
      
        performSleepAnimation(forwards: true)
        isSleepEnabled = false
        return true
    }
    
    @objc func enableSleep() -> Bool {
        if !isJustMessingAround {
//            var error: NSDictionary?
//            enableSleepScript?.executeAndReturnError(&error)
//
//            if let error = error {
//                let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
//                alert.runModal()
//                return false
//            }UTF
          
//            let command = "sudo pmset -a disablesleep 0"
//            Authorize.runCommand(asRoot: command)
        }

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
    }
  
    // MARK: - image handling
    static private func imageWithInverseColor(_ image: NSImage) -> NSImage {
        let inverted = image.inverted()
        return inverted
    }
  
    // MARK: - dark/light handling
    static private func isDarkMode(_ statusItem: NSStatusItem) -> Bool {
        let effectiveAppearance = statusItem.button?.effectiveAppearance
        let themeName = effectiveAppearance?.name.rawValue.lowercased()
        let containsDark = themeName?.contains("dark")
        return containsDark ?? false
    }
  
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        themeifyMenuItems()
    }
  
    private func themeifyMenuItems() {
        var baseImage = isSleepEnabled ? NSImage(named: NSImage.Name("hattie off"))! : NSImage(named: NSImage.Name("hattie on 3"))!
        var baseHattieOffImage = NSImage(named: NSImage.Name("hattie off"))!
        var baseHattieOne1Image = NSImage(named: NSImage.Name("hattie on 1"))!
        var baseHattieOne2Image = NSImage(named: NSImage.Name("hattie on 2"))!
        var baseHattieOne3Image = NSImage(named: NSImage.Name("hattie on 3"))!

        if AppDelegate.isDarkMode(whilomStatusItem) {
            baseImage = AppDelegate.imageWithInverseColor(baseImage)
            baseHattieOffImage = AppDelegate.imageWithInverseColor(baseHattieOffImage)
            baseHattieOne1Image =  AppDelegate.imageWithInverseColor(baseHattieOne1Image)
            baseHattieOne2Image =  AppDelegate.imageWithInverseColor(baseHattieOne2Image)
            baseHattieOne3Image =  AppDelegate.imageWithInverseColor(baseHattieOne3Image)
        }
      
        whilomStatusItem.button?.image = baseImage
        imageHattieOff = baseHattieOffImage
        imageHattieOn1 = baseHattieOne1Image
        imageHattieOn2 = baseHattieOne2Image
        imageHattieOn3 = baseHattieOne3Image
    }
}


extension AppDelegate: NSMenuDelegate, NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
  
    func menuDidClose(_ menu: NSMenu) {
        destroyWhilomMenu()
    }
}

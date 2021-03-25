//
//  AppDelegate.swift
//  whilom
//
//  Created by Julian Weiss on 8/28/20, 3/11/21.
//  Copyright © 2021 Snowcode, LLC. All rights reserved.
//

import Cocoa
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - properties
    // MARK: state
    private var rememberedPassword: String?
    private var hasShownRememberPasswordAlert: Bool = false
    
    // MARK: modals that need to be referenced twice
    private var passwordRememberAlert: NSAlert?

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
  
    private static var titleMenuItemString: String {
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let emoji = String.randomEmoji ?? "💝"
        let string = "\(emoji) whilom \(versionString)"
        return string
    }

    let titleMenuItem: NSMenuItem = {
        return NSMenuItem(title: AppDelegate.titleMenuItemString, action: nil, keyEquivalent: "")
    }()
  
    let aboutMenuItem: NSMenuItem = {
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "👋 About"
        return quitMenuItem
    }()
    
    let launchAtLoginItem: NSMenuItem = {
        let startItem = NSMenuItem()
        startItem.title = AppDelegate.launchAtLoginTitle
        return startItem
    }()
  
    let changePasswordItem: NSMenuItem = {
        let startItem = NSMenuItem()
        startItem.title = "🔐 Change password"
        return startItem
    }()
    
    private static var launchAtLoginTitle: String {
        return "\(LaunchAtLogin.isEnabled ? "👍" : "👎") Start at login"
    }

    let quitMenuItem: NSMenuItem = {
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        return quitMenuItem
    }()
  
    // MARK: scripts, states
    var isSleepEnabled = true
    private var isJustMessingAround = false
  
    private func buildEnableSleepScript(_ password: String?=nil) -> NSAppleScript? {
        var appendString: String = ""
        if let pass = password {
            appendString = " user name \"\(NSUserName())\" password \"\(pass)\""
        }
        
        /**
         # enable sleep script
         # step one, kill existing noidle screen session
         # step two, pmset enable sleep to allow computer to sleep
         # step three, restore display and computer sleep energy prefs
         # step four, restore screensaver time in prefs
         */
        let regex = #"^\\s*[0-9]+.whilom"#
        let myAppleScript = """
        do shell script "screen -ls | egrep '\(regex)' | awk -F '.' '{print $1}' | xargs kill"

        do shell script "sudo pmset -a disablesleep 0"\(appendString) with administrator privileges

        do shell script "defaults -currentHost write com.apple.screensaver idleTime `defaults -currentHost read com.insanj.whilom idleTime`"

        do shell script "defaults -currentHost write com.apple.screensaver idleTime 0"
        """
        
        /*
         
         do shell script "sudo systemsetup -setcomputersleep `defaults -currentHost read com.insanj.whilom computerSleep`"\(appendString) with administrator privileges
         do shell script "sudo systemsetup -setdisplaysleep `defaults -currentHost read com.insanj.whilom displaySleep`"\(appendString) with administrator privileges

         */
        
        guard let scriptObject = NSAppleScript(source: myAppleScript) else {
            return nil
        }
        
        return scriptObject
    }
  
    private func buildDisableSleepScript(_ password: String?=nil) -> NSAppleScript? {
        var appendString: String = ""
        if let pass = password {
            appendString = " user name \"\(NSUserName())\" password \"\(pass)\""
        }
        
        /**
         # disable sleep script
         # step one, run a detached screen session with pmset prevent idle, one of the most powerful commands
         # step two, pmset disable sleep to prevent computer from completely sleeping
         # step three, override display and computer sleep energy prefs, but first we must save them
         # step four, override screensaver time in prefs, but we must check if null ifrst
         */
        let myAppleScript = """
        do shell script "screen -S whilom -d -m caffeinate -u"

        do shell script "sudo pmset -a disablesleep 1"\(appendString) with administrator privileges

        do shell script "
                if defaults -currentHost read com.apple.screensaver idleTime; then
                    defaults -currentHost write com.insanj.whilom idleTime `defaults -currentHost read com.apple.screensaver idleTime`
                    echo 'Saved custom screensaver time to com.insanj.whilom idleTime default'
                else
                    defaults -currentHost write com.insanj.whilom idleTime 1200
                    echo 'Saved default screensaver time to com.insanj.whilom idleTime default'
                fi
        "
        
        do shell script "defaults -currentHost write com.apple.screensaver idleTime 0"
        """
        
        /*
         
         do shell script "defaults -currentHost write com.insanj.whilom computerSleep `sudo systemsetup -getcomputersleep | cut -d ':' -f 2`"\(appendString) with administrator privileges
         do shell script "sudo systemsetup -setcomputersleep Never"\(appendString) with administrator privileges

         do shell script "defaults -currentHost write com.insanj.whilom displaySleep `sudo systemsetup -getdisplaysleep | cut -d ':' -f 2`"\(appendString) with administrator privileges
         do shell script "sudo systemsetup -setdisplaysleep Never"\(appendString) with administrator privileges
         
         */
        
        guard let scriptObject = NSAppleScript(source: myAppleScript) else {
            return nil
        }
        
        return scriptObject
    }
  
    // MARK: - anim props
    let animDuration: CFTimeInterval = 0.125
    var imageHattieOff: NSImage?
    var imageHattieOn1: NSImage?
    var imageHattieOn2: NSImage?
    var imageHattieOn3: NSImage?
  
    // MARK: - runtime
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        whilomStatusItem.button?.action = #selector(whilomClicked(_:))
        whilomStatusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
      
        whilomStatusItem.button?.addObserver(self, forKeyPath: "effectiveAppearance", options: .new, context: nil)
        themeifyMenuItems()
      
        setupRightClickMenu()
        
        guard let _ = WhilomKeychain.getSavedPassword() else {
            showPasswordRememberAlert()
            return
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
          // bye bye!
    }
    
    // MARK: - left or right click handler
    @objc private func whilomClicked(_ sender: NSStatusBarButton)  {
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
      
        changePasswordItem.action = #selector(changePasswordWhilom(_:))
        changePasswordItem.target = self
        menu.addItem(changePasswordItem)
      
        launchAtLoginItem.action = #selector(launchAtLoginWhilom(_:))
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())

        quitMenuItem.action = #selector(quitWhilom(_:))
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
    }
  
    private func createWhilomMenu() {
        titleMenuItem.title = AppDelegate.titleMenuItemString
        whilomStatusItem.menu = menu
        let frame = NSApp.currentEvent?.window?.frame ?? .zero
        let point = frame.origin
        let bottomPoint = CGPoint(x: point.x, y: point.y - 6)
        menu.popUp(positioning: titleMenuItem, at: bottomPoint, in: nil)
    }
  
    private func destroyWhilomMenu() {
        whilomStatusItem.menu = nil
    }
  
    @objc func aboutWhilom(_ sender: Any) {
        let aboutAlert = NSAlert()
        aboutAlert.icon = NSImage(named: NSImage.Name("whilom"))
        aboutAlert.messageText = "whilom\(isJustMessingAround == true ? " just messin' around mode" : "")"
        
        var emojiString = ""
        if #available(OSX 11.2.3, *) {
            emojiString = "🪄 "
        }
        
        aboutAlert.informativeText = "\(emojiString)keep your mac awake even when the lid is closed\n\n💭 whi·lom, meaning \"at times,\" having once been\n\n🎉 thanks for checking out our app! follow us @SnowcodeDesign\n\n© 2021 Snowcode, LLC"
        aboutAlert.addButton(withTitle: "👋 Sweet dreams!")
        aboutAlert.runModal()
    }
  
    @objc func launchAtLoginWhilom(_ sender: Any) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        launchAtLoginItem.title = AppDelegate.launchAtLoginTitle
    }
    
    @objc func changePasswordWhilom(_ sender: Any) {
        showPasswordRememberAlert()
    }
    
    @objc func quitWhilom(_ sender: Any) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
    
    // MARK: - left click handler
    func toggleSleep() {
        guard let _ = WhilomKeychain.getSavedPassword() else {
            showPasswordRememberAlert { [unowned self] in
                toggleSleep()
            }
            return
        }
        
        if isSleepEnabled {
            let _ = disableSleep()
        } else {
            let _ = enableSleep()
        }
    }
    
    // MARK: execute scripts based on state
    @objc func disableSleep() -> Bool {
        if !isJustMessingAround {
            var error: NSDictionary?
            
            let password = WhilomKeychain.getSavedPassword()
            let disableSleepScript = buildDisableSleepScript(password)
            disableSleepScript?.executeAndReturnError(&error)

            if let error = error {
                let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
                alert.runModal()
                return false
            }
        }
      
        performSleepAnimation(forwards: true)
        isSleepEnabled = false
        return true
    }
    
    @objc func enableSleep() -> Bool {
        if !isJustMessingAround {
            var error: NSDictionary?
            
            let password = WhilomKeychain.getSavedPassword()
            let enableSleepScript = buildEnableSleepScript(password)
            enableSleepScript?.executeAndReturnError(&error)

            if let error = error {
                let alert = NSAlert(error: NSError(domain: "com.insanj.whilom", code: 0, userInfo: [NSLocalizedDescriptionKey: error["NSAppleScriptErrorMessage"]!]))
                alert.runModal()
                return false
            }
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
    
    // MARK: - perhaps temporary auth
    private var pendingShowPasswordCompletionBlock: (() -> (Void))?
    private func showPasswordRememberAlert(_ completion: (() -> (Void))? = nil) {
        let alert = NSAlert()
        passwordRememberAlert = alert
        
        alert.icon = NSImage(named: NSImage.Name("whilom"))
        alert.messageText = "Do you want us to remember your password for this session?"
        alert.informativeText = "Otherwise, we'll ask when you try to use whilom."
        
        let passwordTextField = NSSecureTextField(string: "")
        passwordTextField.placeholderString = "\(NSUserName())'s local computer password"
        passwordTextField.frame = CGRect(x: 0, y: 0, width: 240, height: 32)
        passwordTextField.maximumNumberOfLines = 1
        passwordTextField.delegate = self
        
        alert.accessoryView = passwordTextField
        alert.showsHelp = true
        alert.addButton(withTitle: "🔐 Remember")
        alert.buttons.first?.target = self
        alert.buttons.first?.action = #selector(rememberPasswordConfirmClicked(_:))

        alert.addButton(withTitle: "🤫 Ask Me Later")
        
        alert.delegate = self
        alert.runModal()
        
        pendingShowPasswordCompletionBlock = completion
    }
    
    @objc func rememberPasswordConfirmClicked(_ sender: NSButton) {
        passwordRememberAlert?.buttons.last?.performClick(sender)
        
        guard let password = rememberedPassword else {
            
            let problem = NSAlert()
            problem.icon = NSImage(named: NSImage.Name("whilom"))
            problem.messageText = "Did You Forget to Type Something In?"
            problem.informativeText = "Please try again, if you wanna. Have a wonderful day!"
            problem.runModal()
            
            return
        }
      
        let result = WhilomKeychain.saveCurrentPassword(password)
        
        guard result == true else {
            
            let problem = NSAlert()
            problem.icon = NSImage(named: NSImage.Name("whilom"))
            problem.messageText = "Unable to Save"
            problem.informativeText = "Uh-oh, we had a problem trying to securely save your information. Please try again or check if you're running on the latest version of whilom. Have a great day!"
            problem.runModal()
            
            return
        }
      
//        enableSleepScript = buildEnableSleepScript(rememberedPassword)
//        disableSleepScript = buildDisableSleepScript(rememberedPassword)
        rememberedPassword = nil
        
        pendingShowPasswordCompletionBlock?()
    }
}

extension AppDelegate: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let editorValue = obj.userInfo?["NSFieldEditor"] as? NSTextView else {
            return
        }
        
        rememberedPassword = editorValue.string
    }
}

extension AppDelegate: NSAlertDelegate {
    func alertShowHelp(_ alert: NSAlert) -> Bool {
        let help = NSAlert()
        help.icon = NSImage(named: NSImage.Name("whilom"))
        help.messageText = "What is this?"
        help.informativeText = "whilom keeps your computer safe. stopping you mac from sleeping is a root-level command. we lock your secure information in your mac's keychain, which means we only need to ask for your password when opening for the first time or after changing your password.\n\nwant this experience to be improved? we're open source, and we're always open to suggestions, reach out @SnowcodeDesign ❤️"
        help.runModal()
        
        return true
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

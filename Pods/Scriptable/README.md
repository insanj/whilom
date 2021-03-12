# Scriptable

[![CI Status](https://img.shields.io/travis/cs4alhaider/Scriptable.svg?style=flat)](https://travis-ci.org/cs4alhaider/Scriptable)
[![Version](https://img.shields.io/cocoapods/v/Scriptable.svg?style=flat)](https://cocoapods.org/pods/Scriptable)
[![License](https://img.shields.io/cocoapods/l/Scriptable.svg?style=flat)](https://cocoapods.org/pods/Scriptable)
[![Platform](https://img.shields.io/cocoapods/p/Scriptable.svg?style=flat)](https://cocoapods.org/pods/Scriptable)

Scriptable will allow you to run and automate your daily basis Terminal tasks through a macOS app.


## Scriptable protocol
```swift
public protocol Scriptable {
    
    typealias ScriptResponce = (command: String, errorOutput: String?, dataOutput: String)
    
    /// The command you want to execute through your terminal
    ///
    /// Keep in mind if you pass any aurgument with a space like:
    /// `open -a Some Application`
    /// you will need to remove the spaces between the app name "Some Application"
    var command: String { get }
    
    /// Run the task throue the terminal
    ///
    /// - Returns: The output string for (command: String, errorOutput: String?, dataOutput: String)
    @discardableResult func runTask(launchPath: String) -> ScriptResponce
}
```
## Simple Example
```swift
enum MySimpleCommands: Scriptable {
    
    case openDesktop
    
    var command: String {
        switch self {
        case .openDesktop:
            return "cd ~ && cd Desktop/ && open ."
        }
    }
}

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MySimpleCommands.openDesktop.runTask() // This will open your desktop folder
    }
}
```

## Scriptable Task
Scriptable provide a bunch of ready made tasks like: Network tasks, App tasks, Directory tasks and also you can run your random task through Custom task

### Here is an example on how to get it:
Make sure you import Scriptable 
```swift
import Scriptable
```

And inside any method you can say:
```swift
Task.Network.getSecureWebProxyInfo.runTask()
```

Note that `runTask()`  marked as `@discardableResult` so it's actually returns some values like:
- `command: String`
- `errorOutput: String?`
- `dataOutput: String`

You also can get access to those values to display them if you want to build a small Terminal app or for debugging purpose: 
``` swift
Task.Network.getSecureWebProxyInfo.runTask().dataOutput
```

## Example

There is an example project thats allows you to turn on/off the proxy, simpl clone the repo, and run `pod install` from the Example directory first.

## Requirements
Make sure to disable App Sandbox in your Cocoa Application (found under your Project app target > Capabilities tab > App Sandbox switch). If you didn't disable it you'll find that you're being blocked by a sandbox exception. 

## Installation

Scriptable is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Scriptable'
```

## Author

cs4alhaider, cs.alhaider@gmail.com

## License

Scriptable is available under the MIT license. See the LICENSE file for more info.

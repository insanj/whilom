//
//  Scriptable.swift
//  Pods-Scriptable_Example
//
//  Created by Abdullah Alhaider on 13/07/2019.
//

import Foundation

public protocol Scriptable {
    
    typealias ScriptResponce = (command: String, errorOutput: String?, dataOutput: String)
    
    /// The command you want to execute through your terminal
    ///
    /// Keep in mind if you pass any aurgument with a space like:
    /// `open -a Some Application`
    /// you will need to remove the spaces between the app name "Some Application"
    ///
    /// - Author: Abdullah Alhaider
    var command: String { get }
    
    /// Run the task throue the terminal
    ///
    /// - Returns: The output string for (command: String, errorOutput: String?, dataOutput: String)
    ///
    /// - Author: Abdullah Alhaider
    @discardableResult func runTask(launchPath: String) -> ScriptResponce
}

public extension Scriptable {
    
    @discardableResult
    func runTask(launchPath: String = "/bin/bash") -> ScriptResponce {
        
        // Creating a Pipe and make the task, putting all the output there
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        // Getting the output data from output pipe
        let data = outputPipe.fileHandleForReading
        // Getting the error data from error pipe
        let errorData = errorPipe.fileHandleForReading
        
        // Creating a Task instance
        let task = Process()
        
        // Setting the task parameters
        task.launchPath = launchPath
        task.arguments = ["-c", String(format:"%@", command)]
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.environment = ProcessInfo.processInfo.environment
        
        // Launching the task
        task.launch()
        task.waitUntilExit()
        
        let dataOutput = stringFromFile(file: data) ?? ""
        let errorOutput = stringFromFile(file: errorData)
        
        return (command, errorOutput, dataOutput)
    }
    
    private func stringFromFile(file: FileHandle) -> String? {
        let data = file.readDataToEndOfFile()
        file.closeFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
        return output
    }
}

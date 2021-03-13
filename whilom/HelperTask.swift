//
//  Helper.swift
//  MyApplication
//
//  Created by Erik Berglund on 2016-12-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

import Foundation

@objc(HelperProtocol)
protocol HelperProtocol {
    func startConfirmedProxy(reply: @escaping (NSNumber) -> Void)
}
    
class HelperTask {
    
    
    func runTask(command: String, arguments: Array<String>, reply:@escaping ((NSNumber) -> Void)) -> Void
       {
           let task:Process = Process()
           let stdOut:Pipe = Pipe()
           
           let stdOutHandler =  { (file: FileHandle!) -> Void in
               let data = file.availableData
               guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
//               if let remoteObject = self.connection().remoteObjectProxy as? ProcessProtocol {
//                   //remoteObject.log(stdOut: output as String)
//               }
           }
           stdOut.fileHandleForReading.readabilityHandler = stdOutHandler
           
           let stdErr:Pipe = Pipe()
           let stdErrHandler =  { (file: FileHandle!) -> Void in
               let data = file.availableData
               guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
//               if let remoteObject = self.connection().remoteObjectProxy as? ProcessProtocol {
//                   //remoteObject.log(stdErr: output as String)
//               }
           }
           stdErr.fileHandleForReading.readabilityHandler = stdErrHandler
           
           task.launchPath = command
           task.arguments = arguments
           task.standardOutput = stdOut
           task.standardError = stdErr
           
           task.terminationHandler = { task in
               reply(NSNumber(value: task.terminationStatus))
           }
           
           task.launch()
       }
}

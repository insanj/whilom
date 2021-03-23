//
//  NSImage+Extension.swift
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//
//  https://stackoverflow.com/questions/2137744/draw-standard-nsimage-inverted-white-instead-of-black
//

import os
import AppKit
import Foundation

public extension NSImage {
    func inverted() -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            os_log(.error, "Could not create CGImage from NSImage")
            return self
        }

        let ciImage = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else {
            os_log(.error, "Could not create CIColorInvert filter")
            return self
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else {
            os_log(.error, "Could not obtain output CIImage from filter")
            return self
        }

        guard let outputCgImage = outputImage.toCGImage() else {
            os_log(.error, "Could not create CGImage from CIImage")
            return self
        }

        return NSImage(cgImage: outputCgImage, size: self.size)
    }
}

fileprivate extension CIImage {
    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
}

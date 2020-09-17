// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CoreGraphics
import Foundation
import UIKit

extension UIImage {
    // Get pixel data of image at the given size
    func pixelData(size: CGSize) -> Data? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        guard let image: CGImage = self.cgImage else { return nil }
        guard let context = CGContext(
          data: nil,
          width: width, height: height,
          bitsPerComponent: 8, bytesPerRow: width * 4,
          space: CGColorSpaceCreateDeviceRGB(),
          bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
          return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let imageData = context.data else { return nil }
        
        var inputData = Data()
        var totalSum = 0
        do {
            for row in 0 ..< height {
                for col in 0 ..< width {
                    let offset = 4 * (row * width + col)
                    // (Ignore offset 0, the unused alpha channel)
                    var red = imageData.load(fromByteOffset: offset+1, as: UInt8.self)
                    var green = imageData.load(fromByteOffset: offset+2, as: UInt8.self)
                    var blue = imageData.load(fromByteOffset: offset+3, as: UInt8.self)
                    
                    totalSum += Int(red)
                    totalSum += Int(green)
                    totalSum += Int(blue)
                    
                    // Append normalized values to Data object in RGB order.
                    let elementSize = MemoryLayout.size(ofValue: red)
                    var bytes = [UInt8](repeating: 0, count: elementSize)
                    memcpy(&bytes, &red, elementSize)
                    inputData.append(&bytes, count: elementSize)
                    memcpy(&bytes, &green, elementSize)
                    inputData.append(&bytes, count: elementSize)
                    memcpy(&bytes, &blue, elementSize)
                    inputData.append(&bytes, count: elementSize)
                }
            }
        
            return inputData
        } catch let error {
            print("Failed to add input: \(error)")
            return nil
        }
    }
}

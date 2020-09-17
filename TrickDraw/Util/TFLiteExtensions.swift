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

// MARK: - UIImage
extension UIImage {
    
    /// Returns the data representation of the image after scaling to the given `size` and converting
    /// to grayscale.
    ///
    /// - Parameters
    ///   - size: Size to scale the image to (i.e. image size used while training the model).
    /// - Returns: The scaled image as data or `nil` if the image could not be scaled.
    public func scaledData(with size: CGSize, isModelQuantized: Bool) -> Data? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &pixelBuffer)
        
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        // Create CGImage
        guard let cgImage = self.cgImage, cgImage.width > 0, cgImage.height > 0 else { return nil }
        
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        let width = Int(size.width)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let numberOfComponents = colorSpace.numberOfComponents + 1
        let bitsPerComponent = 8;
        let bytesPerPixel = (bitsPerComponent * numberOfComponents) / 8;
        let bytesPerRow = bytesPerPixel * width;
        
        guard let context = CGContext(
                data: pixelData,
                width: width,
                height: Int(size.height),
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue)
        else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        let sourcePixelFormat = CVPixelBufferGetPixelFormatType(buffer)
        assert(sourcePixelFormat == kCVPixelFormatType_32ARGB ||
                sourcePixelFormat == kCVPixelFormatType_32BGRA ||
                sourcePixelFormat == kCVPixelFormatType_32RGBA)
        
        
        let inputChannels = 4
        
        // Remove the alpha component from the image buffer to get the RGB data.
        guard let rgbData = ImageHelper.rgbDataFromBuffer(
            buffer,
            byteCount: Int(size.width * size.height) * inputChannels,
            isModelQuantized: isModelQuantized
        ) else {
            print("Failed to convert the image buffer to RGB data.")
            return nil
        }
        
        return rgbData
    }
    
}

// MARK: - Data
extension Data {
    /// Creates a new buffer by copying the buffer pointer of the given array.
    ///
    /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
    ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
    ///     data from the resulting buffer has undefined behavior.
    /// - Parameter array: An array with elements of type `T`.
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer(Data.init)
    }
    
    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

// MARK: - Constants
private enum Constant {
    static let maxRGBValue: Float32 = 255.0
}

extension UIImage {
    func pixelData() -> Data? {
        let width = 224
        let height = 224

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
        do {
            for row in 0 ..< height {
                for col in 0 ..< width {
                    let offset = 4 * (col * width + row)
                    // (Ignore offset 0, the unused alpha channel)
                    var red = imageData.load(fromByteOffset: offset+1, as: UInt8.self)
                    var green = imageData.load(fromByteOffset: offset+2, as: UInt8.self)
                    var blue = imageData.load(fromByteOffset: offset+3, as: UInt8.self)
                    
//                    // Normalize channel values to [0.0, 1.0]. This requirement varies
//                    // by model. For example, some models might require values to be
//                    // normalized to the range [-1.0, 1.0] instead, and others might
//                    // require fixed-point values or the original bytes.
//                    var normalizedRed = Float32(red) / 255.0
//                    var normalizedGreen = Float32(green) / 255.0
//                    var normalizedBlue = Float32(blue) / 255.0
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
    
    func pixelValues() -> [UInt8]?
    {
        let imageRef = self.cgImage
        let width = 224
        let height = 224
        var pixelValues: [UInt8]?
        
        if let imageRef = imageRef {
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = 224 * 1
            let totalBytes = height * bytesPerRow
            let bitmapInfo = CGBitmapInfo(
                rawValue: CGImageAlphaInfo.none.rawValue
            )
            
            //            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpace,
                                       bitmapInfo: bitmapInfo.rawValue)
            
            let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height))
            
            // Draw a black background
            contextRef?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
            contextRef?.fill(CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            // Draw the image in white
            //            contextRef?.clip(to: rect, mask: imageRef)
            //            contextRef?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
            //            contextRef?.fill(rect)
            //                CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
            
            contextRef?.draw(imageRef, in: rect)
            
            let outputImage = contextRef?.makeImage()
            //            guard let scaledBytes = outputImage?.dataProvider?.data as Data? else { return nil }
            //
            //            let array = scaledBytes.withUnsafeBytes {
            //                [UInt8](UnsafeBufferPointer(start: $0, count: scaledBytes.count))
            //            }
            
            //            intensities = intensities.map { $0 > 0 ? 255 : 0 }
            //            intensities = (3-1).stride(to: intensities.count, by: 3).flatMap { intensities[($0-3+1)..<$0] }
            //            var sum: Int = 0
            //
            //            var sum = 0
            //
            //            for number in intensities {
            //                sum += Int(number)
            //            }
            //
            pixelValues = intensities + intensities + intensities
            var counter = [UInt8: Int]()
            //            let asdf = intensities.map({ $0 > 0 ? UInt8(255) : UInt8(0) })
            for (index, number) in intensities.enumerated() {
                //                if (number != 0) {
                //                    print("[\(index)] = \(number)")
                //                }
                
                counter[number] = counter[number, default: 0] + 1
                
                //                pixelValues?.append(number)
                //                pixelValues?.append(number)
                //                pixelValues?.append(number)
            }
            
            print(counter.sorted { $0.key < $1.key })
            
            let sum = pixelValues?.reduce(0) { Int($0) + Int($1) }
            print(sum)
            //
            //
            
            //            pixelValues = intensities
            ////                .map { $0 > 0 ? 255 : 0 }
            //                .enumerated()
            //                .compactMap {
            //                    if $0.element != 0 {
            //                        print($0.offset % 4)
            //                    }
            
            //                    return $0.offset % 4 == 3 ? nil : $0.element
            ////
            //                    let new = $0.offset % 4 == 3 ? $0.element : $0.element
            //
            ////                    if (new != nil && new! > 0) {
            ////                        print(new)
            ////
            //                    }
            //
            //                    return new
            //
            //            } // Remove every four value (alpha)
        }
        
        //        var sum = 0
        //
        //        for number in pixelValues! {
        //            sum += Int(number)
        //        }
        
        return pixelValues
    }
}

func pixelValuesFromImage(imageRef: CGImage) -> ([UInt8], width: Int, height: Int)
{
    var width = 0
    var height = 0
    var pixelValues: [UInt8]
    
    width = imageRef.width
    height = imageRef.height
    let bitsPerComponent = imageRef.bitsPerComponent
    let bytesPerRow = imageRef.bytesPerRow
    let totalBytes = height * bytesPerRow
    
    let colorSpace = CGColorSpaceCreateDeviceGray()
    //        let colorSpace = CGColorSpaceCreateDeviceRGB()
    let buffer = [UInt8](repeating: 0, count: totalBytes)
    let mutablePointer = UnsafeMutablePointer<UInt8>(mutating: buffer)
    
    let contextRef = CGContext(data: mutablePointer,
                               width: width,
                               height: height,
                               bitsPerComponent: bitsPerComponent,
                               bytesPerRow: bytesPerRow,
                               space: colorSpace,
                               bitmapInfo: 0)
    
    contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
    
    let bufferPointer = UnsafeBufferPointer<UInt8>(start: mutablePointer, count: totalBytes)
    pixelValues = Array<UInt8>(bufferPointer)
    
    return (pixelValues, width, height)
}


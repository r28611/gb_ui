//
//  + UIImage.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 22.05.2021.
//

import UIKit

extension UIImage {
    /// There are two main ways to get the color from an image, just a simple "sum up an average" or by squaring their sums. Each has their advantages, but the 'simple' option *seems* better for average color of entire image and closely mirrors CoreImage. Details: https://sighack.com/post/averaging-rgb-colors-the-right-way
    enum AverageColorAlgorithm {
        case simple
        case squareRoot
    }
    
    func findAverageColor(algorithm: AverageColorAlgorithm = .simple) -> UIColor? {
        guard let cgImage = cgImage else { return nil }
        
        let size = CGSize(width: 40, height: 40)
        
        let width = Int(size.width)
        let height = Int(size.height)
        let totalPixels = width * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
 
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        guard let pixelBuffer = context.data else { return nil }
  
        let pointer = pixelBuffer.bindMemory(to: UInt32.self, capacity: width * height)

        var totalRed = 0
        var totalBlue = 0
        var totalGreen = 0
        
        for x in 0 ..< width {
            for y in 0 ..< height {

                let pixel = pointer[(y * width) + x]
                
                let r = red(for: pixel)
                let g = green(for: pixel)
                let b = blue(for: pixel)

                switch algorithm {
                case .simple:
                    totalRed += Int(r)
                    totalBlue += Int(b)
                    totalGreen += Int(g)
                case .squareRoot:
                    totalRed += Int(pow(CGFloat(r), CGFloat(2)))
                    totalGreen += Int(pow(CGFloat(g), CGFloat(2)))
                    totalBlue += Int(pow(CGFloat(b), CGFloat(2)))
                }
            }
        }
        
        let averageRed: CGFloat
        let averageGreen: CGFloat
        let averageBlue: CGFloat
        
        switch algorithm {
        case .simple:
            averageRed = CGFloat(totalRed) / CGFloat(totalPixels)
            averageGreen = CGFloat(totalGreen) / CGFloat(totalPixels)
            averageBlue = CGFloat(totalBlue) / CGFloat(totalPixels)
        case .squareRoot:
            averageRed = sqrt(CGFloat(totalRed) / CGFloat(totalPixels))
            averageGreen = sqrt(CGFloat(totalGreen) / CGFloat(totalPixels))
            averageBlue = sqrt(CGFloat(totalBlue) / CGFloat(totalPixels))
        }
  
        return UIColor(red: averageRed / 255.0, green: averageGreen / 255.0, blue: averageBlue / 255.0, alpha: 1.0)
    }
    
    private func red(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 16) & 255)
    }

    private func green(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 8) & 255)
    }

    private func blue(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 0) & 255)
    }
}


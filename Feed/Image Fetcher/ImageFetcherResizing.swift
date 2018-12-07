//
//  ImageFetcherResizing.swift
//  Feed
//
//  Created by Jason Howlin on 6/6/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import AVFoundation

extension CGSize {
    var isLandscape:Bool {
        return width >= height
    }
    
    var isPortrait:Bool {
        return height >= width
    }
    
    var aspectRatio:CGFloat {
        return ((self.width / self.height) * 100).rounded() / 100
    }
    
    public var scaledForScreen:CGSize {
        return scaled(scaleFactor: UIScreen.main.scale)
    }

    func scaled(scaleFactor:CGFloat) -> CGSize {
        return CGSize(width: self.width * scaleFactor, height: self.height * scaleFactor)
    }
}

typealias Decompressor = (UIImage) -> (UIImage)

let imageFetcherSimpleDecompressor: Decompressor = { image in
    let size = image.size
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    image.draw(at: CGPoint.zero)
    let decompressed = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return decompressed ?? image
}

func resizeImageByScalingAndCropping(imageData:Data, sourceSize:CGSize, targetSize:CGSize) -> UIImage? {
    
    var resized:UIImage? = nil
    
    guard let image = UIImage(data: imageData) else { return resized }
    
    let cropRect = AVMakeRect(aspectRatio: targetSize, insideRect: CGRect(x: 0, y: 0, width: sourceSize.width, height: sourceSize.height))
    let scale:CGFloat = targetSize.width / cropRect.width
    let scaledSize = sourceSize.applying(CGAffineTransform(scaleX: scale, y: scale))
    
    
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1.0
    let renderer = UIGraphicsImageRenderer(size: scaledSize, format: format)
    let decompressed = renderer.image { imageContext in
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
    }
    let r = CGRect(x: decompressed.size.width / 2 - targetSize.width / 2, y: decompressed.size.height / 2 - targetSize.height / 2, width: targetSize.width, height: targetSize.height)
    if let cgImage = decompressed.cgImage, let cropped = cgImage.cropping(to: r) {
        resized = UIImage(cgImage: cropped)
        
    }
    return resized
}

func resizeImageByCreatingThumbnail(imageData:Data, sourceSize:CGSize, targetSize:CGSize) -> UIImage? {
    var resized:UIImage? = nil
    let cropRect = AVMakeRect(aspectRatio: targetSize, insideRect: CGRect(x: 0, y: 0, width: sourceSize.width, height: sourceSize.height))
    let scale:CGFloat = targetSize.width / cropRect.width
    let maxSixe = sourceSize.applying(CGAffineTransform(scaleX: scale, y: scale))
    let maxPixels = max(maxSixe.width, maxSixe.height)
    let options: [String:Any] = [kCGImageSourceCreateThumbnailFromImageAlways as String:true, kCGImageSourceThumbnailMaxPixelSize as String:maxPixels, kCGImageSourceCreateThumbnailWithTransform as String:true, kCGImageSourceShouldCacheImmediately as String:true]
    let sourceOptions:[String:Any] = [kCGImageSourceShouldCache as String:false]
    
    if let source = CGImageSourceCreateWithData(imageData as CFData, sourceOptions as CFDictionary), let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
        let resizedImage = UIImage(cgImage:thumbnail)
        let r = CGRect(x: resizedImage.size.width / 2 - targetSize.width / 2, y: resizedImage.size.height / 2 - targetSize.height / 2, width: targetSize.width, height: targetSize.height)
        if let cgImage = resizedImage.cgImage, let cropped = cgImage.cropping(to: r) {
            resized = UIImage(cgImage: cropped)
        }
    }
    return resized
}

func decompressAndResize(imageData:Data, sourceSize:CGSize, targetSize:CGSize) -> UIImage? {
    
    if sourceSize.width > targetSize.width && sourceSize.height > targetSize.height {
        return resizeImageByCreatingThumbnail(imageData: imageData, sourceSize: sourceSize, targetSize: targetSize)
    } else {
        return resizeImageByScalingAndCropping(imageData: imageData, sourceSize: sourceSize, targetSize: targetSize)
    }
}


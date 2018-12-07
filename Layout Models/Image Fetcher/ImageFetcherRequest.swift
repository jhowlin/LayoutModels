//
//  ImageFetcherRequest.swift
//  Feed
//
//  Created by Jason Howlin on 6/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

public class ImageFetcherRequest:Codable, Hashable {
    
    public static func == (lhs: ImageFetcherRequest, rhs: ImageFetcherRequest) -> Bool {
        var isEqual = true
        if lhs.sizeMetrics != rhs.sizeMetrics {
            isEqual = false
        } else {
            isEqual = lhs.identifier == rhs.identifier
        }
        return isEqual
    }
    
    public let url:String
    public let identifier:String
    public let isLowPriority:Bool
    let performanceMetrics = ImageFetcherMetrics()
    public var sizeMetrics:ImageFetcherImageSizeMetrics?

    public init(url:String, identifier:String, isLowPriority:Bool = false, sizeMetrics:ImageFetcherImageSizeMetrics? = nil) {
        self.url = url
        self.identifier = identifier
        performanceMetrics.identifier = identifier
        self.isLowPriority = isLowPriority
        self.sizeMetrics = sizeMetrics
    }

    func printMetrics() {
        performanceMetrics.printMetrics()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
    
    var cacheKey:String {
        var key = identifier
        if let metrics = sizeMetrics {
            key.append("t\(metrics.targetSize)r\(metrics.sourceSize)")
        }
        return key
    }
    
    var diskCacheKey:String {
        var key = identifier
        if let metrics = sizeMetrics {
            key.append("r\(metrics.sourceSize)")
        }
        return key
    }
}

public enum ImageFetcherResult {
    case success(UIImage, ImageFetcherRequest)
    case error(ImageFetcherError, ImageFetcherRequest)

    var image:UIImage? {
        switch self {

        case let .success(img, _):
            return img
        case .error(_, _):
            return nil
        }
    }
}

enum ImageOperationResult {
    case success(UIImage, Data, ImageFetcherRequest)
    case error(ImageFetcherError, ImageFetcherRequest)
}

public enum ImageFetcherError: Error {
    case network
    case notFound
    case cancelled
    case corruptImage
}

public struct ImageFetcherImageSizeMetrics:Codable, Equatable, Hashable {
    public let targetSize:CGSize
    public let sourceSize:CGSize
    
    public init(targetSize:CGSize, sourceSize:CGSize) {
        self.targetSize = targetSize
        self.sourceSize = sourceSize
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine("t\(targetSize)r\(sourceSize)")
    }
}

struct CachedImage:Codable, Hashable, Equatable  {
    static func == (lhs: CachedImage, rhs: CachedImage) -> Bool {
        var isEqual = true
        if lhs.sizeMetrics != rhs.sizeMetrics {
            isEqual = false
        } else {
            isEqual = lhs.identifier == rhs.identifier
        }
        return isEqual
    }
    
    let identifier:String
    let path:String
    let dateFetched:Date
    var sizeMetrics:ImageFetcherImageSizeMetrics?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        if let metrics = sizeMetrics {
            hasher.combine("t\(metrics.targetSize)r\(metrics.sourceSize)")
        }
    }
}



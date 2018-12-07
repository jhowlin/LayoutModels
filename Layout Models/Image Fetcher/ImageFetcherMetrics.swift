//
//  ImageFetcherMetrics.swift
//  Feed
//
//  Created by Jason Howlin on 3/17/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation

class ImageFetcherMetrics:Codable {
    var absoluteStartTime:CFAbsoluteTime = 0
    var absoluteEndTime:CFAbsoluteTime = 0

    var downloadEnqueueTime:CFAbsoluteTime = 0
    var downloadStartTime:CFAbsoluteTime = 0
    var downloadEndTime:CFAbsoluteTime = 0

    var renderEnqueueTime:CFAbsoluteTime = 0
    var renderStartTime:CFAbsoluteTime = 0
    var renderEndTime:CFAbsoluteTime = 0

    var memoryCacheLookupStart:CFAbsoluteTime = 0
    var memoryCacheLookupEnd:CFAbsoluteTime = 0

    var diskCacheLookupStart:CFAbsoluteTime = 0
    var diskCacheLookupEnd:CFAbsoluteTime = 0

    var fulfillmentType:ImageFetcherRequestFulfillmentType?
    var workerType:ImageFetcherRequestWorkerType = .worker
    var identifier:String = "No ID"
    var bytes:Int = 0

    var totalTime:String {
        return "*** Total time:" + durationFrom(absoluteStartTime, end: absoluteEndTime)
    }

    var renderTotalTime:String {
        let renderStart = renderStartTime //renderEnqueueTime == 0 ? renderStartTime : renderEnqueueTime
        return "Render time:" + durationFrom(renderStart, end: renderEndTime)
    }

    var memoryCacheLookupTime:String {
        return "Memory cache lookup time:" + durationFrom(memoryCacheLookupStart, end: memoryCacheLookupEnd)
    }

    var diskCacheLookupTime:String {
        return "Disk cache lookup time:" + durationFrom(diskCacheLookupStart, end: diskCacheLookupEnd)
    }

    var downloadTime:String {
        return "Download time:" + durationFrom(downloadStartTime, end: downloadEndTime)
    }

    func durationFrom(_ start:CFAbsoluteTime, end:CFAbsoluteTime) -> String {
        let ms = (end - start) * 1000
        return "\(ms) ms"
    }

    func printMetrics() {
//        print("IFC: Metrics for \(identifier.prefix(4)):")
//        print("IFC: " + diskCacheLookupTime)
        print("IFC: " + downloadTime)
        print("IFC: " + renderTotalTime)
//        print("IFC: Bytes \(bytes)")
        print("IFC: " + totalTime)
    }
}

enum ImageFetcherRequestFulfillmentType:String, Codable, Hashable {
    case downloaded
    case memoryCache
    case diskCache
}

enum ImageFetcherRequestWorkerType:String, Codable {
    case worker
    case waiter
}


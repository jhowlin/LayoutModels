//
//  ImageFetcherController.swift
//  ImagesController
//
//  Created by Jason Howlin on 1/11/18.
//

import Foundation
import UIKit
import ImageIO

public struct ImageFetcherOptions {
    let imageCacheName:String
    let maxConcurrentFetches:Int
    let numberOfImagesBetweenCacheSaves:Int
    let requestCachePolicy:NSURLRequest.CachePolicy

    public static let defaultOptions = ImageFetcherOptions(imageCacheName: "com.imageFetcher.dict", maxConcurrentFetches: 6, numberOfImagesBetweenCacheSaves: 20, requestCachePolicy: .useProtocolCachePolicy)
}

final public class ImageFetcherController {

    let session: URLSession
    let inMemoryCache = NSCache<NSString,UIImage>()
    let imageFetchQueue = OperationQueue()
    let renderQueue = OperationQueue()
    let diskQueue = DispatchQueue(label: "com.imageFetcher.diskQueue", attributes: [])
    let isolationQueue = DispatchQueue(label: "com.imageFetcher.imageFetcherIsolationQueue", attributes: [])
    let imageCacheName: String
    var imageLookup = [String:CachedImage]()
    var observers: [String:[String:(ImageFetcherResult)->()]] = [:]
    var imagesAddedSinceLastLookupSave = 0
    let numberOfImagesBetweenCacheSaves:Int
    var fetchOperations: [String:Operation] = [:]
    var renderOperations: [String:Operation] = [:]
    let logMetrics = false
    let shouldLogStatus = false

    public static let shared = ImageFetcherController()

    lazy public var cachesURL:URL = {
        return self.createCachesURL()
    }()

    public init(options:ImageFetcherOptions = ImageFetcherOptions.defaultOptions) {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = options.requestCachePolicy
        self.session = URLSession(configuration: config)
        imageFetchQueue.maxConcurrentOperationCount = options.maxConcurrentFetches
        imageFetchQueue.name = "com.imageFetcher.imageFetchOperationQueue"
        renderQueue.maxConcurrentOperationCount = 6
        renderQueue.name = "com.imageFetcher.renderQueue"
        imageCacheName = options.imageCacheName
        numberOfImagesBetweenCacheSaves = options.numberOfImagesBetweenCacheSaves
        loadImageLookup()
    }

    @discardableResult func createCachesURL() -> URL {
        let fileManager = FileManager.default
        var url = try! fileManager.url(for: .cachesDirectory, in: [.userDomainMask], appropriateFor: nil, create: true)
        do {
            url = url.appendingPathComponent("com.imageFetcher.imageFetcher", isDirectory: true)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error in \(#function): \(error)")
        }
        return url
    }

    func cacheImageToDisk(_ data:Data, request:ImageFetcherRequest) {
        diskQueue.async {
            let name = request.diskCacheKey + ".imageData"
            let path = self.cachesURL.appendingPathComponent(name, isDirectory: false)
            do {
                try data.write(to: path)
                let info = CachedImage(identifier: request.diskCacheKey, path: name, dateFetched: Date(), sizeMetrics:request.sizeMetrics)
                self.addImageInfoToLookup(info: info)
            } catch let error {
                print("Error in \(#function): \(error)")
                self.createCachesURL()
            }
        }
    }

    func readDataFromDisk(identifier:CachedImage, completion:@escaping (Data?)->()){
        diskQueue.async {
            let path = identifier.path
            let url = self.cachesURL.appendingPathComponent(path, isDirectory: false)
            var data:Data?
            do {
                data = try Data(contentsOf: url)

            } catch let error  {
                print("Error in \(#function): \(error)")
            }
            completion(data)
        }
    }

    func saveImageLookup() {
        var lookupCopy = [String:CachedImage]()
        isolationQueue.sync {
            lookupCopy = self.imageLookup
        }
        diskQueue.async {
            do {
                let data = try JSONEncoder().encode(lookupCopy)
                let cache = self.cachesURL.appendingPathComponent(self.imageCacheName, isDirectory: false)
                try data.write(to: cache)
            } catch let error {
                print("Error in \(#function): \(error)")
            }
        }
    }

    func loadImageLookup() {
        isolationQueue.sync {
            do {
                let url = cachesURL.appendingPathComponent(imageCacheName, isDirectory: false)
                if try url.checkResourceIsReachable() {
                    let data = try Data(contentsOf: url)
                    let lookup = try JSONDecoder().decode([String:CachedImage].self, from: data)
                    self.imageLookup = lookup
                    print("Loaded \(lookup.count) from disk")
                }
            } catch let error {
                print("Error in \(#function): \(error)")
            }
        }
    }

    func deleteImageLookup() {
        do {
            let url = cachesURL.appendingPathComponent(imageCacheName, isDirectory: false)
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print("Error in \(#function): \(error)")
        }
        isolationQueue.sync {
            imageLookup.removeAll()
        }
    }

    func addImageInfoToLookup(info:CachedImage) {
        var lookupCopy:[String:CachedImage]?
        isolationQueue.async {
            self.imagesAddedSinceLastLookupSave += 1
            self.imageLookup[info.identifier] = info
            if self.imagesAddedSinceLastLookupSave >= self.numberOfImagesBetweenCacheSaves {
                self.imagesAddedSinceLastLookupSave = 0
                lookupCopy = self.imageLookup
                self.diskQueue.async {
                    do {
                        let data = try JSONEncoder().encode(lookupCopy!)
                        let cache = self.cachesURL.appendingPathComponent(self.imageCacheName, isDirectory: false)
                        try data.write(to: cache)
                    } catch let error {
                        print("Error in \(#function): \(error)")
                    }
                }
            }
        }
    }

    func cachedImageInfoFromLookup(identifier:String) -> CachedImage? {
        return isolationQueue.sync {
            imageLookup[identifier]
        }
    }

    func removeCachedImageInfoFromLookup(identifier:String) {
        isolationQueue.sync {
            self.imageLookup[identifier] = nil
        }
    }

    func cacheImageInMemory(_ image:UIImage, request:ImageFetcherRequest) {
        inMemoryCache.setObject(image, forKey: request.cacheKey as NSString)
    }

    func cachedImageFromMemory(request:ImageFetcherRequest) -> UIImage? {
        return inMemoryCache.object(forKey: request.cacheKey as NSString)
    }

    @discardableResult public func fetchImage(imageRequest:ImageFetcherRequest, completion:@escaping (ImageFetcherResult) -> ()) -> String {

        imageRequest.performanceMetrics.absoluteStartTime = CFAbsoluteTimeGetCurrent()

        let observationToken = UUID().uuidString

        fetchImage(imageRequest: imageRequest, observationToken: observationToken, completion: completion)

        return observationToken
    }

    public func fetchImage(imageRequest:ImageFetcherRequest, observationToken:String, completion: @escaping (ImageFetcherResult) -> ()) {

        imageRequest.performanceMetrics.absoluteStartTime = CFAbsoluteTimeGetCurrent()
        imageRequest.performanceMetrics.memoryCacheLookupStart = CFAbsoluteTimeGetCurrent()

        // Check if we have an image already decoded and cached in memory
        if let image = cachedImageFromMemory(request: imageRequest) {

            imageRequest.performanceMetrics.memoryCacheLookupEnd = CFAbsoluteTimeGetCurrent()
            imageRequest.performanceMetrics.fulfillmentType = .memoryCache
            imageRequest.performanceMetrics.absoluteEndTime = CFAbsoluteTimeGetCurrent()

            if logMetrics {
                imageRequest.printMetrics()
            }
            if shouldLogStatus {
                logStatus()
            }

            completion(.success(image, imageRequest))

        } else {
            imageRequest.performanceMetrics.memoryCacheLookupEnd = CFAbsoluteTimeGetCurrent()

            // Check if a request for this image is in progress
            if requestHasObservers(request: imageRequest) {

                imageRequest.performanceMetrics.workerType = .waiter

                addRequestObserver(request: imageRequest, token: observationToken, completion: completion)

                if !imageRequest.isLowPriority { promoteOperationPriorityIfNeeded(request: imageRequest) }
            } else {
                addRequestObserver(request: imageRequest, token: observationToken, completion: completion)

                // Check our in memory list of images on disk
                if let info = cachedImageInfoFromLookup(identifier: imageRequest.diskCacheKey) {
                    queueImageRenderOperationForRequest(imageRequest: imageRequest, cachedInfo: info, obsToken: observationToken)
                } else {
                    // Queue up for download
                    queueImageFetchOperationForRequest(imageRequest: imageRequest)
                }
            }
        }
    }

    /// Queue an image operation that will both download the image and decompress it
    /// The raw data is returned for caching to disk
    func queueImageFetchOperationForRequest(imageRequest:ImageFetcherRequest) {

        isolationQueue.sync {
            let operation = ImageFetcherDownloadOperation(session: self.session, request: imageRequest) { [weak self] result in
                switch result {
                case let .success(image, data, request):
                    self?.notifyObserversWithResult(.success(image, request), request: request)
                    self?.cacheImageInMemory(image, request: request)
                    self?.cacheImageToDisk(data, request: request)
                case let .error(error, request):
                    self?.notifyObserversWithResult(.error(error, request), request: request)
                }
            }
            if imageRequest.isLowPriority {
                operation.queuePriority = .low
            }
            self.fetchOperations[imageRequest.cacheKey] = operation
            self.imageFetchQueue.addOperation(operation)
        }
    }

    func queueImageRenderOperationForRequest(imageRequest:ImageFetcherRequest, cachedInfo:CachedImage, obsToken:String) {

        imageRequest.performanceMetrics.renderEnqueueTime = CFAbsoluteTimeGetCurrent()

        imageRequest.performanceMetrics.diskCacheLookupStart = CFAbsoluteTimeGetCurrent()
        readDataFromDisk(identifier: cachedInfo) { data in

            guard let data = data else {
                self.removeCachedImageInfoFromLookup(identifier: imageRequest.cacheKey)
                self.queueImageFetchOperationForRequest(imageRequest: imageRequest)
                return
            }
            
            imageRequest.performanceMetrics.diskCacheLookupEnd = CFAbsoluteTimeGetCurrent()
            imageRequest.performanceMetrics.renderEnqueueTime = CFAbsoluteTimeGetCurrent()

            self.isolationQueue.async {

                let completion:(UIImage?)->() = {[weak self] decompressedImage in
                    if let decompressedImage = decompressedImage {
                        let result:ImageFetcherResult = .success(decompressedImage, imageRequest)
                        self?.notifyObserversWithResult(result, request: imageRequest)
                        self?.cacheImageInMemory(decompressedImage, request: imageRequest)
                    } else {
                        let result:ImageFetcherResult =  .error(.corruptImage, imageRequest)
                        self?.notifyObserversWithResult(result, request: imageRequest)
                    }
                }
                let operation: ImageFetcherRenderOperation
                if let targetSize = imageRequest.sizeMetrics?.targetSize, targetSize.width > 0 && targetSize.height > 0, let sourceSize = imageRequest.sizeMetrics?.sourceSize  {
                    let sizes = ImageFetcherImageSizeMetrics(targetSize: targetSize, sourceSize: sourceSize)
                    operation = ImageFetcherRenderOperation(data: data, request: imageRequest, imageSizes:sizes, completion:completion)
                } else {
                    operation = ImageFetcherRenderOperation(data: data, request: imageRequest, imageSizes: nil, completion:completion)
                }
                self.renderOperations[imageRequest.cacheKey] = operation
                self.renderQueue.addOperation(operation)
            }
        }
    }

    func requestHasObservers(request:ImageFetcherRequest) -> Bool {
        return isolationQueue.sync {
            observers[request.cacheKey] != nil
        }
    }

    func addRequestObserver(request:ImageFetcherRequest, token:String, completion:@escaping (ImageFetcherResult)->()) {
        isolationQueue.sync {
            if var observersForRequest = observers[request.cacheKey] {
                observersForRequest[token] = completion
                observers[request.cacheKey] = observersForRequest
            } else {
                observers[request.cacheKey] = [token:completion]
            }
        }
    }

    public func removeRequestObserver(request:ImageFetcherRequest, token:String) {
        isolationQueue.sync {
            guard var requestObservers = self.observers[request.cacheKey] else {
                return
            }

            requestObservers[token] = nil

            if requestObservers.count == 0 {

                if let op = self.fetchOperations[request.cacheKey] as? ImageFetcherDownloadOperation {
                    op.task?.cancel()
                    op.cancel()
                }
                self.observers[request.cacheKey] = nil
                self.fetchOperations[request.cacheKey] = nil

                if let op = self.renderOperations[request.cacheKey] as? ImageFetcherRenderOperation {
                    op.cancel()
                }

                self.renderOperations[request.cacheKey] = nil
            } else {
                self.observers[request.cacheKey] = requestObservers
            }
            if shouldLogStatus {
                logStatus()
            }
        }
    }

    func promoteOperationPriorityIfNeeded(request:ImageFetcherRequest) {
        isolationQueue.async {
            self.fetchOperations[request.cacheKey]?.queuePriority = .normal
            self.renderOperations[request.cacheKey]?.queuePriority = .normal
        }
    }

    //TODO: Only make one context switch to main rather than for each observer
    func notifyObserversWithResult(_ result:ImageFetcherResult, request:ImageFetcherRequest) {
        isolationQueue.async {
            if let observersForRequest = self.observers[request.cacheKey]?.values {
                observersForRequest.forEach { callback in
                    DispatchQueue.main.async {
                        request.performanceMetrics.absoluteEndTime = CFAbsoluteTimeGetCurrent()
                        if self.logMetrics {request.printMetrics() }
                        callback(result)
                    }
                }
                self.observers[request.cacheKey] = nil

            }
            self.fetchOperations[request.cacheKey] = nil
            self.renderOperations[request.cacheKey] = nil
            if self.shouldLogStatus {
                self.logStatus()
            }
        }
    }
    
    public func clearCaches() {
        isolationQueue.sync {
            inMemoryCache.removeAllObjects()
            self.imageLookup.removeAll()
            diskQueue.async {
                do {
                    try FileManager.default.removeItem(at: self.cachesURL)
                } catch let error {
                    print("Error in \(#function): \(error)")
                }
            }
        }
    }

    public func clearInMemoryCache() {
        isolationQueue.sync {
            inMemoryCache.removeAllObjects()
        }
    }

    public func clearOnDiskCache() {
        isolationQueue.async {
            do {
                try FileManager.default.removeItem(at: self.cachesURL)
            } catch let error {
                print("Error in \(#function): \(error)")
            }
            self.imageLookup.removeAll()
        }
    }
    
    public func cancelAll() {
        isolationQueue.async {
            for op in self.imageFetchQueue.operations {
                (op as? ImageFetcherDownloadOperation).flatMap { $0.task?.cancel() }
                op.cancel()
            }
            self.renderQueue.cancelAllOperations()
            self.observers.removeAll()
            
            if self.shouldLogStatus {
                self.logStatus()
            }
        }
    }
    
    func logStatus() {
        
        print("Observers: \(self.observers.count)")
        print("Total fetches: \(self.fetchOperations.count)")
        print("Total renders: \(self.renderOperations.count)")
    }

    deinit {
        print("Images controller deallocated...")
        cancelAll()
    }
}

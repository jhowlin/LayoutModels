//
//  ImageFetcherDownloadOperation.swift
//  Feed
//
//  Created by Jason Howlin on 6/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

final class ImageFetcherDownloadOperation:ImageFetcherBaseOperation {
    
    var task : URLSessionDataTask?
    let session:URLSession
    var request:ImageFetcherRequest
    var completion:((ImageOperationResult) -> ())
    let decompressor:Decompressor
    
    init(session:URLSession, request:ImageFetcherRequest, decompressor:@escaping Decompressor = imageFetcherSimpleDecompressor, completion:@escaping (ImageOperationResult)->()) {
        self.session = session
        self.completion = completion
        self.request = request
        self.decompressor = decompressor
        super.init()
    }
    
    override func execute() {
        self.request.performanceMetrics.downloadStartTime = CFAbsoluteTimeGetCurrent()
        guard isCancelled == false else { operationCancelled() ; return}
        guard let url = URL(string:request.url) else {corruptImage() ; return }
        
        let urlRequest = URLRequest(url: url)
        
        task = session.dataTask(with: urlRequest) { data, response, error in
            
            guard self.isCancelled == false else {
                self.operationCancelled()
                return
            }
            self.request.performanceMetrics.downloadEndTime = CFAbsoluteTimeGetCurrent()
            
            guard let data = data else { self.networkFailed() ; return }
            
            self.request.performanceMetrics.bytes = data.count
            self.request.performanceMetrics.renderStartTime = CFAbsoluteTimeGetCurrent()
            
            if let sizes = self.request.sizeMetrics  {
                
                if let image = decompressAndResize(imageData: data, sourceSize: sizes.sourceSize, targetSize: sizes.targetSize) {
                    self.request.performanceMetrics.renderEndTime = CFAbsoluteTimeGetCurrent()
                    
                    self.completion(.success(image, data, self.request))
                    self.finish()
                } else {
                    self.corruptImage()
                }
            } else {
                if let image = UIImage(data:data){
                    let decompressed = self.decompressor(image)
                    self.request.performanceMetrics.renderEndTime = CFAbsoluteTimeGetCurrent()
                    self.completion(.success(decompressed, data, self.request))
                    self.finish()
                } else {
                    self.networkFailed()
                }
            }
        }
        task?.resume()
    }
    
    func corruptImage() {
        completion(.error(.corruptImage, request))
        finish()
    }
    
    func imageNotFound() {
        completion(.error(.notFound, request))
        finish()
    }
    
    func networkFailed() {
        completion(.error(.network, request))
        finish()
    }
    
    func operationCancelled() {
        completion(.error(.cancelled, request))
        finish()
    }
}

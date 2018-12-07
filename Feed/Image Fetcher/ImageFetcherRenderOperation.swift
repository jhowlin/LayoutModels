//
//  ImageFetcherRenderOperation.swift
//  Feed
//
//  Created by Jason Howlin on 6/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

final class ImageFetcherRenderOperation: ImageFetcherBaseOperation {

    var data:Data
    var completion:(UIImage?)->()
    var identifier:String
    var request:ImageFetcherRequest
    var imageSizes:ImageFetcherImageSizeMetrics?

    public init(data: Data, request:ImageFetcherRequest, imageSizes:ImageFetcherImageSizeMetrics?, completion: @escaping (UIImage?)->()) {
        self.data = data
        self.completion = completion
        self.identifier = request.identifier
        self.request = request
        self.imageSizes = imageSizes
        super.init()
    }

    override func execute() {
        guard isCancelled == false else { onCancel() ; return }
        self.request.performanceMetrics.renderStartTime = CFAbsoluteTimeGetCurrent()
        self.request.performanceMetrics.bytes = data.count

        if let sizes = imageSizes {
            
            if let image = decompressAndResize(imageData: data, sourceSize: sizes.sourceSize, targetSize: sizes.targetSize) {
                self.request.performanceMetrics.renderEndTime = CFAbsoluteTimeGetCurrent()
                completion(image)
                self.finish()
            } else {
                fatalError("To do generate uiimage from data")
            }
        } else {
            var decompressed:UIImage?
            if let image = UIImage(data:data) {
                decompressed = imageFetcherSimpleDecompressor(image)
            }
            request.performanceMetrics.renderEndTime = CFAbsoluteTimeGetCurrent()
            completion(decompressed)
            self.finish()
        }
    }

    func onCancel() {
        completion(nil)
        self.finish()
    }
}

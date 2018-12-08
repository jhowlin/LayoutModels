//
//  UIImageView+ImageFetcherController.swift
//  Feed
//
//  Created by Jason Howlin on 2/17/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import UIKit
import ObjectiveC

private var requestPropertyAssociationKey: UInt8 = 0
private var tokenPropertyAssociationKey: UInt8 = 0

extension UIImageView {

    public var request: ImageFetcherRequest? {
        get {
            let optionalObject: AnyObject? = objc_getAssociatedObject(self, &requestPropertyAssociationKey) as AnyObject
            if let object: AnyObject = optionalObject {
                return object as? ImageFetcherRequest
            }
            return nil
        }
        set(newValue) {
            self.image = nil
            if let request = request, let token = obsToken, newValue?.identifier !=  request.identifier {
                ImageFetcherController.shared.removeRequestObserver(request: request, token: token)
                self.obsToken = nil
            }

            objc_setAssociatedObject(self, &requestPropertyAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            let token = obsToken ?? UUID().uuidString
            obsToken = token
            ImageFetcherController.shared.fetchImage(imageRequest: request!, observationToken:obsToken!) { [weak self] (result) in
                switch result {
                case let .success(image, imageRequest):
                    if imageRequest.identifier == self?.request?.identifier {
                        self?.obsToken = nil
                        self?.image = image
                    }
                case let .error(error, request):
                    if error != .cancelled {
                        //print(error)
                    }
                    if request.identifier == self?.request?.identifier {
                        self?.obsToken = nil
                    }
                }
            }
        }
    }

    public var obsToken: String? {
        get {
            let optionalObject: AnyObject? = objc_getAssociatedObject(self, &tokenPropertyAssociationKey) as AnyObject
            if let object: AnyObject = optionalObject {
                return object as? String
            }
            return nil
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tokenPropertyAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc public func setImageViewWithURL(url:String, guid:String, rawImageSize:CGSize, targetSize:CGSize) {
        let size = targetSize.scaledForScreen
        let sizeMetrics = ImageFetcherImageSizeMetrics.init(targetSize: size, sourceSize: rawImageSize)
        let req = ImageFetcherRequest(url: url, identifier: guid, isLowPriority:false, sizeMetrics:sizeMetrics)
        self.request = req
    }

    @objc public func setImageViewWithURL(url:String, guid:String) {
        let req = ImageFetcherRequest(url: url, identifier: guid, isLowPriority:false)
        self.request = req
    }

    @objc public func setImageViewWithURL(url:String) {
        var size = self.bounds.size
        let scale = UIScreen.main.scale
        size = CGSize(width: size.width * scale, height: size.height * scale)
        let guid = hashURL(url: url, size: size)
        let req = ImageFetcherRequest(url: url, identifier: guid, isLowPriority:false)
        self.request = req
    }

    func hashURL(url:String, size:CGSize) -> String {
        let hash = ("\(size)" + url).djb2hash
        return "\(hash)"
    }
}

extension String {
    var djb2hash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}



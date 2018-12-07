//
//  ImageFetcherBaseOperation.swift
//  Feed
//
//  Created by Jason Howlin on 6/6/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation

class ImageFetcherBaseOperation:Operation {
    
    func execute() { }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    fileprivate var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        _executing = true
        execute()
    }
    
    func finish() {
        _executing = false
        _finished = true
    }
}

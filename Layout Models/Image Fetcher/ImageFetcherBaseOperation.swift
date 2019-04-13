//
//  ImageFetcherBaseOperation.swift
//  Feed
//
//  Created by Jason Howlin on 6/6/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
/*
 Async operations require a subclass of Operation, and docs state you must override
 - start()
 - isAsynchronous
 - isExecuting
 - isFinished
 
 These must be done in a synchronized and thread-safe manner
 */
class ImageFetcherBaseOperation:Operation {
    
    enum State {
        case executing, finished, notTrackedYet
    }
    
    func execute() {
        fatalError("Subclasses must override this")
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    let queue = DispatchQueue(label: "com.howlin.opIsolationQueue", attributes:.concurrent)
    
    var state:State {
        get {
            return queue.sync {
                unsafeInternalState
            }
        }
        set {
            switch newValue {
            case .executing:
                willChangeValue(forKey: "isExecuting")
            case .finished:
                willChangeValue(forKey: "isFinished")
            case .notTrackedYet:
                break
            }
            
            queue.sync(flags:.barrier) {
                self.unsafeInternalState = newValue
            }
            
            switch newValue {
            case .executing:
                didChangeValue(forKey: "isExecuting")
            case .finished:
                didChangeValue(forKey: "isFinished")
            case .notTrackedYet:
                break
            }
        }
    }
    
    var unsafeInternalState:State = .notTrackedYet
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        state = .executing
        execute()
    }
    
    func finish() {
        state = .finished
    }
}

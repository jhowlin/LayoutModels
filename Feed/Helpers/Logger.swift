//
//  Logger.swift
//  HomeRun
//
//  Created by Jason Howlin on 6/22/18.
//  Copyright © 2018 Yahoo. All rights reserved.
//

import Foundation
import os
import os.signpost
import UIKit

enum LogArgument:String {
    case logGeneral = "LOG_GENERAL"
    case logFPS = "LOG_FPS"
}

@objcMembers
class Logger:NSObject {


    var generalLogger = OSLog(subsystem: "Feed Default", category: "General")
    var startCurrentDequeueCell = CFAbsoluteTimeGetCurrent()
    var startCalculateModels = CFAbsoluteTimeGetCurrent()
    var startHeight = CFAbsoluteTimeGetCurrent()
    var startViewLoad = CFAbsoluteTimeGetCurrent()
    
    
    static let shared:Logger = Logger()

    override init () {
        super.init()
    }

    func log(logMessage:String) {
        if isRunningLaunchArgument(.logGeneral) {
            os_log("%{public}s", log: generalLogger, type: .info, logMessage)
        }
    }

    public func isRunningLaunchArgument(_ argument:LogArgument) -> Bool {
        let args = ProcessInfo.processInfo.arguments
        return args.contains(argument.rawValue.uppercased())
    }

    func beginCellDequeueSignpost(identifier:String) {
        startCurrentDequeueCell = CFAbsoluteTimeGetCurrent()
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log: generalLogger, name: "CellDequeue", "%{public}s", identifier)
        }
    }

    func endCellDequeueSignpost(identifier:String) {
        let duration = (CFAbsoluteTimeGetCurrent() - startCurrentDequeueCell) * 1000
        log(logMessage:"Dequeue cell took \(String(format: "%.2f", duration)) ms")
        if #available(iOS 12.0, *) {
            os_signpost(.end, log:generalLogger, name: "CellDequeue", "%{public}s", identifier)
        }
    }

    func beginHeight() {
        startHeight = CFAbsoluteTimeGetCurrent()
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log:generalLogger, name: "HeightCell")
        }
    }

    func endHeight() {
        let duration = (CFAbsoluteTimeGetCurrent() - startHeight) * 1000
        log(logMessage:"Calculate cell height took \(String(format: "%.2f", duration)) ms")
        if #available(iOS 12.0, *) {
            os_signpost(.end, log:generalLogger, name: "HeightCell")
        }
    }

    func beginWillDisplay() {
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log:generalLogger, name: "WillDisplayCell")
        }
    }

    func endWillDisplay() {
        if #available(iOS 12.0, *) {
            os_signpost(.end, log:generalLogger, name: "WillDisplayCell")
        }
    }
    
    func beginCalculateModels() {
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log:generalLogger, name: "CalculateModels")
            startCalculateModels = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func endCalculateModels() {
        if #available(iOS 12.0, *) {
            os_signpost(.end, log:generalLogger, name: "CalculateModels")
            let duration = (CFAbsoluteTimeGetCurrent() - startCalculateModels) * 1000
            log(logMessage:"Calculate models took \(String(format: "%.2f", duration)) ms")
        }
    }
    
    func beginVCLoad() {
        startViewLoad = CFAbsoluteTimeGetCurrent()
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log:generalLogger, name: "VLoad")
        }
    }
    
    func endVCLoad() {
        let duration = (CFAbsoluteTimeGetCurrent() - startViewLoad) * 1000
        log(logMessage:"Initial view render took \(String(format: "%.2f", duration)) ms")
        if #available(iOS 12.0, *) {
            os_signpost(.end, log:generalLogger, name: "VLoad")
        }
    }
}

class FPSLogger {

    var previousTimeStamp:CFAbsoluteTime = 0
    var frameCount = 0
    var displayLink:CADisplayLink?

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(linkFired))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }

    @objc func linkFired() {
        let now = CFAbsoluteTimeGetCurrent()
        let elapsed = now - previousTimeStamp
        frameCount = frameCount + 1
        if elapsed > 1.0 {
            let fps = (Double(frameCount) / elapsed).rounded()
            print("FPS Logger: \(fps) frames per second")
            previousTimeStamp = now
            frameCount = 0
        }
    }

    deinit {
        displayLink?.invalidate()
    }
}


func randomImageURL(width:CGFloat, height:CGFloat) -> String {
    let url = "https://picsum.photos/\(Int(width))/\(Int(height))/?random"
    return url
}

func measure(id:String, block:()->()) {
    let now = CFAbsoluteTimeGetCurrent()
    block()
    let duration = (CFAbsoluteTimeGetCurrent() - now) * 1000
    print("\(id) took \(String(format: "%.2f", duration)) ms")
}



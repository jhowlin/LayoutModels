//
//  NetworkingManager.swift
//  BackgroundNetworking
//
//  Created by Jason Howlin on 7/7/19.
//  Copyright © 2019 Jason Howlin. All rights reserved.
//

import Foundation
import UIKit

class NetworkManagerRequest {
    
}

typealias NetworkManagerResponse = Result<(URLSessionTask, Data), Error>

class NetworkManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {

    var backgroundSession: URLSession!
    var foregroundSession:URLSession!
    
    var responseHandlers:[ResponseHandling] = []

    var accumulatedData:[URLSessionTask:Data] = [:]
    var completionHandlers:[URLSessionTask:(NetworkManagerResponse)->()] = [:]
    
    let delegateQueue = OperationQueue()
    
    var backgroundSessionEventsCompletedBlock:(()->())?
    
    init(responseHandlers:[ResponseHandling]) {
        super.init()
        
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.name = "Delegate Queue for URLSession"
        
        self.responseHandlers = responseHandlers
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.howlin.NetworkManager")
        self.backgroundSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: delegateQueue)
        
        let foregroundConfig = URLSessionConfiguration.ephemeral
        foregroundConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        
        self.foregroundSession = URLSession(configuration: foregroundConfig, delegate: self, delegateQueue: delegateQueue)
        
//        let sourceSize = CGSize(width: 3400, height: 2600)
//        let url = URL(string:"https://picsum.photos/\(Int(sourceSize.width))/\(Int(sourceSize.height))/?random")!
//        let req = URLRequest(url: url)
//
//        let task = backgroundSession.downloadTask(with: req)
//        task.countOfBytesClientExpectsToSend = 200
//        task.countOfBytesClientExpectsToReceive = 1000000
        
//        task.earliestBeginDate = Date() + 30
        
//        task.resume()
    }
    
    func addResponseHandler(_ handler:Any) {
        
    }
    
    func executeRequest(_ request:Any) {
        
    }
    
    private func completeRequest(_ request:Any) {
        
    }
    
    func runTask(task:URLSessionDataTask, completion:@escaping (NetworkManagerResponse)->()) {
        completionHandlers[task] = completion
        task.resume()
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        // Will only be called in event session was put together after app delegate method called...
        print(#function, session)
        DispatchQueue.main.async {
            self.backgroundSessionEventsCompletedBlock?()
            self.backgroundSessionEventsCompletedBlock = nil
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        print(#function)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        print(#function, session, task, error as Any)
        
        if let data = accumulatedData[task], let completion = completionHandlers[task] {
            completion(.success((task, data)))
        }
        
        
        completionHandlers[task] = nil
        accumulatedData[task] = nil
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if var currentData = accumulatedData[dataTask] {
            currentData.append(data)
            accumulatedData[dataTask] = currentData
        } else {
            accumulatedData[dataTask] = data
        }
        
//        let numSessions = accumulatedData.reduce(0) { (curr:Int, keyVal:(key: URLSessionTask, value: Data)) -> Int in
//
//            return 0
//
//        }
        print("Concurrent tasks: \(accumulatedData.count)")
        
//        print(#function, session, dataTask, data.count)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
//        print(#function)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
//        print(#function)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
//        print(#function)
        completionHandler(nil)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download task finished, downloaded to: \(location.absoluteString)")
        do {
            let data = try Data(contentsOf: location)
            let image = UIImage(data: data)
            assert(image != nil)
            
            print("Total size of downloaded data: \(data.count)")
            
            let fileManager = FileManager.default
            var url = try! fileManager.url(for: .documentDirectory, in: [.userDomainMask], appropriateFor: nil, create: true)
            do {
                url = url.appendingPathComponent("com.howlin.backgroundNetworking", isDirectory: true)
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error in \(#function): \(error)")
            }
            let name = "\(Date())" + ".dat"
            let path = url.appendingPathComponent(name, isDirectory: false)
            do {
                try data.write(to: path)
                print("Wrote to: \(path.absoluteString)")
            } catch let error {
                print("Error in \(#function): \(error)")
            }
            
            
            
            
            
        } catch (let error) {
            print(error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print(#function)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Download task progress: \(totalBytesWritten) out of \(totalBytesExpectedToWrite)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
//        print(metrics)
    }
    
    
}

protocol ResponseHandling {
    func canHandleResponse(_ response:NetworkManagerResponse) -> Bool
    func handleResponse( _ response:NetworkManagerResponse)
}

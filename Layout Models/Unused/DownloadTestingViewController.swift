//
//  DownloadTestingViewController.swift
//  LayoutModels
//
//  Created by Jason Howlin on 7/12/19.
//  Copyright © 2019 Howlin. All rights reserved.
//

import Foundation
import UIKit

enum DownloadMethod {
    case urlSession, ifc
}

class DownloadTestingViewController: UIViewController {
    
    var session:URLSession!
    let imageFetchQueue = OperationQueue()
//    let delegateQueue = OperationQueue()
    let method:DownloadMethod
    let networkManager = NetworkManager(responseHandlers: [])
    let logger = Logger()
    let imageFetcher = ImageFetcherController()
    
    required init(downloadMethod:DownloadMethod) {
        
        self.method = downloadMethod
        imageFetchQueue.maxConcurrentOperationCount = 6
//        delegateQueue.maxConcurrentOperationCount = 1
        
        super.init(nibName: nil, bundle: nil)
        
        
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        session = URLSession(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch method {
            
        case .urlSession:
//            downloadWithURLSession()
            downloadWithNetworkManager()
        case .ifc:
            downloadWithIFC()
        }
        
    }
    
    func urls(number:Int) -> [String] {
        return (0..<number).map { "https://picsum.photos/\(2800 + $0)/\(1600 + $0)/?random" }
    }
    
    func sampleURLs() -> [String] {
        let url = Bundle.main.url(forResource: "sampleImageURLs", withExtension: "data")
        let data = try! Data(contentsOf: url!)
        let urls = try! JSONDecoder().decode([String].self, from: data)
        return urls
    }
    
    var urls:[String] {
        return sampleURLs()
    }
    
    let numberToDownload = 60

    func downloadWithIFC() {
        
        logger.beginTimingForIdentifier("Download with IFC")
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            let guid = UUID().uuidString
            
            let req = ImageFetcherRequest(url: url, identifier: guid)
            
            let op = ImageFetcherDownloadOperation(session: session, request: req, decompressor: noDecompressor) { result in
//                print(self.imageFetchQueue.operations.filter { $0.isExecuting}.count)
                switch result {
                    
                case .success(_, _, let request):
                    break
                case .error(_, _):
                    print("Error IFC")
                }
                
                group.leave()
            }
            
            imageFetchQueue.addOperation(op)
            
            
            
//            imageFetcher.fetchImage(imageRequest: req) { result in
//                if result.image == nil {
//                    print("Error IFC")
//                }
//                group.leave()
//            }
        }
        
        group.notify(queue: .main) { [ weak self ] in
            self?.logger.endTimingForIdentifier("Download with IFC")
//            ImageFetcherController.shared.clearCaches()
        }
        
        


    }
    
    func downloadWithURLSession() {
    
        
        logger.beginTimingForIdentifier("Download with Session")
        let group = DispatchGroup()

        
        let requests = urls.map { URLRequest(url: URL(string: $0)!)}
        for (index, request) in requests.enumerated() {
            
            group.enter()
            let task = session.dataTask(with: request) { data, res, err in
                
                if let data = data, let _ = UIImage(data: data) {
                    
                } else {
                    print("Error downloading at index:\(index)")
                }
                group.leave()
                
                
                
            }
            task.resume()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.logger.endTimingForIdentifier("Download with Session")
            //            ImageFetcherController.shared.clearCaches()
        }
        
        
    }
    
    func downloadWithNetworkManager() {
        logger.beginTimingForIdentifier("Download with Session")
        let group = DispatchGroup()
        
        
        let requests = urls.map { URLRequest(url: URL(string: $0)!)}
        for (_, request) in requests.enumerated() {
            
            group.enter()
            let task = networkManager.foregroundSession.dataTask(with: request)
            networkManager.runTask(task: task) { result in
                switch result {
                    
                case .success(_, _):
                    break
                case .failure(_):
                    
                    break
                }
                
                group.leave()
                
                
            }
        }
        
        group.notify(queue: .main) { [ weak self] in
            self?.logger.endTimingForIdentifier("Download with Session")
            //            ImageFetcherController.shared.clearCaches()
        }
    }
    
    deinit {
        //ImageFetcherController.shared.cancelAll()
        
        
    }
}

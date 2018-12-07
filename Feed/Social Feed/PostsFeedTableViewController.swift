//
//  PostsFeedTableViewController.swift
//  Feed
//
//  Created by Jason Howlin on 6/23/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import UIKit

enum LayoutMethod:String {
    case layoutModel = "Layout Model", sizingCell = "Sizing Cell"
}

// The manual layout approach uses two objects - a view model, and a view layout
struct PhotoPostViewInfo {
    let viewModel:PhotoPostViewModel
    let layout:PhotoPostViewLayout
}

class PostsFeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    var tableView = UITableView(frame: .zero, style: .plain)
    var loadingView = UIView(frame: .zero)
    var loadingSpinner = UIActivityIndicatorView(style: .gray)
    let cellReuseID = "PhotoPostCell"
    let imageDownloadSize = CGSize(width: 800, height: 600)
    var postInfos:[PhotoPostViewInfo] = [] // used for manual layout mode
    var posts:[PostModel] = [] // used for sizing cell mode
    let sizingCell = PhotoPostView()
    var isLoading = false
    var layoutMethod = LayoutMethod.layoutModel
    var usePrefetching = true
    var prefetchCellTokens = [IndexPath:(String, ImageFetcherRequest)]()
    let shouldLogFPSData = false
    var fpsLogger:FPSLogger?
    var useAutoscroll = false
    var useParallelModelCreation = true

    init(layoutMethod:LayoutMethod) {
        Logger.shared.beginVCLoad()
        self.layoutMethod = layoutMethod
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let tableConstraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(tableConstraints)
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        switch layoutMethod {
        case .layoutModel:
            tableView.register(PhotoPostCellManualLayout.self, forCellReuseIdentifier: cellReuseID)
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
            loadingView.backgroundColor = .white
            loadingSpinner.startAnimating()
            view.addSubview(loadingView)
            loadingView.addSubview(loadingSpinner)
            let constraints = [
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            
            if usePrefetching {
                tableView.prefetchDataSource = self
            }
            
        case .sizingCell:
            tableView.register(PhotoPostCellAutoLayout.self, forCellReuseIdentifier: cellReuseID)
        }

        
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onClearCache))
        navigationItem.rightBarButtonItems = [button]
        
        title = layoutMethod.rawValue
        
        if shouldLogFPSData {
            fpsLogger = FPSLogger()
        }
    }
    
    func showLoadingView() {
        loadingView.isHidden = false
        loadingView.alpha = 1
        loadingSpinner.startAnimating()
    }
    
    func hideLoadingView() {
        loadingSpinner.stopAnimating()
        self.loadingView.isHidden = true
    }
    
    @objc func onClearCache() {
        ImageFetcherController.shared.clearCaches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.shared.beginCalculateModels()
        loadForWidth(width: view.bounds.size.width) {
            Logger.shared.endCalculateModels()
        }
    }
    
    // Appends 300 items at a time to our feed (so we could simulate paging if we want)
    func loadForWidth(width:CGFloat, completion:@escaping ()->()) {
        
        let url = "https://picsum.photos/\(Int(imageDownloadSize.width))/\(Int(imageDownloadSize.height))/?random"
        let numItems = 300
        switch layoutMethod {
        case .layoutModel:
            showLoadingView()
            DispatchQueue.global().async {
                
                let createViewModelAndLayout:() -> PhotoPostViewInfo = {
                    let post = PostModel.createModel(imageURL: url)
                    let model = PhotoPostViewModel(userName: post.userName, topComment: post.comment, imageURL: url, guid:post.guid, commentOne:post.commentOne, commentTwo:post.commentTwo, date:post.date)
                    let layout = PhotoPostViewLayout(viewModel: model)
                    layout.prepareLayoutForWidth(width: width)
                    let info = PhotoPostViewInfo(viewModel: model, layout: layout)
                    return info
                }
                
                var infos = [PhotoPostViewInfo]()
                
                let onComplete = {
                    completion()
                    self.hideLoadingView()
                    self.postInfos.append(contentsOf: infos)
                    self.tableView.reloadData()
                }
                
                if self.useParallelModelCreation {
                    var result = Array<PhotoPostViewInfo?>(repeating: nil, count: numItems)
                    let q = DispatchQueue(label: "sync queue")
                    DispatchQueue.concurrentPerform(iterations: numItems) { idx in
                        let info = createViewModelAndLayout()
                        q.sync { result[idx] = info }
                    }
                    infos = result.compactMap { $0 }
                    DispatchQueue.main.async {
                        onComplete()
                    }
                } else {
                    let itemStart = self.postInfos.count
                    var infos = [PhotoPostViewInfo]()
                    for _ in itemStart..<itemStart + numItems {
                        let info = createViewModelAndLayout()
                        infos.append(info)
                    }
                    DispatchQueue.main.async {
                        onComplete()
                    }
                }
            }
        case .sizingCell:
            let itemStart = self.posts.count
            for _ in itemStart..<itemStart + numItems {
                let post = PostModel.createModel(imageURL: url)
                self.posts.append(post)
            }
            completion()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.endVCLoad()
        if useAutoscroll {
            autoscroll()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        switch layoutMethod {
        case .layoutModel:
            showLoadingView()
            coordinator.animate(alongsideTransition: { (context) in
                
            }) { (context) in
                for info in self.postInfos {
                    info.layout.prepareLayoutForWidth(width: size.width)
                }
                self.tableView.reloadData()
                self.hideLoadingView()
            }
        case .sizingCell:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        Logger.shared.beginCellDequeueSignpost(identifier: "\(indexPath.row)")
        defer {
            Logger.shared.endCellDequeueSignpost(identifier: "\(indexPath.row)")
        }

        switch layoutMethod {
        case .layoutModel:

            let cell:PhotoPostCellManualLayout = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! PhotoPostCellManualLayout

            let postInfo = postInfos[indexPath.row]
            cell.postView.info = postInfo
            let request = imageRequestForIndexPath(indexPath, isLowPriority: false)
            cell.postView.postedImageView.request = request
            if usePrefetching {
                cancelPrefetchAtIndexPath(indexPath: indexPath)
            }
            return cell
        case .sizingCell:
            let cell:PhotoPostCellAutoLayout = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! PhotoPostCellAutoLayout
            let post = posts[indexPath.row]
            cell.postView.setTopComment(comment: post.comment)
            cell.postView.setUserName(userName:post.userName)
            cell.postView.setCommentOne(comment: post.commentOne)
            cell.postView.setCommentTwo(comment: post.commentTwo)
            cell.postView.setDate(date: post.date)
            let targetSize = CGSize(width: view.bounds.size.width, height: 250)
            cell.postView.postedImageView.setImageViewWithURL(url: post.url, guid: post.guid, rawImageSize: imageDownloadSize, targetSize: targetSize)
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch layoutMethod {
        case .layoutModel:
             return postInfos.count
        case .sizingCell:
            return posts.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        Logger.shared.beginHeight()
        defer {
            Logger.shared.endHeight()
        }
        switch layoutMethod {
        case .layoutModel:
            
            let height = postInfos[indexPath.row].layout.totalHeight
            return height
        case .sizingCell:
            
            let post = posts[indexPath.row]
            sizingCell.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 0)
            sizingCell.setTopComment(comment: post.comment)
            sizingCell.setUserName(userName: post.userName)
            sizingCell.setCommentOne(comment: post.commentOne)
            sizingCell.setCommentTwo(comment: post.commentTwo)
            sizingCell.setDate(date: post.date)
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()
            let height = sizingCell.sizeThatFits(CGSize(width: view.bounds.size.width, height: .greatestFiniteMagnitude)).height
            return height
        }
    }

    var currentAutoscrollIndexPath = IndexPath(row: 0, section: 0)

    func autoscroll() {
        guard (currentAutoscrollIndexPath.row + 1) < tableView.numberOfRows(inSection: 0) else { return }
        currentAutoscrollIndexPath.row = currentAutoscrollIndexPath.row + 1
        let newPath = IndexPath(row: currentAutoscrollIndexPath.row, section: 0)
        tableView.scrollToRow(at: newPath, at: .none, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if useAutoscroll {
            autoscroll()
        }
    }

    func imageRequestForIndexPath(_ indexPath:IndexPath, isLowPriority:Bool) -> ImageFetcherRequest {
        
        guard layoutMethod == .layoutModel else { fatalError() }
        
        let layout = postInfos[indexPath.row].layout
        let model = postInfos[indexPath.row].viewModel
        let itemSize = layout.postedImageViewFrame.size.scaledForScreen
        let guid = model.guid
        let sizeMetrics = ImageFetcherImageSizeMetrics.init(targetSize: itemSize, sourceSize: imageDownloadSize)
        let req = ImageFetcherRequest(url: model.imageURL, identifier: guid, isLowPriority:isLowPriority, sizeMetrics:sizeMetrics)
        return req
    }
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let request = imageRequestForIndexPath(indexPath, isLowPriority: true)
            let token = UUID().uuidString
            prefetchCellTokens[indexPath] = (token, request)
            ImageFetcherController.shared.fetchImage(imageRequest: request, observationToken: token) { _ in }
        }
    }
    
    func cancelPrefetchAtIndexPath(indexPath:IndexPath) {
        if let (token, req) = prefetchCellTokens[indexPath] {
            ImageFetcherController.shared.removeRequestObserver(request: req, token: token)
            prefetchCellTokens[indexPath] = nil
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cancelPrefetchAtIndexPath(indexPath: indexPath)
        }
    }

    deinit {
        fpsLogger?.displayLink?.invalidate()
    }
}

class PhotoPostCellManualLayout:UITableViewCell {
    let postView = PhotoPostViewWithLayout()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postView)
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoPostCellAutoLayout:UITableViewCell {
    let postView = PhotoPostView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postView)
        postView.translatesAutoresizingMaskIntoConstraints = false
        selectionStyle = .none
        let constraints = [
            postView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: postView.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

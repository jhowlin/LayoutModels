//
//  AppDelegate.swift
//  ImagesController
//
//  Created by Jason Howlin on 10/07/2016.
//  Copyright (c) 2016 Jason Howlin. All rights reserved.
//

import UIKit
import SwiftUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let vc = PopoverViewController(style: .plain)
        vc.title = "Modeling Layouts"

        let layoutModelFeed = PopoverAction(title: "Posts feed with layout model") { [weak self] in
            self?.onPostsFeedLayoutModel()
        }
        
        let sizingCellFeed = PopoverAction(title: "Posts feed with sizing cell") { [weak self] in
            self?.onPostsSizingCell()
        }
        
        let swiftUI = PopoverAction(title: "Posts feed with SwiftUI") { [weak self] in
            self?.onSwiftUI()
        }

        vc.actions = [sizingCellFeed, layoutModelFeed, swiftUI]
        let navVC = UINavigationController(rootViewController: vc)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        DispatchQueue.global().async {
            // warm up image fetcher
            let u = ImageFetcherController.shared.cachesURL
            print("\(u)")
        }

        return true
    }
    
    func onPostsFeedLayoutModel() {
        
        let vc = PostsTableViewController(layoutMethod:.layoutModel)
        (window!.rootViewController as! UINavigationController).pushViewController(vc, animated: true)
    }
    
    func onPostsSizingCell() {
        
        let vc = PostsTableViewController(layoutMethod:.sizingCell)
        (window!.rootViewController as! UINavigationController).pushViewController(vc, animated: true)
    }
    
    func onSwiftUI() {
        
        let vc = UIHostingController(rootView: PostViewContainer(viewModel: PostContainerViewModel()))
        (window!.rootViewController as! UINavigationController).pushViewController(vc, animated: true)
    }
}

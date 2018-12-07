//
//  PopoverViewController.swift
//  Feed
//
//  Created by Jason Howlin on 12/6/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

public struct PopoverAction {
    
    public let title: String
    public let handler: () -> ()
    
    public init(title:String, handler:@escaping ()->()) {
        self.title = title
        self.handler = handler
    }
}

open class PopoverViewController: UITableViewController {
    
    open var actions = [PopoverAction]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PopoverCell")
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopoverCell", for: indexPath)
        let action = actions[indexPath.row]
        cell.textLabel?.text = action.title
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = actions[indexPath.row]
        action.handler()
    }
}


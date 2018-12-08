//
//  PostViewModel.swift
//  LayoutModels
//
//  Created by Jason Howlin on 12/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

class PostViewModel {

    let topComment:NSAttributedString
    let userName:NSAttributedString
    let commentOne:NSAttributedString
    let commentTwo:NSAttributedString
    let date:NSAttributedString
    let imageURL:String
    let guid:String

    init(userName:String, topComment:String, imageURL:String, guid:String, commentOne:String, commentTwo:String, date:Date) {
        self.imageURL = imageURL
        self.guid = guid
        self.topComment = NSAttributedString(string: topComment, attributes: cachedAttributes.topCommentsAttr)
        self.userName = NSAttributedString(string: userName, attributes: cachedAttributes.userNameAttr)
        self.commentOne = NSAttributedString(string: commentOne, attributes: cachedAttributes.commentAttr)
        self.commentTwo = NSAttributedString(string: commentTwo, attributes: cachedAttributes.commentAttr)
        let dateLabelString = "posted \(cachedDateFormatter.string(from: date).lowercased())"
        self.date = NSAttributedString(string: dateLabelString, attributes: cachedAttributes.dateAttr)
    }
}

let cachedAttributes = PostCachedAttributes()

class PostCachedAttributes {
    var topCommentsAttr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 16, weight: .semibold)]
    var userNameAttr: [NSAttributedString.Key:Any] = [.font:UIFont.boldSystemFont(ofSize: 12)]
    var commentAttr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 10, weight: .regular)]
    var dateAttr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 12, weight: .light)]
}

let cachedDateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

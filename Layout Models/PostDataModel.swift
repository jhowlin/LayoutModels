//
//  PostModel.swift
//  Feed
//
//  Created by Jason Howlin on 11/5/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class PostDataModel: BindableObject {
    
    let didChange = PassthroughSubject<PostDataModel, Never>()
    
    let comment:String
    let url:String
    let userName:String
    let date:Date
    let guid:String
    let commentOne:String
    let commentTwo:String
    var image:UIImage? {
        didSet {
            didChange.send(self)
        }
    }
    
    static func createModel(imageURL:String) -> PostDataModel {
        let comment = String.arbitraryWords(random(from: 8, to: 30))
        let commentOne = String.arbitraryWords(random(from: 8, to: 30))
        let commentTwo = String.arbitraryWords(random(from: 8, to: 30))
        let userName = String.arbitraryWords(3)
        let date = Date()
        let guid = UUID().uuidString
        let post = PostDataModel(comment: comment, url: imageURL, userName:userName, date:date, guid:guid, commentOne:commentOne, commentTwo:commentTwo, image:nil)
        return post
    }
    
    init(comment:String, url:String, userName:String, date:Date, guid:String, commentOne:String, commentTwo:String, image:UIImage?) {
        self.comment = comment
        self.url = url
        self.userName = userName
        self.date = date
        self.guid = guid
        self.commentOne = commentOne
        self.commentTwo = commentTwo
        self.image = image
    }
}

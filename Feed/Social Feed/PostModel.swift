//
//  PostModel.swift
//  Feed
//
//  Created by Jason Howlin on 11/5/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

struct PostModel {
    let comment:String
    let url:String
    let userName:String
    let date:Date
    let guid:String
    let commentOne:String
    let commentTwo:String
    
    static func createModel(imageURL:String) -> PostModel {
        let comment = String.arbitraryWords(random(from: 8, to: 30))
        let commentOne = String.arbitraryWords(random(from: 8, to: 30))
        let commentTwo = String.arbitraryWords(random(from: 8, to: 30))
        let userName = String.arbitraryWords(3)
        let date = Date()
        let guid = UUID().uuidString
        let post = PostModel(comment: comment, url: imageURL, userName:userName, date:date, guid:guid, commentOne:commentOne, commentTwo:commentTwo)
        return post
    }
}

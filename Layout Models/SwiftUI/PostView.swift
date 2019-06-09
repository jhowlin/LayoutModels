//
//  PostView.swift
//  LayoutModels
//
//  Created by Jason Howlin on 6/6/19.
//  Copyright © 2019 Howlin. All rights reserved.
//

import SwiftUI
import Foundation
import Combine
import UIKit

extension PostDataModel: Identifiable {
    var id:String {
        return self.guid
    }
}

class PostContainerViewModel:BindableObject {
    
    static func createPosts() -> [PostDataModel] {
        let imageDownloadSize = CGSize(width: 400, height: 300)
        let url =
        "https://picsum.photos/\(Int(imageDownloadSize.width))/\(Int(imageDownloadSize.height))/?random"
        let numItems = 30
        return (0..<numItems).map { _ in return PostDataModel.createModel(imageURL: url)}
    }
    
    var posts:[PostDataModel] = PostContainerViewModel.createPosts() {
        didSet {
            didChange.send(self)
        }
    }
    
    let didChange = PassthroughSubject<PostContainerViewModel, Never>()
}

struct PostViewContainer: View {
    
    @ObjectBinding var viewModel:PostContainerViewModel

    var body: some View {
        
        List(viewModel.posts) { post in
            PostView(post: post)
                .onAppear {
                    self.onAppearForPost(post)
                }
        }
    }
    
    func onAppearForPost(_ post: PostDataModel) {
        // What dimensions can I request for??
        if let idx = viewModel.posts.firstIndex(where: { $0.guid == post.guid }) {
            print("Index: \(idx)")
        }
        let request = ImageFetcherRequest(url: post.url, identifier: post.guid)
        ImageFetcherController.shared.fetchImage(imageRequest:request) { result in
            switch result {
            case let .success(image, _):
                post.image = image
            case let .error(error, _):
                print(error)
            }
        }
    }
}

struct PostView : View {
    
    @ObjectBinding var post:PostDataModel
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Image("robyn").resizable().aspectRatio(nil, contentMode:.fill).frame(width:30, height:30).cornerRadius(15)
                Text(post.userName).bold().font(.caption)
                Spacer()
                Button(action: {
                    print("Tapped")
                }) {
                    Text("...").font(.headline)
                }
            }
            if post.image != nil {
                Image(uiImage: post.image!)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200.0, alignment:.top)
                    .clipped()
            } else {
                Rectangle()
                    .frame(height: 200.0, alignment:.top)
                    .foregroundColor(.gray)
            }
            HStack {
                Image("heart").resizable().aspectRatio(nil, contentMode:.fill).frame(width:23, height:23)
                Image("comment").resizable().aspectRatio(nil, contentMode:.fill).frame(width:23, height:23)
                Image("reply").resizable().aspectRatio(nil, contentMode:.fill).frame(width:23, height:23)
                Spacer()
                Text("posted today").font(.caption)
            }
            Text(post.comment)
                .lineLimit(nil)
                .font(.headline)
            Text(post.commentOne).lineLimit(nil).font(.caption).padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            Text(post.commentTwo).lineLimit(nil).font(.caption).padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}



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
import ImageFetcherController

extension PostDataModel: Identifiable {
    var id:String {
        return self.guid
    }
}

class PostContainerViewModel:ObservableObject {
    @Published var posts = PostContainerViewModel.createPosts()
    
    static func createPosts() -> [PostDataModel] {
        let imageDownloadSize = CGSize(width: 750, height: 400)
        let url =
        "https://picsum.photos/\(Int(imageDownloadSize.width))/\(Int(imageDownloadSize.height))/?random"
        let numItems = 30
        return (0..<numItems).map { _ in return PostDataModel.createModel(imageURL: url)}
    }
}

struct PostViewContainer: View {
    
    @ObservedObject var viewModel:PostContainerViewModel

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
    
    @ObservedObject var post:PostDataModel
    
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
                    .frame(height: 200.0, alignment:.top)
                    .clipped()
            } else {
                Rectangle()
                    .frame(height: 200.0, alignment:.top)
                    .foregroundColor(.gray)
            }
            HStack {
                
                Image(systemName: "heart").resizable().aspectRatio(nil, contentMode:.fill).frame(width:17, height:17).padding([.trailing, .top], 7)
                Image(systemName:"bubble.right").resizable().aspectRatio(nil, contentMode:.fill).frame(width:17, height:17).padding([.trailing, .top], 7)
                Image(systemName:"arrowshape.turn.up.left").resizable().aspectRatio(nil, contentMode:.fill).frame(width:17, height:17).padding([.trailing, .top], 7)
                Spacer()
                Text("posted today").font(.caption).fixedSize(horizontal: false, vertical: true)
            }
            Text(post.comment)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .font(.headline)
            Text(post.commentOne)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .font(.caption)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            Text(post.commentTwo)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .font(.caption)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}

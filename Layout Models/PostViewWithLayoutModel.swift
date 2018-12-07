//
//  PostViewWithLayoutModel.swift
//  LayoutModels
//
//  Created by Jason Howlin on 12/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

class PostCellWithLayoutModel:UITableViewCell {
    
    let postView = PostViewWithLayoutModel()

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

public class PostViewWithLayoutModel: UIView {

    var avatarImageView = UIImageView()
    var userNameLabel = UILabel()
    var optionsButton = UIButton()
    var postedImageView = UIImageView()
    var heartButton = UIButton()
    var commentButton = UIButton()
    var replyButton = UIButton()
    var hairlineView = UIView()
    var postHeadlineLabel = UILabel()
    var commentOneLabel = UILabel()
    var commentTwoLabel = UILabel()
    var dateLabel = UILabel()

    var info:PostViewInfo? {
        didSet {
            guard let info = info else { return }
            let model = info.viewModel

            userNameLabel.attributedText = model.userName
            postHeadlineLabel.attributedText = model.topComment
            commentOneLabel.attributedText = model.commentOne
            commentTwoLabel.attributedText = model.commentTwo
            dateLabel.attributedText = model.date
            setNeedsLayout()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(userNameLabel)

        optionsButton.setTitle("...", for: [])
        optionsButton.setTitleColor(UIColor.black, for: [])
        optionsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        addSubview(optionsButton)

        backgroundColor = UIColor.white

        let avatarImg = UIImage(named: "robyn.jpg")!
        avatarImageView.image = avatarImg

        addSubview(avatarImageView)

        avatarImageView.layer.cornerRadius = 15
        avatarImageView.layer.masksToBounds = true


        addSubview(postedImageView)
        postedImageView.clipsToBounds = false

        addSubview(heartButton)
        addSubview(commentButton)
        addSubview(replyButton)
        heartButton.setImage(UIImage(named:"heart.png"), for: [])
        commentButton.setImage(UIImage(named:"comment.png"), for: [])
        replyButton.setImage(UIImage(named:"reply.png"), for: [])

        commentOneLabel.numberOfLines = 0
        commentTwoLabel.numberOfLines = 0
        addSubview(commentOneLabel)
        addSubview(commentTwoLabel)

        commentOneLabel.backgroundColor = .white
        commentTwoLabel.backgroundColor = .white
        postHeadlineLabel.backgroundColor = .white
        userNameLabel.backgroundColor = .white
        postHeadlineLabel.numberOfLines = 0
        addSubview(postHeadlineLabel)
        hairlineView.backgroundColor = UIColor.lightGray
        hairlineView.alpha = 0.3
        addSubview(hairlineView)

        addSubview(dateLabel)
        dateLabel.numberOfLines = 0
        dateLabel.textAlignment = .right

    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let info = info else { return }

        let layout = info.layoutModel

        avatarImageView.frame = layout.avatarImageFrame
        userNameLabel.frame = layout.userNameLabelFrame
        optionsButton.frame = layout.optionsButtonFrame
        postedImageView.frame = layout.postedImageViewFrame
        heartButton.frame = layout.heartButtonFrame
        commentButton.frame = layout.commentButtonFrame
        replyButton.frame = layout.replyButtonFrame
        hairlineView.frame = layout.hairlineViewFrame
        postHeadlineLabel.frame = layout.topCommentLabelFrame
        commentOneLabel.frame = layout.commentOneLabelFrame
        commentTwoLabel.frame = layout.commentTwoLabelFrame
        dateLabel.frame = layout.dateLabelFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

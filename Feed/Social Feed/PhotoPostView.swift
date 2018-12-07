//
//  SlowView.swift
//  Feed
//
//  Created by Jason Howlin on 3/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import UIKit

public class PhotoPostView: UIView {

    var avatarImageView = UIImageView()
    var userNameLabel = UILabel()
    var optionsButton = UIButton()
    var postedImageView = UIImageView()
    var postedImage: UIImage?
    var heartButton = UIButton()
    var commentButton = UIButton()
    var replyButton = UIButton()
    var hairlineView = UIView()
    var buttonsStackView = UIStackView()
    var postHeadlineLabel = UILabel()
    var commentOneLabel = UILabel()
    var commentTwoLabel = UILabel()
    var dateLabel = UILabel()
    
    public init() {

        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = "robyncolon"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        optionsButton.setTitle("...", for: [])
        optionsButton.setTitleColor(UIColor.black, for: [])
        optionsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        optionsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        addSubview(userNameLabel)
        backgroundColor = UIColor.white
        let avatarImg = UIImage(named: "robyn.jpg")!
        avatarImageView.image = avatarImg
        
        addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.layer.masksToBounds = true
        
        addSubview(optionsButton)
        addSubview(postedImageView)

        postedImageView.contentMode = .scaleAspectFill
        postedImageView.clipsToBounds = true

        heartButton.setImage(UIImage(named:"heart.png"), for: [])
        commentButton.setImage(UIImage(named:"comment.png"), for: [])
        replyButton.setImage(UIImage(named:"reply.png"), for: [])
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        postedImageView.translatesAutoresizingMaskIntoConstraints = false
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        postHeadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        hairlineView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        commentOneLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTwoLabel.translatesAutoresizingMaskIntoConstraints = false

        commentOneLabel.numberOfLines = 0
        commentTwoLabel.numberOfLines = 0
        addSubview(commentOneLabel)
        addSubview(commentTwoLabel)
        
        postHeadlineLabel.numberOfLines = 0
        addSubview(postHeadlineLabel)
        hairlineView.backgroundColor = UIColor.lightGray
        hairlineView.alpha = 0.3
        addSubview(hairlineView)
        addSubview(buttonsStackView)
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 7
        buttonsStackView.addArrangedSubview(heartButton)
        buttonsStackView.addArrangedSubview(commentButton)
        buttonsStackView.addArrangedSubview(replyButton)
        
        addSubview(dateLabel)
        dateLabel.textAlignment = .right
        dateLabel.numberOfLines = 0
        NSLayoutConstraint.activate (
            [avatarImageView.heightAnchor.constraint(equalToConstant: 30),
             avatarImageView.widthAnchor.constraint(equalToConstant: 30),
             avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
             avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
             
             userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
             userNameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 0),
             
             optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
             optionsButton.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor, constant: 0),
             
             postedImageView.heightAnchor.constraint(equalToConstant: 250),
             postedImageView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
             postedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
             postedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
             
             heartButton.heightAnchor.constraint(equalToConstant: 23),
             heartButton.widthAnchor.constraint(equalToConstant: 23),
             
             commentButton.heightAnchor.constraint(equalToConstant: 23),
             commentButton.widthAnchor.constraint(equalToConstant: 23),
             
             replyButton.heightAnchor.constraint(equalToConstant: 23),
             replyButton.widthAnchor.constraint(equalToConstant: 23),
             
             avatarImageView.heightAnchor.constraint(equalToConstant: 30),
             avatarImageView.widthAnchor.constraint(equalToConstant: 30),
             avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
             
             buttonsStackView.topAnchor.constraint(equalTo: postedImageView.bottomAnchor, constant: 7),
             buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
             
             postHeadlineLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 10),
             postHeadlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
             postHeadlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
             
             commentOneLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
             commentOneLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
             commentOneLabel.topAnchor.constraint(equalTo: postHeadlineLabel.bottomAnchor, constant: 10),
             
             commentTwoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
             commentTwoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
             commentTwoLabel.topAnchor.constraint(equalTo: commentOneLabel.bottomAnchor, constant: 10),
             
             hairlineView.heightAnchor.constraint(equalToConstant: 0.5),
             hairlineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
             hairlineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
             hairlineView.topAnchor.constraint(equalTo: commentTwoLabel.bottomAnchor, constant: 20),
             
             dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
             dateLabel.topAnchor.constraint(equalTo: postedImageView.bottomAnchor, constant: 7),
             dateLabel.leadingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor, constant: 10)
            ]
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func setTopComment(comment:String) {
        
        let attrString = NSAttributedString(string: comment, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16, weight: .semibold)])
        postHeadlineLabel.attributedText = attrString
        setNeedsLayout()
    }
    
    func setUserName(userName:String) {
        let attrString = NSAttributedString(string: userName, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12, weight: .bold)])
        userNameLabel.attributedText = attrString
        setNeedsLayout()
    }
    
    func setCommentOne(comment:String) {
        let attrString = NSAttributedString(string: comment, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 10, weight: .regular)])
        commentOneLabel.attributedText = attrString
        setNeedsLayout()
    }
    
    func setCommentTwo(comment:String) {
        let attrString = NSAttributedString(string: comment, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 10, weight: .regular)])
        commentTwoLabel.attributedText = attrString
        setNeedsLayout()
    }
    
    func setDate(date:Date) {
        let dateString = cachedFormatter.string(from: date).lowercased()
        let attrString = NSAttributedString(string: "posted \(dateString)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12, weight: .light)])
        dateLabel.attributedText = attrString
        setNeedsLayout()
    }

    public override var intrinsicContentSize: CGSize {
        let height = self.hairlineView.frame.maxY
        return CGSize(width: bounds.size.width, height: height)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = self.hairlineView.frame.maxY
        return CGSize(width: size.width, height: height)
    }
}

class PhotoPostViewLayout {
    
    let insets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    let avatarWidthHeight:CGFloat = 30
    let avatarToUserNameSpacing:CGFloat = 10
    let userNameToOptionsSpacing:CGFloat = 10
    let optionsButtonWidthHeight:CGFloat = 20
    let imageViewTopPadding:CGFloat = 10
    let commentSpacing:CGFloat = 10
    let postedImageViewHeight:CGFloat = 250
    let buttonWidthHeight:CGFloat = 23
    let imageViewToButtonSpacing:CGFloat = 7
    let betweenButtonSpacing:CGFloat = 8
    let buttonToCommentSpacing:CGFloat = 10
    let imageToDateLabelSpacing:CGFloat = 6
    let hairlineViewInsets = UIEdgeInsets(top: 20, left: 14, bottom: 0, right: 20)
    let hairlineHeight:CGFloat = 0.5
    
    var avatarImageFrame = CGRect.zero
    var userNameLabelFrame = CGRect.zero
    var optionsButtonFrame = CGRect.zero
    var postedImageViewFrame = CGRect.zero
    var heartButtonFrame = CGRect.zero
    var commentButtonFrame = CGRect.zero
    var replyButtonFrame = CGRect.zero
    var hairlineViewFrame = CGRect.zero
    var topCommentLabelFrame = CGRect.zero
    var commentOneLabelFrame = CGRect.zero
    var commentTwoLabelFrame = CGRect.zero
    var dateLabelFrame = CGRect.zero
    var totalHeight:CGFloat = 0
    
    let viewModel:PhotoPostViewModel

    init(viewModel:PhotoPostViewModel) {
        self.viewModel = viewModel
    }
    
    func prepareLayoutForWidth(width:CGFloat) {
        
        var xOffset:CGFloat = insets.left
        var yOffset:CGFloat = insets.top
        
        avatarImageFrame = CGRect(x: xOffset, y: yOffset, width: avatarWidthHeight, height: avatarWidthHeight)
        
        xOffset += avatarWidthHeight
        xOffset += avatarToUserNameSpacing
        
        let availUserNameWidth = width - xOffset - userNameToOptionsSpacing - optionsButtonWidthHeight - insets.right
        let userNameHeight = viewModel.userName.heightConstrainedToWidth(availUserNameWidth)
        
        let avatarOffset = (avatarWidthHeight / 2) - (userNameHeight / 2)
        yOffset += avatarOffset
        
        userNameLabelFrame = CGRect(x: xOffset, y: yOffset, width: availUserNameWidth, height: userNameHeight)
        
        xOffset = width - insets.right - optionsButtonWidthHeight
        yOffset = insets.top
        
        let optionsOffset = (avatarWidthHeight / 2) - (optionsButtonWidthHeight / 2)
        yOffset += optionsOffset
        
        optionsButtonFrame = CGRect(x: xOffset, y: yOffset, width: optionsButtonWidthHeight, height: optionsButtonWidthHeight)
        
        yOffset = max(avatarImageFrame.maxY, userNameLabelFrame.maxY, optionsButtonFrame.maxY) + imageViewTopPadding
        
        xOffset = 0
        
        postedImageViewFrame = CGRect(x: xOffset, y: yOffset, width: width, height: postedImageViewHeight)
        
        yOffset = postedImageViewFrame.maxY + imageViewToButtonSpacing
        
        xOffset = insets.left
        
        heartButtonFrame = CGRect(x: xOffset, y: yOffset, width: buttonWidthHeight, height: buttonWidthHeight)
        
        xOffset = heartButtonFrame.maxX + betweenButtonSpacing
        
        commentButtonFrame = CGRect(x: xOffset, y: yOffset, width: buttonWidthHeight, height: buttonWidthHeight)
        
        xOffset = commentButtonFrame.maxX + betweenButtonSpacing
        
        replyButtonFrame = CGRect(x: xOffset, y: yOffset, width: buttonWidthHeight, height: buttonWidthHeight)
        
        xOffset = replyButtonFrame.maxX + betweenButtonSpacing
        
        let dateAvailWidth = width - insets.right - xOffset
        let dateHeight = viewModel.date.heightConstrainedToWidth(dateAvailWidth)
        dateLabelFrame = CGRect(x: xOffset, y: yOffset, width: dateAvailWidth, height: dateHeight)
        
        xOffset = insets.left
        yOffset = max(replyButtonFrame.maxY + buttonToCommentSpacing, dateLabelFrame.maxY + buttonToCommentSpacing)
        
        let topCommentAvailWidth = width - insets.left - insets.right
        
        let topCommentHeight = viewModel.topComment.heightConstrainedToWidth(topCommentAvailWidth)
        
        topCommentLabelFrame = CGRect(x: xOffset, y: yOffset, width: topCommentAvailWidth, height: topCommentHeight)
        
        yOffset = topCommentLabelFrame.maxY + commentSpacing
        
        let commentOneHeight = viewModel.commentOne.heightConstrainedToWidth(topCommentAvailWidth)
        
        commentOneLabelFrame = CGRect(x: xOffset, y: yOffset, width: topCommentAvailWidth, height: commentOneHeight)
        
        yOffset = commentOneLabelFrame.maxY + commentSpacing
        
        let commentTwoHeight = viewModel.commentTwo.heightConstrainedToWidth(topCommentAvailWidth)
        
        commentTwoLabelFrame = CGRect(x: xOffset, y: yOffset, width: topCommentAvailWidth, height: commentTwoHeight)
        
        xOffset = hairlineViewInsets.left
        
        yOffset = commentTwoLabelFrame.maxY + hairlineViewInsets.top
        
        let hairlineWidth = width - hairlineViewInsets.left - hairlineViewInsets.right
        
        hairlineViewFrame = CGRect(x: xOffset, y: yOffset, width: hairlineWidth, height: 0.5)
        
        yOffset = hairlineViewFrame.maxY + hairlineViewInsets.bottom
        
        totalHeight = yOffset + insets.bottom
    }
}

class PhotoPostCachedAttributes {
    var topCommentsAttr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 16, weight: .semibold)]
    var userNameAttr: [NSAttributedString.Key:Any] = [.font:UIFont.boldSystemFont(ofSize: 12)]
    var commentAttr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 10, weight: .regular)]
    var dateAttr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 12, weight: .light)]
}

let cachedAttributes = PhotoPostCachedAttributes()
let cachedFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

class PhotoPostViewModel {
    
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
        let dateLabelString = "posted \(cachedFormatter.string(from: date).lowercased())"
        self.date = NSAttributedString(string: dateLabelString, attributes: cachedAttributes.dateAttr)
    }
}

public class PhotoPostViewWithLayout: UIView {
    
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
    
    var info:PhotoPostViewInfo? {
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

        let layout = info.layout
        
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

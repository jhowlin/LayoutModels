//
//  SlowView.swift
//  Feed
//
//  Created by Jason Howlin on 3/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import UIKit

class PostCellWithAutoLayout:UITableViewCell {
    
    let postView = PostViewWithAutoLayout()

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

public class PostViewWithAutoLayout: UIView {

    var avatarImageView = UIImageView()
    var userNameLabel = UILabel()
    var optionsButton = UIButton()
    var postedImageView = UIImageView()
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

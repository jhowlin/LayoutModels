//
//  PostLayoutModel.swift
//  LayoutModels
//
//  Created by Jason Howlin on 12/7/18.
//  Copyright © 2018 Howlin. All rights reserved.
//

import Foundation
import UIKit

class PostLayoutModel {

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

    let viewModel:PostViewModel

    init(viewModel:PostViewModel) {
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

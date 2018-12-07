//
//  StringMeasuring.swift
//  ImagesController_Example
//
//  Created by Jason Howlin on 1/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension String {
    public func heightForAttributedString(_ string:NSAttributedString, constrainedToWidth width:CGFloat) -> CGFloat {
        let options: NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading]
        let rect = string.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: options, context: nil)
        let height = ceil(rect.size.height)
        return height
    }
                                                                                     
    public func heightWithFont(_ font:UIFont, constrainedToWidth width:CGFloat) -> CGFloat {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font:font])
        return heightForAttributedString(attributedString, constrainedToWidth: width)
    }
}

extension NSAttributedString {
    func heightConstrainedToWidth(_ width:CGFloat) -> CGFloat {
        let options: NSStringDrawingOptions =
            [NSStringDrawingOptions.usesLineFragmentOrigin,
             NSStringDrawingOptions.usesFontLeading]
        let rect = self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: options, context: nil)
        let height = rect.size.height.rounded(.up)
        return height
    }
    
    func heightForAttributedStringInTextViewWithNoPadding(constrainedToWidth width:CGFloat) -> CGFloat {
        let textStorage = NSTextStorage(attributedString: self)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let container = NSTextContainer(size: CGSize(width: width, height:0))
        container.lineFragmentPadding = 0
        layoutManager.addTextContainer(container)
        layoutManager.ensureLayout(for: container)
        let height = layoutManager.usedRect(for: container).size.height.rounded(.up)
    
        return height
    }
}



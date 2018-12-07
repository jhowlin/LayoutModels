import UIKit
import PlaygroundSupport
/*:

 # High-Performance Scrolling Using Layout Models

 ## Layout models provide the size and position information for a view's subviews, without needing to actually render the view.

 ****

To achieve 60 FPS scrolling, we want to spend as little time as possible configuring our table view and cells for display. We create a view model, which is a formatted view of our data, and use that to create a layout model.

 The layout model contains all of the size and position information for the cell’s subviews, without actually rendering a view. Because there is no UI, the view and layout models can be calculated off of the main thread, and can be cached.

 Table view operations, such as calculating the height for a row, or dequeing a cell and configuring your labels, becomes very fast because the work has already been completed -- we simply apply the frames we’ve calculated and set our labels and the content on our UI elements.


 - experiment:
 Run the playground to execute the code below.
 \
 Change width

 * Change width


 */

let widthConstraint:CGFloat = 275

struct Post {
    var headline = "How to Turbo Charge Flu Protection (Llamas Required)"
    var summary = "A giant antibody is offering new hope against a winter misery."
}

class PostView:UIView {
    let headlineLabel = UILabel()
    let summaryLabel = UILabel()
    
    var post:Post? {
        didSet {
            guard let post = post else { return }
            let headline = NSAttributedString(string: post.headline, attributes: [.font:UIFont.systemFont(ofSize: 24, weight: .black)])
            let summary = NSAttributedString(string: post.summary, attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold)])
            headlineLabel.attributedText = headline
            summaryLabel.attributedText = summary
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(headlineLabel)
        addSubview(summaryLabel)

        headlineLabel.numberOfLines = 0
        summaryLabel.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let spacing:CGFloat = 10

        var offset = CGPoint(x: margins.left, y: margins.top)
        let availableWidth = bounds.size.width - margins.left - margins.right

        let headlineHeight = headlineLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude)).height.rounded(.up)
        headlineLabel.frame = CGRect(x: offset.x, y: offset.y, width: availableWidth, height: headlineHeight)
        offset.y = headlineLabel.frame.maxY + spacing
        let summaryHeight = summaryLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude)).height.rounded(.up)
        summaryLabel.frame = CGRect(x: offset.x, y: offset.y, width: availableWidth, height: summaryHeight)
    }
    
    class func heightForPostConstrainedToWidth(_ width:CGFloat, article:Post) -> CGFloat {
        let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let spacing:CGFloat = 10

        var offset = CGPoint(x: margins.left, y: margins.top)
        let availableWidth = width - margins.left - margins.right

        let headline = NSAttributedString(string: article.headline, attributes: [.font:UIFont.systemFont(ofSize: 24, weight: .black)])
        let summary = NSAttributedString(string: article.summary, attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold)])
        let headlineHeight = headline.boundingRect(with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil).size.height.rounded(.up)
        offset.y += headlineHeight + spacing
        let summaryHeight = summary.boundingRect(with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil).size.height.rounded(.up)
        offset.y += summaryHeight
        return offset.y + spacing
    }
}

struct PostInfo {
    let postViewModel:PostViewModel
    let postLayoutModel:PostLayoutModel
}

class PostViewModel {

    var headlineAttributedString:NSAttributedString
    var summaryAttributedString:NSAttributedString

    init(post:Post) {
        self.headlineAttributedString = NSAttributedString(string: post.headline, attributes: [.font:UIFont.systemFont(ofSize: 24, weight: .black)])
        self.summaryAttributedString = NSAttributedString(string: post.summary, attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold)])
    }
}

class PostLayoutModel {

    var headlineLabelFrame = CGRect.zero
    var summaryLabelFrame = CGRect.zero
    var totalHeight:CGFloat = 0
    var totalWidth:CGFloat = 0

    let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let spacing:CGFloat = 10

    var postViewModel:PostViewModel

    init(postViewModel:PostViewModel) {
        self.postViewModel = postViewModel
    }

    func prepareForWidth(width:CGFloat) {
        var offset = CGPoint(x: margins.left, y: margins.top)
        let availableWidth = width - (margins.left + margins.right)
        let headlineHeight = postViewModel.headlineAttributedString.boundingRect(with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil).size.height.rounded(.up)
        headlineLabelFrame = CGRect(x: offset.x, y: offset.y, width: availableWidth, height: headlineHeight)
        offset.y = headlineLabelFrame.maxY + spacing
        let summaryHeight = postViewModel.summaryAttributedString.boundingRect(with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil).size.height.rounded(.up)
        summaryLabelFrame = CGRect(x: offset.x, y: offset.y, width: availableWidth, height: summaryHeight)
        totalHeight = summaryLabelFrame.maxY + spacing
        totalWidth = width
    }
}

class PostViewUsingLayoutModel:UIView {
    let headlineLabel = UILabel()
    let summaryLabel = UILabel()

    var postInfo:PostInfo? {
        didSet {
            guard let postInfo = postInfo else { return }
            headlineLabel.attributedText = postInfo.postViewModel.headlineAttributedString
            summaryLabel.attributedText = postInfo.postViewModel.summaryAttributedString
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(headlineLabel)
        addSubview(summaryLabel)

        headlineLabel.numberOfLines = 0
        summaryLabel.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        guard let layout = postInfo?.postLayoutModel else { return }
        headlineLabel.frame = layout.headlineLabelFrame
        summaryLabel.frame = layout.summaryLabelFrame
    }
}

class PostLayoutModelPlaygroundView:UIView {
    
    
    
}


class DimensionDisplayingView:UIView {
    let heightLabel = UILabel()
    let widthLabel = UILabel()
    let xLabel = UILabel()
    let yLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configLabel(label: heightLabel)
        configLabel(label: widthLabel)
        //configLabel(label: xLabel)
        //configLabel(label: yLabel)

        
        
        
    }
    
    override func layoutSubviews() {
        xLabel.text = "\(frame.origin.x)"
        xLabel.sizeToFit()
        yLabel.text = "\(frame.origin.y)"
        yLabel.sizeToFit()
        heightLabel.text = "\(frame.size.height)"
        heightLabel.sizeToFit()
        widthLabel.text = "\(frame.size.width)"
        widthLabel.sizeToFit()
        
        let margin:CGFloat = 2
        
        widthLabel.frame = CGRect(x: bounds.size.width / 2 - widthLabel.bounds.width / 2, y: bounds.height - widthLabel.bounds.height - margin, width: widthLabel.bounds.width, height: widthLabel.bounds.height)
        
        
        heightLabel.frame = CGRect(x: margin, y: bounds.size.height / 2.0 - heightLabel.bounds.height / 2, width: heightLabel.bounds.width, height: heightLabel.bounds.height)
        
        
    }
    
    func configLabel(label:UILabel) {
        addSubview(label)
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.numberOfLines = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}



let post = Post()

let height = PostView.heightForPostConstrainedToWidth(widthConstraint, article: post)
print(height)
let frame = CGRect(x: 0, y: 0, width: widthConstraint, height: height)
let postView = PostView(frame: frame)
postView.post = post
PlaygroundPage.current.liveView = postView

PlaygroundPage.current.needsIndefiniteExecution = true

extension PostLayoutModel:CustomPlaygroundDisplayConvertible {
    var playgroundDescription: Any {
        let view = DimensionDisplayingView(frame: CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        view.backgroundColor = .white
        let headline = DimensionDisplayingView(frame: headlineLabelFrame)
        headline.backgroundColor = UIColor.withAlphaComponent(.black)(0.3)
        let summary = DimensionDisplayingView(frame: summaryLabelFrame)
        summary.backgroundColor = UIColor.withAlphaComponent(.black)(0.3)
        view.addSubview(headline)
        view.addSubview(summary)
        return view
    }
}


let postViewModel = PostViewModel(post: post)
let postLayoutModel = PostLayoutModel(postViewModel: postViewModel)
postLayoutModel.prepareForWidth(width: widthConstraint)



let postInfo = PostInfo(postViewModel: postViewModel, postLayoutModel: postLayoutModel)
let postViewUsingLayoutModel = PostViewUsingLayoutModel(frame: CGRect(x: 0, y: 0, width: widthConstraint, height: postLayoutModel.totalHeight))
postViewUsingLayoutModel.postInfo = postInfo
PlaygroundPage.current.liveView = postView

class LayoutModel {
    var avatarFrame = CGRect(x: 10, y: 10, width: 30, height: 30)
    var imageFrame = CGRect(x: 10, y: 50, width: 300, height: 210)
    var textFrame = CGRect(x: 10, y: 270, width: 280, height: 40)
    var totalHeight:CGFloat = 320
}



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
import UIKit
import PlaygroundSupport

let widthConstraint:CGFloat = 275

struct Post {
    var headline = "How to Turbo Charge Flu Protection (Llamas Required)"
    var summary = "A giant antibody is offering new hope against a winter misery."
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

    var postInfo:(PostViewModel, PostLayoutModel)? {
        didSet {
            guard let postInfo = postInfo else { return }
            headlineLabel.attributedText = postInfo.0.headlineAttributedString
            summaryLabel.attributedText = postInfo.0.summaryAttributedString
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
        guard let layout = postInfo?.1 else { return }
        headlineLabel.frame = layout.headlineLabelFrame
        summaryLabel.frame = layout.summaryLabelFrame
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

DispatchQueue.global().async {
    let postDataModel = Post()
    let postViewModel = PostViewModel(post: postDataModel)
    let postLayoutModel = PostLayoutModel(postViewModel: postViewModel)
    postLayoutModel.prepareForWidth(width: widthConstraint)
    DispatchQueue.main.async {
        let postViewUsingLayoutModel = PostViewUsingLayoutModel(frame: CGRect(x: 0, y: 0, width: widthConstraint, height: postLayoutModel.totalHeight))
        postViewUsingLayoutModel.postInfo = (postViewModel, postLayoutModel)
        PlaygroundPage.current.liveView = postViewUsingLayoutModel
    }
}


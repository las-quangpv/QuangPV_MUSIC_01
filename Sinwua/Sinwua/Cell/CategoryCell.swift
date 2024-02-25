

import UIKit
import Lottie

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var vAnimation: UIView!
    @IBOutlet weak var vAdd: UIView!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var lblCategory: UILabel!
    private let animationLoading = LottieAnimationView(name: "add")
    var addClickBlock:((Int, String) -> Void)!
    var indexCategory: Int = -1
    override func awakeFromNib() {
        super.awakeFromNib()
        animationLoading.contentMode = .scaleAspectFit
        vAnimation.addSubview(animationLoading)
        animationLoading.frame = CGRect(x: 0, y: 0, width: vAnimation.frame.width, height: vAnimation.frame.height)
        DispatchQueue.main.async {
            self.animationLoading.play(fromProgress: 0,
                                       toProgress: 1,
                                       loopMode: LottieLoopMode.loop,
                                       completion: { (finished) in})
            
        }
    }

    @IBAction func actionSelect(_ sender: Any) {
        if(addClickBlock != nil) {
            self.addClickBlock(indexCategory, "select")
        }
    }
    @IBAction func actionAdd(_ sender: Any) {
        if(addClickBlock != nil) {
            self.addClickBlock(indexCategory, "add")
        }
    }
}

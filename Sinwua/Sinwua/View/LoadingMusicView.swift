import Foundation
import UIKit
import Lottie
class LoadingMusicView: UIView {
    var animationView: LottieAnimationView = LottieAnimationView(name: "anim_loading")

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "LoadingMusicView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
            settingAnimation(view: view)
        }
    }
    private func settingAnimation(view: UIView) {
          animationView.frame = CGRect(x: App.screenWidth()/2 - 80, y: App.screenHeight()/2 - 80, width: 160, height: 160)
          animationView.contentMode = .scaleAspectFit
          animationView.loopMode = .loop
          view.addSubview(animationView)
    }
}

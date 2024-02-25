

import UIKit
import XLPagerTabStrip
import Gifu
class BasVC: UIViewController, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = "View"
    
    @IBOutlet weak var ivGif: GIFImageView!
    init(itemInfo: IndicatorInfo) {
        super.init(nibName: nil, bundle: nil)
        self.itemInfo = itemInfo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        MusicManager.getInstance.delegate = self
        ivGif.prepareForAnimation(withGIFNamed: "ic_gif") {
            print("Ready to animate!")
          }
        ivGif.startAnimatingGIF()
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
extension BasVC: MusicManagerDelegate{
    func progressMusic(currentTime: Double, duration: TimeInterval) {
        
    }
    func musicState(state: MusicState) {
        print("22222222222")
        if(state == MusicState.Pause) {
            ivGif.stopAnimating()
        }else {
            ivGif.startAnimating()
        }
    }
    
}

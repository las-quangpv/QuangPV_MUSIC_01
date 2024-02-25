
import UIKit
import StoreKit
import XLPagerTabStrip

class SettingVC: BaseVC, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = "View"
    init(itemInfo: IndicatorInfo) {
        super.init(nibName: nil, bundle: nil)
        self.itemInfo = itemInfo
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBOutlet weak var vAudio: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewPlayer(v: vAudio, controller: self)
        setupView()
    }
    func setupView() {
        if let _ = MusicManager.getInstance.currentMusicModel() {
            vAudio.isHidden = false
        }else {
            vAudio.isHidden = true
        }
    }
    
    @IBAction func rateApp(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                if #available(iOS 14.0, *) {
                    SKStoreReviewController.requestReview(in: windowScene)
                } else {
                    SKStoreReviewController.requestReview()
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        } else {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

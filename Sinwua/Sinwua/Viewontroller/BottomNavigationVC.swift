

import UIKit
import XLPagerTabStrip
class BottomNavigationVC: BarPagerTabStripViewController {
    @IBOutlet weak var ivFav: UIImageView!
    @IBOutlet weak var ivSetting: UIImageView!
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var lblFav: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var ivHome: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let listController: [UIViewController] = [HomeVC(itemInfo: IndicatorInfo(title: "")),
                                                  FavouriteVC(itemInfo: IndicatorInfo(title: "")),
                                                  SettingVC(itemInfo: IndicatorInfo(title: ""))]
        return listController
    }
    
    @IBAction func actionHome(_ sender: Any) {
        self.moveToViewController(at: 0)
        ivHome.image = UIImage(named: "ic_home_select")
        lblHome.textColor = UIColor(rgb: 0xFFFFFF)
        ivFav.image = UIImage(named: "ic_music")
        lblFav.textColor = UIColor(rgb: 0xED9728)
        ivSetting.image = UIImage(named: "ic_setting")
        lblSetting.textColor = UIColor(rgb: 0xED9728)
    }
    
    @IBAction func actionSearch(_ sender: Any) {
        let vc = SearchVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionFav(_ sender: Any) {
        self.moveToViewController(at: 1)
        ivHome.image = UIImage(named: "ic_home")
        lblHome.textColor = UIColor(rgb: 0xED9728)
        ivFav.image = UIImage(named: "ic_music_select")
        lblFav.textColor = UIColor(rgb: 0xFFFFFF)
        ivSetting.image = UIImage(named: "ic_setting")
        lblSetting.textColor = UIColor(rgb: 0xED9728)
    }
    
    
    @IBAction func actionSetting(_ sender: Any) {
        self.moveToViewController(at: 2)
        ivHome.image = UIImage(named: "ic_home")
        lblHome.textColor = UIColor(rgb: 0xED9728)
        ivFav.image = UIImage(named: "ic_music")
        lblFav.textColor = UIColor(rgb: 0xED9728)
        ivSetting.image = UIImage(named: "ic_setting_select")
        lblSetting.textColor = UIColor(rgb: 0xFFFFFF)
    }
}

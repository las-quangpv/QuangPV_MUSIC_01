

import UIKit
import XLPagerTabStrip
class PlayerVC: BarPagerTabStripViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnLoop: UIButton!
    @IBOutlet weak var btnShuler: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var btnPlayer: UIButton!
    @IBOutlet weak var lblEnd: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAlbum: UILabel!
    @IBOutlet weak var vSlider: UISlider!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MusicManager.getInstance.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlayerUpdate), name: Notification.Name(rawValue: "reloadData"), object: nil);
        
        vSlider.minimumValue = 0
        vSlider.maximumValue = 1
        MusicManager.getInstance.setupTimeObserver()
        setupView()
        // Do any additional setup after loading the view.
    }
   
    func setupView() {
        if let musicModel = MusicManager.getInstance.currentMusicModel() {
            lblName.text = musicModel.name
            togetherPlayButton()
            togetherLoopButtion()
            togetherShulfeButtion()
            togetherFavButton()
        }
        
    }
    func togetherLoopButtion() {
        if(MusicManager.getInstance.isLoop) {
            btnLoop.setImage(UIImage(named: "ic_round_player"), for: .normal)
        }else {
            btnLoop.setImage(UIImage(named: "ic_not_round"), for: .normal)
        }
    }
    
    func togetherShulfeButtion() {
        if(MusicManager.getInstance.isShufle) {
            btnShuler.setImage(UIImage(named: "ic_shuffle"), for: .normal)
        }else {
            btnShuler.setImage(UIImage(named: "ic_not_shuffle"), for: .normal)
        }
    }
    
    func togetherPlayButton() {
        if(MusicManager.getInstance.isPlaying()) {
            btnPlayer.setImage(UIImage(named: "ic_pause_Player"), for: .normal)
        }else {
            btnPlayer.setImage(UIImage(named: "ic_play_player"), for: .normal)
        }
    }
    func togetherFavButton() {
        if let musicModel = MusicManager.getInstance.currentMusicModel() {
            if(musicModel.favourite == FavouriteEnum.FAV.rawValue) {
                btnFav.setImage(UIImage(named: "ic_fav_player"), for: .normal)
            }else {
                btnFav.setImage(UIImage(named: "ic_not_fav_player"), for: .normal)
            }
        }
    }
    
    @objc func musicPlayerUpdate(_ notification: Notification) {
        if let _ = notification.object as? MusicModel {
            setupView()
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let indicatorInfo: IndicatorInfo = IndicatorInfo(title: "")
        var listController: [UIViewController] = []
        listController.append(BasVC(itemInfo: indicatorInfo))
        let playlistVC = PlayListVC(itemInfo: indicatorInfo, musicList: MusicManager.getInstance.playlist)
        playlistVC.delegate = self
        listController.append(playlistVC)
        return listController
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if toIndex >= 2 {
            return
        } else if toIndex < 0{
            return
        }
        
        pageControl.currentPage = toIndex
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let time = Double(sender.value) * MusicManager.getInstance.duration
        MusicManager.getInstance.seek(to: time)
        togetherPlayButton()
    }

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionMore(_ sender: Any) {
        if let musicModel = MusicManager.getInstance.currentMusicModel() {
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url: URL? = docURL.appendingPathComponent(musicModel.file_path)

            let vBottom = UIView(frame: CGRect(x: App.screenWidth()/2, y: App.screenHeight()-56, width: 300, height: 20))
            self.view.addSubview(vBottom)
            if let url = url {
                let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                share.popoverPresentationController?.sourceView = vBottom
                self.present(share, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionFavourite(_ sender: Any) {
        if let musicModel = MusicManager.getInstance.currentMusicModel() {
            if(musicModel.favourite == 0) {
                musicModel.favourite = FavouriteEnum.FAV.rawValue
            }else {
                musicModel.favourite = FavouriteEnum.NOT_FAV.rawValue
            }
            SQLiteMusicServices.newInstance().updateMusic(musicModel: musicModel)
        }
        togetherFavButton()
    }
    
    @IBAction func actionTogether(_ sender: Any) {
        if(MusicManager.getInstance.isPlaying()) {
            MusicManager.getInstance.pause()
            btnPlayer.setImage(UIImage(named: "ic_play_player"), for: .normal)
        }else {
            MusicManager.getInstance.resume()
            btnPlayer.setImage(UIImage(named: "ic_pause_Player"), for: .normal)
        }
    }
    
    @IBAction func actionPrevious(_ sender: Any) {
        MusicManager.getInstance.previous()
        setupView()
    }
    @IBAction func actionNext(_ sender: Any) {
        MusicManager.getInstance.next()
        setupView()
    }
    
    @IBAction func actionLoop(_ sender: Any) {
        MusicManager.getInstance.isLoop = !MusicManager.getInstance.isLoop
        setupView()
    }
    
    @IBAction func actionShule(_ sender: Any) {
        MusicManager.getInstance.isShufle = !MusicManager.getInstance.isShufle
        setupView()
    }
    
}
extension PlayerVC: MusicManagerDelegate, PlayListDelegate {
    func progressMusic(currentTime: Double, duration: TimeInterval) {
        // Cập nhật Slider và Label
        vSlider.value = Float(currentTime / duration)
        lblStart.text = convertTimeToHHMM(time: currentTime)
        lblEnd.text = convertTimeToHHMM(time: duration)
    }
    func musicState(state: MusicState) {
        togetherPlayButton()
    }
    func playlistSelect(musicModel: MusicModel) {
        setupView()
    }
}


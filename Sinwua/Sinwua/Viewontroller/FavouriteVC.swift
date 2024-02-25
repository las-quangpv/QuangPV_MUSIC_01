

import UIKit
import XLPagerTabStrip
import Lottie
enum FavouriteEnum: Int {
    case FAV = 1
    case NOT_FAV = 0
}
class FavouriteVC: BaseVC, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = "View"
    init(itemInfo: IndicatorInfo) {
        super.init(nibName: nil, bundle: nil)
        self.itemInfo = itemInfo
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var vShuffle: BaseUiView!
    @IBOutlet weak var vEmpty: UIView!
    @IBOutlet weak var tbvMusic: UITableView!
    @IBOutlet weak var vAudio: UIView!
    @IBOutlet weak var viewAnimation: UIView!
    private let animationLoading = LottieAnimationView(name: "empty")
    var musicList = [MusicModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvMusic.delegate = self
        tbvMusic.dataSource = self
        tbvMusic.register(UINib(nibName: "MusicCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewPlayer(v: vAudio, controller: self)
        
        let list = SQLiteMusicServices.newInstance().getMusics(category: "")
        musicList = list.filter({ musicModel in
            return musicModel.favourite == FavouriteEnum.FAV.rawValue
        })
        setupView()
        checkEmpty()
        tbvMusic.reloadData()

        animationLoading.contentMode = .scaleAspectFit
        viewAnimation.addSubview(animationLoading)
        animationLoading.frame = CGRect(x: 0, y: 0, width: viewAnimation.frame.width, height: viewAnimation.frame.height)
        DispatchQueue.main.async {
            self.animationLoading.play(fromProgress: 0,
                                       toProgress: 1,
                                       loopMode: LottieLoopMode.loop,
                                       completion: { (finished) in})
            
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    func checkEmpty() {
        if(musicList.count == 0) {
            vEmpty.isHidden = false
            vShuffle.isHidden = true
        }else {
            vEmpty.isHidden = true
            vShuffle.isHidden = false
        }
    }
    func setupView() {
        if let _ = MusicManager.getInstance.currentMusicModel() {
            vAudio.isHidden = false
        }else {
            vAudio.isHidden = true
        }
    }
    func actionMore(musicModel: MusicModel) {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url: URL? = docURL.appendingPathComponent(musicModel.file_path)

        let vBottom = UIView(frame: CGRect(x: App.screenWidth()/2, y: App.screenHeight()-56, width: 300, height: 20))
        self.view.addSubview(vBottom)
        let makerAlert = UIAlertController(title: musicModel.name, message: nil, preferredStyle: .actionSheet)
        makerAlert.popoverPresentationController?.sourceView = vBottom
        
        makerAlert.addAction(UIAlertAction(title: "Share", style: .default , handler:{ (UIAlertAction)in
            if let url = url {
                let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                share.popoverPresentationController?.sourceView = vBottom
                self.present(share, animated: true, completion: nil)
            }
        }))
        
        makerAlert.addAction(UIAlertAction(title: "Delete", style: .default , handler:{ [self] (UIAlertAction)in
            musicList.removeAll { musicSelect in
                return musicSelect.name == musicModel.name && musicModel.file_path == musicModel.file_path
            }
            SQLiteMusicServices.newInstance().deleteBookMark(musicModel: musicModel)
            tbvMusic.reloadData()
            checkEmpty()
        }))
        
        makerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                
        }))
        
        self.present(makerAlert, animated: true)
    }
    
    @IBAction func actionShuffle(_ sender: Any) {
        MusicManager.getInstance.isShufle = true
        MusicManager.getInstance.playMusicWithNewList(musicList: musicList)
    }
    
}
extension FavouriteVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let musicModel = musicList[indexPath.row]
        cell.btnFav.isHidden = false
        if(musicModel.favourite == FavouriteEnum.FAV.rawValue) {
            cell.btnFav.setImage(UIImage(named: "ic_heart_red"), for: .normal)
        }else {
            cell.btnFav.setImage(UIImage(named: "ic_heart_white"), for: .normal)
        }
        cell.setData(musicModel: musicModel)
        cell.itemCLickBlock = { musicModel, typeButton in
            if(typeButton == MusicCellType.More) {
                // show dialog
                self.actionMore(musicModel: musicModel)
            }else if(typeButton == MusicCellType.Fav) {
                if(musicModel.favourite == 0) {
                    musicModel.favourite = FavouriteEnum.FAV.rawValue
                }else {
                    musicModel.favourite = FavouriteEnum.NOT_FAV.rawValue
                }
                if let currentMusicModel = MusicManager.getInstance.currentMusicModel() {
                    if(currentMusicModel.name == musicModel.name && currentMusicModel.file_path == musicModel.file_path) {
                        currentMusicModel.favourite = musicModel.favourite
                    }
                }
                SQLiteMusicServices.newInstance().updateMusic(musicModel: musicModel)
                self.tbvMusic.reloadData()
            }
            else {
                // play audio
                MusicManager.getInstance.addMusicModelAndPlay(musicModel: musicModel)
                let vc = PlayerVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}



import UIKit
import XLPagerTabStrip

protocol PlayListDelegate {
    func playlistSelect(musicModel: MusicModel)
}
class PlayListVC: BaseVC, IndicatorInfoProvider {
    @IBOutlet weak var tbvMusic: UITableView!
    var musicList = [MusicModel]()
    var delegate: PlayListDelegate?

    var itemInfo: IndicatorInfo = "View"
    var musicSelectModel: MusicModel?
    init(itemInfo: IndicatorInfo, musicList: [MusicModel]) {
        super.init(nibName: nil, bundle: nil)
        self.itemInfo = itemInfo
        self.musicList = musicList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        musicSelectModel = MusicManager.getInstance.currentMusicModel()
        NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlayerUpdate), name: Notification.Name(rawValue: "reloadData"), object: nil);
        
        tbvMusic.delegate = self
        tbvMusic.dataSource = self
        tbvMusic.register(UINib(nibName: "MusicCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    @objc func musicPlayerUpdate(_ notification: Notification) {
        if let musicModel = notification.object as? MusicModel {
            musicSelectModel = musicModel
            tbvMusic.reloadData()
        }
    }
}
extension PlayListVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let musicModel = musicList[indexPath.row]
        cell.setData(musicModel: musicModel)
        if(musicModel.name == musicSelectModel?.name && musicModel.file_path == musicSelectModel?.file_path) {
            cell.ivGradient.image = UIImage(named: "ic_gradient_select")
        }else {
            cell.ivGradient.image = UIImage(named: "ic_gradient")
        }
        cell.btnMore.isHidden = false
        cell.btnMore.setImage(UIImage(named: "ic_delete"), for: .normal)
        cell.itemCLickBlock = { musicModel, typeButton in
            if(typeButton == MusicCellType.More) {
                // show dialog
               
                if let musicNowModel = MusicManager.getInstance.currentMusicModel() {
                    if(musicNowModel.name == musicModel.name && musicNowModel.file_path == musicModel.file_path) {
                        self.showMessage(message: "The currently playing song cannot be deleted") {
                            
                        }
                    }else {
                        if(self.musicList.count > 1) {
                            self.musicList.removeAll { musicSelect in
                                return musicSelect.name == musicModel.name && musicSelect.file_path == musicModel.file_path
                            }
                            MusicManager.getInstance.playlist = self.musicList
                            let currentNew = self.musicList.firstIndex { musicFindModel in
                                return musicFindModel.name == musicModel.name && musicFindModel.file_path == musicModel.file_path
                            } ?? 0
                            MusicManager.getInstance.currentIndex = currentNew
                            self.tbvMusic.reloadData()

                        }
                       
                    }
                }
            }else {
                MusicManager.getInstance.addMusicModelAndPlay(musicModel: musicModel)
                if(self.delegate != nil) {
                    self.delegate?.playlistSelect(musicModel: musicModel)
                }
                // play audio
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

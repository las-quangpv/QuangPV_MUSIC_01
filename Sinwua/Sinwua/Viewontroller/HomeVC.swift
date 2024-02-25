
import UIKit
import XLPagerTabStrip
import Lottie
import MediaPlayer

class HomeVC: BaseVC, IndicatorInfoProvider {
    @IBOutlet weak var tbvMusic: UITableView!
    @IBOutlet weak var vEmpty: UIView!
    @IBOutlet weak var vListEmpty: UIView!
    @IBOutlet weak var clvCategory: UICollectionView!
    @IBOutlet weak var vAudio: UIView!
    @IBOutlet weak var clvAlbum: UICollectionView!
    @IBOutlet weak var lblEmpty: UILabel!
    @IBOutlet weak var viewAnimation: UIView!
    private let animationLoading = LottieAnimationView(name: "empty")
    var itemInfo: IndicatorInfo = "View"
    var categories: [String] = ["All Song", "Album", "Cloud", "Box Driver"]
    var indexCategory: Int = 0
    var musicList = [MusicModel]()
    var albumList = [AlbumModel]()
    init(itemInfo: IndicatorInfo) {
        super.init(nibName: nil, bundle: nil)
        self.itemInfo = itemInfo
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        musicList = SQLiteMusicServices.newInstance().getMusics(category: "")
        clvAlbum.isHidden = true
        indexCategory = 0
        showViewEmpty()
        tbvMusic.reloadData()
        clvCategory.reloadData()
        setupView()
        
        animationLoading.contentMode = .scaleAspectFit
        viewAnimation.addSubview(animationLoading)
        animationLoading.frame = CGRect(x: 0, y: 0, width: viewAnimation.frame.width, height: viewAnimation.frame.height)
        DispatchQueue.main.async {
            self.animationLoading.play(fromProgress: 0,
                                       toProgress: 1,
                                       loopMode: LottieLoopMode.loop,
                                       completion: { (finished) in})
            
        }
        addViewPlayer(v: vAudio, controller: self)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationLoading.pause()
        animationLoading.removeFromSuperview()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpListView()
    }
   
    func showViewEmpty() {
        lblEmpty.text = "List music empty"
        if(musicList.count == 0) {
            vEmpty.isHidden = false
        }else {
            vEmpty.isHidden = true
            tbvMusic.isHidden = false
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
            showViewEmpty()
        }))
        
        makerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                
        }))
        
        self.present(makerAlert, animated: true)
    }
   
    
    func setUpListView() {
        clvCategory.delegate = self
        clvCategory.dataSource = self
        if let layout = clvCategory.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        clvCategory.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        
        clvAlbum.delegate = self
        clvAlbum.dataSource = self
        clvAlbum.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "AlbumCell")
        
        tbvMusic.delegate = self
        tbvMusic.dataSource = self
        tbvMusic.register(UINib(nibName: "MusicCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
    }
    
    func getMusicAlbum(albumModel: AlbumModel)-> Int {
        let allMusic = SQLiteMusicServices.newInstance().getMusics(category: "")
        let count = allMusic.filter { musicSelect in
            return (musicSelect.id_album.components(separatedBy: ",").contains(albumModel.id))
        }.count
        return count
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == clvAlbum) {
            return albumList.count
        }
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == clvAlbum) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
            let albumModel = albumList[indexPath.row]
            let count = getMusicAlbum(albumModel: albumModel)
            cell.setData(albumModel: albumModel, count: count)
            cell.itemCLickBlock = { [self] indexCell, type in
                if(type == MusicCellType.Select) {
                    let vc = AlbumDetailVC()
                    vc.albumModel = albumModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if(type == MusicCellType.More) {
                    let vBottom = UIView(frame: CGRect(x: App.screenWidth()/2, y: App.screenHeight()-56, width: 300, height: 20))
                    self.view.addSubview(vBottom)
                    let makerAlert = UIAlertController(title: albumModel.name, message: nil, preferredStyle: .actionSheet)
                    makerAlert.popoverPresentationController?.sourceView = vBottom
                    makerAlert.addAction(UIAlertAction(title: "Edit Album", style: .default , handler:{ [self] (UIAlertAction)in
                        let vc = CreateAlbumVC()
                        vc.albumModel = albumModel
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    makerAlert.addAction(UIAlertAction(title: "Delete", style: .default , handler:{ [self] (UIAlertAction)in
                        albumList.removeAll { albumSelect in
                            return albumSelect.name == albumModel.name
                        }
                        SQLiteMusicServices.newInstance().deleteAlbum(albumModel: albumModel)
                        clvAlbum.reloadData()
                        if(albumList.count == 0) {
                            lblEmpty.text = "List album empty"
                            vEmpty.isHidden = false
                        }else {
                            vEmpty.isHidden = true
                        }
                    }))
                    
                    makerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                            
                    }))
                    
                    self.present(makerAlert, animated: true)
                }
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let item = categories[indexPath.row]
        cell.indexCategory = indexPath.row
        cell.lblCategory.text = item
        cell.viewLine.isHidden = indexCategory != indexPath.row
        let size = indexCategory == indexPath.row ? 18 : 14
        cell.lblCategory.font = UIFont(name: "Orbitron-SemiBold", size: CGFloat(size))
        cell.lblCategory.textColor = UIColor(rgb: indexCategory == indexPath.row ? 0xFFFFFF: 0xE3E3E3)
        if(indexPath.row < 1) {
            cell.vAdd.isHidden = true
        }else {
            if(indexCategory == indexPath.row) {
                cell.vAdd.isHidden = false
            }else {
                cell.vAdd.isHidden = true
            }
            
        }
        cell.addClickBlock = { [self] indexCategory, type in
            self.indexCategory = indexCategory
            if(type == "select") {
                if (indexCategory == 3) {
                    musicList = SQLiteMusicServices.newInstance().getMusics(category: CategoryInput.boxDriver.rawValue)
                    clvAlbum.isHidden = true
                    tbvMusic.isHidden = false
                    showViewEmpty()
                    tbvMusic.reloadData()
                }else if (indexCategory == 0) {
                    musicList = SQLiteMusicServices.newInstance().getMusics(category: "")
                    clvAlbum.isHidden = true
                    tbvMusic.isHidden = false
                    showViewEmpty()
                    tbvMusic.reloadData()
                }else if (indexCategory == 1) {
                    albumList = SQLiteMusicServices.newInstance().getAlbums()
                    if(albumList.count == 0) {
                        lblEmpty.text = "List album empty"
                        vEmpty.isHidden = false
                    } else {
                        vEmpty.isHidden = true
                    }
                    clvAlbum.isHidden = false
                    tbvMusic.isHidden = true
                    clvAlbum.reloadData()
                    // show album
                } else if (indexCategory == 2) {
                    clvAlbum.isHidden = true
                    tbvMusic.isHidden = false
                    musicList = SQLiteMusicServices.newInstance().getMusics(category: CategoryInput.cloud.rawValue)
                    showViewEmpty()
                    tbvMusic.reloadData()
                }
                clvCategory.reloadData()
            }else {
                // add new
                if(indexCategory == 2) {
                    // show cloud
                    let pickerController = MPMediaPickerController(mediaTypes: .music)
                    pickerController.delegate = self
                    self.present(pickerController, animated: true)
                }else if(indexCategory == 3) {
                    let vc = MusicBoxViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if(indexCategory == 1) {
                    let alertController = UIAlertController(title: "Create New Album", message: nil, preferredStyle: .alert)
                    alertController.addTextField { (textField) in
                        textField.placeholder = "Album name"
                    }
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        if let textField = alertController.textFields?.first {
                            let text = textField.text
                            if let newText = text, newText != "" {
                                let albumModel = AlbumModel()
                                albumModel.name = newText
                                albumModel.id = "\(Date().timeIntervalSince1970)"
                                let vc = CreateAlbumVC()
                                vc.albumModel = albumModel
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else {
                                self.showMessage(message: "Album name is not empty") {
                                    
                                }
                            }
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                       
                    }
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    present(alertController, animated: true, completion: nil)
                }
            }
        }
        return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == clvAlbum) {
            if(App.isPad()) {
                let size = clvAlbum.frame.width/3 - 8
                return CGSize(width: size, height: size)
            }
            let size = clvAlbum.frame.width/2 - 8
            return CGSize(width: size, height: size)
        }
        return CGSize(width: 100, height: 32)
    }
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let musicModel = musicList[indexPath.row]
        cell.setData(musicModel: musicModel)
        cell.itemCLickBlock = { musicModel, typeButton in
            if(typeButton == MusicCellType.More) {
                // show dialog
                self.actionMore(musicModel: musicModel)
            }else if(typeButton == MusicCellType.Select){
                // play audio
                self.indexCategory = 0
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

extension HomeVC: MPMediaPickerControllerDelegate {
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let item: MPMediaItem = mediaItemCollection.items[0]
        let pathURL: URL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
        if pathURL == nil {
                
        }

        let title = item.value(forProperty: MPMediaItemPropertyTitle) as! String
        let newTitle = title.replacingOccurrences(of: " ", with: "")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(newTitle).m4a")
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        let exSession = AVAssetExportSession(asset: AVAsset(url: item.assetURL!), presetName: AVAssetExportPresetAppleM4A)
        exSession?.shouldOptimizeForNetworkUse = true
        exSession?.outputFileType = .m4a
        exSession?.outputURL = fileURL
        exSession?.shouldOptimizeForNetworkUse = true
        exSession?.exportAsynchronously(completionHandler: {
            if (exSession!.status == AVAssetExportSession.Status.completed){
                let name = "\(newTitle).m4a"
                let musicModel = MusicModel()
                musicModel.file_path = name
                musicModel.name = name
                musicModel.category = CategoryInput.cloud.rawValue
                SQLiteMusicServices.newInstance().insertMusic(musicModel: musicModel)
            } else if (exSession!.status == AVAssetExportSession.Status.cancelled) {
            } else {
            }
        })
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}

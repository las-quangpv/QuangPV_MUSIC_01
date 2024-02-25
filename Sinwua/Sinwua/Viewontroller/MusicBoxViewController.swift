import UIKit
import BoxSDK
import AuthenticationServices
protocol MusicBoxDelegate {
    func itemOnClick(url: URL)
}
class MusicBoxViewController: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var clvBox: UICollectionView!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var vDownload: UIView!
    @IBOutlet weak var vLoadingProgress: UIProgressView!
    
    var delegate: MusicBoxDelegate?
    var files: [File] = [File]()
    var musicBoxService = MusicBoxService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clvBox.delegate = self
        clvBox.dataSource = self
        clvBox.register(UINib(nibName: "MusicBoxCell2", bundle: .main), forCellWithReuseIdentifier: "MusicBoxCell2")
        
        musicBoxService.awake()
        musicBoxService.signInBoxDriver { isSuccess in
            if isSuccess == true {
                self.btnLogin.setTitle("Logout", for: .normal)
                self.musicBoxService.requestBoxAccount { user in
                    DispatchQueue.main.async {
                        self.clvBox.reloadData()

                    }
                    //self.lblUser.text = user?.name
                }
                self.musicBoxService.searchAudio() { listFile, error in
                    self.files = listFile
                    DispatchQueue.main.async {
                        self.clvBox.reloadData()

                    }
                }
            }
        }
    }

    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionLogout(_ sender: Any) {
        if (btnLogin.title(for: .normal) == "Logout") {
            musicBoxService.signOutBoxDriver()
            files = [File]()
            clvBox.reloadData()
            btnLogin.setTitle("Login", for: .normal)
        } else {
            musicBoxService.signInBoxDriver { isSuccess in
                self.btnLogin.setTitle("Logout", for: .normal)
                self.musicBoxService.requestBoxAccount { user in
                   // self.lblUser.text = user?.name
                }
                self.musicBoxService.searchAudio() { listFile, error in
                    self.files = listFile
                    DispatchQueue.main.async {
                        self.clvBox.reloadData()

                    }
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicBoxCell2", for: indexPath) as! MusicBoxCell2
        cell.setup(file: files[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width-20, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(files[index].name!)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let musicList = SQLiteMusicServices.newInstance().getMusics(category: "")
            let count = musicList.filter { musicModel in
                return musicModel.name == files[index].name! && musicModel.file_path == fileURL.path
            }.count
            if(count == 0) {
                let musicModel = MusicModel()
                musicModel.file_path = self.files[index].name!
                musicModel.name = self.files[index].name!
                musicModel.category = CategoryInput.boxDriver.rawValue
                SQLiteMusicServices.newInstance().insertMusic(musicModel: musicModel)
            }
            self.navigationController?.popViewController(animated: true)
            if(self.delegate != nil) {
                self.delegate?.itemOnClick(url: fileURL)
            }
        } else {
            vDownload.isHidden = false
            musicBoxService.downloadMusic(files[index]) { progress in
                DispatchQueue.main.async {
                    self.vLoadingProgress.progress = Float(progress.completedUnitCount*100/progress.totalUnitCount)
                }
                
            } completion: { status, urlString in
                if status == true {
                    self.vDownload.isHidden = true
                    let musicModel = MusicModel()
                    musicModel.file_path = urlString
                    musicModel.name = self.files[index].name!
                    musicModel.category = CategoryInput.boxDriver.rawValue
                    SQLiteMusicServices.newInstance().insertMusic(musicModel: musicModel)
                    self.clvBox.reloadData()
                } else {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        print("\(error)")
                    }
                    
                    self.vDownload.isHidden = true
                    self.showMessage(message: "Download Error") {
                        
                    }
                }
            }
        }
    }

}

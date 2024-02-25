
import UIKit
import Lottie

class AlbumDetailVC: UIViewController {
    @IBOutlet weak var vEmpty: UIView!
    @IBOutlet weak var tbvMusic: UITableView!
    @IBOutlet weak var vPlay: BaseUiView!
    @IBOutlet weak var vBoder: BaseUiView!
    @IBOutlet weak var vAudio: UIView!
    @IBOutlet weak var ivBlur: UIImageView!
    @IBOutlet weak var ivCircle: BaseImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var viewAnimation: UIView!
    private let animationLoading = LottieAnimationView(name: "empty")
    var musicList = [MusicModel]()
    var albumModel: AlbumModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        vBoder.clipsToBounds = true
        vBoder.layer.cornerRadius = 40
        vBoder.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
     
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 0, width: App.screenWidth(), height: App.screenHeight())
        ivBlur.addSubview(blurEffectView)
        tbvMusic.delegate = self
        tbvMusic.dataSource = self
        tbvMusic.register(UINib(nibName: "MusicCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let allMusics = SQLiteMusicServices.newInstance().getMusics(category: "")
        if let albumModel = albumModel {
           musicList =  allMusics.filter { musicModel in
                return musicModel.id_album.components(separatedBy: ",").contains { key in
                    return key == albumModel.id
                }
            }
            ivCircle.image = UIImage(named: albumModel.image)
            ivBlur.image = UIImage(named: albumModel.image)
            lblName.text = albumModel.name
            lblCount.text = "\(musicList.count) songs"
            
            checkEmpty()
            tbvMusic.reloadData()
        }
        addViewPlayer(v: vAudio, controller: self)
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
    }
    func checkEmpty() {
        if(musicList.count == 0) {
            vEmpty.isHidden = false
            vPlay.isHidden = true
        }else {
            vEmpty.isHidden = true
            vPlay.isHidden = false
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
            if let albumModel = albumModel {
                var list = musicModel.id_album.components(separatedBy: ",")
                list.removeAll { key in
                    return key == albumModel.id
                }
                musicModel.id_album = list.joined(separator: ",")
                SQLiteMusicServices.newInstance().deleteBookMark(musicModel: musicModel)
            }
            
            tbvMusic.reloadData()
            checkEmpty()
        }))
        
        makerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                
        }))
        
        self.present(makerAlert, animated: true)
    }
    @IBAction func actionPlay(_ sender: Any) {
        MusicManager.getInstance.playMusicWithNewList(musicList: musicList)
        let vc = PlayerVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension AlbumDetailVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let musicModel = musicList[indexPath.row]
        cell.btnFav.isHidden = true
        cell.setData(musicModel: musicModel)
        cell.itemCLickBlock = { musicModel, typeButton in
            if(typeButton == MusicCellType.More) {
                // show dialog
                self.actionMore(musicModel: musicModel)
            }else {
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

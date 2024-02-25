

import UIKit
import Lottie

class SearchVC: BaseVC {
    @IBOutlet weak var vEmpty: UIView!
    @IBOutlet weak var tbvMusic: UITableView!
    @IBOutlet weak var vAudio: UIView!
    @IBOutlet weak var tvSearch: UITextField!
    @IBOutlet weak var viewAnimation: UIView!
    private let animationLoading = LottieAnimationView(name: "empty")
    var musicList = [MusicModel]()
    var listFilter = [MusicModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        tbvMusic.delegate = self
        tbvMusic.dataSource = self
        tbvMusic.register(UINib(nibName: "MusicCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewPlayer(v: vAudio, controller: self)
        tvSearch.text = ""
        musicList = SQLiteMusicServices.newInstance().getMusics(category: "")
        listFilter = musicList
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
    func search(searchStr: String) {
        if(searchStr == "") {
            listFilter = musicList
        }else {
            listFilter = musicList.filter({ musicModel in
                return musicModel.name.contains(searchStr)
            })
        }
        checkEmpty()
        tbvMusic.reloadData()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        let txtSeach = textField.text!
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.search(searchStr: txtSeach)
        }
    }
    func checkEmpty() {
        if(listFilter.count == 0) {
            vEmpty.isHidden = false
        }else {
            vEmpty.isHidden = true
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
            listFilter.removeAll { musicSelect in
                return musicSelect.name == musicModel.name && musicModel.file_path == musicModel.file_path
            }
            SQLiteMusicServices.newInstance().deleteBookMark(musicModel: musicModel)
            tbvMusic.reloadData()
        }))
        
        makerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                
        }))
        
        self.present(makerAlert, animated: true)
    }

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension SearchVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let musicModel = listFilter[indexPath.row]
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

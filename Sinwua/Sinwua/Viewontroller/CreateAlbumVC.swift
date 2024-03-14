
import UIKit

class CreateAlbumVC: BaseVC {
    @IBOutlet weak var vEmpty: UIView!
    @IBOutlet weak var clvBackground: UICollectionView!
    @IBOutlet weak var tbvMusic: UITableView!
    var musicList = [MusicModel]()
    var musicUpdateList = [MusicModel]()
    var albumModel: AlbumModel?
    var images: [String] = ["ic_image_1", "ic_image_2", "ic_image_3", "ic_image_4","ic_image_5", "ic_image_6","ic_image_7", "ic_image_8","ic_image_9", "ic_image_10","ic_image_11", "ic_image_12","ic_image_13", "ic_image_14", "ic_image_15"]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        musicList = SQLiteMusicServices.newInstance().getMusics(category: "")
        checkEmpty()
        tbvMusic.reloadData()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvMusic.delegate = self
        tbvMusic.dataSource = self
        tbvMusic.register(UINib(nibName: "MusicCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
        
        clvBackground.delegate = self
        clvBackground.dataSource = self
        clvBackground.register(UINib(nibName: "BackgroundAlbumCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundAlbumCell")
    }

    func isAddMusicToAlbum(musicModel: MusicModel) -> Bool {
        let idAlbums = musicModel.id_album.components(separatedBy: ",")
        if idAlbums.contains("\(String(describing: albumModel!.id))") {
            return true
        }
        return false
    }
    func checkEmpty() {
        if(musicList.count == 0) {
            vEmpty.isHidden = false
        }else {
            vEmpty.isHidden = true
        }
    }
   

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSave(_ sender: Any) {
        if let albumModel = albumModel {
            SQLiteMusicServices.newInstance().updateAlbum(albumModel: albumModel)
        }
        SQLiteMusicServices.newInstance().updateAllMusic(musicList: musicList) {
            self.showMessage(message: "Save album success") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
extension CreateAlbumVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let musicModel = musicList[indexPath.row]
        if(isAddMusicToAlbum(musicModel: musicModel)) {
            cell.vCircleRatio.isHidden = false
        }else {
            cell.vCircleRatio.isHidden = true
        }
        cell.btnFav.isHidden = true
        cell.btnMore.isHidden = true
        cell.vRatio.isHidden = false
        cell.setData(musicModel: musicModel)
        cell.itemCLickBlock = { [self] musicSelect, typeButton in
            if(typeButton == MusicCellType.Ratio) {
                // show dialog
                if let albumModel = albumModel {
                    var listId = musicModel.id_album.components(separatedBy: ",")
                    if(!isAddMusicToAlbum(musicModel: musicSelect)) {
                        listId.append("\(albumModel.id)")
                        musicUpdateList.append(musicModel)
                    }else {
                        listId.removeAll { id in
                            return String(id) == "\(albumModel.id)"
                        }
                        musicUpdateList.removeAll { musicUpdateSelect in
                            return musicUpdateSelect.name == musicSelect.name &&
                            musicUpdateSelect.file_path == musicSelect.file_path
                        }
                    }
                    musicModel.id_album = listId.joined(separator: ",")
                }
                tbvMusic.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}
extension CreateAlbumVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundAlbumCell", for: indexPath) as! BackgroundAlbumCell
        if let albumModel = albumModel {
            cell.setData(albumModel: albumModel, imageName: images[indexPath.row])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = images[indexPath.row]
        albumModel?.image = item
        clvBackground.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 136)
    }
}

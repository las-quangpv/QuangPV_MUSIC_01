
import UIKit

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblNameAlbum: UILabel!
    var itemCLickBlock: ((AlbumModel, MusicCellType)-> Void)!
    @IBOutlet weak var ivAlbum: UIImageView!
    var albumModel: AlbumModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(albumModel: AlbumModel, count: Int) {
        self.albumModel = albumModel
        lblContent.text = "\(count) songs"
        lblNameAlbum.text = albumModel.name
        ivAlbum.image = UIImage(named: albumModel.image)
    }

    @IBAction func actionSelect(_ sender: Any) {
        if(itemCLickBlock != nil && albumModel != nil) {
            itemCLickBlock(albumModel!, MusicCellType.Select)
        }
    }
    @IBAction func actionMore(_ sender: Any) {
        if(itemCLickBlock != nil && albumModel != nil) {
            itemCLickBlock(albumModel!, MusicCellType.More)
        }
    }
}

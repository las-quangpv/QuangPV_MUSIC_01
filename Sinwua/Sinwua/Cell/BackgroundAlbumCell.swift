

import UIKit

class BackgroundAlbumCell: UICollectionViewCell {
    @IBOutlet weak var vParent: BaseUiView!
    @IBOutlet weak var ivBackground: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(albumModel: AlbumModel, imageName: String) {
        if(albumModel.image == imageName) {
            vParent.borderWidth = 1
        }else {
            vParent.borderWidth = 0
        }
        ivBackground.image = UIImage(named: imageName)
    }

}

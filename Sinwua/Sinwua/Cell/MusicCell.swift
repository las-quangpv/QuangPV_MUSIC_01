

import UIKit
import AVFoundation

enum MusicCellType {
    case More
    case Select
    case Fav
    case Ratio
}
class MusicCell: UITableViewCell {
    @IBOutlet weak var ivGradient: UIImageView!
    @IBOutlet weak var ivThumb: BaseImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    
    @IBOutlet weak var vRatio: BaseUiView!
    @IBOutlet weak var vCircleRatio: BaseUiView!
    var itemCLickBlock: ((MusicModel, MusicCellType)-> Void)!
    var musicModel: MusicModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(musicModel: MusicModel) {
        self.musicModel = musicModel
        lblTitle.text = musicModel.name
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docURL.appendingPathComponent(musicModel.file_path)
        let asset = AVAsset(url: url)
        
        let mDuration = CMTimeGetSeconds(asset.duration)
        lblDuration.text = convertTimeToHHMM(time: mDuration)
        
        if let fileSize = getAudioFileSize(atPath: url.path) {
            lblSize.text = fileSize
        }
    }

    @IBAction func actionMore(_ sender: Any) {
        if(itemCLickBlock != nil && musicModel != nil) {
            self.itemCLickBlock(musicModel!, MusicCellType.More)
        }
    }
    @IBAction func actionSelect(_ sender: Any) {
        if(itemCLickBlock != nil && musicModel != nil) {
            self.itemCLickBlock(musicModel!, MusicCellType.Select)
        }
    }
    
    @IBAction func actionHeart(_ sender: Any) {
        if(itemCLickBlock != nil && musicModel != nil) {
            self.itemCLickBlock(musicModel!, MusicCellType.Fav)
        }
    }
    
    @IBAction func actionRadio(_ sender: Any) {
        if(itemCLickBlock != nil && musicModel != nil) {
            self.itemCLickBlock(musicModel!, MusicCellType.Ratio)
        }
    }
}


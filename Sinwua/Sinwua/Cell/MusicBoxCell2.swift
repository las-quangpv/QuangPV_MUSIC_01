
import UIKit
import BoxSDK

class MusicBoxCell2: UICollectionViewCell {
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageDown: BaseImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(file: File) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy at HH:mm a"
        self.lblTitle.text = file.name
        self.lblContent.text = String(format: "%@", formatter.string(from: file.modifiedAt ?? Date()))
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(file.name!)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            imageDown.isHidden = true
        } else {
            imageDown.isHidden = false
            imageDown.image = UIImage(named: "ic_download")
        }
    }

}

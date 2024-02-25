
import Foundation
import AVFoundation

enum CategoryInput: String {
    case cloud = "cloud"
    case boxDriver = "boxDriver"
}
class MusicModel : NSObject {
    var id_album: String = ""
    var favourite: Int = 0
    var file_path: String = ""
    var name: String = ""
    var category: String = ""
    
    init(id: String, id_album: String, favourite: Int, file_path: String, name: String, category: String) {
        self.id_album = id_album
        self.favourite = favourite
        self.file_path = file_path
        self.name = name
        self.category = category
    }
    override init() {
        
    }
}

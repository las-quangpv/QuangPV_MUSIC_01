
import Foundation

class AlbumModel : NSObject {
    var id: String = ""
    var name: String = ""
    var category: String = ""
    var image: String = "ic_image_1"
    init(id: String, name: String, category: String, image: String) {
        self.id = id
        self.name = name
        self.category = category
        self.image = image
    }
    override init() {
        
    }
}

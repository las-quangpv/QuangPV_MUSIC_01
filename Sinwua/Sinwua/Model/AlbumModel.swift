
import Foundation

class AlbumModel : NSObject {
    var id: Int = 0
    var name: String = ""
    var category: String = ""
    var image: String = "ic_image_1"
    init(id: Int, name: String, category: String, image: String) {
        self.id = id
        self.name = name
        self.category = category
        self.image = image
    }
    override init() {
        
    }
}

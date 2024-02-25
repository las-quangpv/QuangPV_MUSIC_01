
import Foundation
import UIKit
class App {
    static func screenWidth() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return screenWidth
    }
    static func screenHeight() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return screenHeight
    }
    static func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class func getUrlPath(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }
    class func copyFile(fileName: NSString) {
        let dbPath: String = getUrlPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch {
                print("copy failed \(error)")
            }
        }
    }
}

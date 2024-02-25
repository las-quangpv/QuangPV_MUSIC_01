
import Foundation
import AVFoundation
import UIKit

typealias MDictionary = [String: Any]
public let clientId = "zcj90drotm80i0vvl01p3os4rmbxzza6"
public let clientSecret = "Bn5bFucjiZNsCBVjJEoOJsTVxQVQ0ugr"
class Constrants {
    
}

func convertTimeToHHMM(time: Double) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad

    if let formattedString = formatter.string(from: TimeInterval(time)) {
        return formattedString
    } else {
        return "00:00"
    }
}
func addViewPlayer(v: UIView, controller: UIViewController) {
    let playerView = PlayerView(frame: CGRect(x: 0, y: 0, width: App.screenWidth(), height: 88))
    playerView.controller = controller
    v.addSubview(playerView)
}
func formatFileSize(_ size: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB]
    formatter.countStyle = .file

    return formatter.string(fromByteCount: size)
}

func getAudioFileSize(atPath path: String) -> String? {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
        if let fileSize = fileAttributes[.size] as? NSNumber {
            return formatFileSize(fileSize.int64Value)
        } else {
            return nil
        }
    } catch {
        return nil
    }
}

import UIKit

class BaseVC: UIViewController {
    var loadingMusicView: LoadingMusicView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingMusicView = LoadingMusicView(frame: CGRect(x: 0, y: 0, width: App.screenWidth(), height: App.screenHeight()))
        loadingMusicView.tag = 111
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
    func showLoading() {
        self.view.addSubview(loadingMusicView)
        loadingMusicView.animationView.play()
    }
    
    func hideLoading() {
        loadingMusicView.animationView.stop()
        if let viewWithTag = self.view.viewWithTag(111) {
            viewWithTag.removeFromSuperview()
        }
    }
    func showMessage(message: String?, completion:  @escaping () -> Void) {
        let popupVC = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        popupVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            popupVC.dismiss(animated: true) {
                completion()
            }
        }))
        DispatchQueue.main.async { [weak self] in
            self?.present(popupVC, animated: true, completion: nil)
        }
    }

}

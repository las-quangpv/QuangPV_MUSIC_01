
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        App.copyFile(fileName: "conversation.db")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: BottomNavigationVC())
        navVC.navigationBar.isHidden = true
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
        return true
    }
}

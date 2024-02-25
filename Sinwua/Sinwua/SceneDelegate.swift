import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {return}
        UINavigationBar.appearance().barStyle = .default

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let navi = UINavigationController(rootViewController: BottomNavigationVC())
        navi.navigationBar.isHidden = true
        self.window?.rootViewController = navi
        window?.makeKeyAndVisible()
    }
}

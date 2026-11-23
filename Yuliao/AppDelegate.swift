import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.backgroundColor = UIColor(red: 0.043, green: 0.067, blue: 0.094, alpha: 1)
        w.rootViewController = 聊天()
        window = w
        w.makeKeyAndVisible()
        return true
    }
}

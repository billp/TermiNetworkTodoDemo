import UIKit
import TermiNetwork

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureUIAppearance()
        configureNetworking()
        
        let window = UIWindow()
        window.rootViewController = UINavigationController(rootViewController: TodoViewController())
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func configureUIAppearance() {
        let appearance = UINavigationBar.appearance()
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label
        ]

        appearance.tintColor = .label
        appearance.prefersLargeTitles = true
        appearance.isTranslucent = true
        appearance.titleTextAttributes = titleTextAttributes
        appearance.largeTitleTextAttributes = titleTextAttributes
    }

    func configureNetworking() {
        Environment.set(Env.dev)
    }
}

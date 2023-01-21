//
//  SceneDelegate.swift
//  swift-keychain-adavanced-demo
//
//  Created by Paolo Prodossimo Lopes on 20/01/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = createController()
        window?.makeKeyAndVisible()
    }
    
    private func createController() -> UIViewController {
        let writter = KeychainWritterAdapter()
        let reader = KeychainReaderAdapter()
        let updater = KeychainUpdaterAdapter()
        let deleter = KeychainDeleterAdapter()
        let lister = KeychainListerAdapter()
        let client = KeychainAdapter(
            witter: writter,
            reader: reader,
            updater: updater,
            deleter: deleter,
            lister: lister
        )
        return ViewController(client: client)
    }
}

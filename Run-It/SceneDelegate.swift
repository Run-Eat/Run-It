//
//  SceneDelegate.swift
//  Run-It
//
//  Created by Jason Yang on 2/22/24.
//

import UIKit
import KakaoSDKAuth
import AuthenticationServices
import KeychainAccess
import KakaoSDKUser

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let runningTimer = RunningTimer()

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowsScene)
        let tabBarController = UITabBarController()
        let loginViewController = LoginViewController()
        tabBarController.viewControllers = [RunningMapViewController(), BookmarkViewController(), ProfileViewController()]
        window?.rootViewController = loginViewController  // 코드작업 간 자신의 ViewController로 변경하되, github commit 간에는 unstaged 처리
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) 
    {
        if let url = URLContexts.first?.url
        {
            if (AuthApi.isKakaoTalkLoginUrl(url))
            {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        runningTimer.state = .foreground
        runningTimer.timerWillEnterForeground()
        
        // 카카오 자동 로그인
        if AuthApi.hasToken()
        {
            UserApi.shared.accessTokenInfo
            {   accessTokenInfo, error in
                
                if let error = error
                {
                    print("DEBUG: 카카오톡 토큰 가져오기 에러 \(error.localizedDescription)")
                    
                }
                
                else
                {
                    // 토큰 유효성 체크 성공 (필요 시 토큰 갱신됨)
                }
            }
            self.window?.rootViewController = MainTabBarViewController()
        }
        
        // 애플 자동 로그인
        let keychain = Keychain(service: "com.team5.Run-It")
        
        do
        {   // Keychain에 저장된 UserID 불러오기
            guard let userID = try keychain.get("UserID") else { return }
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                switch credentialState
                {
                case .authorized:
                    print("authorized")
                    // The Apple ID credential is valid.
                    DispatchQueue.main.async
                    {
                        //authorized된 상태이므로 바로 로그인 완료 화면으로 이동
                        self.window?.rootViewController = MainTabBarViewController()
                    }
                case .revoked:
                    print("revoked")
                case .notFound:
                    print("notFound")
                    
                default:
                    break
                }
            }
        }
        
        catch
        {
            print("Can't bring userID: \(error)")
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        runningTimer.state = .background
        runningTimer.timerEnterBackground()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


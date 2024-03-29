//
//  ViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        // 모든 탭 바 상태에 대해 동일한 외관을 사용
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
        let runningMapVC = RunningMapViewController()
        let runningMapViewNavigationController = UINavigationController(rootViewController: runningMapVC)
        runningMapViewNavigationController.tabBarItem = UITabBarItem(title: "러닝", image: UIImage(systemName: "figure.run"), tag: 0)
//        runningMapVC.tabBarHeight = self.tabBar.frame.height
        
        let bookmarkVC = BookmarkViewController()
        let BookmarkViewNavigationController = UINavigationController(rootViewController: bookmarkVC)
        BookmarkViewNavigationController.tabBarItem = UITabBarItem(title: "즐겨찾기", image: UIImage(systemName: "star.fill"), tag: 1)
        
        let profileVC = ProfileViewController()
        let profileViewNavigationController = UINavigationController(rootViewController: profileVC)
        profileViewNavigationController.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.crop.circle"), tag: 2)

        viewControllers = [runningMapViewNavigationController, BookmarkViewNavigationController, profileViewNavigationController]

    }

}


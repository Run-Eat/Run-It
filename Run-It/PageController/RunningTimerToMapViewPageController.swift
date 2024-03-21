//
//  RunningRecordToMapViewController ViewController.swift
//  Run-It
//
//  Created by Jason Yang on 2/25/24.
//

import UIKit
import SnapKit

class RunningTimerToMapViewPageController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    var viewControllers: [UIViewController] = []
    
//    lazy var pageControl: UIPageControl = {
//        let pageControl = UIPageControl()
//        pageControl.currentPageIndicatorTintColor = .systemYellow
//        pageControl.pageIndicatorTintColor = .systemTeal
//        return pageControl
//    }()
    
    let statusBarView = UIView()
    let bottomView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setuptoolbarbutton()
        setupUI()
    }
    
    @objc func switchToRunningTimer() {
        pageViewController.setViewControllers([viewControllers[0]], direction: .reverse, animated: true, completion: nil)
    }
    
    func setupUI() {
        
        view.addSubview(statusBarView)
        view.addSubview(bottomView)
        
        view.backgroundColor = .black
        statusBarView.backgroundColor = .black
        bottomView.backgroundColor = .black
        
        [statusBarView, bottomView].forEach { subView in view.addSubview(subView)
        }
        
        statusBarView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }


    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllers.count > previousIndex else {
            return nil
        }
        
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < viewControllers.count else {
            return nil
        }
        
        guard viewControllers.count > nextIndex else {
            return nil
        }
        
        return viewControllers[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers.first,
              let firstViewControllerIndex = viewControllers.firstIndex(of: firstViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
}


extension RunningTimerToMapViewPageController {
    private func setuptoolbarbutton() {
        // Initialize view controllers
        let runningRecordVC = RunningTimerViewController()
        let runningMapVC = RunningMapViewController()
        runningMapVC.parentVC = self
        runningMapVC.startRunningButton.isHidden = true
        runningMapVC.backToRunningTimerViewButton.isHidden = false

        // Add view controllers to the array
        viewControllers = [runningRecordVC, runningMapVC]
        // Create a page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self // UIPageViewControllerDelegate 설정
        
        // Set the initial view controller
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        // Add the page view controller as a child view controller
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
}

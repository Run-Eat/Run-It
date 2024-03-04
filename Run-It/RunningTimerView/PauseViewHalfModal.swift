//
//  HalfModal.swift
//  Run-It
//
//  Created by Jason Yang on 2/23/24.
//

import Foundation

// In a subclass of UIViewController, customize and present the sheet.
extension RunningTimerViewController {
    func showMyViewControllerInACustomizedSheet(_ viewControllerToPresent: PauseRunningHalfModalViewController) {
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()] // 모달의 높이를 중간.medium로 설정하고, .large()를 추가하면 크게.large로 설정합니다.
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium // 최대 확장 시 어둡게 표시되지 않도록 설정
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false // 모달 내부 스크롤 시 확장되지 않도록 설정
            sheet.prefersEdgeAttachedInCompactHeight = true // 컴팩트 높이에서 모달이 화면 가장자리에 붙도록 설정
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true // 모달의 너비가 preferredContentSize를 따르도록 설정
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
}

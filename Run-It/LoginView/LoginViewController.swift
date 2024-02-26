//
//  LoginViewController.swift
//  Run-It
//
//  Created by 석진 on 2/26/24.
//


//#if DEBUG
//import SwiftUI
//struct Preview: UIViewControllerRepresentable {
//    
//    // 여기 ViewController를 변경해주세요
//    func makeUIViewController(context: Context) -> UIViewController {
//        LoginViewController()
//    }
//    
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//}
//
//struct ViewController_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            Preview()
//                .edgesIgnoringSafeArea(.all)
//                .previewDisplayName("Preview")
//                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
//        }
//    }
//}
//#endif


import UIKit
import SnapKit

class LoginViewController: UIViewController
{
    
    let loginLogo = UIImageView(image: UIImage(named: "LoginLogo"))
    
    let signUPButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(jumpToSignUp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubView()
        setLayout()

       
    }
    
    func addSubView()
    {
        view.addSubview(loginLogo)
        view.addSubview(signUPButton)
    }
    
    func setLayout()
    {
        loginLogo.snp.makeConstraints
        {   make in
            make.top.equalTo(view.snp.top).inset(150)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(170)
            make.height.equalTo(60)
        }
        
        signUPButton.snp.makeConstraints
        {   make in
            make.top.equalTo(view.snp.top).inset(300)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
    
    @objc func jumpToSignUp()
    {
        let VC = SignUpViewController()
        
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
    }

}

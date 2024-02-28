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
import FirebaseAuth
import FirebaseCore

class LoginViewController: UIViewController
{
    
    let loginLogo = UIImageView(image: UIImage(named: "LoginLogo"))
    
    let emailTextField: UITextField =
    {
        let textField = UITextField()
        textField.placeholder = "이메일 주소"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .continue
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    let pwTextField: UITextField =
    {
        let textField = UITextField()
        textField.placeholder = "비밀번호"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .default
        textField.returnKeyType = .go
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    let loginButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(touchedLoginButton), for: .touchUpInside)
        return button
    }()
    
    let findEmailButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("이메일 찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(touchedFindEmailButton), for: .touchUpInside)
        return button
    }()
    
    let resetPasswordButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("비밀번호 재설정", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(touchedResetPasswordButton), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(touchedSignUpButton), for: .touchUpInside)
        return button
    }()
    
    let leftLine_verticality: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.black
        return lineView
    }()
    
    let rightLine_verticality: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.black
        return lineView
    }()
    
    let socialLoginLabel: UILabel =
    {
        let label = UILabel()
        label.text = "또는 소셜 계정으로 로그인"
        label.font = UIFont.systemFont(ofSize: CGFloat(14))
        
        return label
    }()
    
    let leftLine: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.black
        return lineView
    }()
    
    let rightLine: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.black
        return lineView
    }()
    
    let kakaoLoginButton: UIButton =
    {
        let button = UIButton()
        button.setImage(UIImage(named: "KakaoLogin"), for: .normal)
        button.addTarget(self, action: #selector(touchedKakaoLoginButton), for: .touchUpInside)
        return button
    }()
    
    let appleLoginButton: UIButton =
    {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleLogin"), for: .normal)
        button.addTarget(self, action: #selector(touchedAppleLoginButton), for: .touchUpInside)
        return button
    }()
    
// MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubView()
        setLayout()

       
    }

// MARK: - 레이아웃 설정
    func addSubView()
    {
        view.addSubview(loginLogo)
        view.addSubview(emailTextField)
        view.addSubview(pwTextField)
        view.addSubview(loginButton)
        view.addSubview(findEmailButton)
        view.addSubview(resetPasswordButton)
        view.addSubview(signUpButton)
        view.addSubview(leftLine_verticality)
        view.addSubview(rightLine_verticality)
        view.addSubview(socialLoginLabel)
        view.addSubview(leftLine)
        view.addSubview(rightLine)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleLoginButton)
    }
    
    func setLayout()
    {
        loginLogo.snp.makeConstraints
        {   make in
            make.top.equalTo(view.snp.top).inset(120)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(170)
            make.height.equalTo(60)
        }
        
        emailTextField.snp.makeConstraints
        {   make in
            make.top.equalTo(loginLogo.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        
        pwTextField.snp.makeConstraints
        {   make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints
        {   make in
            make.top.equalTo(pwTextField.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(250)
            make.height.equalTo(40)
        }
        
        resetPasswordButton.snp.makeConstraints
        {   make in
            make.top.equalTo(loginButton.snp.bottom).offset(10)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(100)
        }
        
        leftLine_verticality.snp.makeConstraints
        {   make in
            make.centerY.equalTo(resetPasswordButton.snp.centerY)
            make.leading.equalTo(resetPasswordButton.snp.leading).offset(-15)
            make.width.equalTo(1)
            make.height.equalTo(10)
        }
        
        rightLine_verticality.snp.makeConstraints
        {   make in
            make.centerY.equalTo(resetPasswordButton.snp.centerY)
            make.trailing.equalTo(resetPasswordButton.snp.trailing).offset(15)
            make.width.equalTo(1)
            make.height.equalTo(10)
        }
        
        findEmailButton.snp.makeConstraints
        {   make in
            make.centerY.equalTo(resetPasswordButton.snp.centerY)
            make.leading.equalTo(leftLine_verticality.snp.leading).offset(-85)
            make.width.equalTo(70)
        }
        
        signUpButton.snp.makeConstraints
        {   make in
            make.centerY.equalTo(resetPasswordButton.snp.centerY)
            make.trailing.equalTo(rightLine_verticality.snp.trailing).offset(80)
            make.width.equalTo(70)
        }
        
        socialLoginLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(resetPasswordButton.snp.bottom).offset(25)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        leftLine.snp.makeConstraints
        {   make in
            make.centerY.equalTo(socialLoginLabel.snp.centerY)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.trailing.equalTo(socialLoginLabel.snp.leading).offset(-10)
            make.height.equalTo(1)
        }
        
        rightLine.snp.makeConstraints
        {   make in
            make.centerY.equalTo(socialLoginLabel.snp.centerY)
            make.leading.equalTo(socialLoginLabel.snp.trailing).offset(10)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.height.equalTo(1)
        }
        
        kakaoLoginButton.snp.makeConstraints
        {   make in
            make.top.equalTo(socialLoginLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX).offset(-35)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        appleLoginButton.snp.makeConstraints
        {   make in
            make.top.equalTo(socialLoginLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX).offset(35)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
    }
    
// MARK: - Firebase 로그인
    func signInUser()
    {
        guard let email = emailTextField.text   else { return }
        guard let pw = pwTextField.text   else { return }
        
        Auth.auth().signIn(withEmail: email, password: pw)
        {   [self] authResult, error in
            if authResult == nil
            {
                print("로그인 실패")
                if let error = error
                {
                    print(error)
                }
            }
            else if authResult != nil
            {
                print("로그인 성공")
                
                let VC = MainTabBarViewController()
                VC.selectedIndex = 1
                
                VC.modalPresentationStyle = .fullScreen
                present(VC, animated: true, completion: nil)
            }
        }
    }
    
// MARK: - 버튼 함수
    @objc func touchedLoginButton()
    {
        signInUser()
    }
    
    @objc func touchedKakaoLoginButton()
    {
        
    }
    
    @objc func touchedAppleLoginButton()
    {
        
    }
    
    @objc func touchedFindEmailButton()
    {
        //추후 구현 사항
//        let VC = FindEmailController()
//
//        VC.modalPresentationStyle = .fullScreen
//        present(VC, animated: true, completion: nil)
    }
    
    @objc func touchedResetPasswordButton()
    {
        //추후 구현 사항
//        let VC = resetPasswordController()
//        
//        VC.modalPresentationStyle = .fullScreen
//        present(VC, animated: true, completion: nil)
    }
    
    @objc func touchedSignUpButton()
    {
        let VC = SignUpViewController()
        
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
    }

}


// MARK: - TextFieldDelegate extension
extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //  키보드 done 버튼 터치 시
        if textField == emailTextField
        {
            pwTextField.becomeFirstResponder()
        }
        
        else
        {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    //  키보드 바깥 터치 시
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        view.endEditing(true)
    }
    
    //  키보드 툴 바
    func addInputAccessoryForTextFields()
    {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let prevButton = UIBarButtonItem(title: "이전", style: .plain, target: self, action: #selector(prevButtonTapped))
        let nextButton = UIBarButtonItem(title: "다음", style: .plain, target: self, action: #selector(nextButtonTapped))
        
        toolbar.items = [prevButton, nextButton, flexibleSpace, doneButton]
        
        emailTextField.inputAccessoryView = toolbar
        pwTextField.inputAccessoryView = toolbar
    }
    
    // 키보드 툴 바 버튼 함수
    @objc func doneButtonTapped()
    {
        view.endEditing(true)
    }
        
        @objc func prevButtonTapped()
    {
        emailTextField.becomeFirstResponder()
    }
        
        @objc func nextButtonTapped()
    {
        pwTextField.becomeFirstResponder()
    }

}

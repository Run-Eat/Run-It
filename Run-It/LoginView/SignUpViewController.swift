//
//  SignUpViewController.swift
//  Run-It
//
//  Created by 석진 on 2/26/24.
//

#if DEBUG
import SwiftUI
struct Preview: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        SignUpViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct ViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            Preview()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
    }
}
#endif

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

class SignUpViewController: UIViewController
{
    var idValue = ""
    var pwValue = ""
    
// MARK: - UI 구성
    let cancelButton: UIButton =
    {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(cancelSignUp), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel =
    {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: CGFloat(17))
        return label
    }()
    
    let explainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "이메일과 비밀번호만으로 \nRUN IT에 가입할 수 있어요!"
        label.font = UIFont.systemFont(ofSize: CGFloat(21))
        label.numberOfLines = 2
        return label
    }()
    
    let emailTextField: UITextField =
    {
        let textField = UITextField()
        textField.placeholder = "RUNIT@xxxxx.com"
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
    
    let idExplainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "정확한 이메일을 입력해주세요"
        label.font = UIFont.systemFont(ofSize: CGFloat(15))
        
        return label
    }()
    
    let pwTextField: UITextField =
    {
        let textField = UITextField()
        textField.placeholder = "비밀번호 설정"
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
    
    let pwExplainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "비밀번호는 8 - 20자 이내로 입력해주세요"
        label.font = UIFont.systemFont(ofSize: CGFloat(15))
        
        return label
    }()
    
    let signUpButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(touchedSignUpButton), for: .touchUpInside)
        return button
    }()
    
    let socialSignUpLabel: UILabel =
    {
        let label = UILabel()
        label.text = "또는 소셜 계정으로 가입"
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
    
    
    
    let id_pwLabel: UILabel =
    {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: CGFloat(21))
        label.numberOfLines = 2
        return label
    }()

// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubView()
        setLayout()
        
        emailTextField.delegate = self
        pwTextField.delegate = self
       
        addInputAccessoryForTextFields()
    }

// MARK: - 레이아웃 지정
    func addSubView()
    {
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(explainLabel)
        view.addSubview(emailTextField)
        view.addSubview(idExplainLabel)
        view.addSubview(pwTextField)
        view.addSubview(pwExplainLabel)
        view.addSubview(signUpButton)
        view.addSubview(socialSignUpLabel)
        view.addSubview(leftLine)
        view.addSubview(rightLine)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleLoginButton)
        
        view.addSubview(id_pwLabel)
    }
    
    func setLayout()
    {
        cancelButton.snp.makeConstraints
        {   make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(view.snp.trailing).inset(10)
        }
        
        titleLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        explainLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
            make.leading.equalTo(view.snp.leading).inset(20)
        }
        
        emailTextField.snp.makeConstraints
        {   make in
            make.top.equalTo(explainLabel.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        
        idExplainLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.leading.equalTo(view.snp.leading).inset(25)
        }
        
        pwTextField.snp.makeConstraints
        {   make in
            make.top.equalTo(idExplainLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        
        pwExplainLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(pwTextField.snp.bottom).offset(7)
            make.leading.equalTo(view.snp.leading).inset(25)
        }
        
        signUpButton.snp.makeConstraints
        {   make in
            make.top.equalTo(pwExplainLabel.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(250)
            make.height.equalTo(40)
        }
        
        socialSignUpLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(signUpButton.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        leftLine.snp.makeConstraints
        {   make in
            make.centerY.equalTo(socialSignUpLabel.snp.centerY)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.trailing.equalTo(socialSignUpLabel.snp.leading).offset(-10)
            make.height.equalTo(1)
        }
        
        rightLine.snp.makeConstraints
        {   make in
            make.centerY.equalTo(socialSignUpLabel.snp.centerY)
            make.leading.equalTo(socialSignUpLabel.snp.trailing).offset(10)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.height.equalTo(1)
        }
        
        kakaoLoginButton.snp.makeConstraints
        {   make in
            make.top.equalTo(socialSignUpLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX).offset(-35)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        appleLoginButton.snp.makeConstraints
        {   make in
            make.top.equalTo(socialSignUpLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX).offset(35)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        id_pwLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(50)
            make.centerX.equalTo(view.snp.centerX)
            
        }
    }
    
// MARK: - 버튼 함수
    @objc func cancelSignUp()
    {
        
        dismiss(animated: true)
        
    }
    
    @objc func touchedSignUpButton()
    {
        createUser()
    }
    
    @objc func touchedKakaoLoginButton()
    {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error = error {
                    print("DEBUG: 카카오톡 토큰 가져오기 에러 \(error.localizedDescription)")
                    self.kakaoLogin()
                } else {
                    // 토큰 유효성 체크 성공 (필요 시 토큰 갱신됨)
                }
            }
        } 
        
        else {
            // 토큰이 없는 상태 로그인 필요
            kakaoLogin()
        }
    }
    
    @objc func touchedAppleLoginButton()
    {
        
    }
    
    @objc func keyboardExit()
    {
        self.view.endEditing(true)
    }
    
// MARK: - Firebase 유저 생성
    func createUser()
    {
        guard let email = emailTextField.text else { return }
        guard let password = pwTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password)
        {   result,error in
            
            if let error = error
            {
                print("사용자 생성 실패")
                print(error)
            }
            
            if let result = result
            {
                print("사용자 생성 성공")
                print(result)
            }
        }
        dismiss(animated: true)
    }
    
    func kakaoLogin()
    {
        if UserApi.isKakaoTalkLoginAvailable()
        {
            kakaoLoginInApp()
        }
        
        else
        {
            kakaoLoginInWeb()
        }
    }
    
    func kakaoLoginInApp()
    {
        UserApi.shared.loginWithKakaoTalk
        {   oauthToken, error in
            if let error = error
            {
                print("카카오톡 로그인 실패")
            }
            
            else
            {
                print("카카오톡 로그인 실패")
                if let token = oauthToken
                {
                    self.createUserByKakao()
                }
            }
        }
    }
    
    func kakaoLoginInWeb()
    {
        UserApi.shared.loginWithKakaoAccount
        {   oauthToken, error in
            if let error = error
            {
                print("카카오톡 로그인 실패")
            }
            
            else
            {
                if let token = oauthToken
                {
                    self.createUserByKakao()
                }
            }
        }
    }
    
    func createUserByKakao()
    {
        UserApi.shared.me()
        {   user, error in
            if let error = error
            {
                print("카카오 사용자 정보 가져오기 실패")
            }
            
            else
            {
                print("카카오 사용자 정보 가져오기 성공")
                Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))")
                {   result, error in
                    if let error = error
                    {
                        print("사용자 생성 실패")
                    }
                    if let result = result
                    {
                        print("사용자 생성 성공")
                        self.dismiss(animated: true)
                    }
                    
                }
            }
        }
    }
        
    
}

// MARK: - TextFieldDelegate extension
extension SignUpViewController: UITextFieldDelegate
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
    
    func textFieldDidEndEditing(_ textField: UITextField) 
    {
        if textField == emailTextField
        {
            if let id = textField.text
            {
                self.idValue = id
            }
        }
        
        else if textField == pwTextField
        {
            if let pw = textField.text
            {
                self.pwValue = pw
            }
        }
        
        id_pwLabel.text = "ID : \(idValue)\nPW : \(pwValue)"
    }

}

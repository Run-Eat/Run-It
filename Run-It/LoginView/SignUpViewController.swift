//
//  SignUpViewController.swift
//  Run-It
//
//  Created by 석진 on 2/26/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


class SignUpViewController: UIViewController
{
    
// MARK: - UI 구성
    lazy var cancelButton: UIButton =
    {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = UIColor.label
        button.addTarget(self, action: #selector(cancelSignUp), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel =
    {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: CGFloat(17))
        label.textColor = UIColor.label
        return label
    }()
    
    let explainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "이메일과 비밀번호만으로 \nRUN IT에 가입할 수 있어요!"
        label.font = UIFont.systemFont(ofSize: CGFloat(21))
        label.numberOfLines = 2
        label.textColor = UIColor.label
        return label
    }()
    
    let emailTextField: UITextField =
    {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "RUNIT@xxxxx.com", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .continue
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 7
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    
    let emailExplainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "정확한 이메일을 입력해주세요"
        label.font = UIFont.systemFont(ofSize: CGFloat(12))
        label.textColor = UIColor.label
        return label
    }()
    
    let passwordTextField: UITextField =
    {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "비밀번호 설정", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.borderStyle = .roundedRect
        textField.keyboardType = .default
        textField.returnKeyType = .go
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 7
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    
    lazy var passwordShowHideButton: UIButton =
    {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.addTarget(self, action: #selector(showHidePassword), for: .touchUpInside)
        button.tintColor = .lightGray
        return button
    }()
    
    let passwordExplainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "비밀번호는 영문, 숫자, 특수문자를 포함해 8 - 20자 이내로 입력해주세요"
        label.font = UIFont.systemFont(ofSize: CGFloat(12))
        label.numberOfLines = 2
        label.textColor = UIColor.label
        return label
    }()
    
    lazy var signUpButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(touchedSignUpButton), for: .touchUpInside)
        return button
    }()
    
    let socialSignUpLabel: UILabel =
    {
        let label = UILabel()
        label.text = "또는 소셜 계정으로 가입"
        label.font = UIFont.systemFont(ofSize: CGFloat(14))
        label.textColor = UIColor.label
        return label
    }()
    
    let leftLine: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.label
        return lineView
    }()
    
    let rightLine: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.label
        return lineView
    }()
    
    lazy var kakaoSignupButton: UIButton =
    {
        let button = UIButton()
        button.setImage(UIImage(named: "KakaoLogo"), for: .normal)
        button.addTarget(self, action: #selector(touchedKakaoSignupButton), for: .touchUpInside)
        return button
    }()
    
    lazy var appleSignupButton: UIButton =
    {
        let button = UIButton()
        let logoImage = UIImage(systemName: "applelogo")
        button.setImage(logoImage, for: .normal)
        button.addTarget(self, action: #selector(touchedAppleSignupButton), for: .touchUpInside)
        let buttonSize: CGFloat = 40
            button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        // cornerRadius를 버튼 높이의 절반으로 설정하여 원형으로 만듭니다.
        button.layer.cornerRadius = buttonSize / 2
        // 클립 투 바운즈를 true로 설정하여 레이어 바깥으로 내용이 표시되지 않도록 합니다.
        button.clipsToBounds = true
        if #available(iOS 13.0, *) {
            // 초기 인터페이스 스타일에 따라 버튼의 색상을 설정합니다.
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                button.backgroundColor = .white
                button.tintColor = .black
            } else {
                button.backgroundColor = .black
                button.tintColor = .white
            }
        } else {
            // iOS 13 미만에서는 기본 테마를 사용합니다.
            button.backgroundColor = .black
            button.tintColor = .white
        }
        return button
    }()

// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addSubView()
        setLayout()
        addInputAccessoryForTextFields()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTextFieldBorderColor()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // 이전 트레이트 컬렉션과 현재 트레이트 컬렉션을 비교하여
        // 색상 모드(다크 모드, 라이트 모드)가 변경되었는지 확인합니다.
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 색상 모드가 변경되었다면 테두리 색상을 업데이트합니다.
            updateTextFieldBorderColor()
        }
        
        if #available(iOS 13.0, *) {
            // 현재 트레이트 컬렉션을 가져와서 인터페이스 스타일을 확인합니다.
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            // 다크 모드일 때
            if userInterfaceStyle == .dark {
                appleSignupButton.backgroundColor = .white
                appleSignupButton.tintColor = .black
            } else { // 라이트 모드 또는 미정의일 때
                appleSignupButton.backgroundColor = .black
                appleSignupButton.tintColor = .white
            }
        }
    }

// MARK: - 레이아웃 지정
    func addSubView()
    {
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(explainLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailExplainLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordShowHideButton)
        view.addSubview(passwordExplainLabel)
        view.addSubview(signUpButton)
        view.addSubview(socialSignUpLabel)
        view.addSubview(leftLine)
        view.addSubview(rightLine)
        view.addSubview(kakaoSignupButton)
        view.addSubview(appleSignupButton)
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
        
        emailExplainLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.leading.equalTo(view.snp.leading).inset(25)
        }
        
        passwordTextField.snp.makeConstraints
        {   make in
            make.top.equalTo(emailExplainLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        
        passwordShowHideButton.snp.makeConstraints
        {   make in
            make.centerY.equalTo(passwordTextField.snp.centerY)
            make.trailing.equalTo(passwordTextField).offset(-10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        passwordExplainLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(7)
            make.leading.equalTo(view.snp.leading).inset(25)
        }
        
        signUpButton.snp.makeConstraints
        {   make in
            make.top.equalTo(passwordExplainLabel.snp.bottom).offset(40)
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
        
        kakaoSignupButton.snp.makeConstraints
        {   make in
            make.top.equalTo(socialSignUpLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX).offset(-35)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        appleSignupButton.snp.makeConstraints
        {   make in
            make.top.equalTo(socialSignUpLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX).offset(35)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    func updateTextFieldBorderColor() {
        emailTextField.layer.borderColor = (traitCollection.userInterfaceStyle == .dark)
            ? UIColor.white.cgColor
            : UIColor.black.cgColor
        emailTextField.layer.borderWidth = 0.7
        
        passwordTextField.layer.borderColor = (traitCollection.userInterfaceStyle == .dark)
            ? UIColor.white.cgColor
            : UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 0.7
    }
    
// MARK: - 버튼 함수
    @objc func cancelSignUp()
    {
        let alertController = UIAlertController(title: "알림", message: "회원가입을 중단하시겠습니까?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in self.dismiss(animated: true) }
        alertController.addAction(cancel)
        alertController.addAction(confirm)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func showHidePassword()
    {
        passwordTextField.isSecureTextEntry.toggle()
        
        if passwordTextField.isSecureTextEntry
        {
            passwordShowHideButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
        
        else
        {
            passwordShowHideButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
    }
    
    @objc func touchedSignUpButton()
    {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        emailSignUp(email: email, password: password)

        let alertController = UIAlertController(title: "알림", message: "회원가입이 완료되었습니다", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in self.dismiss(animated: true) }
        alertController.addAction(confirm)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func touchedKakaoSignupButton()
    {
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
        }
        
        else
        {
            UserApi.shared.me
            {   user, error in
                
                guard let useremail = user?.kakaoAccount?.email else { return }
                if user == nil
                {
                    print("이메일 가져오기 실패")
                    if let error = error
                    {
                        print(error)
                    }
                }
                
                else if user != nil
                {
                    print("이메일 가져오기 성공")
                    checkData(loginType: "Kakao", email: useremail)
                }
                
            }
            kakaoSignup()
            dismiss(animated: true)
        }
    }
    
    @objc func touchedAppleSignupButton()
    {
        dismiss(animated: true)
        sendTask(task: "signupToAppleLogin")
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
            passwordTextField.becomeFirstResponder()
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
    
    func textFieldDidChangeSelection(_ textField: UITextField)
    {
        let isEmailValid = isValidEmail(emailTextField.text ?? "")
        let (isPasswordValid, passwordMessage) = isValidPassword(passwordTextField.text ?? "")
        
        if textField == emailTextField
        {
            if isEmailValid
            {
                emailTextField.layer.borderColor = UIColor.green.cgColor
                emailExplainLabel.text = "이메일 주소가 올바릅니다."
            }
            else
            {
                emailTextField.layer.borderColor = UIColor.red.cgColor
                emailExplainLabel.text = "올바른 이메일을 입력했는지 확인하세요."
            }
        }
        
        else if textField == passwordTextField
        {
            if isPasswordValid
            {
                
                passwordTextField.layer.borderColor = UIColor.green.cgColor
                passwordExplainLabel.text = "비밀번호가 올바릅니다."
            }
            else
            {
                passwordTextField.layer.borderColor = UIColor.red.cgColor
                passwordExplainLabel.text = passwordMessage
            }
        }

        signUpButton.isEnabled = isEmailValid && isPasswordValid
        signUpButton.backgroundColor = ((emailTextField.text != "" && passwordTextField.text != "") && (isEmailValid && isPasswordValid)) ? .systemTeal : .systemGray
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
        passwordTextField.inputAccessoryView = toolbar
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
        passwordTextField.becomeFirstResponder()
    }
}

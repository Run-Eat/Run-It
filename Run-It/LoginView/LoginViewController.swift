//
//  LoginViewController.swift
//  Run-It
//
//  Created by 석진 on 2/26/24.
//

import UIKit
import SnapKit
import CoreData
import FirebaseAuth
import FirebaseCore
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices
import CryptoKit


class LoginViewController: UIViewController
{
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    let loginVM = LoginVM()
    
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
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 7
        return textField
    }()
    
    let passwordTextField: UITextField =
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
        textField.isSecureTextEntry = true
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 7
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
    
    lazy var loginButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(touchedLoginButton), for: .touchUpInside)
        return button
    }()
    
    lazy var findEmailButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("이메일 찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(touchedFindEmailButton), for: .touchUpInside)
        return button
    }()
    
    lazy var resetPasswordButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("비밀번호 재설정", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(touchedResetPasswordButton), for: .touchUpInside)
        return button
    }()
    
    lazy var signUpButton: UIButton =
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
    
    lazy var kakaoLoginButton: UIButton =
    {
        let button = UIButton()
        button.setImage(UIImage(named: "KakaoLogo"), for: .normal)
        button.addTarget(self, action: #selector(touchedKakaoLoginButton), for: .touchUpInside)
        return button
    }()
    
    lazy var appleLoginButton: UIButton =
    {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleLogo"), for: .normal)
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
        registerObserver()
        addInputAccessoryForTextFields()
    }

// MARK: - 레이아웃 설정
    func addSubView()
    {
        view.addSubview(loginLogo)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(passwordShowHideButton)
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
        
        passwordTextField.snp.makeConstraints
        {   make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
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
        
        loginButton.snp.makeConstraints
        {   make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
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
    
// MARK: - CoreData 데이터 확인 후 수정
    func checkData(loginType: String, email: String)
    {
        guard let context = self.persistentContainer?.viewContext else { return }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        
        do
        {
            let results = try context.fetch(fetchRequest)
            
            if results.isEmpty
            {
                createUser()
                print("데이터 비어있음")
            }
            
            else
            {
                print("데이터 존재")
                let user = results[0]
                user.loginType = loginType
                user.email = email
                print(user.loginType as Any)
                try context.save()
            }
        }
        catch
        {
            print("error")
        }
    }
    
// MARK: - 데이터 생성
    func createUser()
    {
        guard let context = self.persistentContainer?.viewContext else { return }
        let userInfo = User(context: context)
        userInfo.userId = UUID()
    }
    
// MARK: - 버튼 함수
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
    
    @objc func touchedLoginButton()
    {
        guard let email = emailTextField.text   else { return }
        guard let password = passwordTextField.text   else { return }
        checkData(loginType: "Email", email: email)
        signInUser(email: email, password: password)
    }
    
    @objc func touchedKakaoLoginButton()
    {
        var email: String = ""
        
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
                    email = useremail
                    print("이메일 가져오기 성공")
                }
            }
        self.checkData(loginType: "Kakao", email: email)
        kakaoLogin()
    }
    
    @objc func touchedAppleLoginButton()
    {
        self.checkData(loginType: "Apple", email: "appleLogin")
        loginVM.setPresentationAnchor(self.view.window!)
        loginVM.appleLogin()
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

// MARK: - Notification
    func registerObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(loginTask), name: NSNotification.Name("loginTask"), object: nil)
    }
    
    @objc func loginTask(notification: NSNotification)
    {
        let result = notification.object as? String
        
        if result == "emptyEmailOrPassword"
        {
            let alertController = UIAlertController(title: "로그인 실패", message: "이메일 또는 비밀번호를 입력해주세요.", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(confirm)
            self.present(alertController, animated: true, completion: nil)
        }
        
        else if result == "wrongEmailOrPassword"
        {
            let alertController = UIAlertController(title: "로그인 실패", message: "이메일 또는 비밀번호가 올바르지 않습니다.", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(confirm)
            self.present(alertController, animated: true, completion: nil)
        }
        
        else if result == "successLogin"
        {
            let VC = MainTabBarViewController()
            
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true, completion: nil)
            emailTextField.text = ""
            passwordTextField.text = ""
        }
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

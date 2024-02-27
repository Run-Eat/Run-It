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
    
    let emailTextfield: UITextField =
    {
        let textfield = UITextField()
        textfield.placeholder = "RUNIT@xxxxx.com"
        textfield.borderStyle = .roundedRect
        textfield.keyboardType = .emailAddress
        textfield.returnKeyType = .continue
        textfield.isUserInteractionEnabled = true
        textfield.isEnabled = true
        textfield.autocorrectionType = .no
        textfield.spellCheckingType = .no
        return textfield
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
        let textfield = UITextField()
        textfield.placeholder = "비밀번호 설정"
        textfield.borderStyle = .roundedRect
        textfield.keyboardType = .default
        textfield.returnKeyType = .go
        textfield.isUserInteractionEnabled = true
        textfield.isEnabled = true
        textfield.autocorrectionType = .no
        textfield.spellCheckingType = .no
        return textfield
    }()
    
    let pwExplainLabel: UILabel =
    {
        let label = UILabel()
        label.text = "비밀번호는 8 - 20자 이내로 입력해주세요"
        label.font = UIFont.systemFont(ofSize: CGFloat(15))
        
        return label
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
    
    let signUpButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(touchedSignUpButton), for: .touchUpInside)
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
        
        emailTextfield.delegate = self
        pwTextField.delegate = self
       
    }

// MARK: - 레이아웃 지정
    func addSubView()
    {
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(explainLabel)
        view.addSubview(emailTextfield)
        view.addSubview(idExplainLabel)
        view.addSubview(pwTextField)
        view.addSubview(pwExplainLabel)
        view.addSubview(socialSignUpLabel)
        view.addSubview(leftLine)
        view.addSubview(rightLine)
        view.addSubview(signUpButton)
        
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
        
        emailTextfield.snp.makeConstraints
        {   make in
            make.top.equalTo(explainLabel.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        
        idExplainLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(emailTextfield.snp.bottom).offset(7)
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
        
        socialSignUpLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(pwExplainLabel.snp.bottom).offset(40)
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
        
        signUpButton.snp.makeConstraints
        {   make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(50)
        }
        
        id_pwLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(emailTextfield.snp.bottom).offset(300)
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
    
    @objc func keyboardExit()
    {
        self.view.endEditing(true)
    }
    
// MARK: - Firebase 유저 생성
    func createUser()
    {
        guard let email = emailTextfield.text else { return }
        guard let password = pwTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password)
        {   result,error in
            
            if let error = error
            {
                print(error)
            }
            
            if let result = result
            {
                print(result)
            }
        }
    }
}


extension SignUpViewController: UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool 
    {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailTextfield 
        {
            pwTextField.becomeFirstResponder()
        }
        
        else
        {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) 
    {
        if textField == emailTextfield
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

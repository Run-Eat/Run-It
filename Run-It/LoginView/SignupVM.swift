//
//  Login_SignupVM.swift
//  Run-It
//
//  Created by 석진 on 2/29/24.
//

import Foundation
import FirebaseAuth
import KakaoSDKAuth
import KakaoSDKUser


func isValidEmail(_ email: String) -> Bool      // 이메일 유효성 검사
{
    // 이메일 정규 표현식
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}
    
   
func isValidPassword(_ password: String) -> (isVaild: Bool, message: String)    // 비밀번호 유효성 검사
{
    // 비밀번호 정규 표현식
    let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,20}$"
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
    let isValid = passwordPredicate.evaluate(with: password)
    
    var message = ""
    if !isValid
    {
        if password.count < 8 || password.count > 20
        {
            message += "비밀번호는 8자 이상 20자 이하여야 합니다."
        }
        
        else
        {
            var inValidCondition = [String]()
            if password.rangeOfCharacter(from: CharacterSet.letters) == nil
            {
                inValidCondition.append("영문자")
            }
            if password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil
            {
                inValidCondition.append("숫자")
            }
            if password.rangeOfCharacter(from: CharacterSet(charactersIn: "@$!%*#?&")) == nil
            {
                inValidCondition.append("특수문자")
            }
            if !inValidCondition.isEmpty
            {
                message = "\(inValidCondition.joined(separator: ", "))가 입력되지 않았습니다."
            }
        }
    }
    return(isValid, message)
}

// MARK: - Firebase 유저 생성
func emailSignUp(email: String, password: String)
    {
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
    }

// MARK: - 카카오 아이디 생성
func kakaoSignup()   // 카카오 로그인
{
    if UserApi.isKakaoTalkLoginAvailable()
    {
        kakaoSignupInApp()
    }
    
    else
    {
        kakaoSignupInWeb()
    }
}
    
func kakaoSignupInApp()  // 카카오톡 앱이 설치되어있을 경우
{
    UserApi.shared.loginWithKakaoTalk
    {   oauthToken, error in
        if error != nil
        {
            print("카카오톡 로그인 실패")
        }
        
        else
        {
            print("카카오톡 로그인 실패")
            if oauthToken != nil
            {
                createUserByKakao()
            }
        }
    }
}
    
func kakaoSignupInWeb()  // 카카오톡 앱이 설치되어있지 않거나 열수 없는 경우
{
    UserApi.shared.loginWithKakaoAccount
    {   oauthToken, error in
        if error != nil
        {
            print("카카오톡 로그인 실패")
        }
        
        else
        {
            if oauthToken != nil
            {
                createUserByKakao()
            }
        }
    }
}
    
func createUserByKakao()
{
    UserApi.shared.me()
    {   user, error in
        if error != nil
        {
            print("카카오 사용자 정보 가져오기 실패")
        }
        
        else
        {
            print("카카오 사용자 정보 가져오기 성공")
            
            guard let email = user?.kakaoAccount?.email else { return }
            guard let pw = user?.id else { return }
            
            Auth.auth().createUser(withEmail: email, password: "\(pw)")
            {   result, error in
                if error != nil
                {
                    print("사용자 생성 실패 - \(String(describing: error))")
                    checkData(loginType: "Kakao", email: email)
                    sendTask(task: "Account Exists - Login")
                }
                if result != nil
                {
                    print("사용자 생성 성공")
                    checkData(loginType: "Kakao", email: email)
                    sendTask(task: "KakaoSignupSucces")
                }
                
            }
        }
    }
}

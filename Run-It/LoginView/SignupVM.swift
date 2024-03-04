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
    
   
func isValidPassword(_ password: String) -> Bool    // 비밀번호 유효성 검사
{
    // 비밀번호 정규 표현식
    let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,20}$"
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
    return passwordPredicate.evaluate(with: password)
}

// MARK: - Firebase 유저 생성
func createUser(email: String, password: String)
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
        if let error = error
        {
            print("카카오톡 로그인 실패")
        }
        
        else
        {
            print("카카오톡 로그인 실패")
            if let token = oauthToken
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
        if let error = error
        {
            print("카카오톡 로그인 실패")
        }
        
        else
        {
            if let token = oauthToken
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
        if let error = error
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
                if let error = error
                {
                    print("사용자 생성 실패")
                }
                if let result = result
                {
                    print("사용자 생성 성공")
                    
                }
                
            }
        }
    }
}

//
//  LoginVM.swift
//  Run-It
//
//  Created by 석진 on 2/29/24.
//

import Foundation
import FirebaseAuth
import KakaoSDKAuth
import KakaoSDKUser


// MARK: - Firebase 로그인
func signInUser(email: String, password: String)
    {
        
        
        if email == "" || password == ""
        {
            sendTask(task: "emptyEmailOrPassword")
        }
        
        else
        {
            Auth.auth().signIn(withEmail: email, password: password)
            {   authResult, error in
                if authResult == nil
                {
                    print("로그인 실패")
                    if let error = error
                    {
                        print(error)
                        sendTask(task: "wrongEmailOrPassword")
                    }
                }
                else if authResult != nil
                {
                    print("로그인 성공")
                    sendTask(task: "successLogin")
                }
            }
        }
    }

    func kakaoLogin()
    {
        if AuthApi.hasToken()
        {
            UserApi.shared.accessTokenInfo
            {   _, error in
                if let error = error    // 토큰이 유효하지 않은 경우
                {
                    openKakaoService()
                }
                
                else    // 토큰이 유효한 경우
                {
                    bringKakaoInfo()
                }
                
            }
        }
        
        else    // 토큰이 만료된 경우
        {
            openKakaoService()
        }
    }
    
    func openKakaoService()   // 카카오 서비스 열기
    {
        if UserApi.isKakaoTalkLoginAvailable()
        {
            kakaoLoginInApp()
        }
        
        else
        {
            kakaoLoginInWeb()
            bringKakaoInfo()
        }
    }
    
    func kakaoLoginInApp()  // 카카오톡 앱이 설치되어있을 경우
    {
        UserApi.shared.loginWithKakaoTalk
        {   oauthToken, error in
            if let error = error
            {
                print("카카오톡 로그인 실패")
            }
            
            else
            {
                if let token = oauthToken
                {
                    bringKakaoInfo()
                }
            }
        }
    }
    
    func kakaoLoginInWeb()  // 카카오톡 앱이 설치되어있지 않거나 열수 없는 경우
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
                    bringKakaoInfo()
                }
            }
        }
    }
    
    func bringKakaoInfo()
    {
        UserApi.shared.me
        {   user, error in
            if let error = error
            {
                print("카카오 사용자 정보 불러오기 실패")
                return
            }
            
            guard let email = user?.kakaoAccount?.email else { return }
            guard let pw = user?.id else { return }
            
            Auth.auth().signIn(withEmail: email, password: "\(pw)")
            {    authResult, error in
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
                    sendTask(task: "successLogin")
                }
            }
        }
    }

// MARK: - Notification
func sendTask(task: String)
{
    NotificationCenter.default.post(name: Notification.Name("loginTask"), object: task)
}


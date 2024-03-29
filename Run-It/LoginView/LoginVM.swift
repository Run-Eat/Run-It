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
import AuthenticationServices
import CryptoKit
import SwiftJWT
import Alamofire
import KeychainAccess
import CoreData


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
            if error != nil    // 토큰이 유효하지 않은 경우
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
        if error != nil
        {
            print("카카오톡 로그인 실패")
        }
        
        else
        {
            if oauthToken != nil
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
        if error != nil
        {
            print("카카오톡 로그인 실패")
        }
        
        else
        {
            if oauthToken != nil
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
        if error != nil
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
                checkData(loginType: "Kakao", email: email)
                sendTask(task: "successLogin")
            }
        }
    }
}

//MARK: - 애플 로그인
class LoginVM: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding
{
    
    var currentNonce: String?
    var presentationAnchor: ASPresentationAnchor?
    
    func setPresentationAnchor(_ anchor: ASPresentationAnchor) 
    {
        presentationAnchor = anchor
    }

    func appleLogin() 
    {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        if presentationAnchor != nil
        {
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        
        else
        {
            fatalError("presentationAnchor 가 설정되지 않음")
        }
    }
    
    func sha256(_ input: String) -> String
    {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func randomNonceString(length: Int = 32) -> String
    {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map
            {   _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess
                {
                    fatalError("nonce를 생성 실패 - \(errorCode)")
                }
                return random
            }
            
            randoms.forEach
            {   random in
                if remainingLength == 0
                {
                    return
                }
                
                if random < charset.count
                {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) 
    {
        switch authorization.credential
        {
        case
            let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            checkData(loginType: "Apple", email: email ?? "none")
            
            if let authorizationCode = appleIDCredential.authorizationCode,
               let identityToken = appleIDCredential.identityToken,
               let authCodeString = String(data: authorizationCode, encoding: .utf8),
               let tokenString = String(data: identityToken, encoding: .utf8)
            {
                let keychain = Keychain(service: "com.team5.Run-It")
                
                do
                {
                    try keychain.set(authorizationCode, key: "authorizationCode")
                    try keychain.set(userIdentifier, key: "UserID")
                }
                catch
                {
                    print("키 체인 저장 실패 - \(error)")
                }
                
                print("authorizationCode : \(authorizationCode)")
                print("identityToken : \(identityToken)")
                print("authCodeString : \(authCodeString)")
                print("tokenString : \(tokenString)")
            }
            
            print("userIdentifier : \(userIdentifier)")
            print("fullName : \(String(describing: fullName))")
            print("email : \(String(describing: email))")
            
        case
            let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username : \(username)")
            print("password : \(password)")
            
        default:
            break
        }
        sendTask(task: "successLogin")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        guard let anchor = presentationAnchor else { fatalError("presentationAnchor 가 설정되지 않음") }
        
        return anchor
    }
}

// MARK: - Notification
func sendTask(task: String)
{
    NotificationCenter.default.post(name: Notification.Name("loginTask"), object: task)
}


var persistentContainer: NSPersistentContainer?
{
    (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
}

// MARK: - CoreData 데이터 확인 후 수정
func checkData(loginType: String, email: String)
{
    guard let context = persistentContainer?.viewContext else { return }
    
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(value: true)
    
    do
    {
        let results = try context.fetch(fetchRequest)
        
        if results.isEmpty
        {
            print("데이터 비어있음")
            return
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

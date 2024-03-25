//
//  ProfileViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit
import SnapKit
import CoreData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck
import KakaoSDKAuth
import KakaoSDKUser
import SwiftJWT
import Alamofire
import KeychainAccess


class ProfileViewController: UIViewController
{
    var viewModel: RunningRecordViewModel!
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    private var stackView: UIStackView!
    // 총 뛴 거리
    var totalRunningDistance: Double = 0

    // 이번 주 데이터
    var thisWeekDistance: Double = 0
    var thisWeekPace: Double = 0
    var thisWeekRunningCount: Int = 0

    // 지난 주 데이터
    var lastWeekDistance: Double = 0
    var lastWeekPace: Double = 0
    var lastWeekRunningCount: Int = 0

    // 이번 달 데이터
    var thisMonthDistance: Double = 0
    var thisMonthPace: Double = 0
    var thisMonthRunningCount: Int = 0

    // 지난 달 데이터
    var lastMonthDistance: Double = 0
    var lastMonthPace: Double = 0
    var lastMonthRunningCount: Int = 0
    
    var runningRecords: [RunningRecord] = []
    var uiView = UIView()
    var tableView = UITableView()
    var userRecord: UILabel = {
        let label = UILabel()
        label.text = "활동기록"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    var tableViewHeightConstraint: Constraint?
    
// MARK: - UI 생성
    
    let scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    lazy var noticeButton: UIButton =
    {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "알림"
        configuration.image = UIImage(named: "NoticeIcon")
        configuration.imagePadding = 10 // 이미지와 제목 간격 조정
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(noticeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var imageName = loginType()
    
    lazy var loginTypeIcon = UIImageView(image: UIImage(named: imageName + "Logo"))
    
    lazy var logoutButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(touchedLogoutButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var titleLabel = createLabel("내 정보", 35)
    
    let profileImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    lazy var imageSettingButton: UIButton =
    {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .bold, scale: .medium)
        button.setImage(UIImage(systemName: "camera.circle",withConfiguration: config), for: .normal)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        return button
    }()
    
    let pointImage = UIImageView(image: UIImage(named: "PointIcon"))
    
    lazy var pointLabel = createLabel("포인트", 20)
    
    lazy var statsLabel = createLabel("통계", 25)
    
    let line: UIView =
    {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.label
        lineView.alpha = 0.7
        return lineView
    }()
    
    lazy var totalRunningDistanceLabel = createLabel("", 16)
    
    lazy var weeklyButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("주 간", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(touchedWeeklyButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var monthlyButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("월 간", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(touchedMonthlyButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var nonLabel = createLabel("구분", 16)
    lazy var thisWeek_MonthLabel = createLabel("이번 주", 16)
    lazy var lastWeek_MonthLabel = createLabel("지난 주", 16)
    
    lazy var distanceTextLabel = createLabel("거리(km)", 18)
    lazy var thisWeek_MonthDistanceLabel = createLabel("", 18)
    lazy var lastWeek_MonthDistanceLabel = createLabel("", 18)
    
    lazy var paceAveragTextLabel = createLabel("평균 페이스", 18)
    lazy var thisWeek_MonthPaceLabel = createLabel("", 18)
    lazy var lastWeek_MonthPaceLabel = createLabel("", 18)
    
    lazy var runningCountTextLabel = createLabel("활동", 18)
    lazy var thisWeek_MonthRunningCountLabel = createLabel("", 18)
    lazy var lastWeek_MonthRunningCountLabel = createLabel("", 18)
    
    lazy var resetButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("러닝 기록 초기화", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 14
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(resetRecord), for: .touchUpInside)
        
        return button
    }()
    

    let generator = UIImpactFeedbackGenerator(style: .heavy)
    lazy var withdrawButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("회원 탈퇴", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 14
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(withdrawal), for: .touchUpInside)
        
        return button
    }()
    
    let buttonsContainerView = UIView()
// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2000)
        addScrollView()
        setLayout()
        setupProfileUI()
        setupRecordStackView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let uiViewHeight = CGFloat(runningRecords.count) * 170.0 + 16.0
        let contentHeight = 671.33 + 44 + 8 + uiViewHeight
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRunningRecords()
        displayProfileImage()
        statisticsManager(true)
        
        totalRunningDistanceLabel.text = "총 거리 : \(String(format: "%.2f", totalRunningDistance / 1000))km"

        
        thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", thisWeekDistance))"
        thisWeek_MonthPaceLabel.text = String(format: "%.2f", thisWeekPace)
        thisWeek_MonthRunningCountLabel.text = "\(thisWeekRunningCount) 회"
        
        lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", lastWeekDistance))"
        lastWeek_MonthPaceLabel.text = String(format: "%.2f", lastWeekPace)
        lastWeek_MonthRunningCountLabel.text = "\(lastWeekRunningCount) 회"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statisticsManager(false)
    }
   
    // MARK: - addSubView
    func addScrollView()
    {
        scrollView.addSubview(noticeButton)
        scrollView.addSubview(loginTypeIcon)
        scrollView.addSubview(logoutButton)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(imageSettingButton)
        scrollView.addSubview(pointImage)
        scrollView.addSubview(pointLabel)
        scrollView.addSubview(statsLabel)
        scrollView.addSubview(line)
        scrollView.addSubview(totalRunningDistanceLabel)
        scrollView.addSubview(weeklyButton)
        scrollView.addSubview(monthlyButton)
        scrollView.addSubview(userRecord)
        scrollView.addSubview(uiView)
        scrollView.addSubview(resetButton)
        scrollView.addSubview(withdrawButton)

    }
    
// MARK: - 레이아웃
    func setLayout()
    {
        scrollView.snp.makeConstraints
        {   make in
            make.edges.equalToSuperview()
        }
        
        noticeButton.snp.makeConstraints
        {   make in
            make.top.equalTo(scrollView.snp.top).inset(0)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.width.equalTo(90)
        }
        
        loginTypeIcon.snp.makeConstraints
        {   make in
            make.centerY.equalTo(noticeButton.snp.centerY)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        logoutButton.snp.makeConstraints
        {   make in
            make.centerY.equalTo(loginTypeIcon.snp.centerY)
            make.leading.equalTo(loginTypeIcon.snp.leading).offset(15)
            make.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(noticeButton.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        profileImageView.snp.makeConstraints
        {   make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        
        imageSettingButton.snp.makeConstraints
        {   make in
            make.top.equalTo(titleLabel.snp.bottom).offset(145)
            make.trailing.equalTo(view.snp.trailing).inset(130)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        
        pointImage.snp.makeConstraints
        {   make in
            make.top.equalTo(profileImageView.snp.bottom).offset(25)
            make.trailing.equalTo(view.snp.trailing).inset(100)
            make.width.equalTo(22)
            make.height.equalTo(22)
        }
        
        pointLabel.snp.makeConstraints
        {   make in
            make.centerY.equalTo(pointImage.snp.centerY)
            make.trailing.equalTo(pointImage.snp.trailing).offset(60)
        }
        
        statsLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(pointImage.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).inset(20)
        }
        
        line.snp.makeConstraints
        {   make in
            make.top.equalTo(statsLabel.snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.height.equalTo(1)
        }
        
        totalRunningDistanceLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(line.snp.bottom).offset(9)
            make.leading.equalTo(view.snp.leading).inset(20)
        }
        
        weeklyButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalTo(totalRunningDistanceLabel.snp.bottom).offset(32)
            // weeklyButton은 뷰의 중앙에서 왼쪽으로 (50/2)인 25만큼 이동
            make.centerX.equalToSuperview().offset(-25 - 50) // 50은 두 버튼 사이의 간격
        }
        
        monthlyButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalTo(weeklyButton.snp.top)
            make.leading.equalTo(weeklyButton.snp.trailing).offset(50)
        }
        
        resetButton.snp.makeConstraints
        {   make in
            make.centerY.equalTo(pointImage.snp.centerY)
            make.leading.equalTo(view.snp.leading).inset(30)
            make.width.equalTo(120)
        }
        
        withdrawButton.snp.makeConstraints
        {   make in
            make.trailing.equalTo(view.snp.trailing).inset(30)
            make.top.equalTo(noticeButton.snp.bottom).offset(10)
            make.width.equalTo(80)
        }
        
    }
    
    func setupRecordStackView() {
        let labelInfoStackView = UIStackView(arrangedSubviews: [nonLabel,distanceTextLabel,paceAveragTextLabel,runningCountTextLabel])
        labelInfoStackView.axis = .vertical
        labelInfoStackView.spacing = 20.0
        labelInfoStackView.distribution = .fillEqually
        
        let thisWeekInfoStackView = UIStackView(arrangedSubviews: [thisWeek_MonthLabel,thisWeek_MonthDistanceLabel,thisWeek_MonthPaceLabel,thisWeek_MonthRunningCountLabel])
        thisWeekInfoStackView.axis = .vertical
        thisWeekInfoStackView.spacing = 20.0
        thisWeekInfoStackView.alignment = .trailing
        
        let lastWeekInfoStackView = UIStackView(arrangedSubviews: [lastWeek_MonthLabel,lastWeek_MonthDistanceLabel,lastWeek_MonthPaceLabel,lastWeek_MonthRunningCountLabel])
        lastWeekInfoStackView.axis = .vertical
        lastWeekInfoStackView.spacing = 22.0
        lastWeekInfoStackView.alignment = .trailing
        
        stackView = UIStackView(arrangedSubviews: [labelInfoStackView, thisWeekInfoStackView,lastWeekInfoStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40.0
        
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(weeklyButton.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        userRecord.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        uiView.snp.makeConstraints { make in
            make.top.equalTo(userRecord.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(runningRecords.count * 170 + 16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            self.tableViewHeightConstraint = make.height.equalTo(runningRecords.count * 170).constraint
        }
    }
    
// MARK: - 레이블 생성 함수
    func createLabel(_ text: String, _ fontSize: Int) -> UILabel
    {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        
        return label
    }
    
// MARK: - 로그인 방식 가져오기
    func loginType() -> String
    {
        guard let context = self.persistentContainer?.viewContext else { return "" }
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do
        {
            let data = try context.fetch(request)
            let user = data.first!
            
            return user.loginType ?? ""
        }
        catch
        {
            print("데이터 가져오기 에러")
            return ""
        }
    }
    
// MARK: - 로그아웃 함수
    func kakaoLogout()
    {
        // 사용자 액세스 토큰과 리프레시 토큰을 모두 만료시켜, 더 이상 해당 사용자 정보로 카카오 API를 호출할 수 없도록 합니다.
        UserApi.shared.logout {(error) in
            if let error = error
            {
                print(error)
            }
            else
            {
                print("logout() success.")
            }
        }
    }
    
    func emailLogout()
    {
        let firebaseAuth = Auth.auth()
        do
        {
            try firebaseAuth.signOut()
            print("로그아웃 완료")
        }
        catch _ as NSError
        {
            print("로그아웃 에러")
        }
    }
    
    func appleLogout()
    {
        
    }
 
// MARK: - 프로필 사진 관리 메서드
    func saveImageData(profileImage: UIImage)
    {
        guard let context = self.persistentContainer?.viewContext else { return }
        
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        
        do
        {
            let results = try context.fetch(fetchRequest)
            
            if results.isEmpty
            {
                print("데이터 비어있음")
            }
            
            else
            {
                print("User데이터 존재")
                let user = results[0]
                user.profilePhoto = profileImage.imageData
                print(user.loginType as Any)
                try context.save()
            }
        }
        catch
        {
            print("error")
        }
    }
    
    func displayProfileImage()
    {
        guard let context = persistentContainer?.viewContext else { return }
        let request: NSFetchRequest<User> = User.fetchRequest()
            // 이미지 데이터 가져오기
        do
        {
            if let imageData = try context.fetch(request).first?.profilePhoto
            {
                if let image = UIImage(data: imageData)
                {
                    profileImageView.image = image
                }
            }
        }
        catch
        {
            print("Error fetching image data: \(error)")
        }
    }
    
// MARK: - 통계 관리 메서드
    func statisticsManager(_ task: Bool)
    {
        if task
        {
            print("통계 불러오기")
            guard let context = persistentContainer?.viewContext else { return }
            
            let currentDate = Date()
            let calender = Calendar.current
            
            let currentMonth = calender.component(.month, from: currentDate)    // 현재 월
            let currentWeekOfYear = calender.component(.weekOfYear, from: currentDate)      // 현재 연 중의 주차
            
            let fetchRequest: NSFetchRequest<RunningRecord> = RunningRecord.fetchRequest()
            
            do {
                let records = try context.fetch(fetchRequest)
                var thisWeekTotalTime: TimeInterval = 0
                var lastWeekTotalTime: TimeInterval = 0
                var thisMonthTotalTime: TimeInterval = 0
                var lastMonthTotalTime: TimeInterval = 0
                
                for record in records
                {
                    guard let recordDate = record.date else { return }
                    
                    let recordMonth = calender.component(.month, from: recordDate)
                    let recordWeekOfYear = calender.component(.weekOfYear, from: recordDate)
                    
                    // 총 거리
                    totalRunningDistance += record.distance
                    
                    // 이번 주 데이터
                    if recordWeekOfYear == currentWeekOfYear
                    {
                        thisWeekDistance += record.distance / 1000
                        thisWeekTotalTime += Double(record.time)
                        thisWeekRunningCount += 1
                    }
                    
                    // 지난 주 데이터
                    else if recordWeekOfYear == currentWeekOfYear - 1
                    {
                        lastWeekDistance += record.distance / 1000
                        lastWeekTotalTime += Double(record.time)
                        lastWeekRunningCount += 1
                    }
                    
                    // 이번 달 데이터
                    if recordMonth == currentMonth
                    {
                        thisMonthDistance += record.distance / 1000
                        thisMonthTotalTime += Double(record.time)
                        thisMonthRunningCount += 1
                    }
                    
                    // 지난 달 데이터
                    else if recordMonth == currentMonth - 1
                    {
                        lastMonthDistance += record.distance / 1000
                        lastMonthTotalTime += Double(record.time)
                        lastMonthRunningCount += 1
                    }
                    
                }
                // 주간, 월간 페이스 계산
                thisWeekPace = (thisWeekRunningCount > 0) ? (thisWeekTotalTime / 60) / (thisWeekDistance) : 0
                lastWeekPace = (lastWeekRunningCount > 0) ? (lastWeekTotalTime / 60) / lastWeekDistance : 0
                thisMonthPace = (thisMonthRunningCount > 0) ? (thisMonthTotalTime / 60) / thisMonthDistance : 0
                lastMonthPace = (lastMonthRunningCount > 0) ? (lastMonthTotalTime / 60 ) / lastMonthDistance : 0
            }
            catch
            {
                print("Error")
            }
        }
        
        else
        {
            totalRunningDistance = 0

            thisWeekDistance = 0
            thisWeekPace = 0
            thisWeekRunningCount = 0

            lastWeekDistance = 0
            lastWeekPace = 0
            lastWeekRunningCount = 0

            thisMonthDistance = 0
            thisMonthPace = 0
            thisMonthRunningCount = 0

            lastMonthDistance = 0
            lastMonthPace = 0
            lastMonthRunningCount = 0
        }
    }
    
    //MARK: - 이메일 회원 탈퇴
        func deleteAccount()
        {
            if  let user = Auth.auth().currentUser {
                user.delete
                {   [self] error in
                    if let error = error
                    {
                        print("Firebase Error : ",error)
                    }
                    else
                    {
    //                    dismiss(animated: true)
                        let VC = LoginViewController()
                        VC.modalPresentationStyle = .fullScreen
                        self.present(VC, animated: true)
                        
                        print("회원탈퇴 성공!")
                    }
                }
            }
            else
            {
                print("로그인 정보가 존재하지 않습니다")
            }
        }
        
        func deleteKakaoAccount()
        {
            UserApi.shared.unlink
            {   (error) in
                if let error = error
                {
                    print(error)
                }
                else
                {
    //                self.dismiss(animated: true)
                    let VC = LoginViewController()
                    VC.modalPresentationStyle = .fullScreen
                    self.present(VC, animated: true)
                    
                    print("카카오 계정 연결 끊기 성공")
                }
            }
        }
        
        func deleteAppleAccount()
        {
            let jwtString = self.makeJWT()
            // JWT 값 저장
            let keychain = Keychain(service: "com.team5.Run-It")
            
            do
            {
                try keychain.set(jwtString, key: "secret")
            }
            catch
            {
                print("키 체인 저장 실패 - \(error)")
            }
            
            // authorizationCode 불러오기
            do {
                if let taCode = try keychain.get("authorizationCode")
                {
                    print("authorizationCode: \(taCode)")
                    
                    self.getAppleRefreshToken(code: taCode, completionHandler: { output in
                    
                        let clientSecret = jwtString
                        if let refreshToken = output
                        {
                            print("Client_secret - \(clientSecret)")
                            print("refresh_token - \(refreshToken)")
                            
                            self.revokeAppleToken(clientSecret: clientSecret, token: refreshToken)
                            {
                                print("Apple revokeToken Success")
                            }
                            
    //                        self.dismiss(animated: true)
                            let VC = LoginViewController()
                            VC.modalPresentationStyle = .fullScreen
                            self.present(VC, animated: true)
                        }
                        
                        else
                        {
                            let dialog = UIAlertController(title: "error", message: "회원탈퇴 실패", preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: "확인", style: .default, handler: {_ in})
                            dialog.addAction(okayAction)
                            self.present(dialog, animated: true, completion: nil)
                        }
                    })
                }
                else
                {
                    print("authorizationCode이 저장되지 않았습니다.")
                }
            }
            catch
            {
                print("Error fetching from Keychain: \(error)")
            }
        }

        
    // MARK: - 버튼 함수
        @objc func selectImage()    // 프로필 사진
        {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        }
        
        @objc func touchedLogoutButton()    // 로그아웃 버튼
        {
            let alertController = UIAlertController(title: "알림", message: "로그아웃을 하시겠습니까?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                self.kakaoLogout()
                self.emailLogout()
                let VC = LoginViewController()
                VC.modalPresentationStyle = .fullScreen
                self.present(VC, animated: true)
            }
            alertController.addAction(cancel)
            alertController.addAction(confirm)
            self.present(alertController, animated: true, completion: nil)
        }
        
        @objc func touchedWeeklyButton()    // 주별 기록
        {
            generator.impactOccurred()
            weeklyButton.backgroundColor = .systemBlue
            monthlyButton.backgroundColor = .gray
            thisWeek_MonthLabel.text = "이번 주"
            thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", thisWeekDistance))"
            thisWeek_MonthPaceLabel.text = String(format: "%.2f", thisWeekPace)
            thisWeek_MonthRunningCountLabel.text = "\(thisWeekRunningCount) 회"
            
            lastWeek_MonthLabel.text = "지난 주"
            lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", lastWeekDistance))"
            lastWeek_MonthPaceLabel.text = String(format: "%.2f", lastWeekPace)
            lastWeek_MonthRunningCountLabel.text = "\(lastWeekRunningCount) 회"
        }
        
        @objc func touchedMonthlyButton()       // 월별 기록
        {
            generator.impactOccurred()
            monthlyButton.backgroundColor = .systemBlue
            weeklyButton.backgroundColor =  .gray
            thisWeek_MonthLabel.text = "이번 달"
            thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", thisMonthDistance))"
            thisWeek_MonthPaceLabel.text = String(format: "%.2f", thisMonthPace)
            thisWeek_MonthRunningCountLabel.text = "\(thisMonthRunningCount) 회"
            
            lastWeek_MonthLabel.text = "지난 달"
            lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", lastMonthDistance))"
            lastWeek_MonthPaceLabel.text = String(format: "%.2f", lastMonthPace)
            lastWeek_MonthRunningCountLabel.text = "\(lastMonthRunningCount) 회"
        }
        
        @objc func noticeButtonTapped()     // 공지 버튼 present
        {
            let eventVC = EventViewController()
            self.navigationController?.pushViewController(eventVC, animated: true)
        }
        // 추후 coreData 활용 데이터 관리 코드 작성
        
        @objc func resetRecord()    // 러닝 기록 초기화
        {
            print("러닝 기록 초기화")
            let alertController = UIAlertController(title: "알림", message: "러닝 기록을 초기화 하시겠습니까?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                guard let context = self.persistentContainer?.viewContext else { return }
                
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RunningRecord")
                
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do 
                {
                    // Batch Delete 실행
                    try context.execute(batchDeleteRequest)
                    try context.save() // 변경 사항 저장
                }
                
                catch
                {
                    print("error")
                }
                
                self.thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", 0))"
                self.thisWeek_MonthPaceLabel.text = String(format: "%.2f", 0)
                self.thisWeek_MonthRunningCountLabel.text = "0 회"
                
                self.lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", 0))"
                self.lastWeek_MonthPaceLabel.text = String(format: "%.2f", 0)
                self.lastWeek_MonthRunningCountLabel.text = "0 회"
                
                // 총 뛴 거리
                self.totalRunningDistance = 0

                // 이번 주 데이터
                self.thisWeekDistance = 0
                self.thisWeekPace = 0
                self.thisWeekRunningCount = 0

                // 지난 주 데이터
                self.lastWeekDistance = 0
                self.lastWeekPace = 0
                self.lastWeekRunningCount = 0

                // 이번 달 데이터
                self.thisMonthDistance = 0
                self.thisMonthPace = 0
                self.thisMonthRunningCount = 0

                // 지난 달 데이터
                self.lastMonthDistance = 0
                self.lastMonthPace = 0
                self.lastMonthRunningCount = 0
                
                self.tableView.reloadData()
            }
            alertController.addAction(cancel)
            alertController.addAction(confirm)
            present(alertController, animated: true, completion: nil)
            
        }
        
        @objc func withdrawal()     // 회원탈퇴
        {
            let alertController = UIAlertController(title: "알림", message: "회원 탈퇴를 하시겠습니까?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                let loginType = self.loginType()
                
                if loginType == "Email"
                {
                    self.deleteAccount()
                    self.emailLogout()
                }
                
                else if loginType == "Kakao"
                {
                    self.deleteKakaoAccount()
                    self.kakaoLogout()
                }
                
                else
                {
                    self.deleteAppleAccount()
                }
                
                guard let context = self.persistentContainer?.viewContext else { return }
                
                let fetchRequestRunningRecord: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RunningRecord")
                let batchDeleteRequestRunningRecord = NSBatchDeleteRequest(fetchRequest: fetchRequestRunningRecord)
                
                let fetchRequestFavorite: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
                let batchDeleteRequestFavorite = NSBatchDeleteRequest(fetchRequest: fetchRequestFavorite)
                
                let fetchRequestUser: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
                let batchDeleteRequestUser = NSBatchDeleteRequest(fetchRequest: fetchRequestUser)
                
                do
                {
                    // Batch Delete 실행
                    try context.execute(batchDeleteRequestRunningRecord)
                    try context.execute(batchDeleteRequestFavorite)
                    try context.execute(batchDeleteRequestUser)
                    try context.save() // 변경 사항 저장
                }
                
                catch
                {
                    print("error")
                }
            }
            
            alertController.addAction(cancel)
            alertController.addAction(confirm)
            present(alertController, animated: true, completion: nil)
        }
    }


// MARK: - UIImage extension
extension UIImage
{
    var imageData: Data?
    {
        return self.pngData()
    }
}

// MARK: - ImageView extension
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let selectedImage = info[.originalImage] as? UIImage
        {
            guard let image = makeRoundedImage(from: selectedImage) else { return }
            profileImageView.image = image
            saveImageData(profileImage: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}

func makeRoundedImage(from image: UIImage) -> UIImage?
{
    // 이미지를 정사각형으로 만듭니다.
    let imageSize = min(image.size.width, image.size.height)
    let imageOrigin = CGPoint(x: (image.size.width - imageSize) / 2.0, y: (image.size.height - imageSize) / 2.0)
    let imageRect = CGRect(origin: imageOrigin, size: CGSize(width: imageSize, height: imageSize))
    let croppedImage = image.cgImage?.cropping(to: imageRect)
    
    // 정사각형 이미지를 원으로 만듭니다.
    let imageView = UIImageView(image: UIImage(cgImage: croppedImage!, scale: image.scale, orientation: image.imageOrientation))
    imageView.layer.cornerRadius = imageSize / 2.0
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    imageView.layer.render(in: context)
    
    return UIGraphicsGetImageFromCurrentImageContext()
}


extension ProfileViewController {
    // MARK: - UI Setup
    func setupProfileUI() {
        setupRecordListUI()
    }
    
    func setupRecordListUI() {
        uiView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(RecordViewCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.backgroundColor = UIColor.systemGray6
        tableView.isScrollEnabled = false
        uiView.backgroundColor = UIColor.systemGray6
    }
    
    func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        tableViewHeightConstraint?.update(offset: runningRecords.count * 170)
        uiView.snp.updateConstraints { make in
            make.height.equalTo(runningRecords.count * 170 + 16)
        }
        view.layoutIfNeeded()
    }
    
    
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - 데이터 로딩
    func loadRunningRecords() {
        runningRecords = CoreDataManager.shared.fetchRunningRecords()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateTableViewHeight()
        }
    }
    
    private func updateUI() {
        // 뷰모델의 데이터로 UI 업데이트
        thisWeek_MonthDistanceLabel.text = viewModel.distanceText
        thisWeek_MonthPaceLabel.text = viewModel.paceText
        // 더 많은 UI 컴포넌트 업데이트
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runningRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as? RecordViewCell else {
            return UITableViewCell()
        }
        let record = runningRecords[indexPath.row]
        let recordViewModel = RunningRecordViewModel(runningRecord: record)
        cell.configure(with: recordViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecord = runningRecords[indexPath.row]
        let selectedRecordViewModel = RunningRecordViewModel(runningRecord: selectedRecord)
        
        let recordVC = RunningRecordViewController()
        recordVC.viewModel = selectedRecordViewModel
        
        navigationController?.pushViewController(recordVC, animated: true)
    }
    // 선택된 레코드의 뷰모델을 생성하는 메서드
    private func viewModelForRecord(atIndexPath indexPath: IndexPath) -> RunningRecordViewModel {
        let selectedRecord = runningRecords[indexPath.row]
        return RunningRecordViewModel(runningRecord: selectedRecord)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recordToDelete = runningRecords[indexPath.row]
            guard let id = recordToDelete.id else {
                // id가 nil일 경우의 처리, 예: 로그 남기기
                print("Error: Record ID is nil. Cannot delete the record.")
                return
            }
            CoreDataManager.shared.deleteRunningRecord(withId: id) { [weak self] success in
                guard success else {
                    // 삭제 실패에 대한 처리, 여기서는 단순 로그를 남깁니다.
                    print("Failed to delete the record.")
                    return
                }
                // 모델에서 데이터 삭제
                self?.runningRecords.remove(at: indexPath.row)
                // UI 업데이트
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
}

// MARK: - 애플 엑세스 토큰 발급 응답 모델
extension ProfileViewController
{
    struct AppleTokenResponse: Codable 
    {
        var access_token: String?
        var token_type: String?
        var expires_in: Int?
        var refresh_token: String?
        var id_token: String?
        
        enum CodingKeys: String, CodingKey
        {
            case refresh_token = "refresh_token"
        }
    }
            
    func makeJWT() -> String    //client_secret
    {
        let myHeader = Header(kid: "CMKV35Z7JD")
        struct MyClaims: Claims
        {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }
        
        let nowDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = 6
        let sixDate = Calendar.current.date(byAdding: dateComponent, to: nowDate) ?? Date()
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        let myClaims = MyClaims(iss: "335MYJGX88", iat: iat, exp: exp, aud: "https://appleid.apple.com", sub: "com.team5.Run-It")
        
        var myJWT = JWT(header: myHeader, claims: myClaims)
        
        guard let url = Bundle.main.url(forResource: "AuthKey_CMKV35Z7JD", withExtension: "p8") else { return "키 파일 찾기 실패" }
        
        guard let privateKey = try? Data(contentsOf: url) else { return "키 파일 읽기 실패" }
        
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        
        print("signed JWT - \(signedJWT)")
        
        return signedJWT
    }
    
    
    func getAppleRefreshToken(code: String, completionHandler: @escaping (String?) -> Void)
    {
        let keychain = Keychain(service: "com.team5.Run-It")
        
        // jwt 불러오기
        do {
            if let savedSecret = try keychain.get("secret")
            {
                print("secret: \(savedSecret)")
                
                let url = "https://appleid.apple.com/auth/token?client_id=com.team5.Run-It&client_secret=\(savedSecret)&code=\(code)&grant_type=authorization_code"
                let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
                
                print("🗝 clientSecret - \(savedSecret)")
                print("🗝 authCode - \(code)")
                
                print("🗝 url - \(url)")
                
                let a = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
                    .validate(statusCode: 200..<500)
                    .responseData { response in
                        print("🗝 response - \(response.description)")
                        
                        switch response.result
                        {
                        case .success(let output):
                            print("🗝 ouput - \(output)")
                            let decoder = JSONDecoder()
                            do
                            {
                                let decodedData = try decoder.decode(AppleTokenResponse.self, from: output)
                                print("🗝 output2 - \(String(describing: decodedData.refresh_token))")
                                
                                if let refreshToken = decodedData.refresh_token
                                {
                                    completionHandler(refreshToken)
                                }
                                else 
                                {
                                    let alert = UIAlertController(title: "Error", message: "토큰 생성 실패", preferredStyle: .alert)
                                    let okayAction = UIAlertAction(title: "확인", style: .default, handler: {_ in})
                                    alert.addAction(okayAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                            catch
                            {
                                print("Error decoding JSON: \(error)")
                                let alert = UIAlertController(title: "Error", message: "JSON 디코딩 실패", preferredStyle: .alert)
                                let okayAction = UIAlertAction(title: "확인", style: .default, handler: {_ in})
                                alert.addAction(okayAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        case .failure(_):
                            //로그아웃 후 재로그인하여
                            print("애플 토큰 발급 실패 - \(response.error.debugDescription)")
                            let alert = UIAlertController(title: "error", message: "토큰 생성 실패", preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: "확인", style: .default, handler: {_ in})
                            alert.addAction(okayAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
            }
            else
            {
                print("secret이 저장되지 않았습니다.")
            }
        }
        catch
        {
            print("Error fetching from Keychain: \(error)")
        }
        
        
    }
    
    func revokeAppleToken(clientSecret: String, token: String, completionHandler: @escaping () -> Void)
    {
        let url = "https://appleid.apple.com/auth/revoke?client_id=com.team5.Run-It&client_secret=\(clientSecret)&token=\(token)&token_type_hint=refresh_token"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        AF.request(url,
                   method: .post,
                   headers: header)
        .validate(statusCode: 200..<600)
        .responseData { response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 {
                print("애플 토큰 삭제 성공!")
                completionHandler()
            }
        }
    }
}

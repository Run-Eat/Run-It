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
import KakaoSDKAuth
import KakaoSDKUser


class ProfileViewController: UIViewController
{
    var viewModel: RunningRecordViewModel!
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
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
    
    lazy var imageName = setImage()
    
    lazy var loginTypeIcon = UIImageView(image: UIImage(named: imageName + "Logo"))
    
    lazy var logoutButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.black, for: .normal)
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
        lineView.backgroundColor = UIColor.black
        return lineView
    }()
    
    lazy var totalRunningDistanceLabel = createLabel("", 15)
    
    lazy var weeklyButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("매 주", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(touchedWeeklyButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var monthlyButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("매 달", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(touchedMonthlyButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var thisWeek_MonthLabel = createLabel("이번 주", 15)
    lazy var lastWeek_MonthLabel = createLabel("지난 주", 15)
    
    lazy var distanceTextLabel = createLabel("거리(km)", 17)
    lazy var thisWeek_MonthDistanceLabel = createLabel("", 17)
    lazy var lastWeek_MonthDistanceLabel = createLabel("", 17)
    
    lazy var paceAveragTextLabel = createLabel("평균 페이스", 17)
    lazy var thisWeek_MonthPaceLabel = createLabel("", 17)
    lazy var lastWeek_MonthPaceLabel = createLabel("", 17)
    
    lazy var runningCountTextLabel = createLabel("활동", 17)
    lazy var thisWeek_MonthRunningCountLabel = createLabel("", 17)
    lazy var lastWeek_MonthRunningCountLabel = createLabel("", 17)
    
    lazy var resetButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("러닝 기록 초기화", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(resetRecord), for: .touchUpInside)
        
        return button
    }()
    
    
// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        let uuidToDelete = UUID()
        
        CoreDataManager.shared.deleteRunningRecord(withId: uuidToDelete) { success in
            if success {
                print("Record successfully deleted.")
            } else {
                print("Failed to delete the record.")
            }
        }
        loadRunningRecords()
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2000)
        addScrollView()
        setLayout()
        setupProfileUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateTableViewHeight()
        displayProfileImage()
        statisticsManager(true)
        
        totalRunningDistanceLabel.text = "총 거리 : \(String(format: "%.2f", totalRunningDistance / 1000))km"

        
        thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", thisWeekDistance / 1000))"
        thisWeek_MonthPaceLabel.text = String(format: "%.2f", thisWeekPace / 60)
        thisWeek_MonthRunningCountLabel.text = "\(thisWeekRunningCount) 회"
        
        lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", lastWeekDistance / 1000))"
        lastWeek_MonthPaceLabel.text = String(format: "%.2f", lastWeekPace / 60)
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
        scrollView.addSubview(thisWeek_MonthLabel)
        scrollView.addSubview(lastWeek_MonthLabel)
        scrollView.addSubview(distanceTextLabel)
        scrollView.addSubview(thisWeek_MonthDistanceLabel)
        scrollView.addSubview(lastWeek_MonthDistanceLabel)
        scrollView.addSubview(paceAveragTextLabel)
        scrollView.addSubview(thisWeek_MonthPaceLabel)
        scrollView.addSubview(lastWeek_MonthPaceLabel)
        scrollView.addSubview(runningCountTextLabel)
        scrollView.addSubview(thisWeek_MonthRunningCountLabel)
        scrollView.addSubview(lastWeek_MonthRunningCountLabel)
        scrollView.addSubview(userRecord)
        scrollView.addSubview(uiView)
        scrollView.addSubview(resetButton)

    }
    
// MARK: - 레이아웃
    func setLayout()
    {
        scrollView.snp.makeConstraints
        {   make in
            make.edges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
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
        
        weeklyButton.snp.makeConstraints
        {   make in
            make.top.equalTo(totalRunningDistanceLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).inset(100)
        }
        
        monthlyButton.snp.makeConstraints
        {   make in
            make.top.equalTo(weeklyButton.snp.top).offset(0)
            make.trailing.equalTo(weeklyButton.snp.trailing).offset(150)
        }
        
        thisWeek_MonthLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(weeklyButton.snp.bottom).offset(25)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        lastWeek_MonthLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(weeklyButton.snp.bottom).offset(25)
            make.leading.equalTo(thisWeek_MonthLabel.snp.leading).offset(120)
        }
        
        distanceTextLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(thisWeek_MonthLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).inset(20)
        }
        
        thisWeek_MonthDistanceLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(thisWeek_MonthLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        lastWeek_MonthDistanceLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(thisWeek_MonthLabel.snp.bottom).offset(30)
            make.leading.equalTo(thisWeek_MonthLabel.snp.leading).offset(120)
        }
        
        paceAveragTextLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(distanceTextLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).inset(20)
        }
        
        thisWeek_MonthPaceLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(thisWeek_MonthDistanceLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        lastWeek_MonthPaceLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(lastWeek_MonthDistanceLabel.snp.bottom).offset(30)
            make.leading.equalTo(thisWeek_MonthPaceLabel.snp.leading).offset(120)
        }
        
        runningCountTextLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(paceAveragTextLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).inset(20)
        }
        
        thisWeek_MonthRunningCountLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(thisWeek_MonthPaceLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        lastWeek_MonthRunningCountLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(thisWeek_MonthPaceLabel.snp.bottom).offset(30)
            make.leading.equalTo(thisWeek_MonthRunningCountLabel.snp.leading).offset(120)
        }
        
        resetButton.snp.makeConstraints
        {   make in
            make.centerY.equalTo(pointImage.snp.centerY)
            make.leading.equalTo(view.snp.leading).inset(30)
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
    func setImage() -> String
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
                        thisWeekDistance += record.distance
                        thisWeekPace += record.pace
                        thisWeekRunningCount += 1
                    }
                    
                    // 지난 주 데이터
                    else if recordWeekOfYear == currentWeekOfYear - 1
                    {
                        lastWeekDistance += record.distance
                        lastWeekPace += record.pace
                        lastWeekRunningCount += 1
                    }
                    
                    // 이번 달 데이터
                    if recordMonth == currentMonth
                    {
                        thisMonthDistance += record.distance
                        thisMonthPace += record.pace
                        thisMonthRunningCount += 1
                    }
                    
                    // 지난 달 데이터
                    else if recordMonth == currentMonth - 1
                    {
                        lastMonthDistance += record.distance
                        lastMonthPace += record.pace
                        lastMonthRunningCount += 1
                    }
                    
                }
                thisWeekPace /= Double(thisWeekRunningCount)
                lastWeekPace /= Double(lastWeekRunningCount)
                thisMonthPace /= Double(thisMonthRunningCount)
                lastMonthPace /= Double(lastMonthRunningCount)
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
    
// MARK: - 버튼 함수
    @objc func selectImage()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func touchedLogoutButton()
    {
        kakaoLogout()
        emailLogout()
        dismiss(animated: true)
    }
    
    @objc func touchedWeeklyButton()
    {
        thisWeek_MonthLabel.text = "이번 주"
        thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", thisWeekDistance))"
        thisWeek_MonthPaceLabel.text = String(format: "%.2f", thisWeekPace)
        thisWeek_MonthRunningCountLabel.text = "\(thisWeekRunningCount) 회"
        
        lastWeek_MonthLabel.text = "지난 주"
        lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", lastWeekDistance))"
        lastWeek_MonthPaceLabel.text = String(format: "%.2f", lastWeekPace)
        lastWeek_MonthRunningCountLabel.text = "\(lastWeekRunningCount) 회"
    }
    
    @objc func touchedMonthlyButton()
    {
        thisWeek_MonthLabel.text = "이번 달"
        thisWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", thisMonthDistance))"
        thisWeek_MonthPaceLabel.text = String(format: "%.2f", thisMonthPace)
        thisWeek_MonthRunningCountLabel.text = "\(thisMonthRunningCount) 회"
        
        lastWeek_MonthLabel.text = "지난 달"
        lastWeek_MonthDistanceLabel.text = "\(String(format: "%.2f", lastMonthDistance))"
        lastWeek_MonthPaceLabel.text = String(format: "%.2f", lastMonthPace)
        lastWeek_MonthRunningCountLabel.text = "\(lastMonthRunningCount) 회"
    }
    
    @objc func noticeButtonTapped()
    {
        let eventVC = EventViewController()
        self.navigationController?.pushViewController(eventVC, animated: true)
    }
    // 추후 coreData 활용 데이터 관리 코드 작성
    
    @objc func resetRecord()
    {
        print("러닝 기록 초기화")
        guard let context = persistentContainer?.viewContext else { return }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RunningRecord")
        
        do
        {
            let datas = try context.fetch(fetchRequest)
            for data in datas
            {
                guard let removeData = data as? NSManagedObject else { continue }
                context.delete(removeData)
            }
            
            try context.save()
        }
        catch
        {
            print("error")
        }
    }
    
    @objc func withdrawal()     // 회원탈퇴
    {
        
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
        
        userRecord.snp.makeConstraints { make in
            make.top.equalTo(runningCountTextLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.height.equalTo(20)
        }
        
        uiView.snp.makeConstraints { make in
            make.top.equalTo(userRecord.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(runningRecords.count * 120 + 60)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            self.tableViewHeightConstraint = make.height.equalTo(runningRecords.count * 120).constraint
        }
    }
    
    func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        tableViewHeightConstraint?.update(offset: runningRecords.count * 120)
        uiView.snp.updateConstraints { make in
            make.height.equalTo(runningRecords.count * 120 + 60)
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
        return 120
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

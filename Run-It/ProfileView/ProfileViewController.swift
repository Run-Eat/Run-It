//
//  ProfileViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit
import SnapKit

#if DEBUG
import SwiftUI
struct Preview: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        ProfileViewController()
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

class ProfileViewController: UIViewController
{
    
    let totalDistance = 9999.99
    
    var thisWeek_MonthDistance = 0
    var lastWeek_MonthDistance = 0
    var thisWeek_MonthPace = 0
    var lastWeek_MonthPace = 0
    var thisWeek_MonthRunningCount = 0
    var lastWeek_MonthRunningCount = 0
    var tableView = UITableView()
    var userRecord: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "활동기록"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
// MARK: - UI 생성
    
    let scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    lazy var noticeButton: UIButton =
    {
        var configuration = UIButton.Configuration.plain()
            configuration.title = "알림"
            configuration.image = UIImage(named: "NoticeIcon")
            configuration.imagePadding = 10 // 이미지와 제목 간격 조정
        let button = UIButton(configuration: configuration)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(noticeButtonTapped), for: .touchUpInside)
        
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let imageSettingButton: UIButton =
    {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .bold, scale: .medium)
        button.setImage(UIImage(systemName: "camera.circle",withConfiguration: config), for: .normal)
        button.tintColor = .darkGray
        
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
  
    lazy var totalRunningDistanceLabel = createLabel("총 거리 : \(totalDistance) (km)", 15)
    
    let weeklyButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("매 주", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        button.addTarget(self, action: #selector(touchedWeeklyButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let monthlyButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("매 달", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        button.addTarget(self, action: #selector(touchedMonthlyButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    lazy var thisWeek_MonthLabel = createLabel("이번 주", 15)
    lazy var lastWeek_MonthLabel = createLabel("지난 주", 15)
    
    lazy var distanceTextLabel = createLabel("거리(km)", 17)
    lazy var thisWeek_MonthDistanceLabel = createLabel("\(thisWeek_MonthDistance) km", 17)
    lazy var lastWeek_MonthDistanceLabel = createLabel("\(lastWeek_MonthDistance) km", 17)
    
    lazy var paceAveragTextLabel = createLabel("평균 페이스", 17)
    lazy var thisWeek_MonthPaceLabel = createLabel("\(thisWeek_MonthPace) (분)", 17)
    lazy var lastWeek_MonthPaceLabel = createLabel("\(lastWeek_MonthPace) (분)", 17)
    
    lazy var runningCountTextLabel = createLabel("활동", 17)
    lazy var thisWeek_MonthRunningCountLabel = createLabel("\(thisWeek_MonthRunningCount)회", 17)
    lazy var lastWeek_MonthRunningCountLabel = createLabel("\(lastWeek_MonthRunningCount)회", 17)
    
    
    
// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1500)
        addScrollView()
        setLayout()
        setupProfileUI()
    }
    
// MARK: - addSubView
    func addScrollView()
    {
        scrollView.addSubview(noticeButton)
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
        
    }
    
// MARK: - 레이아웃
    func setLayout()
    {
        scrollView.snp.makeConstraints
        {   make in
            make.top.equalTo(view.snp.top).inset(0)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.frame.width)
            make.height.equalTo(600)
            make.edges.equalToSuperview()
        }
        
        noticeButton.snp.makeConstraints
        {   make in
            make.top.equalTo(scrollView.snp.top).inset(0)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.width.equalTo(90)
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
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.trailing.equalTo(view.snp.trailing).inset(100)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        pointLabel.snp.makeConstraints
        {   make in
            make.top.equalTo(pointImage.snp.top).offset(2)
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
        
    }
    
// MARK: - 레이블 생성 함수
    func createLabel(_ text: String, _ fontSize: Int) -> UILabel
    {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    // MARK: - 버튼 함수
    @objc func selectImage()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func touchedWeeklyButton()
    {
        thisWeek_MonthLabel.text = "이번 주"
        thisWeek_MonthDistance = 100
        thisWeek_MonthDistanceLabel.text = "\(thisWeek_MonthDistance) 이번 주"
        thisWeek_MonthPaceLabel.text = "\(thisWeek_MonthPace) 이번 주"
        thisWeek_MonthRunningCountLabel.text = "\(thisWeek_MonthRunningCount) 이번 주"
        
        lastWeek_MonthLabel.text = "지난 주"
        lastWeek_MonthDistanceLabel.text = "\(lastWeek_MonthDistance) 지난 주"
        lastWeek_MonthPaceLabel.text = "지난 주"
        lastWeek_MonthRunningCountLabel.text = "지난 주"
    }
    
    @objc func touchedMonthlyButton()
    {
        thisWeek_MonthLabel.text = "이번 달"
        thisWeek_MonthDistanceLabel.text = "이번 달"
        thisWeek_MonthPaceLabel.text = "이번 달"
        thisWeek_MonthRunningCountLabel.text = "이번 달"
        
        lastWeek_MonthLabel.text = "지난 달"
        lastWeek_MonthDistanceLabel.text = "지난 달"
        lastWeek_MonthPaceLabel.text = "지난 달"
        lastWeek_MonthRunningCountLabel.text = "지난 달"
    }
    
    @objc func noticeButtonTapped(){
        let eventVC = EventViewController()
        self.navigationController?.pushViewController(eventVC, animated: true)
    }
    // 추후 coreData 활용 데이터 관리 코드 작성
}



// MARK: - ImageView extension
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let selectedImage = info[.originalImage] as? UIImage
        {
            profileImageView.image = selectedImage
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.sizeToFit()
        }
        picker.dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController {
    // MARK: - UI Setup
    func setupProfileUI() {
        setupRecordListUI()
    }
    
    func setupRecordListUI() {
        view.addSubview(userRecord)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(RecordViewCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.backgroundColor = UIColor.white
        tableView.isScrollEnabled = false
        
        userRecord.snp.makeConstraints { make in
            make.top.equalTo(runningCountTextLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(userRecord.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(4 * 120)
        }
    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as? RecordViewCell else {
            return UITableViewCell()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let recordVC = RunningRecordViewController()
//        navigationController?.pushViewController(recordVC, animated: true)
//    }
}

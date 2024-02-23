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
    
    let statsStackView: UIStackView =
    {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        return stackView
    }()
    
    
    
// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1500)
        addScrollView()
        setLayout()
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
        scrollView.addSubview(statsStackView)
        scrollView.addSubview(weeklyButton)
        scrollView.addSubview(monthlyButton)
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
        
        statsStackView.snp.makeConstraints
        {   make in
            make.top.equalTo(weeklyButton.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.frame.width - 40)
            make.height.equalTo(300)
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
        
    }
    
    @objc func touchedMonthlyButton()
    {
        
    }
    
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

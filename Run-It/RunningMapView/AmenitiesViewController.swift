//
//  AmenitiesViewController.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/26/24.
//

import UIKit
import SnapKit

class AmenitiesViewController: UIViewController {
    var distanceType: [Int] = [500, 1000, 3000]
    var distance: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        return collection
    }()
    
    var amenities: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        collection.backgroundColor = .cyan
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupDelegate()
        configure()
    }
    
    func setupDelegate() {
        distance.register(DistanceCollectionViewCell.self, forCellWithReuseIdentifier: DistanceCollectionViewCell.id)
        distance.delegate = self
        distance.dataSource = self
        
        amenities.register(AmenitiesCollectionViewCell.self, forCellWithReuseIdentifier: AmenitiesCollectionViewCell.id)
        amenities.delegate = self
        amenities.dataSource = self
    }
    
    func addSubviews() {
        view.addSubview(distance)
        view.addSubview(amenities)
    }
    
    func configure() {
        distance.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(40)
            $0.height.equalTo(50)
        }
        amenities.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(distance.snp.bottom).offset(30)
            $0.height.equalTo(700)
        }
    }
    
}

extension AmenitiesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == distance {
            return 3
        }else if collectionView == amenities {
            return 10
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == distance {
            guard let distancecell = collectionView.dequeueReusableCell(withReuseIdentifier: DistanceCollectionViewCell.id, for: indexPath) as? DistanceCollectionViewCell else { return UICollectionViewCell() }
            return distancecell
            
        }else if collectionView == amenities {
            guard let amenitiescell = collectionView.dequeueReusableCell(withReuseIdentifier: AmenitiesCollectionViewCell.id, for: indexPath) as? AmenitiesCollectionViewCell else { return UICollectionViewCell() }
            return amenitiescell
        }
        
        return UICollectionViewCell()
        
    }
}

extension AmenitiesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == distance {
            return CGSize(width: 100, height: collectionView.frame.height)
        }else if collectionView == amenities{
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        return CGSize()
    }
}


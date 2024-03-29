//
//  MapSnapshotManager.swift
//  Run-It
//
//  Created by t2023-m0024 on 3/8/24.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class MapSnapshotManager {
    
    static func createSnapshot(for locations: [CLLocation], completion: @escaping (UIImage?) -> Void) {
        guard !locations.isEmpty else {
            completion(nil)
            return
        }
        
        let coordinates = locations.map { $0.coordinate }
        let (region, size) = optimalRegionAndSize(for: coordinates, maxSize: CGSize(width: 390, height: 202)) // 최대 사이즈 설정
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        mapSnapshotOptions.region = region
        mapSnapshotOptions.size = size
        
        // 스냅샷 옵션을 사용하여 MKMapSnapshotter 인스턴스를 생성합니다.
        let snapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil)
                return
            }
            
            let image = snapshot.image
            
            // 경로를 그릴 이미지 컨텍스트를 생성합니다.
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            
            // 경로를 그립니다.
            let path = UIBezierPath()
            path.lineWidth = 2.0 // 경로 선의 두께를 설정합니다.
            for (index, location) in locations.enumerated() {
                let point = snapshot.point(for: location.coordinate)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            
            UIColor.red.setStroke()
            path.stroke()
            
            // 최종 이미지를 생성합니다.
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            completion(finalImage)
        }
    }
    
    // 주어진 좌표들을 모두 포함하는 지도 영역을 계산하는 메서드입니다.
    static func optimalRegionAndSize(for coordinates: [CLLocationCoordinate2D], maxSize: CGSize) -> (region: MKCoordinateRegion, size: CGSize) {
        var minLat = coordinates.first!.latitude
        var maxLat = minLat
        var minLon = coordinates.first!.longitude
        var maxLon = minLon
        
        coordinates.forEach { coordinate in
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
//        let span = MKCoordinateSpan(latitudeDelta: maxLat - minLat + 0.01, longitudeDelta: maxLon - minLon + 0.01) // 여백을 추가합니다.
        
        let latitudeDelta = maxLat - minLat + 0.01 // 여백 추가
        let longitudeDelta = maxLon - minLon + 0.01 // 여백 추가
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        // 지도 스냅샷의 비율 결정
        let aspectRatio = longitudeDelta / latitudeDelta
        let sizeWidth = min(maxSize.width, maxSize.height * aspectRatio)
        let sizeHeight = sizeWidth / aspectRatio

        
//        return MKCoordinateRegion(center: center, span: span)
        return (region: MKCoordinateRegion(center: center, span: span), size: CGSize(width: sizeWidth, height: sizeHeight))
    }
}

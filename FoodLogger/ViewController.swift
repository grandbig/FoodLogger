//
//  ViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/17.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    internal var locationManager: CLLocationManager?
    internal var currentLocation: CLLocationCoordinate2D?
    internal var placesClient: GMSPlacesClient!
    internal var zoomLevel: Float = 16.0
    /// 初期描画の判断に利用
    internal var initView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // GoogleMapの初期化
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = GMSMapViewType.normal
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.delegate = self
        
        // 位置情報関連の初期化
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.distanceFilter = 50
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.delegate = self
        
        self.placesClient = GMSPlacesClient.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Button Action
    @IBAction func search(_ sender: Any) {
        let gurunavi = Gurunavi.init()
        guard let myCurrentLocation = self.currentLocation else {
            return
        }
        gurunavi.searchRestaurant(coordinate: myCurrentLocation) { (result) in
            if let restaurants = result.array {
                for restaurant in restaurants {
                    let name = restaurant["name"].string ?? "店舗名不明"
                    guard let latitude = restaurant["latitude"].string, let longitude = restaurant["longitude"].string else {
                        return
                    }
                    self.putMarker(title: name, latitude: atof(latitude), longitude: atof(longitude))
                }
            }
        }
    }
    
    // MARK: Other
    /**
     マップにマーカをプロットする処理
     
     - parameter title: タイトル
     - parameter latitude: 緯度
     - parameter longitude: 経度
     */
    private func putMarker(title: String, latitude: Double, longitude: Double) {
        let marker = GMSMarker()
        marker.title = title
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = self.mapView
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !self.initView {
            // 初期描画時のマップ中心位置の移動
            self.currentLocation = locations.last?.coordinate
            let camera = GMSCameraPosition.camera(withTarget: self.currentLocation!, zoom: self.zoomLevel)
            self.mapView.camera = camera
            self.locationManager?.stopUpdatingLocation()
            self.initView = true
        }
    }
}


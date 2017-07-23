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

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    internal var locationManager: CLLocationManager?
    internal var currentLocation: CLLocationCoordinate2D?
    internal var placesClient: GMSPlacesClient!
    internal var zoomLevel: Float = 16.0
    /// 初期描画の判断に利用
    internal var initView: Bool = false
    internal var restaurants: [JSON]?
    internal let hotpepperAPI = HotpepperAPI.init()
    internal var selectedShopImageURLString: String?
    internal var realmShopManager: RealmShopManager = RealmShopManager()
    
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
        
        if let savedShops = self.realmShopManager.selectAll() {
            for savedShop in savedShops {
                let shop = HotpepperShop(id: savedShop.id, name: savedShop.name, category: savedShop.category, imageURL: savedShop.imageURL, latitude: savedShop.latitude, longitude: savedShop.longitude, shopURL: savedShop.shopURL)
                self.putMarker(shop: shop, type: MarkerType.saved)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Button Action
    @IBAction func search(_ sender: Any) {
        guard let myCurrentLocation = self.currentLocation else {
            return
        }
        // 現在地周辺のレストランを取得
        self.hotpepperAPI.searchRestaurant(coordinate: myCurrentLocation) { (result) in
            if let restaurants = result.array {
                self.restaurants = restaurants
                for restaurant in restaurants {
                    let shop = HotpepperShop(data: restaurant)
                    self.putMarker(shop: shop, type: MarkerType.searched)
                }
            }
        }
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "shopDetailSegue" {
            if let shopDetailViewController = segue.destination as? ShopDetailViewController, let shop = sender as? HotpepperShop {
                shopDetailViewController.shop = shop
            }
        }
    }
    
    // MARK: Other
    /**
     マップにマーカをプロットする処理
     
     - parameter shop: 店舗データ
     */
    private func putMarker(shop: HotpepperShop, type: MarkerType) {
        let marker = CustomGMSMarker()
        marker.id = shop.id
        marker.shopName = shop.name
        marker.categoryName = shop.category
        marker.imageURL = shop.imageURL
        marker.shopURL = shop.shopURL
        marker.position = CLLocationCoordinate2D(latitude: shop.latitude ?? 0, longitude: shop.longitude ?? 0)
        marker.type = type
        if type == MarkerType.saved {
            marker.icon = UIImage(named: "savedShopIcon")
        } else {
            marker.icon = UIImage(named: "searchedShopIcon")
        }
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

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let cMarker = marker as? CustomGMSMarker else {
            return true
        }
        self.selectedShopImageURLString = cMarker.imageURL
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let cMarker = marker as? CustomGMSMarker else {
            return nil
        }
        cMarker.tracksInfoWindowChanges = true
        let view = MarkerInfoContentsView(frame: CGRect(x: 0, y: 0, width: 250, height: 265))
        view.setData(shopName: cMarker.shopName, categoryName: cMarker.categoryName, shopImageURLString: cMarker.imageURL)
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let cMarker = marker as? CustomGMSMarker else {
            return
        }
        guard let id = cMarker.id, let name = cMarker.shopName, let category = cMarker.categoryName, let imageURL = cMarker.imageURL, let shopURL = cMarker.shopURL else {
            return
        }
        let shop = HotpepperShop(id: id, name: name, category: category, imageURL: imageURL, latitude: cMarker.position.latitude, longitude: cMarker.position.longitude, shopURL: shopURL)
        
        // 画面遷移
        performSegue(withIdentifier: "shopDetailSegue", sender: shop)
    }
}

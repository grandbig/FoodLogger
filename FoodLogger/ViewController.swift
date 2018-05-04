//
//  ViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/17.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import PromiseKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    /// マップビュー
    @IBOutlet weak var mapView: GMSMapView!
    /// 位置情報マネージャ
    internal var locationManager: CLLocationManager?
    /// 現在地
    internal var currentLocation: CLLocationCoordinate2D?
    /// マップのズームレベル
    internal let zoomLevel: Float = 16.0
    /// 初期描画の判断に利用
    internal var initView: Bool = false
    /// 保存済みショップ
    internal var savedShops: Results<RealmShop>!
    /// 検索ショップ
    internal var searchShops: [Restaurant]!
    /// ホットペッパーAPI
    internal let hotpepperAPI = HotpepperAPI.init()
    /// 選択中マーカ
    internal var selectedMarker: CustomGMSMarker?
    /// Realm管理マネージャ
    internal var realmShopManager = RealmShopManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.delegate = self
        
        // GoogleMapの初期化
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = GMSMapViewType.normal
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.delegate = self
        
        // 位置情報関連の初期化
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.delegate = self
        
        // 保存済みショップマーカをプロット
        self.putSavedMarkers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Button Action
    @IBAction func search(_ sender: Any) {
        guard let myCurrentLocation = self.currentLocation else {
            self.showAlert(title: "確認", message: "位置情報が取得できません。端末の設定を確認してください。", completion: {})
            return
        }
        
        if self.searchShops != nil {
            // 既にマップ上に検索結果が表示されている場合
            // 全てのマーカを削除
            self.mapView.clear()
            // 保存済みショップマーカをプロット
            self.putSavedMarkers()
        }

        firstly {
            GurunaviAPI.init().searchRestaurant(coordinate: myCurrentLocation)
        }.done { [weak self] result in
            guard let strongSelf = self else { return }
            print(result)
            strongSelf.searchShops = result.rest
            for searchShop in strongSelf.searchShops {
                if !strongSelf.checkSavedShop(searchShop) {
                    strongSelf.putMarker(shop: searchShop, rating: nil, type: MarkerType.searched)
                }
            }
        }.catch { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.showAlert(title: "確認", message: "周辺のショップ情報を取得できませんでした。", completion: {})
        }
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "shopDetailSegueFromMap" {
            guard let shopDetailViewController = segue.destination as? ShopDetailViewController else {
                return
            }
            guard let shop = sender as? Restaurant else {
                return
            }
            shopDetailViewController.shop = shop
            shopDetailViewController.myLocation = self.mapView.myLocation
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let createShopMemoViewController = fromVC as? CreateShopMemoViewController, toVC as? ViewController != nil {
            // createShopMemoViewControllerから戻ってきた場合
            if createShopMemoViewController.isSaved {
                // ショップを新たに保存した場合
                // マーカを再設置
                self.selectedMarker?.map = nil
                self.putMarker(shop: createShopMemoViewController.shop, rating: Int(createShopMemoViewController.ratingBar.value), type: MarkerType.saved)
            }
        }
        return nil
    }
    
    // MARK: Other
    /**
     マップにマーカをプロットする処理
     
     - parameter shop: ショップデータ
     - parameter rating: 評価
     - parameter type: マーカタイプ
     */
    private func putMarker(shop: Restaurant, rating: Int?, type: MarkerType) {
        let marker = CustomGMSMarker()
        let latitude = Double(shop.latitude)
        let longitude = Double(shop.longitude)
        marker.id = shop.id
        marker.shopName = shop.name
        marker.categoryName = shop.category
        marker.imageURL = shop.shopImage1 ?? shop.shopImage2
        marker.shopURL = shop.url
        marker.position = CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
        marker.rating = rating
        marker.type = type
        if type == MarkerType.saved {
            marker.icon = UIImage(named: "savedShopIcon")
        } else {
            marker.icon = UIImage(named: "searchedShopIcon")
        }
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = self.mapView
    }
    
    /**
     保存済みショップ判定処理
     
     - parameter shop: ショップ
     - returns: 保存済み/未保存判定結果 (true: 保存済み, false: 未保存)
     */
    private func checkSavedShop(_ shop: Restaurant) -> Bool {
        for savedShop in self.savedShops where shop.id == savedShop.id {
            return true
        }
        return false
    }
    
    /**
     マップに保存済みマーカをプロットする処理
     */
    private func putSavedMarkers() {
        if let savedShops = self.realmShopManager.selectAll() {
            self.savedShops = savedShops
            for savedShop in savedShops {
                let shop = Restaurant(id: savedShop.id,
                                      name: savedShop.name,
                                      latitude: String(savedShop.latitude),
                                      longitude: String(savedShop.longitude),
                                      category: savedShop.category,
                                      url: savedShop.shopURL,
                                      shopImage1: savedShop.imageURL,
                                      shopImage2: nil)
                self.putMarker(shop: shop, rating: savedShop.rating, type: MarkerType.saved)
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .restricted, .denied:
            break
        case .authorizedWhenInUse:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 現在地の更新
        self.currentLocation = locations.last?.coordinate
        
        if !self.initView {
            // 初期描画時のマップ中心位置の移動
            let camera = GMSCameraPosition.camera(withTarget: self.currentLocation!, zoom: self.zoomLevel)
            self.mapView.camera = camera
            self.initView = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !CLLocationManager.locationServicesEnabled() {
            // 端末の位置情報がOFFになっている場合
            // アラートはデフォルトで表示されるので内部で用意はしない
            self.currentLocation = nil
            return
        }
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            // アプリの位置情報許可をOFFにしている場合
            self.showAlert(title: "確認", message: "FoodLoggerで位置情報を取得することができません。設定から位置情報を許可してください。", completion: {
                self.currentLocation = nil
            })
            return
        }
    }
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let cMarker = marker as? CustomGMSMarker else {
            return true
        }
        self.selectedMarker = cMarker
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let cMarker = marker as? CustomGMSMarker else {
            return nil
        }
        cMarker.tracksInfoWindowChanges = true
        let view = MarkerInfoContentsView(frame: CGRect(x: 0, y: 0, width: 250, height: 265))
        view.setData(shopName: cMarker.shopName, categoryName: cMarker.categoryName, rating: cMarker.rating, shopImageURLString: cMarker.imageURL)
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let cMarker = marker as? CustomGMSMarker else {
            return
        }
        guard let id = cMarker.id, let name = cMarker.shopName, let category = cMarker.categoryName,
            let imageURL = cMarker.imageURL, let shopURL = cMarker.shopURL else {
            return
        }
        let shop = Restaurant(id: id,
                              name: name,
                              latitude: String(cMarker.position.latitude),
                              longitude: String(cMarker.position.longitude),
                              category: category,
                              url: shopURL,
                              shopImage1: imageURL,
                              shopImage2: nil)
        
        // 画面遷移
        performSegue(withIdentifier: "shopDetailSegueFromMap", sender: shop)
    }
}

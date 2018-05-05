# Podfile
use_frameworks!
platform :ios, '10.0'

target "FoodLogger" do
  # Normal libraries
  pod 'RealmSwift'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Moya', '~> 11.0'
  pod 'SwiftyJSON'
  pod 'AlamofireImage', '~> 3.3'
  pod 'HCSStarRatingView', '~> 1.5'
  pod 'NVActivityIndicatorView'
  pod 'PromiseKit', '~> 6.0'

  abstract_target 'Tests' do
    target "FoodLoggerTests"
    target "FoodLoggerUITests"

    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
    end
  end
end

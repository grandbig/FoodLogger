# Podfile
use_frameworks!
platform :ios, '10.0'

target "FoodLogger" do
  # Normal libraries
  pod 'RealmSwift'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Alamofire', '~> 4.4'
  pod 'SwiftyJSON'

  abstract_target 'Tests' do
    inherit! :search_paths
    target "FoodLoggerTests"
    target "FoodLoggerUITests"

    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

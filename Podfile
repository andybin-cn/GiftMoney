# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GiftMoney' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

#  pod 'RealmSwift','~> 3.17.3'
#  pod 'SnapKit','~> 5.0.0'
#  pod 'SKPhotoBrowser','~> 6.1.0'
#  pod 'MBProgressHUD','~> 1.1.0'
#  pod 'SwiftyBeaver','~> 1.7.0'
  pod 'libxlsxwriter', '~> 0.8.7'



  target 'GiftMoneyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GiftMoneyUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Common' do
  use_frameworks!
  
  workspace 'GiftMoney.xcworkspace'
  project 'Depends/Common/Common.xcodeproj'

#  pod 'RealmSwift','~> 3.17.3'
#  pod 'SnapKit','~> 5.0.0'
#  pod 'SKPhotoBrowser','~> 6.1.0'
#  pod 'MBProgressHUD','~> 1.1.0'
#  pod 'SwiftyBeaver','~> 1.7.0'

  # Pods for ServiceTests
  target 'CommonTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

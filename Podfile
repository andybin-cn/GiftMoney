# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
#source 'https://gitclub.cn/CocoaPods/Specs.git'


target 'GiftMoney' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Google-Mobile-Ads-SDK', '~> 7.52.0'

#  pod 'RealmSwift','~> 3.17.3'
#  pod 'SnapKit','~> 5.0.0'
#  pod 'SKPhotoBrowser','~> 6.1.0'
#  pod 'MBProgressHUD','~> 1.1.0'
#  pod 'SwiftyBeaver','~> 1.7.0'
  pod 'libxlsxwriter', '~> 0.8.7'
  pod 'DZNEmptyDataSet', '~> 1.8.1'
  
  pod 'UMCCommon'
  pod 'UMCAnalytics'
  
#  pod 'RxSwift', '~> 5.0.1'
#  pod 'RxCocoa', '~> 5.0.1'
#  pod 'SnapKit', '~> 5.0.1'
#  pod 'SwiftyBeaver', '~> 1.7.1'
  pod 'TZImagePickerController', '~> 3.2.2'
  pod 'IQKeyboardManagerSwift', '~> 6.4.1'
#  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'Realm', '~> 3.17.3'
  pod 'RealmSwift', '~> 3.17.3'
  pod 'SKPhotoBrowser', '~> 6.1.0'
  pod 'ObjectMapper', '~> 3.5.1'




  target 'GiftMoneyTests' do
    inherit! :search_paths
    # Pods for testing
  end

#  target 'GiftMoneyUITests' do
#    inherit! :search_paths
#    # Pods for testing
#  end

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

  pod 'RxSwift', '~> 5.0.1'
  pod 'RxCocoa', '~> 5.0.1'
  pod 'SnapKit', '~> 5.0.1'
  pod 'SwiftyBeaver', '~> 1.7.1'
#  pod 'TZImagePickerController', '~> 3.2.2'
#  pod 'IQKeyboardManagerSwift', '~> 6.4.1'
  pod 'MBProgressHUD', '~> 1.1.0'
#  pod 'Realm', '~> 3.17.3'
#  pod 'RealmSwift', '~> 3.17.3'
#  pod 'SKPhotoBrowser', '~> 6.1.0'
#  pod 'ObjectMapper', '~> 3.5.1'

  # Pods for ServiceTests
  target 'CommonTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

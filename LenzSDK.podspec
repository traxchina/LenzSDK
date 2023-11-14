#
# Be sure to run `pod lib lint LenzCameraNativeModuleForRN.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LenzSDK'
  s.version          = '0.0.1'
  s.summary          = 'A short description of LenzSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description  = "this  is the long description"

  s.homepage         = 'https://github.com/traxchina/LenzSDK.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dawei.xu@traxretail.com' => 'dawei.xu@traxretail.com' }
  s.source           = { :git => 'https://github.com/traxchina/LenzSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'LenzCameraNativeModuleForRN/Classes/**/*'
  
  s.resource_bundles = {
    'LenzCameraNativeModuleForRN' => ['LenzCameraNativeModuleForRN/Assets/*.{png,jpeg,jpg,storyboard,xib,xcassets,strings,tflite}', 'LenzCameraNativeModuleForRN/Classes/inner/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,strings}']
  }

  s.public_header_files = 'LenzCameraNativeModuleForRN/Classes/headers/*.h'
  # s.ios.public_header_files = 
  s.frameworks = 'UIKit', 'MapKit', 'WebKit', 'AdSupport', 'Accelerate' ,'MediaPlayer', 'CoreData', 'SystemConfiguration' ,'CoreServices' ,'AssetsLibrary' ,'CoreTelephony' ,'CoreMotion' ,'Photos' ,'AVFoundation' ,'CoreMedia'
  s.vendored_frameworks = 'LenzTensorFlowSDK.framework', "LenzStitchSDK.framework"
  s.libraries = "c++", "z"
  s.dependency "Masonry", '1.1.0'
  s.dependency 'YYText'
  s.dependency 'YBImageBrowser'
  s.dependency 'SVProgressHUD', '~> 2.2.5'
  s.dependency 'OpenCV2', '~> 4.3.0'
  s.dependency "TensorFlowLite", '~> 1.13.1'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }


end

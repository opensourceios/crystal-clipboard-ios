source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

use_frameworks!

plugin 'cocoapods-keys', {
  project: 'CrystalClipboard',
  keys: %w[
    CrystalClipboardStagingAdminAuthToken
    CrystalClipboardProductionAdminAuthToken
  ]
}

target 'CrystalClipboard' do
  pod 'Moya/ReactiveSwift', '9.0.0-alpha1'
  pod 'ReactiveCocoa', '~> 6.0'
  pod 'Starscream', '~> 2.1'
  target 'CrystalClipboardTests'
  target 'CrystalClipboardUITests'
end

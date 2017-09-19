source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/jzzocc/Specs.git'

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
  pod 'CellHelpers', '~> 0.5'
  pod 'KeychainAccess', '~> 3.1'
  pod 'Moya/ReactiveSwift', '~> 9.0'
  pod 'PKHUD', git: 'https://github.com/pkluz/PKHUD.git', branch: 'release/swift4'
  pod 'ReactiveCocoa', '~> 6.0'
  pod 'Starscream', '~> 2.1'
  target 'CrystalClipboardTests'
  target 'CrystalClipboardUITests'
end

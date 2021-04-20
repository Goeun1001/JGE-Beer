# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def pods 
  # Reactive
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxViewController'
  # Network
  pod 'Moya/RxSwift', '~> 14.0'

  # Code Style
  pod 'SwiftLint'
  
end

target 'JGE-Beer' do
  use_frameworks!
  pods

  # Reactive
  pod 'RxDataSources', '~> 4.0'

  # Network
  pod 'ReachabilitySwift'

  # Image
  pod 'Kingfisher'

  # Layout
  pod 'SnapKit', '~> 5.0.0'
  pod 'Then'

  target 'JGE-BeerTests' do
    pods

    # Test
    pod 'RxBlocking', '~> 5'
    pod 'RxTest', '~> 5'
  end

end

Pod::Spec.new do |spec|
  spec.name         = 'Logmatic'
  spec.version      = '1.0.0'
  spec.authors      = 'Logmatic.io'
  spec.license      = 'MIT'
  spec.homepage     = 'http://logmatic.io'
  spec.summary      = 'iOS version for Logmatic.io'
  spec.platform     = 'ios', '8.0'
  spec.source       = { :git => 'https://github.com/logmatic/logmatic-ios.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Logmatic/*.{h,m}'
  spec.framework    = 'Foundation'
  spec.requires_arc = true
  spec.dependency 'AFNetworking', '~>3.0.0'
end

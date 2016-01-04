Pod::Spec.new do |spec|
  spec.name         = 'Logmatic'
  spec.version      = '0.1.1'
  spec.authors      = 'CANAL + Overseas and Applidium by FABERNOVEL'
  spec.license      = 'none'
  spec.homepage     = 'http://applidium.com'
  spec.summary      = 'iOS version for Logmatic.io'
  spec.platform     = 'ios', '7.0'
  spec.license      = { :type => 'Commercial', :text => 'Created and licensed by Applidium. Copyright 2016 Applidium. All rights reserved.' }
  spec.source       = { :git => 'https://github.com/logmatic/logmatic-ios.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Classes/*.{h,m}'
  spec.framework    = 'Foundation'
  spec.requires_arc = true

  spec.dependency 'AFNetworking', '~>3.0.0'
end

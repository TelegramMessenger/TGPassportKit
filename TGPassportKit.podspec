Pod::Spec.new do |s|
  s.name             = 'TGPassportKit'
  s.version          = '1.0.0'
  s.summary          = 'Telegram Passport SDK for iOS & macOS.'
  s.homepage         = 'https://github.com/TelegramMessenger/TGPassportKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Telegram Messenger'
  s.platforms        = { :ios => "6.0", :osx => "10.9" }
  s.source           = { :git => 'https://github.com/TelegramMessenger/TGPassportKit.git', :tag => s.version.to_s }
  s.source_files     = 'Source/*.{h,m}'
  s.requires_arc     = true
  
  s.ios.source_files = 'Source/iOS/*.{h,m}'
  s.ios.deployment_target = '6.0'
  
  s.osx.source_files = 'Source/macOS/*.{h,m}'
  s.osx.deployment_target = '10.9'
  
  s.resources = 'TGPassportKitStrings.bundle'
  
end

Pod::Spec.new do |s|
  s.name             = 'MWKits'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MWKits.'

  s.description      = 'MWKits'

  s.homepage         = 'https://github.com/mingway1991/MWKits'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mingway1991' => 'shimingwei@lvmama.com' }
  s.source           = { :git => 'https://github.com/mingway1991/MWKits.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MWKits/Classes/**/*'
end

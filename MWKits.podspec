Pod::Spec.new do |s|
  s.name             = 'MWKits'
  s.version          = '0.4.0'
  s.summary          = 'iOS 常用工具库'

  s.description      = '1.倒计时 2.转场动画（push、pop、present、dismiss）'

  s.homepage         = 'https://github.com/mingway1991/MWKits'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mingway1991' => 'shimingwei@lvmama.com' }
  s.source           = { :git => 'https://github.com/mingway1991/MWKits.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.subspec 'Common' do |a|
    a.source_files = 'MWKits/Classes/Common/**/*'
  end

  s.subspec 'CountDown' do |a|
    a.source_files = 'MWKits/Classes/CountDown/**/*'
    a.dependency 'MWKits/Common'
  end

  s.subspec 'Transition' do |a|
    a.source_files = 'MWKits/Classes/Transition/**/*'
    a.dependency 'MWKits/Common'
  end

  s.subspec 'PhotoLibrary' do |a|
    a.source_files = 'MWKits/Classes/PhotoLibrary/**/*'
    a.dependency 'MWKits/Common'
    a.dependency 'SDWebImage'
    a.frameworks = 'Photos','AVFoundation'
  end

end

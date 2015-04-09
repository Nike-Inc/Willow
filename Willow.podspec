Pod::Spec.new do |s|
  s.name = 'Willow'
  s.version = '0.2.0'
  s.summary = 'A powerful, yet lightweight logging library written in Swift.'
  s.homepage = 'http://stash.nikedev.com/projects/BMD/repos/willow/browse'
  s.license = { :type => 'FreeBSD', :file => 'LICENSE' }
  s.authors = { 'Christian Noon' => 'christian.noon@gmail.com' }
  
  s.source = { :git => 'ssh://git@stash.nikedev.com/bmd/willow.git', :tag => s.version }
  s.source_files = 'Source/*.swift'
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
end

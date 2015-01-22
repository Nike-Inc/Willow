Pod::Spec.new do |s|
  s.name = 'Timber'
  s.version = '0.0.1'
  s.summary = 'A powerful, yet lightweight logging library written in Swift.'
  s.homepage = 'http://stash.nikedev.com/projects/BMD/repos/timber/browse'
  s.license = { :type => 'FreeBSD', :file => 'LICENSE' }
  s.authors = { 'Christian Noon' => 'christian.noon@gmail.com' }
  
  s.source = { :git => 'ssh://git@stash.nikedev.com/bmd/timber.git', :branch => 'development' }
  s.source_files = 'Source/*.swift'
  
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
end

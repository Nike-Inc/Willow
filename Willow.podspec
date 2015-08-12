Pod::Spec.new do |s|
  s.name = 'Willow'
  s.version = '1.0.1'
  s.summary = 'A powerful, yet lightweight logging library written in Swift.'
  s.homepage = 'http://stash.nikedev.com/projects/BMD/repos/willow/browse'
  s.license = { :type => 'COMMERCIAL', :text => 'Created and licensed by Nike. Copyright 2014-2015 Nike, Inc. All rights reserved.' }
  s.authors = { 'Christian Noon' => 'christian.noon@nike.com', 'Eric Appel' => 'eric.appel@nike.com' }

  s.source = { :git => 'ssh://git@stash.nikedev.com/bmd/willow.git', :tag => s.version }
  s.source_files = 'Source/*.swift'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
end

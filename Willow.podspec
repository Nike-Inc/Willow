Pod::Spec.new do |s|
  s.name = 'Willow'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'A powerful, yet lightweight logging library written in Swift.'
  s.homepage = 'https://github.com/Nike-Inc/Willow'
  s.social_media_url = 'https://twitter.com/Christian_Noon'
  s.authors = { 'Christian Noon' => 'christian.noon@nike.com', 'Eric Appel' => 'eric.appel@nike.com' }

  s.source = { :git => 'https://github.com/Nike-Inc/Willow.git', :tag => s.version }
  s.source_files = 'Source/*.swift'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
end

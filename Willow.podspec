Pod::Spec.new do |s|
  s.name = "Willow"
  s.version = "6.1.0"
  s.license = "MIT"
  s.summary = "A powerful, yet lightweight logging library written in Swift."
  s.homepage = "https://github.com/Nike-Inc/Willow"
  s.social_media_url = "https://twitter.com/Christian_Noon"
  s.authors = { "Christian Noon" => "christian.noon@nike.com", "Eric Appel" => "eric.appel@nike.com" }

  s.source = { git: "https://github.com/Nike-Inc/Willow.git", tag: s.version }
  s.source_files = "Source/*.swift"
  s.swift_versions = ["5.0"]

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"
  s.watchos.deployment_target = "3.0"
end

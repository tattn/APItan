Pod::Spec.new do |s|
  s.name = 'APItan'
  s.version = '1.0.1'
  s.license = 'MIT'
  s.summary = 'Lightweight & Kawaii API client in Swift'
  s.homepage = 'https://github.com/tattn/APItan'
  s.authors = { 'tattn (Tatsuya TANAKA)' => 'tanakasan2525@gmail.com' }
  s.source = { :git => 'https://github.com/tattn/APItan.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'APItan/*.swift'
end

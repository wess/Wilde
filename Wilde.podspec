Pod::Spec.new do |s|
  s.name         = "Wilde"
  s.version      = "0.3.0"
  s.summary      = "Wilde, named after the author Oscar Wilde, is a helper class that eases the pain of creating and drawing attributed strings."
  s.homepage     = "http://github.com/wess/Survey"
  s.license      = 'MIT'
  s.author       = { "Wess Cope" => "wcope@me.com" }
  s.ios.deployment_target = '6.0'
  s.source       = { :git => "https://github.com/wess/Wilde.git", :tag => "0.3.0" }
  s.source_files = 'src/*.{h,m}'
  s.requires_arc = true
  s.framework = 'CoreText'
  s.platform = :ios
end

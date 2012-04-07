Pod::Spec.new do |s|
  s.name     = 'NSAttributedString+Encoding'
  s.version  = '0.1'
  s.license  = 'MIT'
  
  s.summary       = 'NSAttributedString+Encoding'
  s.homepage      = 'https://github.com/mbrandonw/NSAttributedString-Encoding'
  s.author        = { 'Brandon Williams' => 'brandon@opetopic.com' }
  s.source        = { :git => 'git@github.com:mbrandonw/NSAttributedString-Encoding.git' }
  s.requires_arc  = true
  
  s.source_files = '*.{h,m}'
  s.requires_arc = true
  
  s.frameworks = 'CoreText'
  
end
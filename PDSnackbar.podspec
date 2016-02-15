Pod::Spec.new do |spec|
  spec.name         = 'PDSnackbar'
  spec.version      = '0.1.3'
  spec.license      = 'MIT'
  spec.platform     = :ios, '8.0'
  spec.summary      = 'An Objective-C version material snackbar'
  spec.homepage     = 'https://github.com/digital-prime/PDSnackbar'
  spec.author       = 'Prime Digital'
  spec.source       = { :git => 'https://github.com/digital-prime/PDSnackbar.git', :tag => 'v.0.1.3' }
  spec.source_files = 'PDSnackbar/Classes/*.{h,m}'
  spec.requires_arc = true
  spec.dependency 'PureLayout'
end
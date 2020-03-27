#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hyperlpr_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'hyperlpr_flutter'
  s.version          = '0.0.1'
  s.summary          = 'HyperLPR for flutter'
  s.description      = <<-DESC
HyperLPR_for_flutter
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Masonry'
  s.platform = :ios, '10.1'
  s.ios.vendored_frameworks='opencv2.framework'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS' => 'armv7 arm64 x86_64'
  }
end

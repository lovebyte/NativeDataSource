#
# Be sure to run `pod lib lint NativeDataSource.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NativeDataSource"
  s.version          = "0.1.0"
  s.summary          = "A short description of NativeDataSource."
  s.description      = <<-DESC
                       An optional longer description of NativeDataSource

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/lovebyte/NativeDataSource"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Steve Sng" => "steve@lovebyte.us" }
  s.source           = { :git => "https://github.com/lovebyte/NativeDataSource.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/stevesng'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*.png'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

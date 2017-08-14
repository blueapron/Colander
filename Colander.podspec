#
# Be sure to run `pod lib lint CalendarView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Colander'
  s.version          = '0.1.0'
  s.summary          = 'A highly customizable iOS calendar view'

  s.description      = <<-DESC
  Colander (originally developed for use in the Blue Apron app) provides a customizable,
  vertically scrolling calendar view. Colander allows you to customize the display of dates
  and month headers to match the style of your app.
                       DESC

  s.homepage         = 'https://github.com/blueapron/Colander'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bryan Oltman' => 'bryan.oltman@blueapron.com' }
  s.source           = { :git => 'https://github.com/blueapron/Colander', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Colander/Classes/**/*'

  s.dependency 'SnapKit', '~> 3.2.0'
  s.dependency 'SwiftDate', '~> 4.1.1'
end

Pod::Spec.new do |s|
  s.name         = "QBImagePickerController"
  s.version      = "2.1"
  s.summary      = "A clone of UIImagePickerController with multiple selection support"
  s.homepage     = "https://github.com/questbeat/QBImagePickerController"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "questbeat" => "questbeat@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/questbeat/QBImagePickerController.git", :tag => "v#{s.version}" }
  s.source_files = 'QBImagePickerController/*', 'QBImagePickerController/Resources/*.lproj/*'
  s.requires_arc = true
end

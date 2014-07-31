Pod::Spec.new do |s|
    s.name = 'QBImagePickerController'
    s.version = '2.1'
    s.license = 'MIT'
    s.summary = 'A clone of UIImagePickerController with multiple selection support.'
    s.homepage = 'https://github.com/questbeat/QBImagePickerController'
    s.author = { 'questbeat' => 'questbeat@gmail.com' }
    s.source = {
        :git => 'https://github.com/questbeat/QBImagePickerController.git',
        :tag => 'v2.1'
    }
    s.platform = :ios, '6.1'
    s.source_files = 'QBImagePickerController', 'QBImagePickerController/**/*.{h,m}'
    s.resources = 'QBImagePickerController/Resources/*.lproj'
    s.requires_arc = true
    s.frameworks = 'AssetsLibrary'
end

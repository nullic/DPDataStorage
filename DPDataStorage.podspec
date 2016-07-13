
Pod::Spec.new do |s|

  s.name         = "DPDataStorage"
  s.version      = "1.0"
  s.summary      = "Core Data stack"
  s.homepage     = "https://github.com/nullic/DPDataStorage.git"
  s.license      = "MIT"
  s.author       = { "Dmitriy Petrusevich" => "nullic@gmail.com" }
  s.platform     = { :ios => "5.0", :tvos => "9.0" }
  s.framework    = 'CoreData'

  s.source       = { :git => "https://github.com/nullic/DPDataStorage.git", :tag => "1.0" }

  s.source_files = "DPDataStorage", "DPDataStorage/*.{h,m}"
  s.requires_arc = true

  s.subspec 'DPDataSource' do |ss|
    ss.source_files = "DPDataStorage/DPDataSource/*.{h,m}"
  end
  
  s.subspec 'Mapping' do |ss|
    ss.source_files = "DPDataStorage/Mapping/*.{h,m}"
  end
  
  s.subspec 'Categories' do |ss|
    ss.source_files = "DPDataStorage/Categories/*.{h,m}"
  end

end

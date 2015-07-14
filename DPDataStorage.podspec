Pod::Spec.new do |s|

  s.name         = "DPDataStorage"
  s.version      = "1.0"
  s.summary      = "Core Data stack"
  s.homepage     = "https://github.com/nullic/DPDataStorage.git"
  s.license      = "MIT"
  s.author       = { "Dmitriy Petrusevich" => "nullic@gmail.com" }
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/nullic/DPDataStorage.git", :tag => "1.0" }
  s.source_files = "DPDataStorage", "DPDataStorage/*.{h,m}", "DPDataStorage/FRCAdapter/*.{h,m}", "DPDataStorage/Mapping/*.{h,m}"
  s.requires_arc = true

end

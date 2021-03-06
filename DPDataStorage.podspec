
Pod::Spec.new do |s|

  s.name         = "DPDataStorage"
  s.version      = "1.0"
  s.summary      = "Core Data stack"
  s.homepage     = "https://github.com/nullic/DPDataStorage.git"
  s.license      = "MIT"
  s.author       = { "Dmitriy Petrusevich" => "nullic@gmail.com" }

  s.ios.deployment_target = '5.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  
  s.framework    = 'CoreData'

  s.source       = { :git => "https://github.com/nullic/DPDataStorage.git", :tag => "1.0" }

  s.source_files = "DataMapping/*.m", "DataMapping/include/*.h", "DataSource/*.m", "DataSource/include/*.h", "DataStorage/*.m", "DataStorage/include/NSManagedObjectContext+DataStorage.h", "DPDataStorage.h"

  s.requires_arc = true

end

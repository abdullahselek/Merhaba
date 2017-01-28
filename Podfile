def product_pods
	pod 'Merhaba', :path => '.'
end

workspace 'Merhaba.xcworkspace'
project 'Merhaba.xcodeproj'

target 'Merhaba-iOS' do
	platform :ios, '9.0'
	project 'Merhaba.xcodeproj'
  	use_frameworks!

  	target 'Merhaba-iOSTests' do
    	inherit! :search_paths
    	pod 'OCMock', '~> 3.4'
  	end
end

target 'Merhaba-macOS' do
	platform :osx, '10.9'
	project 'Merhaba.xcodeproj'
  	use_frameworks!

  	target 'Merhaba-macOSTests' do
    	inherit! :search_paths
    	pod 'OCMock', '~> 3.4'
  	end
end

target 'Merhaba-tvOS' do
	platform :tvos, '9.0'
	project 'Merhaba.xcodeproj'
  	use_frameworks!

  	target 'Merhaba-tvOSTests' do
    	inherit! :search_paths
    	pod 'OCMock', '~> 3.4'
  	end
end

target 'iOS Sample' do
	project 'Sample/iOS Sample/iOS Sample.xcodeproj'
	use_frameworks!
    inherit! :search_paths
    product_pods
end

target 'macOS Sample' do
	project 'Sample/macOS Sample/macOS Sample.xcodeproj'
	use_frameworks!
    inherit! :search_paths
    product_pods
end

target 'tvOS Sample' do
  project 'Sample/tvOS Sample/tvOS Sample.xcodeproj'
  use_frameworks!
    inherit! :search_paths
    product_pods
end

def product_pods
	pod 'Merhaba', :path => '.'
end

workspace 'Merhaba.xcworkspace'
project 'Merhaba.xcodeproj'
project 'Sample/iOS Sample/iOS Sample.xcodeproj'

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
	use_frameworks!
    inherit! :search_paths
    product_pods
end

![Merhaba](https://github.com/abdullahselek/Merhaba/blob/master/Images/merhaba.png)

# Merhaba
Bonjour networking for discovery and connection between iOS devices.

## Requirements
iOS 9.0+

## CocoaPods
CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:
```	
$ gem install cocoapods
```

To integrate Merhaba into your Xcode project using CocoaPods, specify it in your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Merhaba', '~> 1.0'
end
```
Then, run the following command:
```
$ pod install
```
## Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```

To integrate Merhaba into your Xcode project using Carthage, specify it in your Cartfile:

```
github "abdullahselek/Merhaba" ~> 1.0
```

Run carthage update to build the framework and drag the built Merhaba.framework into your Xcode project.

## Example Usage

Implement your class with MRBServerDelegate to handle Bonjour events
```
@interface ViewController : UIViewController<MRBServerDelegate>
```

Initiation of MRBServer
```
NSString *type = @"TestingProtocol";
self.server = [[MRBServer alloc] initWithProtocol:type];
self.server.delegate = self;

BOOL isStarted = [self.server start];
NSLog(@"Check server started : %@", (isStarted) ? @"YES" : @"NO");
```

Connect to selected service
```
[self.server connectToRemoteService:selectedService];
```


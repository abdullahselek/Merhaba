![Merhaba](https://github.com/abdullahselek/Merhaba/blob/master/Images/merhaba.png)

[![Build Status](https://travis-ci.org/abdullahselek/Merhaba.svg?branch=master)](https://travis-ci.org/abdullahselek/Merhaba)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Merhaba.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Coverage Status](https://coveralls.io/repos/github/abdullahselek/Merhaba/badge.svg?branch=master)](https://coveralls.io/github/abdullahselek/Merhaba?branch=master)
![Platform](https://img.shields.io/cocoapods/p/Merhaba.svg?style=flat)
![License](https://img.shields.io/dub/l/vibe-d.svg)

# Merhaba
Bonjour networking for discovery and connection between iOS, macOS and tvOS devices.

## Features

- Creating Service
- Start & Stop Service
- Stop Browsing
- Create Connection with Another Service
- Send Data
- Strong Events

## Requirements
iOS 9.0+ / macOS 10.9+ / tvOS 9.0+

## Installation

### CocoaPods
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
    pod 'Merhaba', '~> 1.2.1'
end
```
Then, run the following command:
```
$ pod install
```
### Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```

To integrate Merhaba into your Xcode project using Carthage, specify it in your Cartfile:

```
github "abdullahselek/Merhaba" ~> 1.2.1
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

Sending data to selected service
```
NSData *data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
MRBServerErrorCode errorCode = [self.server sendData:data];
NSLog(@"Data sent with code : %ld", errorCode);
```

Handling incoming data with didAcceptData function
```
NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
NSLog(@"Incoming message : %@", message);
```

Stopping server
```
[self.server stop];
```

Stopping browsing for bonjour services
```
[self.server stopBrowser];
```

## License

Merhaba is released under the MIT license. See LICENSE for details.
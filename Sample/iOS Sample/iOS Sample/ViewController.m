//
//  ViewController.m
//  iOS Sample
//
//  Created by Abdullah Selek on 13/01/2017.
//  Copyright © 2017 Abdullah Selek. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *type = @"TestingProtocol";

    self.server = [[MRBServer alloc] initWithProtocol:type];
    self.server.delegate = self;

    BOOL isStarted = [self.server start];
    NSLog(@"Check server started : %@", (isStarted) ? @"YES" : @"NO");
}

#pragma mark MRBServer Delegate functions

- (void)serverRemoteConnectionComplete:(MRBServer *)server {

}

- (void)serverStopped:(MRBServer *)server {

}

- (void)server:(MRBServer *)server didNotStart:(NSDictionary *)errorDict {

}

- (void)server:(MRBServer *)server didAcceptData:(NSData *)data {

}

- (void)server:(MRBServer *)server lostConnection:(NSDictionary *)errorDict {

}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more {

}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

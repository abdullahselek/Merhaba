//
//  ViewController.h
//  macOS Sample
//
//  Created by Abdullah Selek on 23/01/2017.
//  Copyright © 2017 Abdullah Selek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Merhaba/Merhaba.h>

@interface ViewController : NSViewController<MRBServerDelegate, NSTabViewDelegate, NSTableViewDataSource>

@property (nonatomic) MRBServer *server;
@property (nonatomic) NSMutableArray *services;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) NSInteger connectedRow;
@property (nonatomic) BOOL isConnectedToService;

@end


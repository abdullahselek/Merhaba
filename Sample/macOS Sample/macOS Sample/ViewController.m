//
//  ViewController.m
//  macOS Sample
//
//  Created by Abdullah Selek on 23/01/2017.
//  Copyright © 2017 Abdullah Selek. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *textField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.services = [[NSMutableArray alloc] init];

    NSString *type = @"TestingProtocol";
    self.server = [[MRBServer alloc] initWithProtocol:type];
    self.server.delegate = self;

    NSError *error = nil;
    BOOL isStarted = [self.server start];
    if (!isStarted) {
        NSLog(@"Server start failed : %@", error);
    }
}

#pragma mark Button Actions

- (IBAction)connectToService:(id)sender {
    if (self.services.count > 0) {
        [self.server connectToRemoteService:[self.services objectAtIndex:self.selectedRow]];
    }
}

- (IBAction)sendText:(id)sender {
    NSString *textToSend = [self.textField stringValue];
    NSData *data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
    MRBServerErrorCode errorCode = [self.server sendData:data];
    NSLog(@"Data sent with code : %ld", errorCode);
    [self.textField setStringValue:@""];
}

#pragma mark MRBServer Delegate functions

- (void)serverRemoteConnectionComplete:(MRBServer *)server {
    NSLog(@"Connected to service");
    self.isConnectedToService = YES;
    self.connectedRow = self.selectedRow;
    [self.tableView reloadData];
}

- (void)serverStopped:(MRBServer *)server {
    NSLog(@"Disconnected from service");
    self.isConnectedToService = NO;
    self.connectedRow = -1;
    [self.tableView reloadData];
}

- (void)server:(MRBServer *)server didNotStart:(NSDictionary *)errorDict {
    NSLog(@"Server did not start %@", errorDict);
}

- (void)server:(MRBServer *)server didAcceptData:(NSData *)data {
    NSLog(@"Server did accept data %@", data);
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Incoming message : %@", message);
}

- (void)server:(MRBServer *)server lostConnection:(NSDictionary *)errorDict {
    NSLog(@"Lost connection");
    self.isConnectedToService = NO;
    self.connectedRow = -1;
    [self.tableView reloadData];
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more {
    NSLog(@"Added a service: %@", [service name]);
    [self.services addObject:service];
    [self refeshTableView:more];
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more {
    NSLog(@"Removed a service: %@", [service name]);
    [self.services removeObject:service];
    [self refeshTableView:more];
}

#pragma mark NSTableView Helpers

- (void)refeshTableView:(BOOL)more {
    if(!more) {
        [self.tableView reloadData];
    }
}

#pragma mark NSTableView delegate functions

- (void)tableView:(NSTableView *)tableView
  willDisplayCell:(id)aCell
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex {
    if (rowIndex == self.connectedRow) {
        [aCell setTextColor:[NSColor redColor]];
    } else {
        [aCell setTextColor:[NSColor blackColor]];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [[self.services objectAtIndex:rowIndex] name];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.services count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    self.selectedRow = [[aNotification object] selectedRow];
}

@end

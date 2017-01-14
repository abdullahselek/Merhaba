//
//  ViewController.m
//  iOS Sample
//
//  Created by Abdullah Selek on 13/01/2017.
//  Copyright © 2017 Abdullah Selek. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.services = [[NSMutableArray alloc] init];

    NSString *type = @"TestingProtocol";
    self.server = [[MRBServer alloc] initWithProtocol:type];
    self.server.delegate = self;

    BOOL isStarted = [self.server start];
    NSLog(@"Check server started : %@", (isStarted) ? @"YES" : @"NO");
}

#pragma mark Button Actions

- (IBAction)connectToService:(id)sender {
    if (self.services.count > 0) {
        [self.server connectToRemoteService:[self.services objectAtIndex:self.selectedRow]];
    }
}

- (IBAction)sendText:(id)sender {
    NSString *textToSend = self.textField.text;
    if (textToSend != nil) {
        NSData *data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
        MRBServerErrorCode errorCode = [self.server sendData:data];
        NSLog(@"Data sent with code : %ld", errorCode);
    }
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

}

- (void)server:(MRBServer *)server lostConnection:(NSDictionary *)errorDict {

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

#pragma mark UITableView Helpers

- (void)refeshTableView:(BOOL)more {
    if(!more) {
        [self.tableView reloadData];
    }
}

#pragma mark UITableView Delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.services count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"MRBServerTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [[self.services objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

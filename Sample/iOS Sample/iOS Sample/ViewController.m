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
    NSString *textToSend = self.textField.text;
    if (textToSend != nil) {
        NSData *data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
        MRBServerErrorCode errorCode = [self.server sendData:data];
        NSLog(@"Data sent with code : %ld", errorCode);
        self.textField.text = @"";
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
    NSLog(@"Server did accept data %@", data);
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Incoming message : %@", message);
    [self showAlertWithMessage:message];
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

#pragma mark UIAlertController function

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incoming message"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
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

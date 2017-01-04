//
//  MRBServerTests.m
//  Merhaba
//
//  Created by Abdullah Selek on 03/01/2017.
//
//

#import <XCTest/XCTest.h>
#import "MRBServer.h"

@interface MRBServer(Test)

- (CFSocketRef)createSocket;

@end

@interface MRBServerTests : XCTestCase

@end

@implementation MRBServerTests

- (void)testInit {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    XCTAssertNotNil(mrbServer, @"init failed");
    XCTAssertTrue([mrbServer.domain isEqualToString:@""], @"set domain invalid");
    XCTAssertTrue([mrbServer.protocol isEqualToString:MRBDefaultProtocol], @"set protocol invalid");
    XCTAssertTrue([mrbServer.name isEqualToString:@""], @"set name invalid");
}

- (void)testInitWithProtocol {
    MRBServer *mrbServer = [[MRBServer alloc] initWithProtocol:@"protocol"];
    XCTAssertNotNil(mrbServer, @"initWithProtocol failed");
    XCTAssertTrue([mrbServer.domain isEqualToString:@""], @"set domain invalid");
    XCTAssertTrue([mrbServer.protocol isEqualToString:@"_protocol._tcp."], @"set protocol invalid");
    XCTAssertTrue([mrbServer.name isEqualToString:@""], @"set name invalid");
}

- (void)testInitWithDomainName {
    MRBServer *mrbServer = [[MRBServer alloc] initWithDomainName:@"domain"
                                                        protocol:@"protocol"
                                                            name:@"name"];
    XCTAssertNotNil(mrbServer, @"initWithDomainName failed");
    XCTAssertTrue([mrbServer.domain isEqualToString:@"domain"], @"set domain invalid");
    XCTAssertTrue([mrbServer.protocol isEqualToString:@"protocol"], @"set protocol invalid");
    XCTAssertTrue([mrbServer.name isEqualToString:@"name"], @"set name invalid");
}

- (void)testCreateSocket {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    XCTAssertNotNil(mrbServer, @"init failed");
    CFSocketRef socket = [mrbServer createSocket];
    XCTAssertNotNil((__bridge id) socket, @"create socket failed");
}

- (void)testStartServer_shouldSuccess {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    XCTAssertNotNil(mrbServer, @"init failed");
    BOOL successful = [mrbServer start];
    XCTAssertTrue(successful, @"socket start failed");
}

@end

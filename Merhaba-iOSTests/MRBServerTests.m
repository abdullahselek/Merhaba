//
//  MRBServerTests.m
//  Merhaba
//
//  Created by Abdullah Selek on 03/01/2017.
//
//  MIT License
//
//  Copyright (c) 2017 Abdullah Selek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MRBServer.h"
#import "Fixture.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@interface MRBServer(Test)

- (CFSocketRef)createSocket;
- (void)streamHasSpace:(NSStream *)stream;
- (void)connectedToInputStream:(NSInputStream *)inputStream
                  outputStream:(NSOutputStream *)outputStream;
- (void)stopNetService;
- (void)stopStreams;

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorInfo;

@end

@interface MRBServerTests : XCTestCase

@property (nonatomic) MRBServer *mrbServer;

@end

@implementation MRBServerTests

- (void)setUp {
    self.mrbServer = [[MRBServer alloc] init];
}

- (void)testInit {
    XCTAssertNotNil(self.mrbServer, @"init failed");
    XCTAssertTrue([self.mrbServer.domain isEqualToString:@""], @"set domain invalid");
    XCTAssertTrue([self.mrbServer.protocol isEqualToString:MRBDefaultProtocol], @"set protocol invalid");
    XCTAssertTrue([self.mrbServer.name isEqualToString:@""], @"set name invalid");
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
    XCTAssertNotNil(self.mrbServer, @"init failed");
    CFSocketRef socket = [self.mrbServer createSocket];
    XCTAssertNotNil((__bridge id) socket, @"create socket failed");
}

- (void)testStartServer_shouldSuccess {
    XCTAssertNotNil(self.mrbServer, @"init failed");
    BOOL successful = [self.mrbServer start];
    XCTAssertTrue(successful, @"socket start failed");
}

- (void)testSendData_shouldReturnNoSpaceOnOutputStream_whenDataNil {
    self.mrbServer.outputStream = [[NSOutputStream alloc] initToMemory];
    self.mrbServer.outputStreamHasSpace = YES;
    MRBServerErrorCode code = [self.mrbServer sendData:[[NSData alloc] initWithContentsOfFile:@"data"]];
    XCTAssertEqual(code, MRBServerNoSpaceOnOutputStream);
}

- (void)testSendData_shouldReturnNoSpaceOnOutputStream_whenOutputStreamHasSpaceNo {
    self.mrbServer.outputStream = [[NSOutputStream alloc] initToMemory];
    self.mrbServer.outputStreamHasSpace = NO;
    MRBServerErrorCode code = [self.mrbServer sendData:[Fixture dataFromFile:@"data"]];
    XCTAssertEqual(code, MRBServerNoSpaceOnOutputStream);
}

- (void)testSendData_shouldReturnOutputStreamReachedCapacity_whenDataNotNil {
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    NSData *data = [Fixture dataFromFile:@"data"];
    OCMStub([mockOutputStream write:[data bytes] maxLength:[data length]]).andReturn(0);
    self.mrbServer.outputStream = mockOutputStream;
    self.mrbServer.outputStreamHasSpace = YES;
    MRBServerErrorCode code = [self.mrbServer sendData:data];
    XCTAssertEqual(code, MRBServerOutputStreamReachedCapacity);
}

- (void)testSendData_shouldReturnServerSuccess_whenDataNotNil {
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    NSData *data = [Fixture dataFromFile:@"data"];
    OCMStub([mockOutputStream write:[data bytes] maxLength:[data length]]).andReturn(1);
    self.mrbServer.outputStream = mockOutputStream;
    self.mrbServer.outputStreamHasSpace = YES;
    MRBServerErrorCode code = [self.mrbServer sendData:data];
    XCTAssertEqual(code, MRBServerSuccess);
}

- (void)testStreamHasSpace {
    [self.mrbServer streamHasSpace:[[NSStream alloc] init]];
    XCTAssertTrue(self.mrbServer.outputStreamHasSpace, @"streamHasSpace failed");
}

- (void)testConnectedToStream_shouldSetCorrect_whenInputAndOutputStreamNotEmpty {
    id mockInputStream = OCMClassMock([NSInputStream class]);
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    [self.mrbServer connectedToInputStream:mockInputStream outputStream:mockOutputStream];
    XCTAssertEqual(self.mrbServer.inputStream, mockInputStream);
    XCTAssertEqual(self.mrbServer.outputStream, mockOutputStream);
}

- (void)testStopStream_shouldSetNil_whenInputAndOutputStreamNotEmpty {
    id mockInputStream = OCMClassMock([NSInputStream class]);
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    self.mrbServer.inputStream = mockInputStream;
    self.mrbServer.outputStream = mockOutputStream;
    [self.mrbServer stopStreams];
    XCTAssertNil(self.mrbServer.inputStream);
    XCTAssertNil(self.mrbServer.outputStream);
}

- (void)testConnectToRemoteService_withValidService {
    id mockNetService = OCMClassMock([NSNetService class]);
    [self.mrbServer connectToRemoteService:mockNetService];
    XCTAssertEqual(self.mrbServer.currentlyResolvingService, mockNetService);
}

- (void)testStop {
    id mockServer = OCMPartialMock(self.mrbServer);
    [self.mrbServer start];
    id mockNetService = OCMClassMock([NSNetService class]);
    self.mrbServer.netService = mockNetService;
    id mockProtocol = OCMProtocolMock(@protocol(MRBServerDelegate));
    self.mrbServer.delegate = mockProtocol;
    [self.mrbServer stop];
    OCMVerify([mockServer stopNetService]);
    OCMVerify([mockServer stopStreams]);
}

- (void)testServiceDidNotResolve {
    NSNetService *service = OCMClassMock([NSNetService class]);
    self.mrbServer.currentlyResolvingService = service;
    [self.mrbServer netService:service didNotResolve:@{@"error": @"1"}];
    OCMVerify([service stop]);
    XCTAssertNil(self.mrbServer.currentlyResolvingService);
}

- (void)testServiceDidNotPublish {
    NSNetService *service = OCMClassMock([NSNetService class]);
    self.mrbServer.currentlyResolvingService = service;
    id mockProtocol = OCMProtocolMock(@protocol(MRBServerDelegate));
    self.mrbServer.delegate = mockProtocol;
    NSDictionary *errorDict = @{@"error": @"1"};
    [self.mrbServer netService:service didNotPublish:errorDict];
    OCMVerify([mockProtocol server:self.mrbServer didNotStart:errorDict]);
}

- (void)tearDown {
    self.mrbServer = nil;
}

@end

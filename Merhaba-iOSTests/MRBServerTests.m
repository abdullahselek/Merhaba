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
- (void)stopStreams;

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

- (void)testSendData_shouldReturnNoSpaceOnOutputStream_whenDataNil {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    mrbServer.outputStream = [[NSOutputStream alloc] initToMemory];
    mrbServer.outputStreamHasSpace = YES;
    MRBServerErrorCode code = [mrbServer sendData:[[NSData alloc] initWithContentsOfFile:@"data"]];
    XCTAssertEqual(code, MRBServerNoSpaceOnOutputStream);
}

- (void)testSendData_shouldReturnNoSpaceOnOutputStream_whenOutputStreamHasSpaceNo {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    mrbServer.outputStream = [[NSOutputStream alloc] initToMemory];
    mrbServer.outputStreamHasSpace = NO;
    MRBServerErrorCode code = [mrbServer sendData:[Fixture dataFromFile:@"data"]];
    XCTAssertEqual(code, MRBServerNoSpaceOnOutputStream);
}

- (void)testSendData_shouldReturnOutputStreamReachedCapacity_whenDataNotNil {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    NSData *data = [Fixture dataFromFile:@"data"];
    OCMStub([mockOutputStream write:[data bytes] maxLength:[data length]]).andReturn(0);
    mrbServer.outputStream = mockOutputStream;
    mrbServer.outputStreamHasSpace = YES;
    MRBServerErrorCode code = [mrbServer sendData:data];
    XCTAssertEqual(code, MRBServerOutputStreamReachedCapacity);
}

- (void)testSendData_shouldReturnServerSuccess_whenDataNotNil {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    NSData *data = [Fixture dataFromFile:@"data"];
    OCMStub([mockOutputStream write:[data bytes] maxLength:[data length]]).andReturn(1);
    mrbServer.outputStream = mockOutputStream;
    mrbServer.outputStreamHasSpace = YES;
    MRBServerErrorCode code = [mrbServer sendData:data];
    XCTAssertEqual(code, MRBServerSuccess);
}

- (void)testStreamHasSpace {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    [mrbServer streamHasSpace:[[NSStream alloc] init]];
    XCTAssertTrue(mrbServer.outputStreamHasSpace, @"streamHasSpace failed");
}

- (void)testConnectedToStream_shouldSetCorrect_whenInputAndOutputStreamNotEmpty {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    id mockInputStream = OCMClassMock([NSInputStream class]);
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    [mrbServer connectedToInputStream:mockInputStream outputStream:mockOutputStream];
    XCTAssertEqual(mrbServer.inputStream, mockInputStream);
    XCTAssertEqual(mrbServer.outputStream, mockOutputStream);
}

- (void)testStopStream_shouldSetNil_whenInputAndOutputStreamNotEmpty {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    id mockInputStream = OCMClassMock([NSInputStream class]);
    id mockOutputStream = OCMClassMock([NSOutputStream class]);
    mrbServer.inputStream = mockInputStream;
    mrbServer.outputStream = mockOutputStream;
    [mrbServer stopStreams];
    XCTAssertNil(mrbServer.inputStream);
    XCTAssertNil(mrbServer.outputStream);
}

- (void)testConnectToRemoteService_withValidService {
    MRBServer *mrbServer = [[MRBServer alloc] init];
    id mockNetService = OCMClassMock([NSNetService class]);
    [mrbServer connectToRemoteService:mockNetService];
    XCTAssertEqual(mrbServer.currentlyResolvingService, mockNetService);
}

@end

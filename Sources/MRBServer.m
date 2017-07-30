//
//  MRBServer.m
//  Merhaba
//
//  Created by Abdullah Selek on 02/01/2017.
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

#import "MRBServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString * const MRBDefaultProtocol = @"_Server._tcp.";
NSString * const MRBServerErrorDomain = @"ServerErrorDomain";

@interface MRBServer ()

@property (nonatomic) NSString *domain;
@property (nonatomic) NSString *protocol;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNetService *localService;
@property (nonatomic) NSNetServiceBrowser *browser;

@end

/**
  * the call back function called when the server accepts a connection
 */
static void SocketAcceptedConnectionCallBack(CFSocketRef socket,
                                             CFSocketCallBackType type,
                                             CFDataRef address,
                                             const void *data, void *info);

@implementation MRBServer

- (instancetype)init {
    return [self initWithDomainName:@""
                           protocol:MRBDefaultProtocol
                               name:@""];
}

- (instancetype)initWithProtocol:(NSString *)protocol {
    return [self initWithDomainName:@""
                           protocol:[NSString stringWithFormat:@"_%@._tcp.", protocol]
                               name:@""];
}

- (instancetype)initWithDomainName:(NSString *)domain
                          protocol:(NSString *)protocol
                              name:(NSString *)name {
    self = [super init];
    if (self) {
        self.domain = domain;
        self.protocol = protocol;
        self.name = name;
        self.outputStreamHasSpace = NO;
        self.payloadSize = 128;
    }
    return self;
}

- (CFSocketRef)createSocket {
    CFSocketContext socketCtxt = {0, (__bridge_retained void *)(self), NULL, NULL, NULL};
    return CFSocketCreate(kCFAllocatorDefault,
                          PF_INET,
                          SOCK_STREAM,
                          IPPROTO_TCP,
                          kCFSocketAcceptCallBack,
                          (CFSocketCallBack)&SocketAcceptedConnectionCallBack,
                          &socketCtxt);
}

- (BOOL)publishNetService {
    BOOL successful = NO;
    self.netService = [[NSNetService alloc] initWithDomain:self.domain
                                                      type:self.protocol
                                                      name:self.name
                                                      port:self.port];
    if (self.netService) {
        [self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSRunLoopCommonModes];
        [self.netService publish];
        self.netService.delegate = self;
        successful = YES;
    }
    return successful;
}

- (BOOL)start:(NSError **)error {
    BOOL successful = YES;
    self.socket = [self createSocket];
    if (!self.socket) {
        *error = [[NSError alloc] initWithDomain:MRBServerErrorDomain
                                            code:MRBServerNoSocketsAvailable
                                        userInfo:nil];
        successful = NO;
    }
    
    if (successful) {
        // enable address reuse
        int yes = 1;
        setsockopt(CFSocketGetNative(self.socket),
                   SOL_SOCKET, SO_REUSEADDR,
                   (void *)&yes, sizeof(yes));
        /** set the packet size for send and receive
          * cuts down on latency and such when sending
          * small packets
         */
        uint8_t packetSize = self.payloadSize;
        setsockopt(CFSocketGetNative(self.socket),
                   SOL_SOCKET, SO_SNDBUF,
                   (void *)&packetSize, sizeof(packetSize));
        setsockopt(CFSocketGetNative(self.socket),
                   SOL_SOCKET, SO_RCVBUF,
                   (void *)&packetSize, sizeof(packetSize));

        /** set up the IPv4 endpoint; use port 0, so the kernel
          * will choose an arbitrary port for us, which will be
          * advertised through Bonjour
         */
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = 0; // since we set it to zero the kernel will assign one for us
        addr4.sin_addr.s_addr = htonl(INADDR_ANY);
        NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];

        if (kCFSocketSuccess != CFSocketSetAddress(self.socket, (CFDataRef)address4)) {
            *error = [[NSError alloc] initWithDomain:MRBServerErrorDomain
                                                code:MRBServerCouldNotBindToIPv4Address
                                            userInfo:nil];
            if (self.socket) {
                CFRelease(self.socket);
            }
            self.socket = NULL;
            successful = NO;
        } else {
            // now that the binding was successful, we get the port number
            NSData *addr = (NSData *)CFBridgingRelease(CFSocketCopyAddress(self.socket));
            memcpy(&addr4, [addr bytes], [addr length]);
            self.port = ntohs(addr4.sin_port);

            // set up the run loop sources for the sockets
            CFRunLoopRef cfrl = CFRunLoopGetCurrent();
            CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.socket, 0);
            CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
            CFRelease(source4);

            if (![self publishNetService]) {
                successful = NO;
            }
        }
    }

    return successful;
}

- (MRBServerErrorCode)sendData:(NSData *)data {
    if (self.outputStreamHasSpace) {
        NSInteger len = [self.outputStream write:[data bytes] maxLength:[data length]];
        if (len == -1) {
            return MRBServerNoSpaceOnOutputStream;
        } else if (len == 0) {
            return MRBServerOutputStreamReachedCapacity;
        } else {
            return MRBServerSuccess;
        }
    } else {
        return MRBServerNoSpaceOnOutputStream;
    }
}

- (MRBServerErrorCode)sendFileAtPath:(NSString *)filepath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filepath];
        return [self sendData:data];
    } else {
        NSLog(@"Merhaba try to send file on %@, but there is no such file!", filepath);
        return MRBServerFileNotFound;
    }
}

- (void)connectToRemoteService:(NSNetService *)selectedService {
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;

    self.currentlyResolvingService = selectedService;
    self.currentlyResolvingService.delegate = self;
    [self.currentlyResolvingService resolveWithTimeout:0.0];
}

- (void)connectedToInputStream:(NSInputStream *)inputStream
                  outputStream:(NSOutputStream *)outputStream {
    // need to close existing streams
    [self stopStreams];

    self.inputStream = inputStream;
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    [self.inputStream open];

    self.outputStream = outputStream;
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

- (void)stop {
    if (self.netService) {
        [self stopNetService];
    }
    if (self.socket) {
        CFSocketInvalidate(self.socket);
        CFRelease(self.socket);
        self.socket = NULL;
    }
    [self stopStreams];
    [self.delegate serverStopped:self];
}

- (void)stopNetService {
    [self.netService stop];
    [self.netService removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
    self.netService = nil;
}

- (void)stopStreams {
    if (self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
        self.inputStream = nil;
        self.inputStreamReady = NO;
    }
    if (self.outputStream) {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        self.outputStream = nil;
        self.outputStreamReady = NO;
    }
}

- (void)stopBrowser {
    [self.browser stop];
    self.browser = nil;
    [self.localService stop];
    self.localService = nil;
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;
}

#pragma mark Remote Service methods

- (void)remoteServiceResolved:(NSNetService *)remoteService {
    NSInputStream *inputStream = nil;
    NSOutputStream *outputStream = nil;

    if ([remoteService getInputStream:&inputStream outputStream:&outputStream]) {
        [self connectedToInputStream:inputStream outputStream:outputStream];
    }
}

- (void)searchForServicesOfType:(NSString *)type {
    [self.browser stop];
    self.browser = nil;

    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.delegate = self;
    [self.browser searchForServicesOfType:type inDomain:@"local"];
}

#pragma mark Stream methods

- (void)streamCompletedOpening:(NSStream *)stream {
    if (self.inputStream == stream) {
        self.inputStreamReady = YES;
    }
    if (self.outputStream == stream) {
        self.outputStreamReady = YES;
    }

    if (self.inputStreamReady && self.outputStreamReady) {
        [self.delegate serverRemoteConnectionComplete:self];
        [self stopNetService];
    }
}

- (void)streamHasBytes:(NSStream *)stream {
    NSMutableData *data = [NSMutableData data];
    uint8_t *buf = calloc(self.payloadSize, sizeof(uint8_t));
    NSUInteger len = 0;
    while ([(NSInputStream *) stream hasBytesAvailable]) {
        len = [self.inputStream read:buf maxLength:self.payloadSize];
        if (len > 0) {
            [data appendBytes:buf length:len];
        }
    }
    free(buf);
    [self.delegate server:self didAcceptData:data];
}

- (void)streamHasSpace:(NSStream *)stream {
    self.outputStreamHasSpace = YES;
}

- (void)streamEncounteredEnd:(NSStream *)stream {
    // remote side died, tell the delegate then restart my local
    // service looking for some other server to connect to
    [self.delegate server:self lostConnection:nil];
    [self stopStreams];
    [self publishNetService];
}

- (void)streamEncounteredError:(NSStream *)stream {
    [self.delegate server:self lostConnection:[[stream streamError] userInfo]];
    [self stop];
}

#pragma mark NSNetServiceDelegate methods

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorInfo {
    [self.delegate server:self didNotStart:errorInfo];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    assert(service == self.currentlyResolvingService);

    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;

    [self remoteServiceResolved:service];
}

- (void)netServiceDidPublish:(NSNetService *)service {
    self.localService = service;
    self.name = service.name;
    // now start looking for others
    [self searchForServicesOfType:self.protocol];
}

#pragma mark NetServiceBrowser setup and delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser
         didRemoveService:(NSNetService*)service
               moreComing:(BOOL)moreComing {

    if ([service.name isEqualToString:self.currentlyResolvingService.name]) {
        [self.currentlyResolvingService stop];
        self.currentlyResolvingService = nil;
    } else if ([self.localService.name isEqualToString:service.name]) {
        self.localService = nil;
    }
    [self.delegate serviceRemoved:service moreComing:moreComing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser
           didFindService:(NSNetService*)service
               moreComing:(BOOL)moreComing {
    if (![service.name isEqualToString:self.localService.name]) {
        [self.delegate serviceAdded:service moreComing:moreComing];
    }
}

#pragma mark NSStreamDelegate methods

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self streamCompletedOpening:stream];
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            [self streamHasBytes:stream];
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            [self streamHasSpace:stream];
            break;
        }
        case NSStreamEventEndEncountered: {
            [self streamEncounteredEnd:stream];
            break;
        }
        case NSStreamEventErrorOccurred: {
            [self streamEncounteredError:stream];
            break;
        }
        default:
            break;
    }
}

#pragma mark Dealloc

- (void)dealloc {
    [self stop];
    [self stopBrowser];
    self.domain = nil;
    self.protocol = nil;
    self.name = nil;
    self.delegate = nil;
}

@end

static void SocketAcceptedConnectionCallBack(CFSocketRef socket,
                                             CFSocketCallBackType type,
                                             CFDataRef address,
                                             const void *data, void *info) {
    /**
      * the server's socket has accepted a connection request
      * this function is called because it was registered in the
      * socket create method
     */
    if (kCFSocketAcceptCallBack == type) {
        MRBServer *server = (MRBServer *) CFBridgingRelease(info);
        // on an accept the data is the native socket handle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        // create the read and write streams for the connection to the other process
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle,
                                     &readStream, &writeStream);
        if (readStream && writeStream) {
            CFReadStreamSetProperty(readStream,
                                    kCFStreamPropertyShouldCloseNativeSocket,
                                    kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream,
                                     kCFStreamPropertyShouldCloseNativeSocket,
                                     kCFBooleanTrue);
            [server connectedToInputStream:(__bridge NSInputStream *) readStream
                              outputStream:(__bridge NSOutputStream *)writeStream];
        } else {
            /**
              * on any failure, need to destroy the CFSocketNativeHandle
              * since we are not going to use it any more
             */
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}


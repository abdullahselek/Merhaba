//
//  MRBServer.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const MRBDefaultProtocol;
extern NSString * const MRBServerErrorDomain;

@class MRBServer;

/**
  * Protocol for MRBServer
 */
@protocol MRBServerDelegate <NSObject>

/**
  * Both sides of the connection are ready to go
  *
  * @param server MRBServer
 */
- (void)serverRemoteConnectionComplete:(MRBServer *)server;

/**
  * server is finished stopping
  *
  * @param server MRBServer
 */
- (void)serverStopped:(MRBServer *)server;

/**
  * Server could not start
  *
  * @param server MRBServer
  * @param errorDict NSDictionary
 */
- (void)server:(MRBServer *)server didNotStart:(NSDictionary *)errorDict;

/**
  * Gets data from the remote side of the server
  *
  * @param server MRBServer
  * @param data NSData
 */
- (void)server:(MRBServer *)server didAcceptData:(NSData *)data;

/**
  * connection to the remote side is lost
  *
  * @param server MRBServer
  * @param errorDict NSDictionary
 */
- (void)server:(MRBServer *)server lostConnection:(NSDictionary * _Nullable)errorDict;

/**
  * A new service comes on line
  *
  * @param service NSNetService
  * @param more BOOL
 */
- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more;

/**
  * A service went off line
  *
  * @param service NSNetService
  * @param more BOOL
 */
- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more;

@end

typedef NS_ENUM(NSInteger, MRBServerErrorCode) {
    MRBServerCouldNotBindToIPv4Address,
    MRBServerCouldNotBindToIPv6Address,
    MRBServerNoSocketsAvailable,
    MRBServerNoSpaceOnOutputStream,
    MRBServerOutputStreamReachedCapacity,
    MRBServerFileNotFound,
    MRBServerSuccess,
};

@interface MRBServer : NSObject <NSNetServiceDelegate, NSStreamDelegate, NSNetServiceBrowserDelegate>

/**
  * the port, reterieved from the OS
 */
@property (nonatomic) uint16_t port;
/**
  * the size you expect to be sending
 */
@property (nonatomic) uint8_t payloadSize;
/**
  * when there is space in the output stream this is YES
 */
@property (nonatomic) BOOL outputStreamHasSpace;
/**
  * the socket that data is sent over
 */
@property (nullable, nonatomic) CFSocketRef socket;
/**
  * bonjour net service used to publish this server
 */
@property (nullable, nonatomic) NSNetService *netService;
/**
  * stream that this side writes two
 */
@property (nullable, nonatomic) NSOutputStream *outputStream;
/**
  * stream that this side reads from
 */
@property (nullable, nonatomic) NSInputStream *inputStream;
/**
  * when input stream is ready to read from this turns to YES
 */
@property (nonatomic) BOOL inputStreamReady;
/**
  * when output stream is ready to read from this turns to YES
 */
@property (nonatomic) BOOL outputStreamReady;

/**
  * the service we are currently trying to resolve
 */
@property (nullable, nonatomic) NSNetService *currentlyResolvingService;

@property (nonatomic, weak) id<MRBServerDelegate> delegate;

/**
  * Uses protocol as the bonjour protocol and TCP as the networking layer
  *
  * @param protocol NSString
  * @return MRBServer instance
 */
- (instancetype)initWithProtocol:(NSString *)protocol;

/**
  * Initialize with name, protocol and name
  *
  * @param domain NSString
  * @param protocol NSString
  * @param name NSString
  * @return MRBServer instance
 */
- (instancetype)initWithDomainName:(NSString *)domain
                          protocol:(NSString *)protocol
                              name:(NSString *)name;

/**
  * Starts server
  *
  * @param error NSError for information when it fails
  * @return result
 */
- (BOOL)start:(NSError **)error;

/**
  * Send data to the remote side of the server
  *
  * @param data Data you want to send
  * @return MRBServerErrorCode result code
 */
- (MRBServerErrorCode)sendData:(NSData *)data;

/**
  * Send file at given path to the remote side of the server
  *
  * @param filepath Path for the file
  * @return MRBServerErrorCode result code
 */
- (MRBServerErrorCode)sendFileAtPath:(NSString *)filepath;

/**
  * To connect to the remote service
  *
  * @param selectedService NSNetService
 */
- (void)connectToRemoteService:(NSNetService *)selectedService;

/**
  * Stop the server
 */
- (void)stop;

/**
  * Turns of browsing for like protocol bonjour services
 */
- (void)stopBrowser;

@end

NS_ASSUME_NONNULL_END

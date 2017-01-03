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

NSString * const MRBDefaultProtocol = @"_Server._tcp.";

@implementation MRBServer

- (id)init {
    return [self initWithDomainName:@""
                           protocol:MRBDefaultProtocol
                               name:@""];
}

- (id)initWithProtocol:(NSString *)protocol {
    return [self initWithDomainName:@""
                    protocol:[NSString stringWithFormat:@"_%@._tcp.", protocol]
                        name:@""];
}

- (id)initWithDomainName:(NSString *)domain
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

@end

//
//  HTTPRequestCreator.h
//  CrewPad
//
//  Created by Kevin OSullivan on 02/05/2012.
//  Copyright (c) 2012 ITXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface HTTPRequestCreator : NSObject


+ (ASIHTTPRequest *) prepareAndCallHTTP_GET_RequestWithURL:(NSURL *)url AndRequestType:(NSString*)requestType AndDelegate:(id) delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector;
+ (ASIHTTPRequest *) prepareAndCallHTTP_POST_RequestWithURL:(NSURL *)url AndPostData:(NSData*)postData AndDelegate:(id)delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector;
+ (ASIHTTPRequest *) prepareLoginAndCallHTTP_GET_RequestWithURL:(NSURL *)url AndRequestType:(NSString*)requestType AndDelegate:(id) delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector;
+ (void) logStartRESTAPICall: (ASIHTTPRequest *)request;
+ (void) logEndRESTAPICall: (ASIHTTPRequest *)request;
+ (ASIHTTPRequest *) prepareAndCallHTTP_PUT_RequestWithURL:(NSURL *)url AndPostData:(NSData*)postData AndDelegate:(id)delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector;

+ (ASIHTTPRequest *) prepareAndCallHTTP_PUT_RequestWithURLChangePass:(NSURL *)url AndPostData:(NSData*)postData AndDelegate:(id)delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector;

@end
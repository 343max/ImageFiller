//
//  CHHTTPConnection.h
//  ImageFiller
//
//  Created by hangchen on 4/17/14.
//  Copyright (c) 2014 Hang Chen (https://github.com/cyndibaby905)

#import <Foundation/Foundation.h>


typedef void (^OnComplete) (NSHTTPURLResponse *response, NSData *data, NSError *error);


@interface CHHTTPConnection : NSObject

- (id)initWithRequest:(NSURLRequest *)urlRequest;

- (BOOL)executeRequestOnComplete:(OnComplete)OnCompleteBlock;

@end

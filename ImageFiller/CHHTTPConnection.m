//
//  CHHTTPConnection.m
//  ImageFiller
//
//  Created by hangchen on 4/17/14.
//  Copyright (c) 2014 Hang Chen (https://github.com/cyndibaby905)

#import "CHHTTPConnection.h"


@interface CHHTTPConnection ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, readonly) NSString *body;

@property (nonatomic, copy) OnComplete onComplete;

@end


@implementation CHHTTPConnection

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
    self = [super init];
    if (self) {
        self.request = urlRequest;
    }
    return self;
}

- (NSString *)body
{
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (BOOL)executeRequestOnComplete:(OnComplete)OnCompleteBlock
{
    self.onComplete = OnCompleteBlock;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    return connection != nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)aResponse;
    self.response = httpResponse;
    
    self.data = [NSMutableData data];
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)bytes
{
    [self.data appendData:bytes];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.onComplete)
        self.onComplete(self.response, self.data, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.onComplete)
        self.onComplete(self.response, self.data, nil);
}

@end

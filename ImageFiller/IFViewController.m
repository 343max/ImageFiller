//
//  IFViewController.m
//  ImageFiller
//
//  Created by Max von Webel on 06/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import "IFViewController.h"

@interface IFViewController ()

@property (strong) NSURLSession *session;
@property (assign) NSInteger totalImageCount;
@property (strong) NSMutableArray *images;

@end

@implementation IFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.totalImageCount = 5;
    self.images = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addImagesToLibrary
{
    NSLog(@"add images to library");
}

- (void)log:(NSString *)log
{
    NSLog(@"%@", log);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logMessage.text = log;
    });
}

- (void)progress:(NSInteger)progress of:(NSInteger)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (float)progress / (float)total;
    });
}

- (IBAction)loadImages:(id)sender {
    [self log:@"loading images"];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    for (NSInteger index = 0; index < self.totalImageCount; index++) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lorempixel.com/400/400/?%i", arc4random()]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request
                                                                     completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                         UIImage *image = [[UIImage alloc] initWithContentsOfFile:location.path];
                                                                         
                                                                         NSAssert(image.size.width != 0 && image.size.height != 0, @"image is no image");
                                                                         
                                                                         [self.images addObject:image];
                                                                         [self log:[NSString stringWithFormat:@"loaded %lu of %li images", (unsigned long)self.images.count, (long)self.totalImageCount]];
                                                                         
                                                                         [self progress:self.images.count
                                                                                     of:self.totalImageCount];
                                                                         
                                                                         
                                                                         if (self.images.count == self.totalImageCount) {
                                                                             [self addImagesToLibrary];
                                                                         }
                                                                     }];
        [downloadTask resume];
    }
}
@end

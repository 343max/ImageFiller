//
//  IFViewController.m
//  ImageFiller
//
//  Created by Max von Webel on 06/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#import "IFViewController.h"

@interface IFViewController ()

@property (strong) NSURLSession *session;
@property (assign) NSInteger totalImageDownloadCount;
@property (assign) NSInteger totalImageWriteCount;
@property (assign) NSInteger totalImagesWrittenCount;
@property (strong) NSMutableArray *images;

@property (strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation IFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.totalImageDownloadCount = 100;
    self.totalImageWriteCount = 5000;
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addImagesToLibrary
{
    [self log:[NSString stringWithFormat:@"adding %li images to the library", (long)self.totalImageWriteCount]];

    NSDateFormatter *exifDateFormatter = [[NSDateFormatter alloc] init];
    [exifDateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    
    self.totalImagesWrittenCount = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger index = 0; index < self.totalImageWriteCount; index++) {
            UIImage *image = self.images[arc4random() % self.images.count];
            
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(float)(arc4random() % (5 * 365 * 24 * 3600))];
            
            NSDictionary *exifData = @{ (NSString *)kCGImagePropertyExifDateTimeOriginal: [exifDateFormatter stringFromDate:date] };
            
            NSDictionary *metadata = @{ (NSString *)kCGImagePropertyExifDictionary: exifData };
            
            [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage
                                                    metadata:metadata
                                             completionBlock:^(NSURL *assetURL, NSError *error) {
                                                 self.totalImagesWrittenCount += 1;
                                                 [self progress:self.totalImagesWrittenCount
                                                             of:self.totalImageWriteCount];
                                                 
                                                 if (self.totalImageWriteCount == self.totalImagesWrittenCount) {
                                                     [self log:@"complete!"];
                                                 }
                                             }];
        }
    });
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
    
    self.images = [NSMutableArray array];
    
    NSURL *tempURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    
    for (NSInteger index = 0; index < self.totalImageDownloadCount; index++) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lorempixel.com/400/400/?%i", arc4random()]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request
                                                                     completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                         NSString *filename = [NSString stringWithFormat:@"image%i.jpg", arc4random()];
                                                                         NSURL *imageURL = [tempURL URLByAppendingPathComponent:filename];
                                                                         
                                                                         NSError *fileError;
                                                                         [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                                 toURL:imageURL
                                                                                                                 error:&fileError];
                                                                         NSAssert(fileError == nil, @"something happended");
                                                                         
                                                                         UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageURL.path];
                                                                         
                                                                         NSAssert(image.size.width != 0 && image.size.height != 0, @"image is no image");
                                                                         
                                                                         [self.images addObject:image];
                                                                         [self log:[NSString stringWithFormat:@"loaded %lu of %li images", (unsigned long)self.images.count, (long)self.totalImageDownloadCount]];
                                                                         
                                                                         [self progress:self.images.count
                                                                                     of:self.totalImageDownloadCount];
                                                                         
                                                                         
                                                                         if (self.images.count == self.totalImageDownloadCount) {
                                                                             [self addImagesToLibrary];
                                                                         }
                                                                     }];
        [downloadTask resume];
    }
}
@end

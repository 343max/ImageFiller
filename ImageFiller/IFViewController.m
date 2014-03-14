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
#import "IFSavePhotoOperation.h"
#import "IFCreateAlbumsOperation.h"

@interface IFViewController () <IFSavePhotoOperationDelegate, IFCreateAlbumsOperationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *logMessage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISwitch *createAlbumSwitch;

@property (strong, nonatomic) NSURLSession *session;
@property (assign, nonatomic) NSInteger totalImageDownloadCount;
@property (assign, nonatomic) NSInteger totalImageWriteCount;
@property (assign, nonatomic) NSInteger totalImagesWrittenCount;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation IFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.totalImagesWrittenCount = 0;
    self.totalImageDownloadCount = 150;
    self.totalImageWriteCount = 5000;
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:nil
                                    failureBlock:nil];
}

- (void)addImagesToLibrary
{
    [self log:[NSString stringWithFormat:@"adding %li images to the library", (long)self.totalImageWriteCount]];
    
    for (NSInteger index = 0; index < self.totalImageWriteCount; index++) {
        UIImage *image = self.images[arc4random() % self.images.count];
        
        IFSavePhotoOperation *op = [[IFSavePhotoOperation alloc] initWithAssetsLibrary:self.assetsLibrary
                                                                                 image:image];
        op.delegate = self;
        [self.operationQueue addOperation:op];
    }
}

#pragma mark - <IFSavePhotoOperationDelegate>

- (void)didSavePhoto:(UIImage *)image
{
    self.totalImagesWrittenCount++;
    
    [self progress:self.totalImagesWrittenCount
                of:self.totalImageWriteCount];
    
    if (self.totalImagesWrittenCount == self.totalImageWriteCount) {
        if (self.createAlbumSwitch.on) {
            IFCreateAlbumsOperation *op = [[IFCreateAlbumsOperation alloc] initWithAssetsLibrary:self.assetsLibrary];
            op.delegate = self;
            [op start];
        } else {
            [self didCreateAlbums];
        }
    }
}

#pragma mark - <IFCreateAlbumsOperationDelegate>

- (void)didCreateAlbums
{
    [self log:@"complete!"];
}

#pragma mark - Private

- (void)log:(NSString *)log
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logMessage.text = log;
    });
}

- (void)progress:(NSInteger)progress
              of:(NSInteger)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (float)progress / (float)total;
    });
}

- (IBAction)loadImages:(id)sender
{
    [self log:@"loading images"];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.images = [NSMutableArray array];
    NSURL *tempURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    
    for (NSInteger index = 0; index < self.totalImageDownloadCount; index++) {
        NSInteger imageW = 400 + arc4random() % 400;
        NSInteger imageH = 400 + arc4random() % 200;
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lorempixel.com/%d/%d/?%i", imageW, imageH, arc4random() % self.totalImageDownloadCount]];
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

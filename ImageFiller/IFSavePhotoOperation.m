#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "IFSavePhotoOperation.h"

@interface IFSavePhotoOperation ()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDateFormatter *exifDateFormatter;
@end

@implementation IFSavePhotoOperation

#pragma mark - Initialization

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                                image:(UIImage *)image
{
    self = [super init];
	
    if (self) {
        self.assetsLibrary = assetsLibrary;
        self.image = image;
        
        self.exifDateFormatter = [[NSDateFormatter alloc] init];
        [self.exifDateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    }
	
    return self;
}

#pragma mark - Operation lifecycle

- (void)main
{
    if (!self.isCancelled) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(float)(arc4random() % (5 * 365 * 24 * 3600))];
        
        NSDictionary *exifData = @{(NSString *)kCGImagePropertyExifDateTimeOriginal: [self.exifDateFormatter stringFromDate:date]};
        NSDictionary *metadata = @{(NSString *)kCGImagePropertyExifDictionary: exifData};
        
        [self.assetsLibrary writeImageToSavedPhotosAlbum:self.image.CGImage
                                                metadata:metadata
                                         completionBlock:^(NSURL *assetURL, NSError *error) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.delegate didSavePhoto:self.image];
                                             });
                                         }];
    }
}

@end

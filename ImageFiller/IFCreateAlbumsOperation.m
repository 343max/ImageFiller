#import <AssetsLibrary/AssetsLibrary.h>
#import "IFCreateAlbumsOperation.h"

@interface IFCreateAlbumsOperation ()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@end

@implementation IFCreateAlbumsOperation

#pragma mark - Initialization

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
{
    self = [super init];
	
    if (self) {
        self.assetsLibrary = assetsLibrary;
    }
	
    return self;
}

#pragma mark - Operation lifecycle

- (void)main
{
	if (!self.isCancelled) {
        __block NSMutableArray *arrayOfAssets = @[].mutableCopy;
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                          usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                              [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                  if (result) {
                                                      [arrayOfAssets addObject:result];
                                                  }
                                              }];
                                              
                                              for (NSInteger i = 0; i < 16; i++) {
                                                  [self.assetsLibrary addAssetsGroupAlbumWithName:[NSString stringWithFormat:@"Album %d", i]
                                                                                      resultBlock:^(ALAssetsGroup *group) {
                                                                                          for (NSInteger j = 0; j < arc4random() % arrayOfAssets.count; j++) {
                                                                                              [group addAsset:arrayOfAssets[arc4random() % arrayOfAssets.count]];
                                                                                          }
                                                                                      }
                                                                                     failureBlock:nil];
                                              }
                                              
                                              [self.delegate didCreateAlbums];
                                          } failureBlock:nil];
        
	}
}

@end

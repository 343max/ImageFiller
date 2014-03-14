#import <Foundation/Foundation.h>

@class IFSavePhotoOperation;
	
@protocol IFSavePhotoOperationDelegate <NSObject>
@required
- (void)didSavePhoto:(UIImage *)image;
@end

@interface IFSavePhotoOperation : NSOperation

@property (nonatomic, weak) id<IFSavePhotoOperationDelegate>delegate;

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                                image:(UIImage *)image;

@end

#import <Foundation/Foundation.h>

@class IFCreateAlbumsOperation;
	
@protocol IFCreateAlbumsOperationDelegate <NSObject>
@required
- (void)didCreateAlbums;
@end

@interface IFCreateAlbumsOperation : NSOperation

@property (nonatomic, weak) id<IFCreateAlbumsOperationDelegate>delegate;

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;

@end

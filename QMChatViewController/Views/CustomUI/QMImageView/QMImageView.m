//
//  QMImageView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIImage+Cropper.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+WebCache.h"

#import "QMImageLoader.h"

static NSString * const kQMImageViewLoadOperationKey = @"UIImageViewImageLoad";

@interface QMImageView()

@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) CAShapeLayer *mask;

@end

@implementation QMImageView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    
    self = [super initWithImage:image];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (void)dealloc {
    
    [self sd_cancelCurrentImageLoad];
}

- (void)configure {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    
    self.layer.borderWidth = self.borderWidth;
    
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
    self.userInteractionEnabled = YES;
    
    _mask = [[CAShapeLayer alloc] init];
    _mask.rasterizationScale = [UIScreen mainScreen].scale;
    _mask.shouldRasterize = YES;
    
    // Make a circular shape
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:MAX(self.frame.size.width, self.frame.size.height)];
    
    _mask.path = circularPath.CGPath;
    self.layer.mask = _mask;
}

- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDWebImageCompletionBlock)completedBlock  {
    
    [self sd_cancelCurrentImageLoad];
    
    self.url = url;
    
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        self.image = placehoder;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    id <SDWebImageOperation> operation =
    [[QMImageLoader sharedManager]
     downloadImageWithURL:url
     options:options
     progress:progress
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
         
         __typeof(weakSelf)strongSelf = weakSelf;
         
         dispatch_main_sync_safe(^{
             
             if (!error) {
                 
                 strongSelf.image = image;
                 [strongSelf setNeedsLayout];
             }
             else {
                 
                 if ((options & SDWebImageDelayPlaceholder)) {
                     
                     strongSelf.image = placehoder;
                     [strongSelf setNeedsLayout];
                 }
             }
             
             if (completedBlock) {
                 
                 completedBlock(image, error, cacheType, imageURL);
             }
         });
         
     }];
    
    [self sd_setImageLoadOperation:operation forKey:kQMImageViewLoadOperationKey];
}

- (UIImage *)transformImage:(UIImage *)image {
    
    //    if (self.imageViewType == QMImageViewTypeSquare) {
    //
    //        return [image imageByScaleAndCrop:self.frame.size];
    //    }
    //    else if (self.imageViewType == QMImageViewTypeCircle) {
    //
    //        if (image.size.height > image.size.width
    //            || image.size.width > image.size.height) {
    //            // if image is not square it will be disorted
    //            // making it a square-image first
    //            image = [image imageByScaleAndCrop:self.frame.size];
    //        }
    //
    //        return [image imageByCircularScaleAndCrop:self.frame.size];
    //    }
    //    else {
    //
    //        return image;
    //    }
    return nil;
}

- (void)clearImage {
    
    self.image = nil;
    self.url = nil;
}

- (void)setImage:(UIImage *)image withKey:(NSString *)key {
    
//    [QMImageLoader cachedImageForKey:key completion:^(UIImage *cachedImage, SDImageCacheType cacheType) {
//        
//        if (cachedImage != nil) {
//            
//            self.image = cachedImage;
//        }
//        else {
//            
//            [self applyImage:image];
//            [QMImageLoader storeImage:image forKey:key];
//        }
//    }];
}

- (void)applyImage:(UIImage *)image {
    
    UIImage *img = [self transformImage:image];
    self.image = img;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.delegate respondsToSelector:@selector(imageViewDidTap:)]) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.layer.opacity = 0.6;
            
        } completion:^(BOOL finished) {
            
            self.layer.opacity = 1;
            
            [self.delegate imageViewDidTap:self];
        }];
    }
}

@end

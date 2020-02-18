

// #import "OpenCVUtils.hpp"
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>

@interface YatzyGridDetector : NSObject

- (instancetype)init;

- (void)onYatzyGridDetected:(UIImage *)image
                 completion:(void (^)(NSArray *result, NSError *error))callback;

@end

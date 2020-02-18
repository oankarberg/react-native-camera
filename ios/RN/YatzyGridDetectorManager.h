
@interface YatzyGridDetectorManager : NSObject
typedef void (^postRecognitionBlock)(NSArray *results);

typedef void (^postRecognitionToRNCamera)(NSString *base64Image,
                                          NSArray *yatzyGrid,
                                          NSDictionary *error);
- (instancetype)init;

- (BOOL)isRealDetector;
- (void)findYatzyGridInFrame:(UIImage *)image
                      scaleX:(float)scaleX
                      scaleY:(float)scaleY
                   completed:(postRecognitionToRNCamera)completed;

@end

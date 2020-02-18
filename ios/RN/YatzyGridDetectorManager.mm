#import "YatzyGridDetectorManager.h"
#import "../../../../ios/OpenCV/YatzyGridDetector.h"
// #import "YatzyGridDetector.h"

@interface YatzyGridDetectorManager ()
@property(nonatomic, strong) YatzyGridDetector *yatzyGridDetector;
@property(nonatomic, assign) float scaleX;
@property(nonatomic, assign) float scaleY;
@end

@implementation YatzyGridDetectorManager

- (instancetype)init {
  if (self = [super init]) {
    self.yatzyGridDetector = [[YatzyGridDetector alloc] init];
  }
  return self;
}

- (BOOL)isRealDetector {
  return true;
}

- (void)findYatzyGridInFrame:(UIImage *)uiImage
                      scaleX:(float)scaleX
                      scaleY:(float)scaleY
                   completed:(postRecognitionToRNCamera)completed {
  self.scaleX = scaleX;
  self.scaleY = scaleY;
  NSMutableArray *textBlocks = [[NSMutableArray alloc] init];
  [_yatzyGridDetector
      onYatzyGridDetected:uiImage
               completion:^(NSArray *result) {
                 NSDictionary *error = result[0];
                 // If the error is not null, pass error
                 if (![error isEqual:[NSNull null]] || result == nil) {
                   NSString *base64Image = result[1];
                   completed(base64Image, @[], error);
                 } else {
                   NSArray *parameters = result[1];
                   NSString *base64Image = parameters[0];
                   NSArray *yatzyGridArray = parameters[1];
                   //  completed([self
                   //  processBlocks:result.blocks]);
                   completed(base64Image, yatzyGridArray, error);
                 }
               }];
}

// - (NSArray *)processBlocks:(NSArray *)features {
//   NSMutableArray *textBlocks = [[NSMutableArray alloc] init];
//   for (FIRVisionTextBlock *textBlock in features) {
//     NSDictionary *textBlockDict = @{
//       @"type" : @"block",
//       @"value" : textBlock.text,
//       @"bounds" : [self processBounds:textBlock.frame],
//       @"components" : [self processLine:textBlock.lines]
//     };
//     [textBlocks addObject:textBlockDict];
//   }
//   return textBlocks;
// }

// - (NSArray *)processLine:(NSArray *)lines {
//   NSMutableArray *lineBlocks = [[NSMutableArray alloc] init];
//   for (FIRVisionTextLine *textLine in lines) {
//     NSDictionary *textLineDict = @{
//       @"type" : @"line",
//       @"value" : textLine.text,
//       @"bounds" : [self processBounds:textLine.frame],
//       @"components" : [self processElement:textLine.elements]
//     };
//     [lineBlocks addObject:textLineDict];
//   }
//   return lineBlocks;
// }

// - (NSArray *)processElement:(NSArray *)elements {
//   NSMutableArray *elementBlocks = [[NSMutableArray alloc] init];
//   for (FIRVisionTextElement *textElement in elements) {
//     NSDictionary *textElementDict = @{
//       @"type" : @"element",
//       @"value" : textElement.text,
//       @"bounds" : [self processBounds:textElement.frame]
//     };
//     [elementBlocks addObject:textElementDict];
//   }
//   return elementBlocks;
// }

// - (NSDictionary *)processBounds:(CGRect)bounds {
//   float width = bounds.size.width * _scaleX;
//   float height = bounds.size.height * _scaleY;
//   float originX = bounds.origin.x * _scaleX;
//   float originY = bounds.origin.y * _scaleY;
//   NSDictionary *boundsDict = @{
//     @"size" : @{@"width" : @(width), @"height" : @(height)},
//     @"origin" : @{@"x" : @(originX), @"y" : @(originY)}
//   };
//   return boundsDict;
// }

@end
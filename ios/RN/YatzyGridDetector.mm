//#import "YatzyGridDetector.h"
//#import "Firebase/Firebase.h"
//#import <React/RCTLog.h>
//using namespace std;
//using namespace cv;
//
//
//@implementation YatzyGridDetector
//
//cv::RNG rng(12345);
//struct Prediction {
//  cv::Rect boundingRect;
//  int number;
//  float prob;
//};
//
//struct _GridItem {
//  cv::Rect boundingRect;
//  vector<Prediction> numbers;
//  int area;
//  vector<cv::Point> contours;
//};
//typedef struct _GridItem GridItem;
//
//typedef struct {
//  float real;
//  float imaginary;
//} ImaginaryNumber;
//
//// CUSTOM METHODS
//- (instancetype)init {
//    if (self = [super init]) {
//        // Initialize self
//    }
//    return self;
//}
//- (void) onYatzyGridDetected: (UIImage *) image
//                    callback: (void (^)(NSArray *result, NSDictionary  *_Nullable error)) callback {
//
//  [self processImage:image
//      completion:^(NSString *base64Str, vector<GridItem> grid) {
//        id vecOfVertex = [NSMutableArray new];
//
//        for (auto point : grid) {
//          NSMutableArray *numbersArray = [[NSMutableArray alloc] init];
//
//          for (auto prediction : point.numbers) {
//            [numbersArray addObject:[NSNumber numberWithInt:prediction.number]];
//            [numbersArray addObject:[NSNumber numberWithFloat:prediction.prob]];
//          }
//
//          [vecOfVertex addObject:numbersArray];
//        }
//        NSArray *sendToReactNative = [NSArray arrayWithArray:vecOfVertex];
//        NSArray *parameters = @[ base64Str, sendToReactNative ];
//    NSDictionary *error;
//        callback(@[ [NSNull null], parameters ],error);
//      }
//      completionError:^(NSDictionary *error, NSString *base64) {
//        callback(@[ base64 ], error);
//      }];
//}
//
//- (cv::Mat)convertUIImageToCVMat:(UIImage *)image {
//  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
//  CGFloat cols = image.size.width;
//  CGFloat rows = image.size.height;
//
//  cv::Mat cvMat(
//      rows, cols,
//      CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
//
//  CGContextRef contextRef =
//      CGBitmapContextCreate(cvMat.data,    // Pointer to  data
//                            cols,          // Width of bitmap
//                            rows,          // Height of bitmap
//                            8,             // Bits per component
//                            cvMat.step[0], // Bytes per row
//                            colorSpace,    // Colorspace
//                            kCGImageAlphaNoneSkipLast |
//                                kCGBitmapByteOrderDefault); // Bitmap info flags
//
//  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//  CGContextRelease(contextRef);
//
//  return cvMat;
//}
//
//- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
//  NSData *data = [[NSData alloc]
//      initWithBase64EncodedString:strEncodeData
//                          options:NSDataBase64DecodingIgnoreUnknownCharacters];
//  return [UIImage imageWithData:data];
//}
//
//bool compareArea(GridItem &i1, GridItem &i2) { return (i1.area < i2.area); }
//
//bool sortUpperLeftposition(GridItem &i1, GridItem &i2) {
//  int offsetXpositive = i2.boundingRect.x + i2.boundingRect.width / 3;
//  int offsetXnegative = i2.boundingRect.x - i2.boundingRect.width / 3;
//  int sameColumn = i1.boundingRect.x < offsetXpositive &&
//                   i1.boundingRect.x > offsetXnegative;
//  if (sameColumn) {
//    return i1.boundingRect.y < i2.boundingRect.y;
//  };
//  return (i1.boundingRect.x < offsetXpositive);
//}
//
//bool sortByXPos(Prediction &i1, Prediction &i2) {
//  return i1.boundingRect.x < i2.boundingRect.x;
//}
//
//// tests if angle abc is a right angle
//bool isOrthogonal(cv::Rect a, cv::Rect b, cv::Rect c) {
//  int offsetOK = 40;
//  int bXaX = min(offsetOK - abs(b.x - a.x), 0);
//  int bXcX = min(offsetOK - abs(b.x - c.x), 0);
//  int bYaY = min(offsetOK - abs(b.y - a.y), 0);
//  int bYcY = min(offsetOK - abs(b.y - c.y), 0);
//  return bXaX * bXcX + bYaY * bYcY == 0;
//}
//
//bool isRectangle(cv::Rect a, cv::Rect b, cv::Rect c, cv::Rect d) {
//  return isOrthogonal(a, b, c) && isOrthogonal(b, c, d) &&
//         isOrthogonal(c, d, a);
//}
//
//bool isGridRectangle(GridItem a, GridItem b, GridItem c, GridItem d) {
//  return isRectangle(a.boundingRect, b.boundingRect, c.boundingRect,
//                     d.boundingRect);
//}
//
//- (nullable GridItem *)findGridItem:(vector<GridItem> &)yatzyGrid
//                              point:(cv::Point)point {
//  GridItem *item;
//  for (int i = 0; i < yatzyGrid.size(); i++) {
//    item = &yatzyGrid[i];
//    if (item->boundingRect.contains(point)) {
//      return item;
//    }
//  }
//  return nullptr;
//}
//
//- (void)processImage:(UIImage *)image
//          completion:(void (^)(NSString *, vector<GridItem>))handler
//     completionError:(void (^)(NSDictionary *, NSString *))handlerError {
//
//  // - (NSString *)processImage:(UIImage *)image {
//  void (^_completionHandler)(NSString *someParameter, vector<GridItem> grid);
//  void (^_completionErrorHandler)(NSDictionary *someParameter,
//                                  NSString *baseImage64);
//  // NOTE: copying is very important if you'll call the callback asynchronously,
//  // even with garbage collection!
//  _completionHandler = [handler copy];
//  _completionErrorHandler = [handlerError copy];
//
//  // READ THE NUMBER CLASSIFIER
//  NSString *modelPath =
//      [NSBundle.mainBundle pathForResource:@"predict_number_model"
//                                    ofType:@"tflite"];
//  //                                                 inDirectory:@"OpenCV"];
//
//  FIRCustomLocalModel *localModel =
//      [[FIRCustomLocalModel alloc] initWithModelPath:modelPath];
//
//  FIRModelInterpreter *interpreter =
//      [FIRModelInterpreter modelInterpreterForLocalModel:localModel];
//
//  // READ THE DISCRIMINATOR "YES" / "NO" FOR COUNTOURS
//  // The model predicts numbers -1 to 1 , negative for non numbers and positive
//  // for numbers
//  NSString *discriminatorModelPath =
//      [NSBundle.mainBundle pathForResource:@"discriminator_model"
//                                    ofType:@"tflite"];
//  //                                                 inDirectory:@"OpenCV"];
//
//  FIRCustomLocalModel *localDiscModel =
//      [[FIRCustomLocalModel alloc] initWithModelPath:discriminatorModelPath];
//
//  FIRModelInterpreter *discriminatorInterpreter =
//      [FIRModelInterpreter modelInterpreterForLocalModel:localDiscModel];
//
//  // converting UIImage to OpenCV format - Mat
//  image = [UIImage imageWithCGImage:[image CGImage]
//                              scale:[image scale]
//                        orientation:UIImageOrientationUp];
//  cv::Mat matImage;
//
//  //  UIImageToMat(image,matImage);
//  matImage = [self convertUIImageToCVMat:image];
//  //   cv::rotate(matImage, matImage, cv::ROTATE_90_CLOCKWISE);
//  float ratio = matImage.rows / matImage.cols;
//  float ratioHeight = 1000.f / matImage.rows;
//  cv::resize(matImage, matImage,
//             cv::Size(matImage.cols * ratioHeight, ratioHeight * matImage.rows),
//             0, 0, CV_INTER_LINEAR);
//  cv::Mat matImageGrey;
//
//  // converting image's color space (RGB) to grayscale
//  cv::cvtColor(matImage, matImageGrey, CV_BGR2GRAY);
//  vector<vector<cv::Point>> contours;
//  vector<cv::Vec4i> hierarchy;
//
//  cv::GaussianBlur(matImageGrey, matImageGrey, cv::Size(5, 5), 0);
//  //  cv::threshold(matImageGrey, matImageGrey, 0, 255,
//  //                CV_THRESH_BINARY_INV + CV_THRESH_OTSU);
//
//  cv::adaptiveThreshold(matImageGrey, matImageGrey, 255,
//                        ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 7, 4);
//
//  cv::Mat foundNumbers =
//      cv::Mat::ones(matImageGrey.rows, matImageGrey.cols, matImageGrey.type());
//
//  foundNumbers.setTo(cv::Scalar(255, 255, 255));
//
//  //  // Dilate Shit to fill up holes and make grid more visible
//  Mat gridFinder = matImageGrey.clone();
//
//  //  Mat elementErode = getStructuringElement(MORPH_RECT, cv::Size(7, 3));
//  //  cv::morphologyEx(gridFinder, gridFinder, MORPH_DILATE, elementErode);
//  //
//  //  Mat gridFinderHorizontal = gridFinder.clone();
//  //  Mat gridFinderVertical = gridFinder.clone();
//  //  Mat element =
//  //      getStructuringElement(MORPH_RECT, cv::Size(5 * dilation_size + 1, 1));
//  //
//  //  cv::morphologyEx(gridFinderHorizontal, gridFinderHorizontal, MORPH_ERODE,
//  //                   element);
//  //  cv::morphologyEx(gridFinderHorizontal, gridFinderHorizontal, MORPH_DILATE,
//  //                   element);
//  //
//  //  Mat elementVer =
//  //      getStructuringElement(MORPH_RECT, cv::Size(1, 5 * dilation_size + 1));
//  //
//  //  cv::morphologyEx(gridFinderVertical, gridFinderVertical, MORPH_ERODE,
//  //                   elementVer);
//  //  cv::morphologyEx(gridFinderVertical, gridFinderVertical, MORPH_DILATE,
//  //                   elementVer);
//  //
//  //  cv::add(gridFinderVertical, gridFinderHorizontal, gridFinder);
//
//  vector<vector<cv::Point>> gridContours;
//  vector<cv::Vec4i> gridHierarchy;
//  cv::findContours(gridFinder, gridContours, gridHierarchy, CV_RETR_EXTERNAL,
//                   CV_CHAIN_APPROX_NONE);
//
//  // No Grid found
//  if (gridContours.size() < 1) {
//    // RETURN WITH ERROR!
//    NSDictionary *dict =
//        @{@"error_code" : @"2", @"message" : @"No grid contours found! "};
//    UIImage *imageToSave = MatToUIImage(matImage);
//    NSData *imageData = UIImagePNGRepresentation(imageToSave);
//    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
//    return _completionErrorHandler(dict, base64String);
//  }
//
//  // sort contours
//  std::sort(gridContours.begin(), gridContours.end(), compareContourAreas);
//
//  // grab contours
//  std::vector<cv::Point> biggestContour = gridContours[gridContours.size() - 1];
//  std::vector<cv::Point> smallestContour = gridContours[0];
//
//  cv::RotatedRect biggestRect = cv::minAreaRect(biggestContour);
//  cv::Point2f srcPoints[4];
//
//  biggestRect.points(srcPoints);
//
//  int padding = 20;
//  int paddedHeight = biggestRect.size.height + padding;
//  int paddedWidth = biggestRect.size.width + padding;
//  // Pad the contour to not miss out on any grid :)
//  biggestRect.size.width = paddedWidth;
//  biggestRect.size.height = paddedHeight;
//
//  // Invert width and height if the image is wider than higher...
//  if (paddedWidth > paddedHeight) {
//    int prevHeight = paddedHeight;
//    paddedHeight = paddedWidth;
//    paddedWidth = prevHeight;
//    biggestRect.size.width = paddedWidth;
//    biggestRect.size.height = paddedHeight;
//    biggestRect.angle += 90;
//  }
//
//  biggestRect.points(srcPoints);
//
//  cv::Point2f dstPoints[4];
//  // Bottom left, top left, top right, bottom right
//  dstPoints[0] = Point2f(0, paddedHeight - 1);
//  dstPoints[1] = Point2f(0, 0);
//  dstPoints[2] = Point2f(paddedWidth - 1, 0);
//  dstPoints[3] = Point2f(paddedWidth - 1, paddedHeight - 1);
//
//  cv::Mat M = cv::getPerspectiveTransform(srcPoints, dstPoints);
//  cv::warpPerspective(matImageGrey, matImageGrey, M, biggestRect.size);
//  cv::warpPerspective(matImage, matImage, M, biggestRect.size);
//  cv::warpPerspective(gridFinder, gridFinder, M, biggestRect.size);
//
//  //  cv::Rect biggestRect = cv::boundingRect(biggestContour);
//
//  // Use mask
//  //  matImageGrey = matImageGrey(biggestRect).clone();
//  //  matImage = matImage(biggestRect).clone();
//  //  gridFinder = gridFinder(biggestRect).clone();
//
//  //  // Dilate Shit to fill up holes and make grid more visible
//  int dilation_size = int(biggestRect.size.width / 3.0);
//  //  # FILL IN THE BAD LINES IN THE GRID
//  Mat kernel = getStructuringElement(MORPH_RECT, cv::Size(5, 5));
//  cv::morphologyEx(gridFinder, gridFinder, MORPH_CLOSE, kernel);
//
//  //  # DIVIDE INTO HORIZONTAL LINES
//  Mat gridFinderHorizontal = gridFinder.clone();
//  Mat gridFinderVertical = gridFinder.clone();
//
//  //  # TRY TO REMOVE ALL VERTICAL STUFF IN THE IMAGE,
//  //  # OPENING: ALL FOREGROUND PIXELS(white) that can fit the structelement
//  //  will be white, else black
//  kernel = getStructuringElement(MORPH_RECT, cv::Size(dilation_size, 1));
//  cv::morphologyEx(gridFinderHorizontal, gridFinderHorizontal, MORPH_OPEN,
//                   kernel);
//  // Make it thicker!! ....
//  //  kernel = getStructuringElement(MORPH_RECT, cv::Size(4 , 4));
//  //  cv::morphologyEx(gridFinderHorizontal, gridFinderHorizontal, MORPH_DILATE,
//  //  kernel);
//
//  //  # TRY TO REMOVE ALL HORIZONTAL STUFF IN IMAGE
//  kernel = getStructuringElement(MORPH_RECT, cv::Size(1, dilation_size));
//  cv::morphologyEx(gridFinderVertical, gridFinderVertical, MORPH_OPEN, kernel);
//  // Make it thicker!! ....
//  //  kernel = getStructuringElement(MORPH_RECT, cv::Size(4 , 4));
//  //  cv::morphologyEx(gridFinderVertical, gridFinderVertical, MORPH_DILATE,
//  //  kernel);
//
//  add(gridFinderVertical, gridFinderHorizontal, gridFinder);
//
//  // Standard Hough Line Transform
//  Mat lineDrawer = cv::Mat::zeros(gridFinder.size(), gridFinder.type());
//  Mat matImageLine = matImage.clone();
//  vector<Vec2f> lines; // will hold the results of the detection
//  int pointLength = int(biggestRect.size.width / 4.0);
//  cv::HoughLines(gridFinder, lines, 1, CV_PI / 4, pointLength, 0,
//                 0); // runs the actual detection
//  // Draw the lines
//  for (size_t i = 0; i < lines.size(); i++) {
//    float rho = lines[i][0], theta = lines[i][1];
//    int degrees = int(theta * 180.0 / CV_PI);
//    // Skip lines that are not vertical or horizontal. A bit hacky, Want to deal
//    // with this in Houghlines tranform instead
//    if (degrees != 90 && degrees != 0) {
//      continue;
//    }
//    cv::Point pt1, pt2;
//    double a = cos(theta), b = sin(theta);
//    double x0 = a * rho, y0 = b * rho;
//    pt1.x = cvRound(x0 + 1000 * (-b));
//    pt1.y = cvRound(y0 + 1000 * (a));
//    pt2.x = cvRound(x0 - 1000 * (-b));
//    pt2.y = cvRound(y0 - 1000 * (a));
//    line(matImageLine, pt1, pt2, Scalar(255, 255, 255, 255), 2, LINE_AA);
//    line(lineDrawer, pt1, pt2, Scalar(255, 255, 255, 255), 2, LINE_AA);
//  }
//
//  cv::findContours(lineDrawer, gridContours, gridHierarchy, CV_RETR_LIST,
//                   CV_CHAIN_APPROX_NONE);
//
//  // TRANSFORM TO COLOR AGAIN
//  //  cv::cvtColor(gridFinder,gridFinder,COLOR_GRAY2BGR);
//
//  __block vector<GridItem> yatzyGrid;
//
//  int gridMinSize = matImage.size().height / 50 * (matImage.size().width / 50);
//
//  for (int i = 0; i < gridContours.size(); i++) {
//    vector<cv::Point> cnt = gridContours[i];
//    int area = cv::contourArea(cnt);
//
//    if (area < gridMinSize) {
//      continue;
//    }
//    //    if(gridHierarchy[i][3] == -1){
//    //      continue;
//    //    }
//    vector<cv::Point> approx;
//    cv::convexHull(cnt, approx);
//    // 0.02 * cv::arcLength(approx, true),
//    cv::approxPolyDP(approx, approx, 0.02 * cv::arcLength(approx, true), true);
//    //    if (approx.size() != 4) {
//    //      continue;
//    //    }
//    GridItem gridItem;
//    gridItem.boundingRect = cv::boundingRect(approx);
//    gridItem.area = cv::contourArea(approx);
//    gridItem.contours = approx;
//
//    Scalar color = cv::Scalar(255, 255, 255, 255);
//    cv::rectangle(gridFinder, gridItem.boundingRect, color, 3);
//    if (gridItem.boundingRect.y >= 0 && gridItem.boundingRect.x >= 0)
//      yatzyGrid.push_back(gridItem);
//  }
//
//  // sorts vector in increasing order of their area
//  std::sort(yatzyGrid.begin(), yatzyGrid.end(), compareArea);
//  if (yatzyGrid.size() < 2) {
//    // RETURN WITH ERROR!
//    NSDictionary *dict =
//        @{@"error_code" : @"1", @"message" : @"Could not find enough "};
//    UIImage *imageToSave = MatToUIImage(matImageLine);
//    NSData *imageData = UIImagePNGRepresentation(imageToSave);
//    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
//    return _completionErrorHandler(dict, base64String);
//  }
//
//  int medianArea = yatzyGrid[yatzyGrid.size() / 2].area;
//  int offsetUpper = medianArea + medianArea * 0.3;
//  int offsetLower = medianArea - medianArea * 0.3;
//
//  // assuming `v` is the vector
//  auto w = yatzyGrid.begin();
//  int gridTopY = 9999999;
//  int totHeight = 0;
//  vector<cv::Point> boundingBoxespoints;
//  for (auto r = w, e = yatzyGrid.end(); r != e; ++r) {
//    int rectangleRatio = max(r->boundingRect.width, r->boundingRect.height) /
//                         min(r->boundingRect.width, r->boundingRect.height);
//    // If we' should keep! :)
//    if (offsetUpper > r->area && offsetLower < r->area && rectangleRatio <= 3) {
//      if (gridTopY > r->boundingRect.y) {
//        gridTopY = r->boundingRect.y;
//      }
//      // Insert all contours in one big! ...
//      boundingBoxespoints.insert(boundingBoxespoints.end(), r->contours.begin(),
//                                 r->contours.end());
//      totHeight += r->boundingRect.y;
//      if (r != w) {
//        *w = std::move(*r);
//      }
//      ++w;
//    }
//  }
//  //  int goodAverageYHeight = totHeight / max(yatzyGrid.size(),1);
//  yatzyGrid.erase(w, yatzyGrid.end()); // truncate
//
//  std::sort(yatzyGrid.begin(), yatzyGrid.end(), sortUpperLeftposition);
//
//  cv::Rect gridBoundingBox = cv::boundingRect(boundingBoxespoints);
//
//  // Shrink area to inside grid! :)
//  matImage = matImage(gridBoundingBox).clone();
//  gridFinder = gridFinder(gridBoundingBox).clone();
//  matImageGrey = matImageGrey(gridBoundingBox).clone();
//
//  int NUM_ROW_IN_GRID = 19;
//  int index = 0;
//
//  //  // Populate with fake cell if could not find the contour of cell
//  //  for (auto it = yatzyGrid.begin(); it != yatzyGrid.end(); ++it) {
//  //    auto nextGridItem = std::next(it, 1);
//  //
//  //    index++;
//  //    int pivot = index % NUM_ROW_IN_GRID;
//  //    // if we reach the end of the column. skip this iteration. index starts
//  //    at 1 if (pivot == 0) {
//  //      continue;
//  //    }
//  //    GridItem currGridItem = *it;
//  //    // Check if there is a gridItem with y closer to the top.
//  //    if (pivot == 1 && index + NUM_ROW_IN_GRID < yatzyGrid.size()) {
//  ////      auto gItem = yatzyGrid[index + NUM_ROW_IN_GRID - 1];
//  //      // Smaller y coord is above this item
//  //      //      bool aboveCurrentItem = ((gItem.boundingRect.y +
//  //      //      gItem.boundingRect.height) < currGridItem.boundingRect.y);
//  //      bool aboveCurrentItem = ((gridTopY + currGridItem.boundingRect.height)
//  //      <
//  //                               currGridItem.boundingRect.y);
//  //
//  //      if (aboveCurrentItem) {
//  //        // insert above the current Cell
//  //        GridItem fakeCell;
//  //        fakeCell.boundingRect = cv::boundingRect(cv::Mat());
//  //        fakeCell.boundingRect.x = currGridItem.boundingRect.x;
//  //        fakeCell.boundingRect.y = min(currGridItem.boundingRect.y -
//  //                                  currGridItem.boundingRect.height,gridFinder.rows)
//  //                                  ;
//  //        fakeCell.boundingRect.width = currGridItem.boundingRect.width;
//  //        fakeCell.boundingRect.height = currGridItem.boundingRect.height;
//  //        fakeCell.area =
//  //            fakeCell.boundingRect.width * fakeCell.boundingRect.height;
//  //        yatzyGrid.insert(it, fakeCell);
//  //        continue;
//  //      }
//  //    }
//  //
//  //    // If the y-space between this gridItem and the next is larger than
//  //    height *
//  //    // 2, we create a fake griditem
//  //    if (index < yatzyGrid.size() &&  nextGridItem->boundingRect.y >
//  //        currGridItem.boundingRect.y + currGridItem.boundingRect.height * 2)
//  //        {
//  //      // Create artifical cell
//  //      GridItem fakeCell;
//  //      fakeCell.boundingRect = cv::boundingRect(cv::Mat());
//  //      fakeCell.boundingRect.x = currGridItem.boundingRect.x;
//  //      fakeCell.boundingRect.y =
//  //          abs(currGridItem.boundingRect.y +
//  //          currGridItem.boundingRect.height);
//  //      fakeCell.boundingRect.width = currGridItem.boundingRect.width;
//  //      fakeCell.boundingRect.height = currGridItem.boundingRect.height;
//  //      fakeCell.area =
//  //          fakeCell.boundingRect.width * fakeCell.boundingRect.height;
//  //      yatzyGrid.insert(yatzyGrid.begin() + index, fakeCell);
//  //    }
//  //  }
//  bool correctNumGrid = yatzyGrid.size() > NUM_ROW_IN_GRID &&
//                        yatzyGrid.size() % NUM_ROW_IN_GRID == 0;
//  if (!correctNumGrid) {
//    // RETURN WITH ERROR!
//    NSDictionary *dict =
//        @{@"error_code" : @"1", @"message" : @"Not enough cells found"};
//    UIImage *imageToSave = MatToUIImage(matImageLine);
//    NSData *imageData = UIImagePNGRepresentation(imageToSave);
//    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
//    return _completionErrorHandler(dict, base64String);
//  }
//  GridItem gA = yatzyGrid[0];
//  GridItem gB = yatzyGrid[yatzyGrid.size() - NUM_ROW_IN_GRID];
//  GridItem gC = yatzyGrid[yatzyGrid.size() - 1];
//  GridItem gD = yatzyGrid[NUM_ROW_IN_GRID - 1];
//
//  if (!isGridRectangle(gA, gB, gC, gD)) {
//    // RETURN WITH ERROR!
//    NSDictionary *dict =
//        @{@"error_code" : @"1", @"message" : @"Grid not a rectangle"};
//    UIImage *imageToSave = MatToUIImage(matImageLine);
//    NSData *imageData = UIImagePNGRepresentation(imageToSave);
//    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
//    return _completionErrorHandler(dict, base64String);
//  }
//
//  double matGreyRatioHeight = 1000.0f / matImage.rows;
//  cv::resize(matImage, matImage,
//             cv::Size(matImage.cols * matGreyRatioHeight,
//                      matGreyRatioHeight * matImage.rows),
//             0, 0, CV_INTER_LINEAR);
//
//  cv::resize(matImageGrey, matImageGrey,
//             cv::Size(matImageGrey.cols * matGreyRatioHeight,
//                      matGreyRatioHeight * matImageGrey.rows),
//             0, 0, CV_INTER_LINEAR);
//
//  cv::resize(gridFinder, gridFinder,
//             cv::Size(gridFinder.cols * matGreyRatioHeight,
//                      matGreyRatioHeight * gridFinder.rows),
//             0, 0, CV_INTER_LINEAR);
//
//  matImageGrey = cv::Mat::zeros(matImageGrey.size(), matImageGrey.type());
//  // converting image's color space (RGB) to grayscale
//  cv::cvtColor(matImage, matImageGrey, CV_BGR2GRAY);
//  cv::medianBlur(matImageGrey, matImageGrey, 5);
//  cv::adaptiveThreshold(matImageGrey, matImageGrey, 255,
//                        ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 21, 10);
//
//  int offsetBoundingX = yatzyGrid[0].boundingRect.x * matGreyRatioHeight;
//  int offsetBoundingY = yatzyGrid[0].boundingRect.y * matGreyRatioHeight;
//
//  // Draw rectangles of the found grid
//  for (int i = 0; i < yatzyGrid.size(); i++) {
//    GridItem &gridItem = yatzyGrid[i];
//    gridItem.boundingRect.x *= matGreyRatioHeight;
//    gridItem.boundingRect.y *= matGreyRatioHeight;
//    gridItem.boundingRect.height *= matGreyRatioHeight;
//    gridItem.boundingRect.width *= matGreyRatioHeight;
//    // THIS IS BECAUSE WE NEED TO SHIFT EVERYTHING TO TOP LEFT CORNER!!! :)
//    // .....
//    gridItem.boundingRect.x -= offsetBoundingX;
//    gridItem.boundingRect.y -= offsetBoundingY;
//
//    Scalar color = cv::Scalar((i * 255) / yatzyGrid.size(), 0, 0, 255);
//    cv::rectangle(matImage, gridItem.boundingRect, color, 3);
//  }
//
//  //  cv::threshold(matImageGrey, matImageGrey, 127, 255,
//  //                  CV_THRESH_BINARY_INV + CV_THRESH_OTSU);
//
//  // Invert grid
//  gridFinder = ~gridFinder;
//  gridFinder.convertTo(gridFinder, CV_8U);
//  matImageGrey.convertTo(matImageGrey, CV_8U);
//
//  Mat maskedGreyImage = cv::Mat::zeros(gridFinder.size(), gridFinder.type());
//  matImageGrey.copyTo(maskedGreyImage, gridFinder);
//  matImageGrey = maskedGreyImage;
//  //  cv::bitwise_and(matImageGrey, matImageGrey,matImageGrey,gridFinder);
//
//  Mat element = getStructuringElement(MORPH_RECT, cv::Size(2, 2));
//
//  cv::morphologyEx(matImageGrey, matImageGrey, MORPH_ERODE, element);
//
//  cv::findContours(matImageGrey, contours, hierarchy, CV_RETR_CCOMP,
//                   CV_CHAIN_APPROX_SIMPLE);
//  int borderType = cv::BORDER_CONSTANT;
//  RCTLog(@"Hello findContours %lu", contours.size());
//  int letterMinHeight = yatzyGrid[0].boundingRect.height / 2;
//
//  int numInputs = 0;
//  NSMutableArray *allRoiData = [NSMutableArray array];
//  NSMutableArray *allPoints = [[NSMutableArray alloc] initWithCapacity:40];
//  __block int numPreds = contours.size();
//  __block int completedPredictions = 0;
//  __block std::vector<Prediction> boundingRects;
//  NSArray *arrayWithPoints = @[ @"1", @"2" ];
//
//  for (int i = 0; i < contours.size(); i++) {
//    vector<cv::Point> cnt = contours[i];
//
//    // Filtered countours are detected
//    //  x,y,w, h
//    __block cv::Rect boundingRect = cv::boundingRect(cnt);
//
//    //     // Check the area of contour, if it is very small ignore it
//    // Skip contours that does not have any child level, i.e the holes of the
//    // contours.
//    if (boundingRect.height < letterMinHeight) {
//      numPreds--;
//      continue;
//    }
//    // If the contour does not have a parent (e.i it is a parent), skip this one
//    if (hierarchy[i][3] != -1) {
//      numPreds--;
//      continue;
//    }
//
//    //     #Taking ROI of the cotour
//    cv::Mat roi = matImageGrey(boundingRect);
//
//    // #Convert to Black and white
//    // #roi = cv.cvtColor(roi, cv.COLOR_BGR2GRAY)
//    float longestSide = max(boundingRect.width, boundingRect.height);
//    float shortSide = min(boundingRect.width, boundingRect.height);
//    if (longestSide < 1 || shortSide < 1) {
//      numPreds--;
//      continue;
//    }
//
//    // If we have a very Wide bounding box, its probably Noise or crossed!
//    if (boundingRect.height * 3 < boundingRect.width) {
//      numPreds--;
//      continue;
//    }
//
//    float resizeFactor = 20.f / max(boundingRect.width, boundingRect.height);
//
//    //    if ((shortSide / longestSide) < 0.1) {
//    //      numPreds--;
//    //      continue;
//    //    }
//
//    int sizeWidth = resizeFactor * boundingRect.width;
//    int sizeHeight = resizeFactor * boundingRect.height;
//    if (sizeHeight < 1 || sizeWidth < 1) {
//      numPreds--;
//      continue;
//    }
//
//    // Resize into max 20 x SHORT_SIDE (20x20 is bounding box of letter)
//    cv::resize(roi, roi, cv::Size(sizeWidth, sizeHeight));
//
//    cv::Mat dstRoi = cv::Mat::zeros(cv::Size(28, 28), roi.type());
//    NSLog(@"BOUNDING RECT %i %i", sizeWidth, sizeHeight);
//    // Pad the rest of the ROI to fit 28 x 28
//    int width = roi.size().width;
//    int height = roi.size().height;
//    int bottomBorder = 20 - height + 4;
//    int rightBorder = 20 - width + 4;
//    int topBorder = 4;
//    int leftBorder = 4;
//    copyMakeBorder(roi, dstRoi, topBorder, bottomBorder, leftBorder,
//                   rightBorder, borderType);
//
//    // Center of mass of the letter, Get the mean of height and width
//    cv::Moments M = cv::moments(dstRoi, true);
//    int cX = int(M.m10 / M.m00);
//    int cY = int(M.m01 / M.m00);
//    int shiftx = int((float)(dstRoi.cols / 2.0) - cX);
//    int shifty = int((float)(dstRoi.rows / 2.0) - cY);
//    //
//    Mat trans_mat = (Mat_<double>(2, 3) << 1, 0, shiftx, 0, 1, shifty);
//
//    cv::warpAffine(dstRoi, dstRoi, trans_mat, dstRoi.size());
//
//    //    cv::GaussianBlur(dstRoi, dstRoi, cv::Size(3, 3), 0);
//    NSLog(@"SIZE ROI AT %i %i", dstRoi.rows, dstRoi.cols);
//    int maxRight = boundingRect.x + dstRoi.cols;
//    int maxBottom = boundingRect.y + dstRoi.rows;
//    int boundingRectHeight = dstRoi.rows;
//    int boundingRectWidth = dstRoi.cols;
//    if (maxBottom >= foundNumbers.rows)
//      boundingRectHeight = foundNumbers.rows - boundingRect.y;
//    if (maxRight >= foundNumbers.cols)
//      boundingRectWidth = foundNumbers.cols - boundingRect.x;
//    Range colRange = Range(0, boundingRectWidth);
//    Range rowRange = Range(0, boundingRectHeight);
//    dstRoi(rowRange, colRange)
//        .copyTo(foundNumbers(cv::Rect(boundingRect.x, boundingRect.y,
//                                      boundingRectWidth, boundingRectHeight)));
//
//    NSMutableData *inputData = [[NSMutableData alloc] initWithCapacity:0];
//
//    for (int row = 0; row < 28; row++) {
//      for (int col = 0; col < 28; col++) {
//        //        long offset = 4 * (col * dstRoi.size().width + row);
//        // Normalize channel values to [0.0, 1.0]. This requirement varies
//        // by model. For example, some models might require values to be
//        // normalized to the range [-1.0, 1.0] instead, and others might
//        // require fixed-point values or the original bytes.
//        // (Ignore offset 0, the unused alpha channel)
//        // Just TRY TO Normalize between [-1.0, 1.0]
//
//        float data = (dstRoi.at<uchar>(row, col) - 127.5f) / 127.5f;
//        //        float data = dstRoi.at<uchar>(row,col) / 255.0f; //
//        //        imageData[offset+1] / 255.0f; Float32 green =
//        //        imageData[offset+2] / 255.0f; Float32 blue =
//        //        imageData[offset+3] / 255.0f; NSLog(@"dstRoi AT %u", data);
//        //        //dstRoi.at<uchar>(row,col));
//        [inputData appendBytes:&data length:sizeof(data)];
//        //        [inputData appendBytes:&green length:sizeof(green)];
//        //        [inputData appendBytes:&blue length:sizeof(blue)];
//      }
//    }
//    NSError *error;
//    FIRModelInputs *inputs = [[FIRModelInputs alloc] init];
//    [inputs addInput:inputData error:&error];
//    FIRModelInputOutputOptions *ioOptions =
//        [[FIRModelInputOutputOptions alloc] init];
//    FIRModelInputOutputOptions *ioOptionsDiscriminator =
//        [[FIRModelInputOutputOptions alloc] init];
//
//    [ioOptions setInputFormatForIndex:0
//                                 type:FIRModelElementTypeFloat32
//                           dimensions:@[ @1, @28, @28, @1 ]
//                                error:&error];
//
//    [ioOptions setOutputFormatForIndex:0
//                                  type:FIRModelElementTypeFloat32
//                            dimensions:@[ @1, @10 ]
//                                 error:&error];
//
//    [ioOptionsDiscriminator setInputFormatForIndex:0
//                                              type:FIRModelElementTypeFloat32
//                                        dimensions:@[ @1, @28, @28, @1 ]
//                                             error:&error];
//
//    [ioOptionsDiscriminator setOutputFormatForIndex:0
//                                               type:FIRModelElementTypeFloat32
//                                         dimensions:@[ @1, @1 ]
//                                              error:&error];
//
//    numInputs++;
//
//    // Draw rectangle on pic
//    Scalar color = cv::Scalar(255, 0, 0, 255);
//    cv::rectangle(matImage, boundingRect, color, 1);
//
//    [discriminatorInterpreter
//        runWithInputs:inputs
//              options:ioOptionsDiscriminator
//           completion:^(FIRModelOutputs *_Nullable outputs,
//                        NSError *_Nullable error) {
//             if (error != nil || outputs == nil) {
//               NSLog(@"ERROR FOR DISCRIMINATOR PREDICTION ");
//               return;
//             }
//             NSError *outputError;
//             NSNumber *output = [outputs outputAtIndex:0
//                                                 error:&outputError][0][0];
//             // If model discriminator pred is negative, its not a number, just
//             // noise.
//             float ou = output.floatValue;
//             if (ou < -10.5f) {
//               numPreds--;
//             } else {
//               NSLog(@"OUTPUT FIRST  %f", ou);
//               [interpreter
//                   runWithInputs:inputs
//                         options:ioOptions
//                      completion:^(FIRModelOutputs *_Nullable outputs,
//                                   NSError *_Nullable error) {
//                        if (error != nil || outputs == nil) {
//                          return;
//                        }
//                        completedPredictions++;
//                        NSLog(@"COMPLETED %i with point X %i", i,
//                              boundingRect.x);
//
//                        // Process outputs
//                        // Get first and only output of inference with a batch
//                        // size of 1
//                        NSError *outputError;
//                        NSArray *probabilites =
//                            [outputs outputAtIndex:0 error:&outputError][0];
//                        //      RCTLog("OUTPUTS %a ",probabilites)
//
//                        //      NSNumber * max = [probabilites
//                        //      valueForKeyPath:@"@max.floatValue"];
//
//                        // Find max probability
//                        float maxProbability = -MAXFLOAT;
//                        int maxIndex = 0;
//                        for (int i = 0; i < probabilites.count; i++) {
//                          NSNumber *num = probabilites[i];
//                          float x = num.floatValue;
//                          if (x > maxProbability) {
//                            maxProbability = x;
//                            maxIndex = i;
//                          }
//                        }
//                        // if (maxProbability < 0.9) {
//                        //   return;
//                        // }
//
//                        struct Prediction pred;
//                        pred.number = maxIndex;
//                        pred.prob = maxProbability;
//                        pred.boundingRect = boundingRect;
//                        boundingRects.push_back(pred);
//
//                        int centerX =
//                            boundingRect.x + (boundingRect.width / 2.0f);
//                        int centerY =
//                            boundingRect.y + (boundingRect.height / 2.0f);
//
//                        cv::circle(matImage, cv::Point(centerX, centerY), 3,
//                                   cv::Scalar(255, 0, 0, 255));
//                        cv::Point center(centerX, centerY);
//                        GridItem *item = [self findGridItem:yatzyGrid
//                                                      point:center];
//                        if (item != nullptr) {
//                          item->numbers.push_back(pred);
//                          std::sort(item->numbers.begin(), item->numbers.end(),
//                                    sortByXPos);
//                        }
//                        NSLog(@"Max Index num inputs %i and completed %i. "
//                              @"Predicted a number "
//                              @"%i with probablility %f",
//                              numPreds, completedPredictions, maxIndex,
//                              maxProbability);
//                        if (completedPredictions == numPreds) {
//                          //                                            UIImage
//                          //                                            *imageToSave
//                          //                                            =
//                          // MatToUIImage(foundNumbers);
//
//                          UIImage *imageToSave = MatToUIImage(matImage);
//                          // cv::Mat
//                          // transparentImage(matImageGrey.size().height,
//                          //                          matImageGrey.size().width,
//                          //                          CV_8UC4);
//                          // UIImage *imageToSave =
//                          // MatToUIImage(transparentImage);
//                          for (Prediction pred : boundingRects) {
//                            //                            NSString *output =
//                            //                                [NSString
//                            //                                stringWithFormat:@"%i
//                            //                                                      prob: % .2f ",
//                            //                                                                pred.number,
//                            //                                                            pred.prob];
//                            //                            NSString *output =
//                            //                                [NSString
//                            //                                stringWithFormat:@"%i",
//                            //                                pred.number];
//                            //                            imageToSave = [self
//                            //                                drawText:output
//                            //                                 inImage:imageToSave
//                            //                                 atPoint:CGPointMake(pred.boundingRect.x,
//                            //                                                     pred.boundingRect.y)];
//                          }
//
//                          NSData *imageData =
//                              UIImagePNGRepresentation(imageToSave);
//                          NSString *base64String =
//                              [imageData base64EncodedStringWithOptions:0];
//                          // UIImageWriteToSavedPhotosAlbum(imageToSave, nil,
//                          // nil,
//                          //                                nil);
//
//                          // Call completion handler.
//                          _completionHandler(base64String, yatzyGrid);
//                        }
//                        //      for (int i = 0; i < 10; i++) {
//                        //          NSNumber *probability = probabilites[i];
//                        //          NSLog(@"PROPABILITY %f",
//                        //          probability.floatValue);
//                        //      }
//                        // ...
//                      }];
//             }
//           }];
//
//    //    }
//
//    //    [allRoiData addObject:inputData];
//
//    //    cv::Rect *pointer = &boundingRect;
//    //
//    //    id object = [NSValue valueWithPointer:pointer];
//    //
//    //
//    //    [allPoints addObject:object];
//
//    //    if (error != nil) { return nil; }
//
//    //    NSArray *paths =
//    //    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//    //                                                         NSUserDomainMask,
//    //                                                         YES);
//    //    NSString *directory = [paths objectAtIndex:0];
//    //    NSString *filePath =
//    //        [directory stringByAppendingPathComponent:
//    //                       [NSString stringWithFormat:@"hand%f.jpg",
//    //                                                  CFAbsoluteTimeGetCurrent()]];
//    //    const char *filePathC =
//    //        [filePath cStringUsingEncoding:NSMacOSRomanStringEncoding];
//    //
//    //    const cv::String thisPath = (const cv::String)filePathC;
//    //
//    //    RCTLog(@"Path  %s", thisPath.c_str());
//    // Save image
//    //    cv::imwrite(thisPath, dstRoi);
//
//    // #print(roiZeros.shape)
//    // #Mark them on the image if you want
//    //                      cv.rectangle(orig, (x, y), (x + w, y + h), (0, 10,
//    //                      255), 2)
//
//    //                          data = np.array([[roiZeros, np.array([ x, y, w,
//    //                          h
//    //                          ])]])
//
//    //                                     if (allData.shape[1] != 2)
//    //       : allData = data allData =
//    //           np.append(allData, data, axis = 0)
//    // #Save your contours or characters
//    //               cv.imwrite("./rois3/roi_" + str(i) + "_.png", roiZeros) i =
//    //               i + 1
//  }
//
//  //    int thresh = 100;
//  //    Mat canny_output;
//  //
//  //    /// Detect edges using canny
//  //    cv::Canny(matImageGrey, canny_output, thresh, thresh * 2, 3);
//  //    /// Find contours
//  //    cv::findContours(canny_output, contours, hierarchy, CV_RETR_EXTERNAL,
//  //                     CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
//  //
//  //    Mat drawing = Mat::zeros(canny_output.size(), CV_8UC3);
//  //    for (int i = 0; i < contours.size(); i++) {
//  //      Scalar color = cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255),
//  //                                rng.uniform(0, 255));
//  //      cv::Rect boundingRect = cv::boundingRect(contours[i]);
//  //      cv::rectangle(drawing, boundingRect, color,1);
//  ////      cv::drawContours(drawing, contours, i, color, 2, 8, hierarchy, 0,
//  ////                       cv::Point());
//  //    }
//
//  // Clean up.
//  //  [_completionHandler release];
//  _completionHandler = nil;
//  _completionErrorHandler = nil;
//
//  //  return base64String;
//}
//
//- (UIImage *)drawText:(NSString *)text
//              inImage:(UIImage *)image
//              atPoint:(CGPoint)point {
//
//  UIFont *font = [UIFont boldSystemFontOfSize:24];
//  UIGraphicsBeginImageContext(image.size);
//  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//  CGRect rect =
//      CGRectMake(point.x, point.y, image.size.width, image.size.height);
//  [[UIColor whiteColor] set];
//  NSDictionary *attributes = @{
//    NSFontAttributeName : font,
//    NSForegroundColorAttributeName : [UIColor blueColor]
//  };
//  [text drawInRect:CGRectIntegral(rect) withAttributes:attributes];
//  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//  return newImage;
//}
//
//@end

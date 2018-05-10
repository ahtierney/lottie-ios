//
//  LOTShapePath.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTKeyframe.h"

@class LOTBezierPath;

@interface LOTShapePath : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;
- (instancetype)initWithKeyname:(NSString*)keyname path:(LOTBezierPath*)path;

@property (nonatomic, readonly) NSString *keyname;
@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) NSNumber *index;
@property (nonatomic, readonly) LOTKeyframeGroup *shapePath;

@end

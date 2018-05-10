//
//  LOTShapePath.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapePath.h"
#import "LOTBezierPath.h"

@implementation LOTShapePath

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (instancetype)initWithKeyname:(NSString*)keyname path:(LOTBezierPath*)path {
  self = [super init];
  if (self) {
    _keyname = keyname;
    _closed = true;
    _index = @0;
    LOTKeyframe *frame = [[LOTKeyframe alloc] initWithPathValue:path];
    _shapePath = [[LOTKeyframeGroup alloc] initWithKeyframes:@[frame]];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  
  if (jsonDictionary[@"nm"] ) {
    _keyname = [jsonDictionary[@"nm"] copy];
  }
  
  _index = jsonDictionary[@"ind"];
  _closed = [jsonDictionary[@"closed"] boolValue];
  NSDictionary *shape = jsonDictionary[@"ks"];
  if (shape) {
    _shapePath = [[LOTKeyframeGroup alloc] initWithData:shape];
  }
}

@end

//
//  LOTCharacter.m
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTCharacter.h"
#import "LOTShapeGroup.h"
#import "LOTShapePath.h"
#import "LOTBezierPath.h"

@implementation LOTCharacter

- (nullable instancetype)initWithJSON:(nonnull NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (instancetype)initWithCharacterString:(NSString *)characterString
                             familyName:(NSString *)familyName
                                   size:(NSNumber *)size
                                  style:(NSString *)style
                             bezierPath:(LOTBezierPath *)path {

  self = [super init];
  if (self) {
    _characterString = characterString;
    _width = [[NSNumber alloc] initWithFloat:path.bounds.size.width];
    _fontSize = size;
    _fontStyle = style;
    _fontFamilyName = familyName;
    LOTShapePath *pathShape = [[LOTShapePath alloc] initWithKeyname:characterString path:path];
    _shapes = [[LOTShapeGroup alloc] initWithKeyname:characterString shapes:@[pathShape]];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary*)jsonDictionary {
  _characterString = jsonDictionary[@"ch"];
  _width = jsonDictionary[@"w"];
  _fontSize = jsonDictionary[@"size"];
  _fontStyle = jsonDictionary[@"style"];
  _fontFamilyName = jsonDictionary[@"fFamily"];

  NSDictionary *characterData = jsonDictionary[@"data"];
  if (characterData && characterData[@"shapes"]) {

    // NOTE: is this a guarantee?
    // Assume this array will contain one shape group:
    NSArray *shapesArray = characterData[@"shapes"];
    NSDictionary *shapeJSON = shapesArray.firstObject;
    id shapeItem = [LOTShapeGroup shapeItemWithJSON:shapeJSON];
    _shapes = shapeItem;
  }
}

@end

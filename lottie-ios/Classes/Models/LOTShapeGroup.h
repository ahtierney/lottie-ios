//
//  LOTShape.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface LOTShapeGroup : NSObject

- (instancetype _Nonnull)initWithJSON:(NSDictionary *_Nonnull)jsonDictionary;
- (instancetype _Nonnull)initWithKeyname:(NSString *_Nonnull)keyname
                                  shapes:(NSArray *_Nonnull)shapes;

@property (nonatomic, readonly, nonnull) NSString *keyname;
@property (nonatomic, readonly, nonnull) NSArray *items;

+ (id _Nullable)shapeItemWithJSON:(NSDictionary * _Nonnull)itemJSON;

@end

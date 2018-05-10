//
//  LOTFontResolver.h
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTCharacter;

@interface LOTFontResolver : NSObject

+ (instancetype)shared;

- (void)seedResolverWithFonts:(NSArray*)fontsJSON andCharacterJSON:(nullable NSArray*)charactersJSON;

- (LOTCharacter *)getGlyphForCharacter:(unichar)characterString
                                ofSize:(NSNumber*)size
                     withConjoinedName:(NSString*)familyStyleString;

@end

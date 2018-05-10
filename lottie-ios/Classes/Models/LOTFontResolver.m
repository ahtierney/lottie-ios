//
//  LOTFontResolver.m
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTFontResolver.h"
#import "LOTCharacter.h"
#import "LOTFont.h"
#import "LOTHelpers.h"
#import <CoreText/CoreText.h>

@implementation LOTFontResolver {
  /// maps conjoined font name to font object
  NSMutableDictionary <NSString*, LOTFont*> * _fontMap;
  NSMutableDictionary <NSString*, LOTCharacter*> * _characterMap;
}

// TODO: probably don't use a singleton and scope this to animation
+ (instancetype)shared {
  static LOTFontResolver * _sharedResolver;
  if (!_sharedResolver) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _sharedResolver = [[LOTFontResolver alloc] init];
    });
  }
  return _sharedResolver;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _characterMap = [NSMutableDictionary dictionary];
    _fontMap = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)seedFontLookUp:(NSArray*)fontsJSON {
  for (NSDictionary *fontJSON in fontsJSON) {
    LOTFont *font = [[LOTFont alloc] initWithJSON:fontJSON];
    if (font) {
      _fontMap[font.name] = font;
    }
    NSLog(@"setup fontmap %@", _fontMap);
  }
}

- (void)seedResolverWithFonts:(NSArray*)fontsJSON andCharacterJSON:(nullable NSArray*)charactersJSON {
  [self seedFontLookUp:fontsJSON];
  if (charactersJSON) {
    for (NSDictionary *characterJSON in charactersJSON) {
      LOTCharacter *character = [[LOTCharacter alloc] initWithJSON:characterJSON];
      if (character) {
        [self setGlyph:character];
      }
    }
    NSLog(@"imported glyphs %@", _characterMap);
  }
}

- (LOTCharacter *)getGlyphForCharacter:(unichar)character
                                ofSize:(NSNumber*)size
                     withConjoinedName:(NSString*)familyStyleString {

  LOTFont *font = _fontMap[familyStyleString];

  NSString *keypath = [LOTFontResolver keypathForCharacter:character
                                                      font:font
                                                      size:size];

  LOTCharacter *characterModel = [_characterMap valueForKeyPath:keypath];

  if (!characterModel) {
    UIFont *bundledFont = [UIFont fontWithName:familyStyleString size:size.floatValue];
    if (bundledFont) {

      NSString *characterString = [NSString stringWithFormat:@"%C", character];
      CFStringRef charString = (__bridge CFStringRef) characterString;
      CTFontRef fontRef = (__bridge CTFontRef)bundledFont;

      CFIndex count = CFStringGetLength(charString);
      UniChar *ioChars = (UniChar *)malloc(sizeof(UniChar) * count);
      CGGlyph *ioGlyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
      CFStringGetCharacters(charString, CFRangeMake(0, count), ioChars);

//      CGGlyph glyph = CTFontGetGlyphWithName(fontRef, charString);
      BOOL success = CTFontGetGlyphsForCharacters(fontRef, ioChars, ioGlyphs, count);
      NSUInteger c = CTFontGetGlyphCount(fontRef);

      if (success) {
        CGPathRef path = CTFontCreatePathForGlyph(fontRef, ioGlyphs[0], nil);
        LOTBezierPath *bezierPath = [LOTBezierPath pathWithCGPath:path];
        CGPathRelease(path);

        characterModel = [[LOTCharacter alloc] initWithCharacterString:characterString
                                                            familyName:font.familyName
                                                                  size:size
                                                                 style:font.style
                                                            bezierPath:bezierPath];
        //TODO: Memoize
      }

      free(ioChars);
      free(ioGlyphs);
    }
  }

  if (!characterModel) {
    NSLog(@"%C not present for keypath %@ – be sure to export the character as a glyph or provide a custom font file", character, keypath);
  }

  return characterModel;
}

- (void)setGlyph:(LOTCharacter*)glyph {
  NSString *keypath = [LOTFontResolver keypathForGlyph:glyph];
  NSArray<NSString*> *pathComponents = [keypath componentsSeparatedByString:@"."];
  [self setGlyph:glyph inDictionary:_characterMap forKeypathComponents:pathComponents];
}

- (void)setGlyph:(LOTCharacter*)glyph
    inDictionary:(NSMutableDictionary*)dict
forKeypathComponents:(NSArray<NSString*>*)keypathComponents {

  NSUInteger pathCount = keypathComponents.count;
  NSAssert(pathCount > 0, @"trying to set glyph without a keypath");
  if (pathCount == 1) {
    dict[[keypathComponents firstObject]] = glyph;
  } else {
    NSString *key = [keypathComponents firstObject];
    NSMutableDictionary *mutableContainer;
    if (dict[key] && [dict[key] isKindOfClass:[NSMutableDictionary class]]) {
      mutableContainer = dict[key];
    } else {
      mutableContainer = [NSMutableDictionary dictionary];
      dict[key] = mutableContainer;
    }

    // drop first:
    NSArray *nextComponents = [keypathComponents subarrayWithRange:NSMakeRange(1, pathCount - 1)];

    [self setGlyph:glyph
      inDictionary:mutableContainer
forKeypathComponents: nextComponents];
  }
}

// MARK: - Keypath Helpers

+ (NSString *)keypathForCharacter:(unichar)characterString
                             font:(LOTFont*)font
                             size:(NSNumber*)size {
  return  [LOTFontResolver keypathForCharacter:characterString
                                        ofSize:size
                                fromFontFamily:font.familyName
                                       inStyle:font.style];
}

+ (NSString *)keypathForGlyph:(LOTCharacter*)glyph {
  return [LOTFontResolver keypathForCharacterString:glyph.characterString
                                             ofSize:glyph.fontSize
                                     fromFontFamily:glyph.fontFamilyName
                                            inStyle:glyph.fontStyle];
}

+ (NSString *)keypathForCharacterString:(NSString*)characterString
                                 ofSize:(NSNumber*)size
                         fromFontFamily:(NSString*)family
                                inStyle:(NSString*)style {

  NSRange range = [characterString rangeOfComposedCharacterSequenceAtIndex:0];

  // assume a UTF-16 character, this cue is taken from Android, could probably be relaxed if preferred
  if (range.length != 1) {
    NSLog(@"requesting character key with an invalid character string: %@", characterString);
    return nil;
  }

  unichar characterValue = [characterString characterAtIndex:0];
  NSString *key = [LOTFontResolver keypathForCharacter:characterValue
                                                ofSize:size
                                        fromFontFamily:family
                                               inStyle:style];
  return key;
}

+ (NSString *)keypathForCharacter:(unichar)character
                           ofSize:(NSNumber*)size
                   fromFontFamily:(NSString*)family
                          inStyle:(NSString*)style {
  return [NSString stringWithFormat: @"%@.%@.%@.%C", family, style, size, character];
}

@end

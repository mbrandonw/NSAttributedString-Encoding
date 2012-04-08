//
//  NSAttributedString+Opetopic.m
//  NSAttributedString+Opetopic
//
//  Created by Brandon Williams on 4/6/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import "NSAttributedString+Encoding.h"

const struct NSAttributedStringArchiveKeys {
    __unsafe_unretained NSString *rootString;
    __unsafe_unretained NSString *attributes;
    __unsafe_unretained NSString *attributeDictionary;
    __unsafe_unretained NSString *attributeRange;
} NSAttributedStringArchiveKeys;

const struct NSAttributedStringArchiveKeys NSAttributedStringArchiveKeys = {
    .rootString = @"rootString",
    .attributes = @"attributes",
    .attributeDictionary = @"attributeDictionary",
    .attributeRange = @"attributeRange",
};

@interface NSAttributedString (Encoding_Private)
-(NSDictionary*) dictionaryRepresentation;
+(id) attributedStringWithDictionaryRepresentation:(NSDictionary*)dictionary;
+(NSDictionary*) dictionaryRepresentationOfFont:(CTFontRef)fontRef;
+(CTFontRef) fontFromDictionaryRepresentation:(NSDictionary*)dictionary;
@end

@implementation NSAttributedString (Encoding)

+(id) attributedStringWithData:(NSData*)data {
    return [self attributedStringWithDictionaryRepresentation:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

-(NSData*) convertToData {
    return [NSKeyedArchiver archivedDataWithRootObject:[self dictionaryRepresentation]];
}

@end


@implementation NSAttributedString (Encoding_Private)

+(id) attributedStringWithDictionaryRepresentation:(NSDictionary*)dictionary {
    
    NSString *string = [dictionary objectForKey:NSAttributedStringArchiveKeys.rootString];
    NSMutableAttributedString *retVal = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSArray *attributes = [dictionary objectForKey:NSAttributedStringArchiveKeys.attributes];
    [attributes enumerateObjectsUsingBlock:^(NSDictionary *attribute, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *attributeDictionary = [attribute objectForKey:NSAttributedStringArchiveKeys.attributeDictionary];
        NSRange range = NSRangeFromString([attribute objectForKey:NSAttributedStringArchiveKeys.attributeRange]);
        
        [attributeDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id attr, BOOL *stop) {
            
            if ([key isEqual:(NSString*)kCTFontAttributeName])
            {
                CTFontRef fontRef = [[self class] fontFromDictionaryRepresentation:attr];
                [retVal addAttribute:key value:(__bridge id)fontRef range:range];
            }
            else if([key isEqualToString:(NSString*)kCTForegroundColorFromContextAttributeName] ||
                    [key isEqualToString:(NSString*)kCTKernAttributeName] ||
                    [key isEqualToString:(NSString*)kCTStrokeWidthAttributeName] ||
                    [key isEqualToString:(NSString*)kCTLigatureAttributeName] ||
                    [key isEqualToString:(NSString*)kCTSuperscriptAttributeName] ||
                    [key isEqualToString:(NSString*)kCTUnderlineStyleAttributeName] ||
                    [key isEqualToString:(NSString*)kCTCharacterShapeAttributeName] ||
                    [key isEqualToString:(NSString*)kCTVerticalFormsAttributeName])
            {
                [retVal addAttribute:key value:attr range:range];
            }
            else if([key isEqualToString:(NSString*)kCTForegroundColorAttributeName] ||
                    [key isEqualToString:(NSString*)kCTStrokeColorAttributeName] ||
                    [key isEqualToString:(NSString*)kCTUnderlineColorAttributeName])
            {
                [retVal addAttribute:key value:(id)[attr CGColor] range:range];
            }
            else if([key isEqualToString:(NSString*)kCTParagraphStyleAttributeName])
            {
                CTParagraphStyleSetting settings[[attr count]];
                int settingIndex = 0;
                
#define PARAGRAPH_SETTING(datatype, specifier, container) \
    datatype container = sizeof(datatype) == sizeof(CGFloat) ? [[attr objectForKey:[NSNumber numberWithInt:specifier]] floatValue] : [[attr objectForKey:[NSNumber numberWithInt:specifier]] intValue]; \
    settings[settingIndex].spec = specifier; \
    settings[settingIndex].valueSize = sizeof(datatype); \
    settings[settingIndex].value = &container; \
    settingIndex++; \

                PARAGRAPH_SETTING(uint8_t, kCTParagraphStyleSpecifierAlignment, alignment);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierFirstLineHeadIndent, firstLineHeadIndent);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierHeadIndent, headIndent);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierTailIndent, tailIndent);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierDefaultTabInterval, defaultTabInterval);
                PARAGRAPH_SETTING(uint8_t, kCTParagraphStyleSpecifierLineBreakMode, linebreakMode);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierLineHeightMultiple, lineHeightMultiple);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierMaximumLineHeight, maximumLineHeight);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierMinimumLineHeight, minimumLineHeight);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierLineSpacing, lineSpacing);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierParagraphSpacing, paragraphSpacing);
                PARAGRAPH_SETTING(CGFloat, kCTParagraphStyleSpecifierParagraphSpacingBefore, paragraphSpacingBefore);
                PARAGRAPH_SETTING(int8_t,  kCTParagraphStyleSpecifierBaseWritingDirection, baseWritingDirection);
                
                CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(settings, [attr count]);
                
                [retVal addAttribute:key value:(__bridge id)paragraphStyleRef range:range];
            }
            else if([key isEqualToString:(NSString*)kCTGlyphInfoAttributeName])
            {
                // TODO
            }
            else if([key isEqualToString:(NSString*)kCTRunDelegateAttributeName])
            {
                // TODO
            }
        }];
        
    }];
    
    return retVal;
}

-(NSDictionary*) dictionaryRepresentation {
    
    NSMutableDictionary *retVal = [NSMutableDictionary new];
    
    [retVal setObject:[self string] forKey:NSAttributedStringArchiveKeys.rootString];
    
    NSMutableArray *attributes = [NSMutableArray new];
    [retVal setObject:attributes forKey:NSAttributedStringArchiveKeys.attributes];
    
    [self enumerateAttributesInRange:NSMakeRange(0, [self length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        NSMutableDictionary *attribute = [NSMutableDictionary new];
        [attributes addObject:attribute];
        
        [attribute setObject:NSStringFromRange(range) forKey:NSAttributedStringArchiveKeys.attributeRange];
        NSMutableDictionary *attributeDictionary = [NSMutableDictionary new];
        [attribute setObject:attributeDictionary forKey:NSAttributedStringArchiveKeys.attributeDictionary];
        
        [attrs enumerateKeysAndObjectsUsingBlock:^(id key, id attr, BOOL *stop) {
            
            if ([key isEqual:(NSString*)kCTFontAttributeName])
            {
                [attributeDictionary setObject:[[self class] dictionaryRepresentationOfFont:(CTFontRef)attr] forKey:key];
            }
            else if([key isEqualToString:(NSString*)kCTForegroundColorFromContextAttributeName] ||
                    [key isEqualToString:(NSString*)kCTKernAttributeName] ||
                    [key isEqualToString:(NSString*)kCTStrokeWidthAttributeName] ||
                    [key isEqualToString:(NSString*)kCTLigatureAttributeName] ||
                    [key isEqualToString:(NSString*)kCTSuperscriptAttributeName] ||
                    [key isEqualToString:(NSString*)kCTUnderlineStyleAttributeName] ||
                    [key isEqualToString:(NSString*)kCTCharacterShapeAttributeName] ||
                    [key isEqualToString:(NSString*)kCTVerticalFormsAttributeName])
            {
                [attributeDictionary setObject:attr forKey:key];
            }
            else if([key isEqualToString:(NSString*)kCTForegroundColorAttributeName] ||
                    [key isEqualToString:(NSString*)kCTStrokeColorAttributeName] ||
                    [key isEqualToString:(NSString*)kCTUnderlineColorAttributeName])
            {
                [attributeDictionary setObject:[UIColor colorWithCGColor:(CGColorRef)attr] forKey:key];
            }
            else if([key isEqualToString:(NSString*)kCTParagraphStyleAttributeName])
            {
                NSMutableDictionary *paragraphDictionary = [NSMutableDictionary new];
                
#define SPECIFIER_VALUE(datatype, specifier, container) {\
    datatype container; \
    CTParagraphStyleGetValueForSpecifier((__bridge CTParagraphStyleRef)attr, specifier, sizeof(datatype), &container); \
    [paragraphDictionary setObject:sizeof(datatype)==sizeof(CGFloat) ? [NSNumber numberWithFloat:container] : [NSNumber numberWithInt:container] forKey:[NSNumber numberWithInt:specifier]]; \
}
                SPECIFIER_VALUE(uint8_t, kCTParagraphStyleSpecifierAlignment, alignment);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierFirstLineHeadIndent, firstLineHeadIndent);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierHeadIndent, headIndent);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierTailIndent, tailIndent);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierDefaultTabInterval, defaultTabInterval);
                SPECIFIER_VALUE(uint8_t, kCTParagraphStyleSpecifierLineBreakMode, linebreakMode);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierLineHeightMultiple, lineHeightMultiple);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierMaximumLineHeight, maximumLineHeight);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierMinimumLineHeight, minimumLineHeight);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierLineSpacing, lineSpacing);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierParagraphSpacing, paragraphSpacing);
                SPECIFIER_VALUE(CGFloat, kCTParagraphStyleSpecifierParagraphSpacingBefore, paragraphSpacingBefore);
                SPECIFIER_VALUE(int8_t,  kCTParagraphStyleSpecifierBaseWritingDirection, baseWritingDirection);
                [attributeDictionary setObject:paragraphDictionary forKey:key];
            }
            else if([key isEqualToString:(NSString*)kCTGlyphInfoAttributeName])
            {
                // TODO
            }
            else if([key isEqualToString:(NSString*)kCTRunDelegateAttributeName])
            {
                // TODO
            }
            
        }];
        
    }];
    
    return retVal;
}

+(NSDictionary*) dictionaryRepresentationOfFont:(CTFontRef)fontRef {
    
    NSDictionary *retVal = nil;
    CTFontDescriptorRef descriptorRef = CTFontCopyFontDescriptor(fontRef);
    CFDictionaryRef attributesRef = CTFontDescriptorCopyAttributes(descriptorRef);
    retVal = (__bridge_transfer NSDictionary*)attributesRef;
    CFRelease(descriptorRef);
    return retVal;
}

+(CTFontRef) fontFromDictionaryRepresentation:(NSDictionary*)dictionary {
    
    CTFontRef retVal = NULL;
    CTFontDescriptorRef descriptorRef = CTFontDescriptorCreateWithAttributes((__bridge_retained CFDictionaryRef)dictionary);
    retVal = CTFontCreateWithFontDescriptor(descriptorRef, 0.0f, NULL);
    CFRelease(descriptorRef);
    return retVal;
}

@end

//
//  ModelProcessor.m
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 28.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import "ModelProcessor.h"
#import "Model.h"
#import "Property.h"


@implementation ModelProcessor

-(instancetype)init
{
    self = [super init];
    if (self) {
        _generatedModels = [NSMutableArray new];
    }
    
    return self;
}

- (NSString *)modelClassNameWithString:(NSString *)string
{
    NSString *firstSymbol = [string substringToIndex:1];
    
    if ([firstSymbol isEqualToString:[firstSymbol uppercaseString]] && [string componentsSeparatedByString:@"_"].count == 1) {
        return string;
    }
    
    NSArray *tokens = [string componentsSeparatedByString:@"_"];
    NSString *result = @"";
    
    for (NSString *token in tokens) {
        result = [result stringByAppendingString:[token capitalizedString]];
    }
    
    return [result stringByAppendingString:@"Model"];
}

- (NSString *)variableNameWithProperty:(Property *)property
{
    NSArray *tokens = [property.originalName componentsSeparatedByString:@"_"];
    NSString *result = @"";
    
    for (NSString *token in tokens) {
        result = [result stringByAppendingString:[token capitalizedString]];
    }
    
    NSString *firstSymbol = [[result substringToIndex:1] lowercaseString];
    NSString *others = [result substringFromIndex:1] ;
    
    return [firstSymbol stringByAppendingString:others];
}

- (NSString *)classNameWithProperty:(Property *)property
{
    if (property.array) {
        return @"NSArray";
    }
    
    if ([property.originalValue isKindOfClass:[NSNumber class]]) {
        return @"NSNumber";
    }
    
    if ([property.originalValue isKindOfClass:[NSDictionary class]]) {
        return [self modelClassNameWithString:property.originalName];
    }
    
    if ([property.originalValue isKindOfClass:[NSString class]]) {
        
        NSArray *splitClass = [property.originalValue componentsSeparatedByString:@":"];
        
        if (splitClass.count >= 2 && [splitClass.firstObject isEqualToString:@"class"]) {
            return [self modelClassNameWithString:[splitClass objectAtIndex:1]];
        }
        
        return @"NSString";
    }
    
    property.primitive = YES;
    return @"id";
}

- (void)prepareModel:(NSDictionary *)model
{
    NSString *modelName = [[model allKeys] firstObject];
    NSDictionary *modelBody = [[model allValues] firstObject];
    
    Model *modelObject = [Model new];
    modelObject.originalName = modelName;
    modelObject.className = [self modelClassNameWithString:modelObject.originalName];
    
    [_generatedModels addObject:modelObject];
    
    for (NSString *key in modelBody.allKeys) {
        
        id value = [modelBody objectForKey:key];
        
        Property *property = [Property new];
        property.originalName = key;
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            property.originalValue = key;
            [self prepareModel:@{key : value}];
            [modelObject.includes addObject:[self modelClassNameWithString:key]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            property.originalValue = key;
            [self prepareModel:@{key : [value firstObject]}];
            [modelObject.includes addObject:[self modelClassNameWithString:key]];
            property.array = YES;
        }
        else
        {
            property.originalValue = value;
    
        }
        
        property.variableName = [self variableNameWithProperty:property];
        property.className = [self classNameWithProperty:property];
        
        property.primitive = ([property.className isEqualToString:@"BOOL"]
                              || [property.className isEqualToString:@"NSInteger"]
                              || [property.className isEqualToString:@"CGFloat"]);
        
        [modelObject.properties addObject:property];
    }
}

@end

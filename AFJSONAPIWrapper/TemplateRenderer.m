//
//  TemplateRenderer.m
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 28.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import "TemplateRenderer.h"
#import "Model.h"
#import "Property.h"

@implementation TemplateRenderer


- (NSString *)templateWithName:(NSString *)name
{
    NSString *classTemplate = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@".temp"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:NULL];
    return classTemplate;
}

- (NSString *)renderProperty:(Property *)property
{
    NSString *propertyTemplate = [self templateWithName:@"property"];
    NSString *variable = property.variableName;
    
    if (!property.primitive) {
        variable = [@" * " stringByAppendingString:variable];
    }
    
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$propertyName}" withString:variable];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$propertyClass}" withString:property.className];
    
    return propertyTemplate;
}

- (NSString *)renderPropertyBinding:(Property *)property
{
    
    NSString *propertyTemplate = [self templateWithName:@"mapping"];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$key}" withString:property.variableName];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$value}" withString:property.originalName];
    
    return propertyTemplate;
}

- (void)renderModel:(Model *)model toPath:(NSString *)path
{
    //render .h
    
    NSString *classHeaderTemplate = [self templateWithName:@"model.h"];
    classHeaderTemplate = [classHeaderTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:model.className];
    
    NSMutableArray *renderedProperties = [NSMutableArray new];
    NSMutableArray *renderedBindings = [NSMutableArray new];

    for (Property *property in model.properties) {
        
        [renderedProperties addObject:[self renderProperty:property]];
        [renderedBindings addObject:[self renderPropertyBinding:property]];
        
    }
    
    //includes
    
    NSString *includesHeaderString = @"";
    NSString *includesImpString = @"";
    for (NSString *include in model.includes) {
        includesHeaderString = [includesHeaderString stringByAppendingString:[NSString stringWithFormat:@"@class %@; \r\n" , include]];
        includesImpString = [includesImpString stringByAppendingString:[NSString stringWithFormat:@"#import \"%@.h\" \r\n" , include]];
    }
    
    NSString *properties = [renderedProperties componentsJoinedByString:@"\r\n"];
    classHeaderTemplate = [classHeaderTemplate stringByReplacingOccurrencesOfString:@"{$properties}" withString:properties];
    classHeaderTemplate = [classHeaderTemplate stringByReplacingOccurrencesOfString:@"{$includes}" withString:includesHeaderString];
    //render .m
    
    NSString *classImpTemplate = [self templateWithName:@"model.m"];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:model.className];
    
    NSString *bindings = [renderedBindings componentsJoinedByString:@",\r\n\t\t\t"];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$mapping}" withString:bindings];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$includes}" withString:includesImpString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingString:@"/Models/Machine"]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    [classHeaderTemplate writeToFile:[NSString stringWithFormat:@"%@/%@.h", [path stringByAppendingString:@"/Models/Machine"], model.className] atomically:YES encoding:NSUTF16StringEncoding error:nil];
    
    [classImpTemplate writeToFile:[NSString stringWithFormat:@"%@/%@.m", [path stringByAppendingString:@"/Models/Machine"], model.className] atomically:YES encoding:NSUTF16StringEncoding error:nil];
}

@end

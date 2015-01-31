//
//  TemplateRenderer.m
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
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
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$propertyClass}" withString:((property.array) ? @"NSArray" : property.className)];
    
    return propertyTemplate;
}

- (NSString *)renderPropertyBinding:(Property *)property
{
    
    NSString *propertyTemplate = [self templateWithName:@"mapping"];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$key}" withString:property.variableName];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$value}" withString:property.parsedName];
    
    return propertyTemplate;
}

- (NSString *)renderArrayTransformer:(Property *)property
{
    
    NSString *propertyTemplate = [self templateWithName:@"arraytransformer"];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$key}" withString:property.variableName];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:property.className];
    
    return propertyTemplate;
}

- (NSString *)renderClassTransformer:(Property *)property
{
    
    NSString *propertyTemplate = [self templateWithName:@"classtransformer"];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$key}" withString:property.variableName];
    propertyTemplate = [propertyTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:property.className];
    
    return propertyTemplate;
}

- (void)renderArray:(NSArray *)modelArray toPath:(NSString *)path
{
    NSString *includesString = @"";
    for (Model *model in modelArray) {
        [self renderModel:model toPath:path];
        includesString = [includesString stringByAppendingString:[NSString stringWithFormat:@"#import \"%@+AFJSONWrapper.h\" \r\n" , model.className]];
    }
    
    [includesString writeToFile:[NSString stringWithFormat:@"%@/AFJSONWrapperModels.h", [path stringByAppendingString:@"/Models"]] atomically:YES encoding:NSUTF16StringEncoding error:nil];
}

- (void)renderModel:(Model *)model toPath:(NSString *)path
{
    //render .h
    
    NSString *classHeaderTemplate = [self templateWithName:@"model.h"];
    classHeaderTemplate = [classHeaderTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:model.className];
    
    NSMutableArray *renderedProperties = [NSMutableArray new];
    NSMutableArray *renderedBindings = [NSMutableArray new];
    NSMutableArray *renderedArrayTransformers = [NSMutableArray new];
    NSMutableArray *renderedClassTransformers = [NSMutableArray new];
    
    for (Property *property in model.properties) {
        
        [renderedProperties addObject:[self renderProperty:property]];
        [renderedBindings addObject:[self renderPropertyBinding:property]];
        
        if (!property.customClass) {
            continue;
        }
        
        if (property.array) {
            [renderedArrayTransformers addObject:[self renderArrayTransformer:property]];
        }else{
            [renderedClassTransformers addObject:[self renderClassTransformer:property]];
        }
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
    NSString *transformers = [[renderedClassTransformers arrayByAddingObjectsFromArray:renderedArrayTransformers] componentsJoinedByString:@"\r\n"];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$mapping}" withString:bindings];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$includes}" withString:includesImpString];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$methods}" withString:transformers];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingString:@"/Models/Machine"]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    [classHeaderTemplate writeToFile:[NSString stringWithFormat:@"%@/%@.h", [path stringByAppendingString:@"/Models/Machine"], model.className] atomically:YES encoding:NSUTF16StringEncoding error:nil];
    
    [classImpTemplate writeToFile:[NSString stringWithFormat:@"%@/%@.m", [path stringByAppendingString:@"/Models/Machine"], model.className] atomically:YES encoding:NSUTF16StringEncoding error:nil];
    
    
    /// render category
    classHeaderTemplate = [self templateWithName:@"model+category.h"];
    classImpTemplate = [self templateWithName:@"model+category.m"];
    classHeaderTemplate = [classHeaderTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:model.className];
    classImpTemplate = [classImpTemplate stringByReplacingOccurrencesOfString:@"{$modelName}" withString:model.className];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingString:@"/Models/Human"]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    [classHeaderTemplate writeToFile:[NSString stringWithFormat:@"%@/%@+AFJSONWrapper.h", [path stringByAppendingString:@"/Models/Human"], model.className] atomically:YES encoding:NSUTF16StringEncoding error:nil];
    
    [classImpTemplate writeToFile:[NSString stringWithFormat:@"%@/%@+AFJSONWrapper.m", [path stringByAppendingString:@"/Models/Human"], model.className] atomically:YES encoding:NSUTF16StringEncoding error:nil];
}

@end

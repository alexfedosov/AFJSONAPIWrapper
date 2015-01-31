//
//  ModelsParser.m
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import "ModelsParser.h"

@implementation ModelsParser

- (NSArray *)parseJSONFileWithPath:(NSString *)path
{
    
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    if (!myJSON) {
        return nil;
    }
    
    NSError *error =  nil;
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:kNilOptions
                                                               error:&error];
    return jsonData;
}

@end

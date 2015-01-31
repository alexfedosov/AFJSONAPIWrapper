//
//  ModelsParser.h
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelsParser : NSObject

- (NSArray *)parseJSONFileWithPath:(NSString *)path;

@end

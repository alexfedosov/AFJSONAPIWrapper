//
//  TemplateRenderer.h
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Model;

@interface TemplateRenderer : NSObject

- (void)renderArray:(NSArray *)modelArray toPath:(NSString *)path;
- (void)renderModel:(Model *)model toPath:(NSString *)path;

@end

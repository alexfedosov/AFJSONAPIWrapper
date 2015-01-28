//
//  TemplateRenderer.h
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 28.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Model;

@interface TemplateRenderer : NSObject

- (void)renderModel:(Model *)model toPath:(NSString *)path;

@end

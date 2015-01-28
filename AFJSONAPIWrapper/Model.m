//
//  Model.m
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 28.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import "Model.h"

@implementation Model

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableArray new];
        self.includes = [NSMutableArray new];
    }
    
    return self;
}

@end

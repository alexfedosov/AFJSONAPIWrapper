//
//  ModelProcessor.h
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelProcessor : NSObject

@property (nonatomic, strong) NSMutableArray *generatedModels;

- (void)prepareModel:(NSDictionary *)model;

@end

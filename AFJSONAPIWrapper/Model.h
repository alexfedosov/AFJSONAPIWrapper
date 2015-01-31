//
//  Model.h
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSMutableArray *properties;
@property (nonatomic, strong) NSMutableArray *includes;

@end

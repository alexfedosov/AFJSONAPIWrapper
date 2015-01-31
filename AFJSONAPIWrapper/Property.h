//
//  Property.h
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Property : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *variableName;
@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *parsedName;
@property (nonatomic, strong) id originalValue;
@property (nonatomic, assign) BOOL primitive;
@property (nonatomic, assign) BOOL customClass;
@property (nonatomic, assign) BOOL array;

@end

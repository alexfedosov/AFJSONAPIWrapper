//
//  main.m
//  AFJSONAPIWrapper
//
//  Created by Alexaner Fedosov on 30.01.15.
//  Copyright (c) 2015 alexfedosov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelsParser.h"
#import "TemplateRenderer.h"
#import "ModelProcessor.h"
#import "Model.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        NSString *path = [args stringForKey:@"models"];
        NSString *output = [args stringForKey:@"output"];
        
        ModelsParser *parser = [ModelsParser new];
        NSArray *models = [parser parseJSONFileWithPath:path];
        
        ModelProcessor *processor = [ModelProcessor new];
        for (NSDictionary *model in models) {
            [processor prepareModel:model];
        }
        
        TemplateRenderer *renderer = [TemplateRenderer new];
        [renderer renderArray:processor.generatedModels toPath:output];
    }
    return 0;
}
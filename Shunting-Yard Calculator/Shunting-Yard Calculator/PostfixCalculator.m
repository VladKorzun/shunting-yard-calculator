//
//  PostfixCalculator.m
//  Shunting-Yard Calculator
//
//  Created by Vladyslav Korzun on 2/24/16.
//  Copyright © 2016 Vladyslav Korzun. All rights reserved.
//

#import "PostfixCalculator.h"

@interface PostfixCalculator()

@property (strong, nonatomic) NSArray *operators;
@property (strong, nonatomic) NSMutableArray *stack;

@end

@implementation PostfixCalculator

#pragma mark init methods

- (PostfixCalculator *) init {
    self = [super init];
    
    if (self) {
        self.operators = @[@"+", @"-", @"*", @"/"];
    }
    
    return self;
}

- (NSMutableArray *) stack {
    if (!_stack) {
        _stack = [[NSMutableArray alloc] init];
    }
    return _stack;
}

#pragma mark private methods

- (NSString *) calculateExpression:(NSArray *)expression {
    
    for (NSString *element in expression) {
        
        unichar elem = [element characterAtIndex:0];
        
        if (![self.operators containsObject:[NSString stringWithCharacters:&elem length:1]]) {
            [self.stack addObject:element];
        } else {
            float op2 = [[self.stack lastObject] floatValue];
            [self.stack removeLastObject];
            float op1 = [[self.stack lastObject] floatValue];
            [self.stack removeLastObject];
            float result = 0.0f;
            
            switch (elem) {
                case '+':
                    result = op1 + op2;
                    break;
                case '-':
                    result = op1 - op2;
                    break;
                case '*':
                    result = op1 * op2;
                    break;
                case '/':
                    result = op1 / op2;
                    break;
                default:
                    break;
            }
            
            [self.stack addObject:[NSString stringWithFormat:@"%f", result]];
        }
        
    }
    
    return [self.stack lastObject];
}

@end

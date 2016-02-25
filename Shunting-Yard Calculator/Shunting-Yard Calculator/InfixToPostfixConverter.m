//
//  InfixToPostfixConverter.m
//  Shunting-Yard Calculator
//
//  Created by Vladyslav Korzun on 2/24/16.
//  Copyright © 2016 Vladyslav Korzun. All rights reserved.
//

#import "InfixToPostfixConverter.h"

@interface InfixToPostfixConverter()

@property (strong, nonatomic) NSArray *operators;
@property (strong, nonatomic) NSMutableArray *outputQueue;
@property (strong, nonatomic) NSMutableArray *stack;
@property (strong, nonatomic) NSMutableString *numberCache;

@end

@implementation InfixToPostfixConverter

#pragma mark init methods

- (InfixToPostfixConverter *) init {
    self = [super init];
    
    if (self) {
        self.operators = @[@"+", @"-", @"*", @"/"];
    }
    
    return self;
}

- (NSMutableArray *) outputQueue {
    if (!_outputQueue) {
        _outputQueue = [[NSMutableArray alloc] init];
    }
    return _outputQueue;
}

- (NSMutableArray *) stack {
    if (!_stack) {
        _stack = [[NSMutableArray alloc] init];
    }
    return _stack;
}

- (NSMutableString *) numberCache {
    if (!_numberCache) {
        _numberCache = [[NSMutableString alloc] init];
    }
    return _numberCache;
}

#pragma mark private methods

- (NSArray *) convert:(NSString *)infixExpression {
    
    for (int i = 0; i < [infixExpression length]; i++) {
        
        unichar currentChar = [infixExpression characterAtIndex:i];
        
        if ((currentChar >= '0' && currentChar <= '9') || currentChar == '.') {
            [self.numberCache appendString:[NSString stringWithCharacters:&currentChar length:1]];
        } else if ([self.operators containsObject:[NSString stringWithCharacters:&currentChar length:1]]) {
            [self handleOperator:currentChar];
        } else if (currentChar == '(' || currentChar == ')') {
            [self handleBracket:currentChar];
        }
    }
    
    [self finishTransformation];
    
    return [NSArray arrayWithArray:self.outputQueue];
}

- (void) handleOperator:(unichar)currentChar {
    if (self.numberCache.length != 0) {
        [self.outputQueue addObject:[NSString stringWithString:self.numberCache]];
        [self.numberCache setString:@""];
    }
    
    unichar lastObjectInStack = [[self.stack lastObject] characterAtIndex:0];
    
    if ([self.operators containsObject:[NSString stringWithCharacters:&lastObjectInStack length:1]]) {
        if ([self precedenceOf:currentChar] <= [self precedenceOf:lastObjectInStack]) {
            [self.outputQueue addObject:[NSString stringWithString:[self.stack lastObject]]];
            [self.stack removeLastObject];
        }
    }
    
    [self.stack addObject:[NSString stringWithCharacters:&currentChar length:1]];
}

- (void) handleBracket:(unichar)currentChar {
    if (currentChar == '(') {
        [self.stack addObject:[NSString stringWithCharacters:&currentChar length:1]];
    } else {
        if (self.numberCache.length != 0) {
            [self.outputQueue addObject:[NSString stringWithString:self.numberCache]];
            [self.numberCache setString:@""];
        }
        while (![[self.stack lastObject] isEqualToString:@"("]) {
            [self.outputQueue addObject:[NSString stringWithString:[self.stack lastObject]]];
            [self.stack removeLastObject];
        }
        [self.stack removeLastObject];
    }
}

- (void) finishTransformation {
    if (self.numberCache.length != 0) {
        [self.outputQueue addObject:[NSString stringWithString:self.numberCache]];
        [self.numberCache setString:@""];
    }
    
    unsigned long stackCount = self.stack.count;
    for (int i = 0; i < stackCount; i++) {
        NSString *op = [NSString stringWithString:[self.stack lastObject]];
        [self.stack removeLastObject];
        [self.outputQueue addObject:op];
    }
}

- (int)precedenceOf:(unichar)operator {
    if (operator == '+' || operator == '-') {
        return 0;
    } else if (operator == '*' || operator == '/') {
        return 1;
    }
    return 100;
}

@end

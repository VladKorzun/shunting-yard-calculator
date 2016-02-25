//
//  InfixToPostfixConverter.h
//  Shunting-Yard Calculator
//
//  Created by Vladyslav Korzun on 2/24/16.
//  Copyright © 2016 Vladyslav Korzun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfixToPostfixConverter : NSObject

- (NSArray *) convert:(NSString *)infixExpression;

@end

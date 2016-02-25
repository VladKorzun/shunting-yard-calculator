//
//  ViewController.m
//  Shunting-Yard Calculator
//
//  Created by Vladyslav Korzun on 2/16/16.
//  Copyright © 2016 Vladyslav Korzun. All rights reserved.
//

#import "ViewController.h"
#import "InfixToPostfixConverter.h"
#import "PostfixCalculator.h"

@interface ViewController () <UITextViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *userInput;
@property (strong, nonatomic) NSArray *operators;
@end

@implementation ViewController

#pragma mark Instance initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userInput.delegate = self;
    self.operators = @[@"+", @"-", @"/", @"*"];
}

#pragma mark Private methods

- (void)calculateExpression:(NSString *)expression {
    if ([self isValidExpression:expression]) {
        
        dispatch_queue_t shuntingYard = dispatch_queue_create("Shunting-Yard Queue",NULL);
        
        dispatch_async(shuntingYard, ^{
            
            InfixToPostfixConverter *converter = [[InfixToPostfixConverter alloc] init];
            PostfixCalculator *calc = [[PostfixCalculator alloc] init];
            
            NSArray *reverse = [converter convert:expression];
            NSString *result = [calc calculateExpression:reverse];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *resultMessage = [NSString stringWithFormat:@"RPN: %@\n Result: %@",
                                           [[reverse valueForKey:@"description"] componentsJoinedByString:@" "],
                                           result];
                
                UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Shunting-Yard Calculator"
                                                                 message:resultMessage
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
                [result show];
            });
        });
    }
}



- (void)showInvalidInputAlertWith:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid input"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark Validation methods

- (BOOL)isValidExpression:(NSString *)expression {
    int numberOfOpenedBrackets = 0;
    unichar prevChar = 0;
    
    for (int i = 0; i < [expression length]; i++) {
        
        unichar currentChar = [expression characterAtIndex:i];
        if (!(currentChar >= '0' && currentChar <= '9') &&
            currentChar != '.' && currentChar != ')' && currentChar != '(' &&
            ![self.operators containsObject:[NSString stringWithCharacters:&currentChar length:1]]) {
            [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Unsupported symbol: \"%c\"", currentChar]];
            return NO;
        } else if (i == 0) {
            if (currentChar == ')' ||
                currentChar == '.' ||
                [self.operators containsObject:[NSString stringWithCharacters:&currentChar length:1]]) {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Expression cant start with \"%c\"", currentChar]];
                
                return NO;
            }
        } else if (i == [expression length] - 1) {
            if (!(currentChar >= '0' && currentChar <= '9') &&
                currentChar != ')') {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Expression cant end with \"%c\"", currentChar]];
                return NO;
            }
            if (currentChar == ')' && numberOfOpenedBrackets != 1) {
                [self showInvalidInputAlertWith:@"Brackets mismatch"];
                
                return NO;
            }
        } else {
            if (currentChar >= '0' && currentChar <= '9' &&
                prevChar == ')') {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Number cant be after \"%c\"", prevChar]];
                
                return NO;
            }
            if (([self.operators containsObject:[NSString stringWithCharacters:&currentChar length:1]] &&
                !(prevChar >= '0' && prevChar <= '9') &&
                prevChar != ')')) {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Operator cant be after \"%c\"", prevChar]];
                
                return NO;
            }
            if (currentChar == '(' || currentChar == ')') {
                if (currentChar == ')' && numberOfOpenedBrackets == 0) {
                    [self showInvalidInputAlertWith:@"Brackets mismatch"];
                  
                    return NO;
                } else if (currentChar == '(' &&
                           ((currentChar >= '0' && currentChar <= '9') ||
                            currentChar == '.')) {
                               [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Open bracket \"(\" can't be placed after \"%c\"", prevChar]];
                               return NO;
                           }
            }
            if (currentChar == '.' &&
                (!(prevChar >= '0' && prevChar <= '9') ||
                !([expression characterAtIndex:i+1] >= '0' && [expression characterAtIndex:i+1] <= '9'))) {
                [self showInvalidInputAlertWith:@"Dot \".\" can be used as floating point only"];
                return NO;
            }
        }
        
        if (currentChar == '(') {
            numberOfOpenedBrackets++;
        } else if (currentChar == ')') {
            numberOfOpenedBrackets--;
        }
        prevChar = currentChar;
    }
    
    if (numberOfOpenedBrackets != 0) {
        [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Brackets mismatch"]];
        return NO;
    }
    
    return YES;
}


#pragma mark delegated methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self calculateExpression:textView.text];
        return NO;
    }
        
    return YES;
}

@end

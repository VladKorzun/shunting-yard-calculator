//
//  ViewController.m
//  Shunting-Yard Calculator
//
//  Created by Vladyslav Korzun on 2/16/16.
//  Copyright © 2016 Vladyslav Korzun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *userInput;

@end

@implementation ViewController

#pragma mark Instance initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userInput.delegate = self;
}

#pragma mark Private methods

- (void)calculateExpression:(NSString *)expression {
    if ([self isValidExpression:expression]) {
        
        dispatch_queue_t shuntingYard = dispatch_queue_create("Shunting-Yard Queue",NULL);
        
        dispatch_async(shuntingYard, ^{
            
            NSArray *reverse = [self transformToReversePolishNotation:expression];
            
            NSMutableArray *stack = [[NSMutableArray alloc] init];
            
            for (NSString *element in reverse) {
                
                unichar elem = [element characterAtIndex:0];
                if (![[self typeOf:elem] isEqualToString:@"operator"]) {
                    [stack addObject:element];
                } else {
                    float op2 = [[stack lastObject] floatValue];
                    [stack removeLastObject];
                    float op1 = [[stack lastObject] floatValue];
                    [stack removeLastObject];
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
                    
                    [stack addObject:[NSString stringWithFormat:@"%f", result]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *resultMessage = [NSString stringWithFormat:@"RPN: %@\n Result: %@",
                                           [[reverse valueForKey:@"description"] componentsJoinedByString:@" "],
                                           [stack lastObject]];
                
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

- (NSArray *)transformToReversePolishNotation:(NSString *)postfixExpression {
    
    NSMutableArray *outputQueue = [[NSMutableArray alloc] init];
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    NSMutableString *numberCache = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [postfixExpression length]; i++) {
        unichar currentChar = [postfixExpression characterAtIndex:i];
        
        if ([[self typeOf:currentChar] isEqualToString:@"number"] || [[self typeOf:currentChar] isEqualToString:@"dot"]) {
            [numberCache appendString:[NSString stringWithCharacters:&currentChar length:1]];
        } else if ([[self typeOf:currentChar] isEqualToString:@"operator"]) {
            if (numberCache.length != 0) {
                [outputQueue addObject:[NSString stringWithString:numberCache]];
                [numberCache setString:@""];
            }
            
            unichar lastObjectInStack = [[stack lastObject] characterAtIndex:0];
            
            if ([[self typeOf:lastObjectInStack] isEqualToString:@"operator"]) {
                if ([self precedenceOf:currentChar] <= [self precedenceOf:lastObjectInStack]) {
                    [outputQueue addObject:[NSString stringWithString:[stack lastObject]]];
                    [stack removeLastObject];
                }
            }
            
            [stack addObject:[NSString stringWithCharacters:&currentChar length:1]];
        } else if ([[self typeOf:currentChar] isEqualToString:@"bracket"]) {
            if (currentChar == '(') {
                [stack addObject:[NSString stringWithCharacters:&currentChar length:1]];
            } else {
                if (numberCache.length != 0) {
                    [outputQueue addObject:[NSString stringWithString:numberCache]];
                    [numberCache setString:@""];
                }
                while (![[stack lastObject] isEqualToString:@"("]) {
                    [outputQueue addObject:[NSString stringWithString:[stack lastObject]]];
                    [stack removeLastObject];
                }
                [stack removeLastObject];
            }
        }
    }
    
    if (numberCache.length != 0) {
        [outputQueue addObject:[NSString stringWithString:numberCache]];
        [numberCache setString:@""];
    }
    
    unsigned long stackCount = stack.count;
    for (int i = 0; i < stackCount; i++) {
        NSString *op = [NSString stringWithString:[stack lastObject]];
        [stack removeLastObject];
        [outputQueue addObject:op];
    }
    
    return [NSArray arrayWithArray:outputQueue];
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
        if ([[self typeOf:currentChar] isEqualToString:@"unsupported"]) {
            [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Unsupported symbol: \"%c\"", currentChar]];
            return NO;
        } else if (i == 0) {
            if (currentChar == ')' ||
                currentChar == '.' ||
                ([[self typeOf:currentChar] isEqualToString:@"operator"])) {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Expression cant start with \"%c\"", currentChar]];
                
                return NO;
            }
        } else if (i == [expression length] - 1) {
            if (![[self typeOf:currentChar] isEqualToString:@"number"] &&
                currentChar != ')') {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Expression cant end with \"%c\"", currentChar]];
                return NO;
            }
            if (currentChar == ')' && numberOfOpenedBrackets != 1) {
                [self showInvalidInputAlertWith:@"Brackets mismatch"];
                
                return NO;
            }
        } else {
            if ([[self typeOf:currentChar] isEqualToString:@"number"] &&
                prevChar == ')') {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Number cant be after \"%c\"", prevChar]];
                
                return NO;
            }
            if (([[self typeOf:currentChar] isEqualToString:@"operator"] &&
                ![[self typeOf:prevChar] isEqualToString:@"number"] &&
                prevChar != ')') && !(currentChar == '-' && prevChar =='(')) {
                [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Operator cant be after \"%c\"", prevChar]];
                
                return NO;
            }
            if ([[self typeOf:currentChar] isEqualToString:@"bracket"]) {
                if (currentChar == ')' && numberOfOpenedBrackets == 0) {
                    [self showInvalidInputAlertWith:@"Brackets mismatch"];
                  
                    return NO;
                } else if (currentChar == '(' &&
                           ([[self typeOf:prevChar] isEqualToString:@"number"] ||
                            [[self typeOf:prevChar] isEqualToString:@"dot"])) {
                               [self showInvalidInputAlertWith:[NSString stringWithFormat:@"Open bracket \"(\" can't be placed after \"%c\"", prevChar]];
                               return NO;
                           }
            }
            if ([[self typeOf:currentChar] isEqualToString:@"dot"] &&
                (![[self typeOf:prevChar] isEqualToString:@"number"] ||
                ![[self typeOf:[expression characterAtIndex:i+1]] isEqualToString:@"number"])) {
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

- (NSString *)typeOf:(unichar)theChar {
    
    switch (theChar) {
        case '+':
        case '-':
        case '*':
        case '/':
            return @"operator";
            break;
        case '(':
        case ')':
            return @"bracket";
            break;
        case '.':
            return @"dot";
            break;
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case '0':
            return @"number";
            break;
        default:
            return @"unsupported";
            break;
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

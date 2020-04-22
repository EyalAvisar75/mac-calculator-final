//
//  ViewController.m
//  Calculator
//
//  Created by eyal avisar on 07/04/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UIButton *ACButton;
@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) NSMutableArray *operations;
@property BOOL isLastDigit;
@property BOOL isPlusMinus;
@property BOOL isProgression;
@property BOOL isPercentageProgression;
@property NSMutableArray *progressionNumbersArray;
@property NSMutableArray *progressionOperationsArray;
@end
//deal with 7+4X%= -> 7 + 0.16 * 4^1 %% 7+0.000256 * 4^2

@implementation ViewController

- (IBAction)handleDigit:(id)sender {
    if (!self.isLastDigit) {
        self.screenLabel.text = @"0";
    }
    self.isLastDigit = YES;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
    NSString *number = self.screenLabel.text;
    if([pressedText isEqual:@"+/-"]){
        self.isLastDigit = NO;
        double value = [number doubleValue];
        if(value != 0)
            value = value * -1;
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
        self.isPlusMinus = YES;
        return;
    }
    BOOL isDecimal = [number containsString:@"."];

    if(isDecimal && [pressedText isEqual:@"."])
        return;
    if([pressedText isEqual:@"."])
        number = [number stringByAppendingString:pressedText];
    else {
        if(!isDecimal){
            double value = [number doubleValue] * 10 + [pressedText doubleValue];
            number = [NSString stringWithFormat:@"%40.15g", value];
        }
        else
            number = [number stringByAppendingString:pressedText];
    }
    self.screenLabel.text = number;
    [self.ACButton setTitle:@"C" forState:UIControlStateNormal];
}


-(void)cancelProgression:(NSMutableString *)pressedText {


    
}

- (void)prepareForProgression:(NSMutableString *)pressedText {
    
}



- (BOOL)calculateMultiplication:(NSArray *)numbers operation:(NSString *)operation {
    if([operation isEqual:@"X"]){
        self.screenLabel.text = [self multiply:numbers];
        return YES;
    }
    else if([operation isEqual:@"/"]){
        self.screenLabel.text = [self divide:numbers];
        return YES;
    }
    return NO;
}

- (BOOL)calculateAddition:(NSArray *)numbers operation:(NSString *)operation{
    if([operation isEqual:@"+"]){
        self.screenLabel.text = [self add:numbers];
        return YES;
    }
    else if([operation isEqual:@"-"]){
        self.screenLabel.text = [self subtract:numbers];
        return YES;
    }
    return NO;
}

- (void)calculatePercentage {
    [self calculateMultiplication:@[self.screenLabel.text, @"100"] operation:@"/"];
    if (self.progressionOperationsArray.count > 0) {
        [self.progressionNumbersArray removeObjectAtIndex:0];
        [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
    }
    else {
        [self.numbers removeLastObject];
        [self.numbers addObject:self.screenLabel.text];
    }
}

- (IBAction)handleOperations:(id)sender {
    UIButton *pressed = (UIButton *)sender;
    if(self.isLastDigit || self.isPlusMinus){
        [self.numbers addObject:self.screenLabel.text];
        [self.operations addObject:[pressed currentTitle]];
        [self calculate];
        NSLog(@"nums calc %@",self.numbers);
        NSLog(@"nums ops %@",self.operations);
        self.isLastDigit = NO;
        self.isPlusMinus = NO;
        if(!([[pressed currentTitle] isEqual:@"="] ||
             [[pressed currentTitle] isEqual:@"%"]))
            return;
    }
    else if(self.numbers.count == 0){
        self.numbers[0] = @"0";
    }
    static NSString *progressionChanger;
    if([[pressed currentTitle] isEqual:@"="] ||
            [[pressed currentTitle] isEqual:@"%"]){
        
        self.isLastDigit = NO;
        if(self.progressionNumbersArray.count > 0){
            if([self.progressionOperationsArray[0] isEqual:@"="] &&
               [[pressed currentTitle] isEqual:@"%"]){
                [self calculatePercentage];
                return;
            }
            NSString *progressNumber = [NSString stringWithString:[self.progressionNumbersArray lastObject]];
            BOOL isOperationContained = YES;
            for (int i = 0; i < self.operations.count && isOperationContained; i++) {
                if(![self.progressionOperationsArray containsObject:self.operations[i]]){
                    isOperationContained = NO;
                }
            }
            if(isOperationContained && [progressionChanger isEqual:progressNumber]){
                [self calculateProgressionNextTerm];
                self.numbers[self.numbers.count - 1] = self.screenLabel.text;
                return;

            }
            NSLog(@"reg nums while prog %@",self.numbers);//length 1
            NSLog(@"reg ops while prog %@",self.operations);//length 1
            NSLog(@"prog nums %@",self.progressionNumbersArray);
            NSLog(@"prog ops %@",self.progressionOperationsArray);
        }
        //[self.numbers addObject:self.screenLabel.text];
        //[self.operations addObject:[pressed currentTitle]];
        NSLog(@"nums calc %@",self.numbers);
        NSLog(@"nums ops %@",self.operations);
        progressionChanger = [self.numbers lastObject];
        [self calculateProgressionA1:[pressed currentTitle]];
    }
    else {
        [self.operations removeLastObject];
        [self.operations addObject:[pressed currentTitle]];
        NSLog(@"ops %@",self.operations);
        NSLog(@"nums %@",self.numbers);
    }
}

- (void)calculated1Numbers {
    NSLog(@"calculated1Numbers");
    [self.numbers removeAllObjects];
    [self.operations removeObjectAtIndex:0];
    [self.numbers addObject:self.screenLabel.text];
}

- (void)calculateTerm1Unary {
    if(self.operations.count == 1){
        if(![self calculateMultiplication:@[self.numbers[0],self.numbers[0]] operation:self.operations[0]]){
            [self calculateAddition:@[self.numbers[0],self.numbers[0]] operation:self.operations[0]];
        }
    }
}

-(void)calculateProgressionA1:(NSString *)pressed{
    NSString *operation = [NSString stringWithString:[self.operations lastObject]];
    NSString *number;
    if([pressed isEqual:@"%"] && self.progressionNumbersArray.count == 0){
        [self calculatePercentageA1];
        return;
    }
    else if([pressed isEqual:@"%"]){
        [self calculatePercentageNextTerm];
        return;
    }
    //if last progression exists
    [self.progressionNumbersArray removeAllObjects];
    [self.progressionOperationsArray removeAllObjects];
    [self.progressionOperationsArray addObject: pressed];
    [self.operations removeObject:@"="];
    if (self.operations.count == 0) {
        [self.progressionOperationsArray removeAllObjects];
        return;
    }
    NSLog(@"ops %@ pops %@", self.operations, self.progressionOperationsArray);
    if(self.numbers.count == self.operations.count){
        operation = [NSString stringWithString:[self.operations lastObject]];
        number = [NSString stringWithString:[self.numbers lastObject]];
        [self.progressionOperationsArray addObject:operation];
        [self.progressionNumbersArray addObject:number];
        [self calculateTerm1Unary];
        if(self.operations.count == 2){
            [self calculateMultiplication:@[self.numbers[0],self.numbers[1]] operation:self.operations[1]];
            [self calculateAddition:@[self.screenLabel.text, self.numbers[1]] operation:self.operations[0]];
        }
        [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
        return;
    }
    if(self.progressionNumbersArray.count == 0){
        [self.progressionOperationsArray addObject:[self.operations lastObject]];
        [self.progressionNumbersArray addObject:[self.numbers lastObject]];
        for (int i = 0; i < self.operations.count; i++) {
            if([self calculateMultiplication:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]]){
                [self.operations removeObjectAtIndex:i];
                [self.numbers removeObjectAtIndex:i];
                self.numbers[i] = self.screenLabel.text;
                i--;
            }
        }
        
        for (int i = 0; i < self.operations.count; i++) {
            [self calculateAddition:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]];
            [self.operations removeObjectAtIndex:i];
            [self.numbers removeObjectAtIndex:i];
            self.numbers[i] = self.screenLabel.text;
            i--;
        }
    }
    [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
}
-(void)calculatePercentageA1{
    NSString *operation = [NSString stringWithString:[self.operations lastObject]];
    NSString *number = [NSString stringWithString:self.numbers[0]];//maybe

    //if last progression exists
    [self.progressionNumbersArray removeAllObjects];
    [self.progressionOperationsArray removeAllObjects];
    [self.operations removeObject:@"%"];
    [self.progressionOperationsArray addObject:@"%"];
    [self.progressionOperationsArray addObject:operation];
    if (self.operations.count == 1) {
        [self calculateMultiplication:@[self.numbers[0],self.numbers[0]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
        [self.progressionNumbersArray addObject:number];
        [self.progressionNumbersArray addObject:self.screenLabel.text];
    }
    if (self.operations.count > 1) {
        [self calculateMultiplication:@[self.numbers[0],self.numbers[1]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
        [self.progressionNumbersArray addObject:number];
        [self.progressionNumbersArray addObject:self.screenLabel.text];
    }
}
-(void)calculatePercentageNextTerm{
    NSString *progNum2 = [[NSString alloc] initWithString:self.progressionNumbersArray[1]];
    self.progressionNumbersArray[0] = progNum2;
    [self calculateMultiplication:@[self.progressionNumbersArray[0],self.progressionNumbersArray[0]] operation:@"X"];
    [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
    self.progressionNumbersArray[1] = self.screenLabel.text;
    
//    [self calculateMultiplication:@[self.progressionNumbersArray[1],self.progressionNumbersArray[1]] operation:@"X"];
//    [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];

    self.progressionNumbersArray[1] = self.screenLabel.text;
    if(self.operations.count == 2){
        [self calculateMultiplication:@[self.progressionNumbersArray[0],self.progressionNumbersArray[1]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];

        self.progressionNumbersArray[1] = self.screenLabel.text;
    }
}
-(void)calculateProgressionNextTerm{
    NSLog(@"prog ops %@", self.progressionOperationsArray);
    if(![self calculateMultiplication:self.progressionNumbersArray operation:self.progressionOperationsArray[1]]){
        [self calculateAddition:self.progressionNumbersArray operation:self.progressionOperationsArray[1]];
    }
    [self.progressionNumbersArray removeObjectAtIndex:0];
    [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
}
-(void)calculate {
    if([[self.operations lastObject] isEqual:@"="]){
        return;
    }
    if(self.progressionNumbersArray.count == 0){
        if([[self.operations lastObject] isEqual:@"%"]){
            [self calculatePercentage];
            return;
        }
    }
    if(self.operations.count == 2){//definition is based on operations count for consistency
        if(self.numbers.count == 2 && [self calculateMultiplication:self.numbers operation:self.operations[0]]){
            [self calculated1Numbers];
        }
    }
    if(self.operations.count == 2){
        if([self.operations[1] isEqual:@"+"] ||
           [self.operations[1] isEqual:@"-"]){
            [self calculateAddition:@[self.numbers[0],self.numbers[1]] operation:self.operations[0]];
            [self calculated1Numbers];
        }
    }
    if(self.operations.count == 3 &&
       ([self.operations[2] isEqual:@"+"] ||
       [self.operations[2] isEqual:@"-"])){
        [self calculateMultiplication:@[self.numbers[1],self.numbers[2]] operation:self.operations[1]];
        [self calculateAddition:@[self.numbers[0], self.screenLabel.text] operation:self.operations[0]];
        NSString *operation = [self.operations lastObject];
        [self.operations removeAllObjects];
        [self.numbers removeAllObjects];
        [self.operations addObject:operation];
        [self.numbers addObject:self.screenLabel.text];
    }
    if(self.operations.count == 3 &&
       ([self.operations[2] isEqual:@"X"] ||
       [self.operations[2] isEqual:@"/"])){
        [self calculateMultiplication:@[self.numbers[1],self.numbers[2]] operation:self.operations[1]];
        [self.operations removeObjectAtIndex:1];
        [self.numbers removeLastObject];
        [self.numbers removeLastObject];
        [self.numbers addObject:self.screenLabel.text];
    }
}
- (void)resetFields {
    self.numbers = [NSMutableArray new];
    self.operations =[NSMutableArray new];
    self.progressionNumbersArray = [NSMutableArray new];
    self.progressionOperationsArray = [NSMutableArray new];
    self.isLastDigit = NO;
    self.isPlusMinus = NO;
    self.isProgression = NO;
    self.isPercentageProgression = NO;
}




- (IBAction)handleAC:(id)sender {
    UIButton *pressed = (UIButton *) sender;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
//    [self resetProgressionMode:pressed pressedText:pressedText];
    if([pressedText isEqualToString:@"AC"]){
        [self resetFields];
        self.screenLabel.text = @"0";
    }
    else {
        [pressed setTitle:@"AC" forState:UIControlStateNormal];
        if(self.isLastDigit){
            self.screenLabel.text = @"0";
        }
        else {
            [self.operations removeLastObject];
        }
    }
}

- (void)viewDidLoad {
    [self resetFields];
}

-(NSString *)add:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] + [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)subtract:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] - [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)multiply:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] * [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)divide:(NSArray *)numbers {
    if ([numbers[1] doubleValue] == 0) {
        return @"Not a number";
    }
    double result = [numbers[0] doubleValue] / [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}

@end
/*-(void)calculateProgression {
    NSString *quotient;
    NSString *termN;
    if (self.progressionArray.count == 2) {
        quotient = self.progressionArray[0];
        termN = self.screenLabel.text;
    }
    else if (self.progressionArray.count == 3) {
        quotient = self.progressionArray[2];
        termN = self.progressionArray[0];
    }
    else if (self.progressionArray.count > 3) {//
        if(self.isProgression){
            quotient = self.progressionArray[2];
            termN = self.progressionArray[0];
            if ([self.progressionArray[3] isEqual:@"X"]) {
                termN = [self multiply:@[termN, quotient]];
            }
            else {
                termN = [self divide:@[termN, quotient]];
            }
        }
        else {
            quotient = self.progressionArray[2];
            termN = quotient;
            if (self.progressionArray.count == 4) {
            }
            else if (self.progressionArray.count == 5){
                double value = [self.progressionArray[4] doubleValue];
                value *= value;
                value /= 100;
                self.progressionArray[4] = [NSString stringWithFormat:@"%40.15g", value];
                NSLog(@"pv4 %f",value);
            }
        }
    }
    if(self.isProgression){
        if ([self.progressionArray[1] isEqual:@"+"]) {
            self.screenLabel.text = [self add:@[termN, quotient]];
        }
        else if ([self.progressionArray[1] isEqual:@"-"]) {
            self.screenLabel.text = [self subtract:@[termN, quotient]];
        }
        else if ([self.progressionArray[1] isEqual:@"X"]) {
            self.screenLabel.text = [self multiply:@[termN, quotient]];
        }
        else {
            self.screenLabel.text = [self divide:@[termN, quotient]];
        }
    }
    else {
        self.screenLabel.text = [self multiply:@[termN, quotient]];
        double value = [self.screenLabel.text doubleValue] / 100.0;
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g", value];
    }
    if(self.progressionArray.count > 2){
        if(self.isProgression)
            self.progressionArray[0] = self.screenLabel.text;
        else
            self.progressionArray[2] = self.screenLabel.text;
    }
    if (self.progressionArray.count > 3 && self.isProgression) {
        self.progressionArray[1] = [[NSString alloc] initWithString:self.progressionArray.lastObject];
        [self.progressionArray removeLastObject];
    }
}*/
